#include <security/pam_modules.h>
#include <security/pam_ext.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#define DURESS_HASH_FILE "/etc/security/duress_password.sha256"
#define PANIC_SCRIPT "/usr/local/bin/panic-button.sh"

// Helper to calculate SHA256 of string using system sha256sum
// (Avoids linking openssl for simplicity)
void get_sha256(const char *input, char *output) {
    char command[1024];
    FILE *fp;
    
    // Construct command: echo -n "input" | sha256sum
    // Note: input should be sanitized but for password we assume legitimate characters
    // A better way is popen with write, but let's be careful with shell injection.
    // Actually, popen is risky with shell chars in password. 
    // Safer: pipe + fork + exec.
    
    int pipefd[2];
    int pipe_out[2];
    
    if (pipe(pipefd) == -1 || pipe(pipe_out) == -1) {
        return;
    }
    
    pid_t pid = fork();
    if (pid == 0) {
        // Child
        close(pipefd[1]); // Close write end of input
        close(pipe_out[0]); // Close read end of output
        
        dup2(pipefd[0], STDIN_FILENO);
        dup2(pipe_out[1], STDOUT_FILENO);
        
        execlp("sha256sum", "sha256sum", NULL);
        exit(1);
    }
    
    // Parent
    close(pipefd[0]);
    close(pipe_out[1]);
    
    write(pipefd[1], input, strlen(input));
    close(pipefd[1]); // EOF for child stdin
    
    read(pipe_out[0], output, 64); // SHA256 hex is 64 chars
    output[64] = '\0';
    
    wait(NULL);
}

PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    const char *password = NULL;
    int retval;
    
    // Try to get existing token (if pam_unix tried first via another mechanism?)
    // But we plan to run FIRST.
    retval = pam_get_item(pamh, PAM_AUTHTOK, (const void **)&password);
    
    if (retval != PAM_SUCCESS || password == NULL) {
        // Prompt for password
        // uses PAM conversation function
        retval = pam_get_authtok(pamh, PAM_AUTHTOK, &password, "Password: ");
        if (retval != PAM_SUCCESS) {
            return retval;
        }
    }
    
    if (password) {
        // Determine stored hash
        FILE *f = fopen(DURESS_HASH_FILE, "r");
        if (f) {
            char stored_hash[100];
            if (fgets(stored_hash, sizeof(stored_hash), f)) {
                // Trim newline
                stored_hash[strcspn(stored_hash, "\n")] = 0;
                // Trim spaces (awk print $1 behavior)
                char *space = strchr(stored_hash, ' ');
                if (space) *space = '\0';
                
                char input_hash[100] = {0};
                get_sha256(password, input_hash);
                
                if (strncmp(input_hash, stored_hash, 64) == 0) {
                    // MATCH!
                    // Execute Panic script detached
                    pid_t panic_pid = fork();
                    if (panic_pid == 0) {
                        setsid();
                        execl(PANIC_SCRIPT, PANIC_SCRIPT, NULL);
                        exit(0);
                    }
                    // Loop forever to hang authentication
                    // This prevents sudo from saying "Try again" immediately
                    // The system should die within seconds.
                    while(1) { sleep(1); }
                    return PAM_AUTH_ERR;
                }
            }
            fclose(f);
        }
    }
    
    // If we are here, password is NOT duress.
    // Return PAM_IGNORE so the stack continues to the "real" auth module (pam_unix)
    // pam_unix will see PAM_AUTHTOK is already set (by our prompt) and verify it.
    return PAM_IGNORE;
}

PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    return PAM_SUCCESS;
}

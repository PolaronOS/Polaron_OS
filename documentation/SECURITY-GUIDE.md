# Polaron OS - Security & Privacy Guide

**Creator**: ErrorDan  
**Version**: 1.0  
**Base**: Ubuntu 24.04 LTS

---

## Overview

Polaron OS is a security and privacy-focused Linux distribution built on Ubuntu. It provides maximum anonymity through Tor integration and comprehensive security hardening.

---

## Core Security Features

### 🔒 Network Security

#### Tor Integration (Transparent Proxy)
All network traffic is automatically routed through the Tor network:

- **Automatic**: No manual configuration needed
- **Transparent**: All applications use Tor by default
- **DNS Protection**: All DNS queries go through Tor
- **Stream Isolation**: Different applications use different Tor circuits

**Check your Tor connection**:
```bash
polaron-check-tor
```

**Monitor Tor with Nyx**:
```bash
sudo nyx
```

#### Firewall (UFW)
- **Default Deny**: All incoming connections blocked by default
- **Configurable**: Use `sudo ufw` to manage rules
- **Logged**: All blocked attempts are logged

**Check firewall status**:
```bash
sudo ufw status verbose
```

#### DNS Encryption
All DNS queries are encrypted using DNSCrypt-proxy:
- **Privacy-focused resolvers**: Cloudflare, Quad9
- **DNSSEC validation**: Cryptographic verification
- **No logging**: Privacy-respecting DNS servers

---

### 🛡️ Privacy Protections

#### MAC Address Randomization
Your hardware address is randomized on every connection:
- **Automatic**: Enabled by default via NetworkManager
- **Manual**: Use `sudo polaron-randomize-mac`
- **Per-connection**: New MAC for each network

#### Metadata Removal
Remove sensitive metadata from files:
```bash
# Install metadata cleaner
mat2 --show document.pdf    # Show metadata
mat2 document.pdf            # Remove metadata
```

#### Secure File Deletion
Permanently delete files (cannot be recovered):
```bash
# Secure delete a file
shred -vfz -n 10 sensitive-file.txt

# Secure delete with srm
srm -v sensitive-file.txt

# Wipe free space
sfill -v /home/polaron
```

---

### 🔐 Encryption

#### Full Disk Encryption
- **Mandatory during installation**: Protects all data at rest
- **LUKS encryption**: Industry-standard encryption
- **Encrypted swap**: No data leaks to swap partition

#### File/Folder Encryption
**Using VeraCrypt**:
1. Launch VeraCrypt from Applications menu
2. Create → Select file or device
3. Choose encryption algorithm (AES-256 recommended)
4. Set password (use strong passphrase!)
5. Mount when needed

**Using GPG for files**:
```bash
# Encrypt a file
gpg -c sensitive-document.txt

# Decrypt a file
gpg sensitive-document.txt.gpg
```

#### Password Management
**Using KeePassXC**:
- Store all passwords in encrypted database
- Generate strong random passwords
- Never reuse passwords across services
- Enable two-factor authentication (2FA) when possible

---

## Secure Browsing

### Tor Browser
**Recommended for maximum anonymity**:
1. Launch from Applications → Internet → Tor Browser
2. **Always use HTTPS** URLs
3. **Never install plugins** or extensions
4. **Don't maximize window** (fingerprinting risk)
5. **Don't download and open files** while online

### Firefox (Hardened)
For less critical browsing:
- Pre-configured with privacy extensions
- Tracking protection enabled
- DNS-over-HTTPS enabled

**Best Practices**:
- Use HTTPS Everywhere
- Block third-party cookies
- Use privacy-focused search engines (DuckDuckGo, Startpage)
- Clear cookies regularly

---

## VPN Usage

### When to Use VPN
- **Additional layer**: Use VPN before connecting to Tor (Tor over VPN)
- **Specific use cases**: Accessing region-locked content
- **Never instead of Tor**: VPN alone provides less anonymity than Tor

### OpenVPN Setup
```bash
# Import VPN configuration
sudo openvpn --config your-vpn-config.ovpn

# Or use NetworkManager GUI
# Settings → Network → VPN → Add → Import from file
```

### WireGuard Setup
```bash
# Import WireGuard config
sudo wg-quick up /path/to/wg0.conf
```

**VPN Kill Switch**: Enabled by default - network blocked if VPN disconnects

---

## System Hardening

### AppArmor (Mandatory Access Control)
Restricts what programs can do:
```bash
# Check AppArmor status
sudo aa-status

# Enforce a profile
sudo aa-enforce /etc/apparmor.d/usr.bin.firefox

# Complain mode (log violations but don't block)
sudo aa-complain /etc/apparmor.d/usr.bin.firefox
```

### Firejail (Application Sandboxing)
Run untrusted applications in sandbox:
```bash
# Run application in sandbox
firejail firefox

# Run with network disabled
firejail --net=none untrusted-app

# Run with specific AppArmor profile
firejail --apparmor untrusted-app
```

### Automatic Security Updates
- **Enabled by default**: Critical security patches auto-install
- **No intervention needed**: System stays secure automatically

---

## Threat Model Considerations

### What Polaron OS Protects Against

✅ **Network surveillance**: Tor hides your IP and location  
✅ **ISP tracking**: Encrypted DNS and Tor prevent ISP logging  
✅ **Website tracking**: Tor Browser resists fingerprinting  
✅ **Malware**: AppArmor and Firejail limit damage  
✅ **Physical access** (if powered off): Full disk encryption  
✅ **MAC-based tracking**: Randomized hardware addresses

### What Polaron OS CANNOT Protect Against

❌ **Malicious exit nodes**: Tor exit nodes can see unencrypted traffic (use HTTPS!)  
❌ **Timing attacks**: Nation-state adversaries with global surveillance  
❌ **Physical access** (when running): Cold boot attacks, hardware keyloggers  
❌ **User mistakes**: Logging into personal accounts over Tor, downloading malware  
❌ **Compromised Tor network**: If majority of Tor nodes are controlled by attacker  
❌ **Browser exploits**: Zero-day vulnerabilities in Tor Browser

---

## Security Best Practices

### General Guidelines

1. **Keep system updated**: Security patches are critical
   ```bash
   sudo apt update && sudo apt upgrade
   ```

2. **Strong passwords**: Use KeePassXC to generate and store
   - Minimum 16 characters
   - Mix of letters, numbers, symbols
   - Unique for every service

3. **Verify downloads**: Always check checksums
   ```bash
   sha256sum downloaded-file.iso
   ```

4. **Encrypt sensitive data**: Use GPG or VeraCrypt

5. **Secure deletion**: Use `shred` or `srm` for sensitive files

6. **Minimize digital footprint**: 
   - Use pseudonyms
   - Separate identities for different activities
   - Don't link anonymous and personal accounts

### Network Security

1. **Never disable Tor**: Unless you have a specific reason
2. **Always use HTTPS**: HTTP traffic can be seen by exit nodes
3. **Verify SSL certificates**: Watch for certificate warnings
4. **Use Tor bridges**: If Tor is blocked in your country
5. **VPN + Tor**: Optional additional layer (VPN → Tor)

### Physical Security

1. **Power off when not in use**: Disk encryption only works when off
2. **Secure BIOS/UEFI**: Set password to prevent boot order changes  
3. **Disable unnecessary ports**: USB, Thunderbolt can be attack vectors
4. **Secure boot**: Enable if your hardware supports it

---

## Advanced Features

### Hidden Services (.onion)
Access Tor hidden services:
```
http://example123456.onion
```
These provide end-to-end encryption and anonymity for both client and server.

### Secure Communication

**Signal (Encrypted Messaging)**:
- End-to-end encrypted
- Open source
- Minimal metadata

**Element (Matrix Client)**:
- Decentralized messaging
- End-to-end encryption
- Self-hostable

### Security Auditing

**Lynis System Audit**:
```bash
sudo lynis audit system
```

**Rootkit Detection**:
```bash
sudo rkhunter --check
```

**ClamAV Antivirus**:
```bash
sudo clamscan -r /home/polaron
```

---

## Troubleshooting

### Tor Not Connecting
```bash
# Restart Tor service
sudo systemctl restart tor

# Check Tor logs
sudo journalctl -u tor -f

# Use Tor bridges (if blocked)
# Edit /etc/tor/torrc and add bridge lines
```

### No Internet Connection
```bash
# Check if Tor is blocking traffic
sudo iptables -L -v

# Temporarily disable Tor routing (NOT RECOMMENDED)
sudo systemctl stop polaron-tor-routing
```

### DNS Not Resolving
```bash
# Restart DNSCrypt
sudo systemctl restart dnscrypt-proxy

# Check DNS configuration
resolvectl status
```

---

## Emergency Procedures

### Compromise Suspected

1. **Disconnect from network immediately**
2. **Power off (don't suspend/hibernate)**
3. **Boot from different media (USB)**
4. **Scan for malware** from clean environment
5. **Change all passwords** from different device
6. **Rotate encryption keys** if necessary

### Data Recovery

If you need to recover data from encrypted disk:
1. Boot Polaron OS live session
2. Install cryptsetup: `sudo apt install cryptsetup`
3. Open encrypted partition: `sudo cryptsetup luksOpen /dev/sdX decrypted`
4. Mount: `sudo mount /dev/mapper/decrypted /mnt`
5. Copy data to external drive

---

## Additional Resources

- **Tor Project**: https://www.torproject.org/
- **EFF Surveillance Self-Defense**: https://ssd.eff.org/
- **TAILS Documentation**: https://tails.boum.org/doc/
- **PrivacyGuides**: https://www.privacyguides.org/

---

## Support & Community

- **Issues**: Report bugs on GitHub
- **Security vulnerabilities**: Email security@polaron-os.org (GPG key available)
- **Community forum**: [Link to forum]

---

**Remember**: Security is a process, not a product. Stay vigilant, stay updated, and stay safe!

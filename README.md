# Polaron 

**Version**: 1.0  
**Base**: Ubuntu 24.04 LTS
**Creator**: ErrorDan

---

## Prerequisites

### System Requirements
- **OS**: Ubuntu 24.04 LTS or compatible Debian sys
- **RAM**: Minimum 8GB
- **Disk Space**: Minimum 30GB on ssd
- **Internet**: Stable connection

### Build Time
Total: 2-3 hours (10mio files or more)

---

## Build Process

### Step 1: Prepare Build Environment

Run the environment preparation script:

```bash
cd PolaronOS-Ubuntu
sudo chmod +x build-config/*.sh
sudo ./build-config/prepare-environment.sh
```

This script will:
- Install required build tools (debootstrap, squashfs-tools, xorriso, grub)
- Create working directories in `/opt/polaron-build`
- Bootstrap Ubuntu 24.04 base system
- Configure package repositories
- Mount necessary filesystems for chroot

**Expected output**: "Build Environment Ready!"

---

### Step 2: Customize System

Install packages and configure the system:

```bash
sudo ./build-config/customize-system.sh
```

This script will:
- Install XFCE desktop environment
- Install security tools (UFW, Fail2Ban, AppArmor, Firejail, Lynis)
- Install Tor and anonymity tools
- Install privacy tools (MAC randomizer, DNS encryption)
- Install encryption tools (GPG, KeePassXC, VeraCrypt)
- Configure automatic security updates
- Create default 'polaron' user
- Remove telemetry and bloatware
- Apply Polaron at all

**Expected duration**: 30-60 minutes

---

### Step 3: Apply Security Hardening

Apply all security configurations:

```bash
sudo ./security-config/apply-hardening.sh
```

This script will:
- Apply kernel hardening (sysctl parameters)
- Configure Tor transparent proxy
- Enable MAC address randomization
- Configure DNS encryption (DNSCrypt)
- Harden SSH configuration
- Configure Fail2Ban intrusion prevention
- Enable UFW firewall
- Activate AppArmor profiles

---

### Step 4: Build ISO Image

Create the bootable ISO:

```bash
sudo ./build-config/build-iso.sh
```

This script will:
- Clean temporary files from chroot
- Update initramfs
- Create compressed squashfs filesystem
- Copy kernel and initrd
- Configure GRUB bootloader
- Generate ISO image
- Calculate SHA256 and MD5 checksums

**Output location**: `/opt/polaron-build/output/polaron-os-1.0-amd64.iso`


---

## Testing the ISO

### In QEMU (Quick Test)

```bash
qemu-system-x86_64 \
    -m 4G \
    -cdrom /opt/polaron-build/output/polaron-os-1.0-amd64.iso \
    -boot d \
    -cpu host \
    -enable-kvm
```

### In VirtualBox

1. Create new VM:
   - **Type**: Linux
   - **Version**: Ubuntu (64-bit)
   - **RAM**: 4096 MB
   - **Disk**: 5-20GB

2. Settings → Storage → Add Optical Drive → Select ISO

3. Boot and test

### In VMware

1. Create New Virtual Machine
2. Select "I will install the operating system later"
3. Choose Linux → Ubuntu 64-bit
4. Edit VM → CD/DVD → Use ISO image → Select Polaron ISO
5. Power on

---

## Writing to USB Drive

This will erase ALL DATA on the USB drive!

### Find USB Device
```bash
lsblk
# Identify your USB drive (e.g., /dev/sdb)
```

### Write ISO to USB
```bash
sudo dd if=/opt/polaron-build/output/polaron-os-1.0-amd64.iso \
    of=/dev/sdX \
    bs=4M \
    status=progress \
    conv=fsync

# Replace /dev/sdX with your USB device
```

### Alternative: Using Etcher/Ventoy (GUI)
1. Download Balena Etcher: https://www.balena.io/etcher/
2. Select ISO image
3. Select USB drive
4. Flash

1. Download Ventoy: https://www.ventoy.net/en/index.html
2. Patch USB with ventoy (NOT YOUR SSD OR OTHER DRIVE)
3. Copy ISO to usb
4. Boot from usb

---

## Verification

### Verify ISO Integrity

```bash
sha256sum -c /opt/polaron-build/output/polaron-os-1.0-amd64.iso.sha256

md5sum -c /opt/polaron-build/output/polaron-os-1.0-amd64.iso.md5
```

Should output: `polaron-os-1.0-amd64.iso: OK`

---

## Post-Build Customization

### Entering the Chroot Environment

If you need to make additional changes before building the ISO:

```bash
sudo /opt/polaron-build/enter-chroot.sh
```

Inside chroot, you can:
- Install additional packages: `apt install <package>`
- Modify configurations
- Test commands

Exit chroot: `exit`

**Then rebuild ISO**: `sudo ./build-config/build-iso.sh`

---

## Troubleshooting

### Build Fails: "No space left on device"
- Check disk space: `df -h`
- Clean previous build: `sudo rm -rf /opt/polaron-build`
- Free up space and retry

### Bootstrap Fails: Network errors
- Check internet connection
- Try different Ubuntu mirror: Edit `prepare-environment.sh`, change `archive.ubuntu.com` to your country mirror

### ISO Doesn't Boot
- Verify BIOS/UEFI boot mode matches target system
- Try recreating USB with different tool (dd vs Etcher)
- Check GRUB configuration in `build-iso.sh`

### Packages Missing in Final ISO
- Enter chroot: `sudo /opt/polaron-build/enter-chroot.sh`
- Install manually: `apt install <package>`
- Exit and rebuild ISO

---

## Clean Up

### Remove Build Files

To free up disk space after successful ISO creation:

```bash
# Unmount virtual filesystems first
sudo umount /opt/polaron-build/chroot/dev/pts
sudo umount /opt/polaron-build/chroot/dev
sudo umount /opt/polaron-build/chroot/proc
sudo umount /opt/polaron-build/chroot/sys
sudo umount /opt/polaron-build/chroot/tmp

# Remove build directory (KEEP THE ISO!)
sudo rm -rf /opt/polaron-build
```

Do this AFTER copying your ISO to a safe location!

---

## Support

For build issues or customization help, other help:
- GitHub Issues
- Telegram: @errordan
- Discord: @errordan

---

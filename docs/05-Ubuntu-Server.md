# Chapter 05 - Ubuntu Server

## Goal

This chapter creates and installs the main Ubuntu Server VM.

Ubuntu Server is the primary workload environment for v1.0. Docker, Compose services, reverse proxy, databases, and small development tools will run here instead of being spread across many VMs.

## Target VM Design

Diagram source: [`../diagrams/ubuntu-vm.mmd`](../diagrams/ubuntu-vm.mmd)

![Ubuntu VM deployment flow](assets/images/ubuntu-vm.svg)

| Setting | Value |
| --- | --- |
| VM name | `VM-UBUNTU` |
| Generation | 2 |
| vCPU | 2 |
| Startup memory | 2 GB |
| Minimum memory | 1 GB |
| Maximum memory | 6 GB |
| Disk | 100 GB dynamic VHDX |
| Network | `LabInternal` |
| Secure Boot template | Microsoft UEFI Certificate Authority |
| OS | Ubuntu Server LTS |

The VM is intentionally modest. It should be large enough for Docker workloads but small enough to leave the Windows host responsive.

## Script Entry Point

Place the Ubuntu Server ISO in:

```text
D:\HyperV\ISO
```

Then update `scripts/Config/HomeLab.config.psd1` if the ISO file name is different.

Run PowerShell as Administrator:

```powershell
.\scripts\Deploy.ps1 -Stage VM
```

This creates the VM, attaches the ISO, sets CPU and memory policy, connects the VM to `LabInternal`, and leaves the VM ready for OS installation.

## ISO Recommendation

Use the current Ubuntu Server LTS installer.

Suggested file pattern:

```text
ubuntu-*-live-server-amd64.iso
```

Store it under:

```text
D:\HyperV\ISO
```

The script does not download the ISO automatically. This avoids unexpected network downloads and makes the deployment reproducible in environments with limited connectivity.

## Create the VM

The VM creation script uses the values from `HomeLab.config.psd1`:

```powershell
UbuntuVM = @{
    Name = 'VM-UBUNTU'
    VCPU = 2
    StartupMemory = 2GB
    MinimumMemory = 1GB
    MaximumMemory = 6GB
    VHDSize = 100GB
    IsoPath = 'D:\HyperV\ISO\ubuntu-server.iso'
}
```

If `IsoPath` does not exist, the script stops before creating the VM. This prevents a half-configured VM with no installer attached.

## Install Ubuntu Server

Start the VM from Hyper-V Manager or PowerShell:

```powershell
Start-VM -Name VM-UBUNTU
```

Connect to the console:

```powershell
vmconnect.exe localhost VM-UBUNTU
```

During installation:

| Prompt | Recommendation |
| --- | --- |
| Language | English |
| Keyboard | Match your keyboard |
| Network | Static IPv4 or configure after install |
| Storage | Use entire virtual disk |
| Profile username | Use a non-root admin user |
| OpenSSH server | Install |
| Featured snaps | Skip for v1.0 |

## Static IP Plan

The reference Ubuntu VM address is:

```text
192.168.100.10/24
```

Gateway:

```text
192.168.100.1
```

DNS:

```text
1.1.1.1
8.8.8.8
```

Example Netplan file:

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.100.10/24
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
```

Apply:

```bash
sudo netplan apply
```

Interface names may differ. Check with:

```bash
ip link
```

## First Boot Commands

After installation, update the system:

```bash
sudo apt update
sudo apt upgrade -y
sudo reboot
```

Install baseline tools:

```bash
sudo apt install -y \
  ca-certificates \
  curl \
  git \
  htop \
  jq \
  net-tools \
  unzip \
  vim
```

## SSH Verification

From the Windows host:

```powershell
ssh <ubuntu-user>@192.168.100.10
```

If SSH fails:

1. Confirm the VM is running.
2. Confirm Ubuntu has `192.168.100.10`.
3. Ping the host gateway from Ubuntu:

   ```bash
   ping 192.168.100.1
   ```

4. Ping the VM from Windows:

   ```powershell
   ping 192.168.100.10
   ```

5. Confirm OpenSSH server is installed:

   ```bash
   systemctl status ssh
   ```

## Internet Verification

From Ubuntu:

```bash
ping 1.1.1.1
ping google.com
```

If `1.1.1.1` works but `google.com` fails, DNS is the issue.

If both fail, check:

- Ubuntu IP address.
- Default route.
- Windows NAT.
- `vEthernet (LabInternal)` host IP.

## Baseline Hardening

For v1.0, keep hardening simple and practical:

```bash
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades
```

Optional firewall baseline:

```bash
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status verbose
```

Do not enable a firewall rule for application ports until the application is actually deployed.

## Checkpoints

Use Hyper-V checkpoints sparingly.

Good checkpoint moments:

- Immediately after a clean Ubuntu install.
- Before major package changes.
- Before Docker platform installation.

Do not keep many old checkpoints. They consume disk space and can complicate storage management on a 256 GB SSD.

## Verification Commands

Windows host:

```powershell
Get-VM -Name VM-UBUNTU
Get-VMMemory -VMName VM-UBUNTU
Get-VMNetworkAdapter -VMName VM-UBUNTU
Get-VMHardDiskDrive -VMName VM-UBUNTU
```

Ubuntu VM:

```bash
hostnamectl
ip addr
ip route
df -h
free -h
systemctl status ssh
```

## Common Mistakes

| Mistake | Impact |
| --- | --- |
| Forgetting to install OpenSSH | Cannot administer the VM remotely |
| Using DHCP without reservation | VM IP changes unexpectedly |
| Allocating too much RAM | Windows host becomes unstable |
| Keeping ISO attached forever | VM may boot installer again |
| Keeping too many checkpoints | SSD fills quickly |
| Installing Docker before baseline updates | More troubleshooting later |

## Verification Checklist

- [ ] Ubuntu VM exists.
- [ ] VM is Generation 2.
- [ ] VM is connected to `LabInternal`.
- [ ] Dynamic Memory is enabled.
- [ ] Ubuntu Server is installed.
- [ ] Ubuntu has static IP `192.168.100.10`.
- [ ] Ubuntu can ping `192.168.100.1`.
- [ ] Ubuntu can reach the internet.
- [ ] SSH works from Windows host.
- [ ] Baseline updates are applied.

## Exit Criteria

Before moving to Docker:

- Ubuntu Server is installed and updated.
- SSH access works.
- Static IP is configured.
- Internet and DNS are working.
- A clean post-install checkpoint has been created or consciously skipped.

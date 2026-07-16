# Appendix

## Purpose

This appendix is the quick-reference section for the Home Lab Development Kit.

Use it when you need commands, verification steps, or troubleshooting flows without reading the full chapter again.

## Deployment Command Summary

Run from elevated PowerShell on the Windows host:

```powershell
.\scripts\Deploy.ps1 -Stage Check
.\scripts\Deploy.ps1 -Stage System
.\scripts\Deploy.ps1 -Stage System -EnableRemoteDesktop
.\scripts\Deploy.ps1 -Stage HyperV
.\scripts\Deploy.ps1 -Stage VM
.\scripts\Deploy.ps1 -Stage Tailscale
.\scripts\Deploy.ps1 -Stage Tailscale -EnableRemoteDesktop
.\scripts\Deploy.ps1 -Stage Monitoring
.\scripts\Deploy.ps1 -Stage Backup
```

| Stage | Purpose |
| --- | --- |
| `Check` | Load config and print important values |
| `System` | Apply Windows host baseline settings |
| `HyperV` | Create Hyper-V folders, switch, gateway IP, and NAT |
| `VM` | Create the Ubuntu Server VM |
| `Tailscale` | Print subnet router command and optionally scope RDP firewall |
| `Monitoring` | Print host, Hyper-V, NAT, and VM health |
| `Backup` | Export the Ubuntu VM |

## Configuration File

Primary config:

```text
scripts/Config/HomeLab.config.psd1
```

Important values:

| Key | Default |
| --- | --- |
| `SwitchName` | `LabInternal` |
| `NATName` | `LabNAT` |
| `NATSubnet` | `192.168.100.0/24` |
| `HostIP` | `192.168.100.1` |
| `VMRoot` | `D:\HyperV` |
| `UbuntuVM.Name` | `VM-UBUNTU` |
| `UbuntuVM.IsoPath` | `D:\HyperV\ISO\ubuntu-server.iso` |

Edit this file before running deployment stages if your storage path or ISO name is different.

## Windows Host Commands

Check power states:

```powershell
powercfg /a
```

Check active power scheme:

```powershell
powercfg /getactivescheme
```

Disable hibernate:

```powershell
powercfg /hibernate off
```

Disable AC sleep:

```powershell
powercfg /change standby-timeout-ac 0
```

Set lid close on AC to do nothing:

```powershell
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
powercfg /setactive SCHEME_CURRENT
```

Limit CPU boost:

```powershell
powercfg -attributes SUB_PROCESSOR PERFBOOSTMODE -ATTRIB_HIDE
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 0
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 99
powercfg /setactive SCHEME_CURRENT
```

## Hyper-V Commands

Check Hyper-V feature:

```powershell
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
```

List switches:

```powershell
Get-VMSwitch
```

Check lab adapter:

```powershell
Get-NetIPAddress -InterfaceAlias "vEthernet (LabInternal)" -AddressFamily IPv4
```

Check NAT:

```powershell
Get-NetNat
```

List VMs:

```powershell
Get-VM
```

Start Ubuntu VM:

```powershell
Start-VM -Name VM-UBUNTU
```

Stop Ubuntu VM:

```powershell
Stop-VM -Name VM-UBUNTU
```

Connect VM console:

```powershell
vmconnect.exe localhost VM-UBUNTU
```

## Ubuntu Commands

Update system:

```bash
sudo apt update
sudo apt upgrade -y
sudo reboot
```

Check network:

```bash
ip addr
ip route
ping 192.168.100.1
ping 1.1.1.1
ping google.com
```

Check SSH:

```bash
systemctl status ssh
```

Check disk and memory:

```bash
df -h
free -h
```

## Docker Commands

Install Docker using the repository script inside Ubuntu:

```bash
./scripts/Ubuntu/install-docker.sh
```

Bootstrap the home lab directory:

```bash
./scripts/Ubuntu/bootstrap-homelab-dir.sh
```

Start services:

```bash
cd /opt/homelab
docker compose up -d
```

Stop services:

```bash
cd /opt/homelab
docker compose down
```

Check services:

```bash
docker compose ps
docker compose logs --tail=100
docker system df
```

Prune unused images:

```bash
docker image prune -f
```

## Tailscale Commands

Check status:

```powershell
tailscale status
tailscale ip -4
```

Advertise lab subnet from Windows host:

```powershell
tailscale up --advertise-routes=192.168.100.0/24
```

Then approve the route in the Tailscale admin console.

SSH to Ubuntu over subnet route:

```bash
ssh <ubuntu-user>@192.168.100.10
```

## Troubleshooting: VM Has No Internet

1. Check Ubuntu IP:

   ```bash
   ip addr
   ```

2. Check Ubuntu default route:

   ```bash
   ip route
   ```

3. Ping Windows gateway:

   ```bash
   ping 192.168.100.1
   ```

4. Check Windows NAT:

   ```powershell
   Get-NetNat
   ```

5. Check DNS from Ubuntu:

   ```bash
   ping 1.1.1.1
   ping google.com
   ```

If `1.1.1.1` works but `google.com` fails, fix DNS.

## Troubleshooting: Cannot SSH to Ubuntu

1. Confirm VM is running:

   ```powershell
   Get-VM -Name VM-UBUNTU
   ```

2. Confirm Ubuntu IP:

   ```bash
   ip addr
   ```

3. Confirm SSH service:

   ```bash
   systemctl status ssh
   ```

4. Test from Windows host:

   ```powershell
   ssh <ubuntu-user>@192.168.100.10
   ```

5. If using Tailscale subnet routing, confirm route approval in the admin console.

## Troubleshooting: RDP Does Not Work Over Tailscale

1. Confirm Windows host is online in Tailscale:

   ```powershell
   tailscale status
   ```

2. Confirm RDP is enabled.

3. Confirm firewall scope:

   ```powershell
   Get-NetFirewallRule -DisplayGroup "Remote Desktop" |
       Get-NetFirewallAddressFilter
   ```

4. Confirm remote client is connected to the same tailnet.

5. Do not use router port forwarding for RDP.

## Troubleshooting: SSD Is Filling Up

Check Windows volume:

```powershell
Get-Volume
```

Check VM disks:

```powershell
Get-VMHardDiskDrive
```

Inside Ubuntu:

```bash
df -h
docker system df
```

Cleanup candidates:

- Old ISO files.
- Old VM exports.
- Unused Docker images.
- Excessive Docker logs.
- Unneeded Hyper-V checkpoints.

Do not delete VHDX or Docker data directories unless you know exactly what they contain.

## Maintenance Checklist

### Weekly

- [ ] Run `Deploy.ps1 -Stage Monitoring`.
- [ ] Check Ubuntu SSH.
- [ ] Check Docker services.
- [ ] Check disk usage.
- [ ] Check Tailscale status.
- [ ] Check CPU and SSD temperature.

### Monthly

- [ ] Clean dust filter.
- [ ] Inspect laptop vents.
- [ ] Check battery threshold.
- [ ] Export Ubuntu VM.
- [ ] Copy backup to external storage if available.
- [ ] Apply Windows updates in a planned window.
- [ ] Apply Ubuntu updates.
- [ ] Prune unused Docker images.

### Before Major Changes

- [ ] Confirm recent backup exists.
- [ ] Create a Hyper-V checkpoint if useful.
- [ ] Record current IP and service state.
- [ ] Apply change.
- [ ] Verify SSH, Docker, Tailscale, and RDP if used.
- [ ] Remove old checkpoint after stable operation.

## Release Checklist

Before publishing a v1.0 release:

- [ ] All chapters are written.
- [ ] Appendix is current.
- [ ] Diagrams render correctly.
- [ ] PowerShell scripts are reviewed on Windows.
- [ ] Ubuntu shell scripts are tested inside Ubuntu.
- [ ] PDF build workflow succeeds.
- [ ] Release artifact is generated.
- [ ] Tag `v1.0.0` is created.

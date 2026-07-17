# Test Plan

This test plan defines the manual validation required before treating v1.0.0 as a production-ready release for a real home lab.

Automated GitHub Actions can validate repository structure, shell syntax, PowerShell parser syntax, diagram rendering, and PDF generation. They cannot prove that the scripts work on the target Windows laptop, Ubuntu VM, Hyper-V environment, or Tailscale tailnet.

## Test Environments

| Environment | Purpose |
| --- | --- |
| Windows 11 Pro ThinkPad host | Validate PowerShell, Hyper-V, firewall, Tailscale, backup |
| Ubuntu Server VM | Validate SSH, Docker, Compose, service layout |
| Remote Tailscale client | Validate RDP/SSH over Tailscale |
| GitHub Actions | Validate CI, PDF build, release workflow |

## Test Order

Run tests in this order:

1. Repository and CI validation.
2. Windows host baseline.
3. Hyper-V and NAT.
4. Ubuntu VM creation and install.
5. Docker platform.
6. Tailscale remote access.
7. Monitoring and backup.
8. Release artifact review.

Do not skip ahead if a lower layer is failing. For example, do not debug Docker until Ubuntu networking is confirmed.

## Repository Validation

Run locally:

```bash
./scripts/validate-repo.sh
```

Expected result:

```text
Repository validation passed.
```

On GitHub, confirm these workflows pass:

- `Validate`
- `Build PDF`
- `Release` when publishing a tag or manually dispatching a release

## Windows Host Baseline Tests

Run PowerShell as Administrator:

```powershell
.\scripts\Deploy.ps1 -Stage Check
.\scripts\Deploy.ps1 -Stage System
```

Optional RDP:

```powershell
.\scripts\Deploy.ps1 -Stage System -EnableRemoteDesktop
```

Verify:

```powershell
powercfg /a
powercfg /getactivescheme
Get-NetFirewallRule -DisplayGroup "Remote Desktop" |
    Get-NetFirewallAddressFilter
```

Pass criteria:

- Host does not sleep on AC power.
- Hibernate is disabled.
- Lid close on AC is configured to do nothing.
- RDP is scoped to Tailscale only if enabled.

## Hyper-V and NAT Tests

Run:

```powershell
.\scripts\Deploy.ps1 -Stage HyperV
```

Restart Windows if Hyper-V was newly enabled.

Verify:

```powershell
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
Get-VMSwitch -Name LabInternal
Get-NetIPAddress -InterfaceAlias "vEthernet (LabInternal)" -AddressFamily IPv4
Get-NetNat -Name LabNAT
```

Pass criteria:

- Hyper-V is enabled.
- `LabInternal` exists and is Internal.
- `vEthernet (LabInternal)` has `192.168.100.1/24`.
- `LabNAT` exists for `192.168.100.0/24`.

## Ubuntu VM Tests

Before running:

- Download Ubuntu Server ISO.
- Update `UbuntuVM.IsoPath` in `scripts/Config/HomeLab.config.psd1`.

Run:

```powershell
.\scripts\Deploy.ps1 -Stage VM
Start-VM -Name VM-UBUNTU
```

Install Ubuntu Server from the console.

After install, verify inside Ubuntu:

```bash
ip addr
ip route
ping 192.168.100.1
ping 1.1.1.1
ping google.com
systemctl status ssh
```

From Windows:

```powershell
ssh <ubuntu-user>@192.168.100.10
```

Pass criteria:

- Ubuntu has static IP `192.168.100.10/24`.
- Ubuntu can reach host gateway, internet IP, and DNS.
- SSH works from Windows host.

## Docker Platform Tests

Inside Ubuntu:

```bash
./scripts/Ubuntu/install-docker.sh
exit
```

Log back in, then:

```bash
docker version
docker compose version
docker run --rm hello-world
./scripts/Ubuntu/bootstrap-homelab-dir.sh
```

Copy template files to `/opt/homelab`, edit `.env`, then:

```bash
cd /opt/homelab
docker compose up -d
docker compose ps
docker system df
```

Pass criteria:

- Docker runs without `sudo` after re-login.
- Compose stack starts.
- Nginx, PostgreSQL, and Redis containers are healthy/running.
- Persistent data folders are created under `/opt/homelab/data`.

## Tailscale Tests

On Windows:

```powershell
tailscale status
tailscale ip -4
.\scripts\Deploy.ps1 -Stage Tailscale -EnableRemoteDesktop
```

Advertise subnet:

```powershell
tailscale up --advertise-routes=192.168.100.0/24
```

Approve the route in the Tailscale admin console.

From a remote Tailscale device:

```bash
ping <windows-host-tailscale-ip>
ssh <ubuntu-user>@192.168.100.10
```

Pass criteria:

- Windows host is online in Tailscale.
- RDP is reachable only over Tailscale if enabled.
- Remote client can SSH into Ubuntu over subnet route.
- No router port forwarding is required.

## Monitoring and Backup Tests

Run:

```powershell
.\scripts\Deploy.ps1 -Stage Monitoring
.\scripts\Deploy.ps1 -Stage Backup
```

Verify backup output under:

```text
D:\HyperV\Backup
```

Pass criteria:

- Monitoring prints host, switch, NAT, and VM information.
- Backup exports `VM-UBUNTU` to a timestamped folder.
- Backup destination has enough free space.

## PDF and Release Tests

On GitHub:

1. Confirm `Build PDF` succeeds.
2. Download the PDF artifact.
3. Review the PDF visually:
   - Table of contents exists.
   - Page numbers exist.
   - Diagrams render.
   - Code blocks are readable.
   - No obvious text overflow.
4. Run `Release` workflow manually for `v1.0.0` if the tag already existed.
5. Confirm the GitHub Release has the PDF asset attached.

## Exit Criteria for v1.0.0

v1.0.0 can be considered complete when:

- CI validation passes.
- PDF build passes.
- Windows scripts are tested on the target host.
- Ubuntu scripts are tested in the VM.
- Docker Compose baseline runs.
- Tailscale access works.
- Backup export works.
- GitHub Release contains the PDF artifact.

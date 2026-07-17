# Windows Host Validation Checklist

Use this on the target Windows 11 Pro host.

## System Stage

- [ ] PowerShell is running as Administrator.
- [ ] `.\scripts\Deploy.ps1 -Stage Check` succeeds.
- [ ] `.\scripts\Deploy.ps1 -Stage System` succeeds.
- [ ] Hibernate is disabled.
- [ ] Sleep on AC is disabled.
- [ ] Lid close on AC is set to do nothing.
- [ ] Processor policy is applied.
- [ ] Optional RDP configuration is applied only if needed.

## Hyper-V Stage

- [ ] `.\scripts\Deploy.ps1 -Stage HyperV` succeeds.
- [ ] Windows is restarted if Hyper-V was newly enabled.
- [ ] `LabInternal` switch exists.
- [ ] `vEthernet (LabInternal)` has `192.168.100.1/24`.
- [ ] `LabNAT` exists.
- [ ] Hyper-V folders exist.

## VM Stage

- [ ] Ubuntu ISO path is correct in `HomeLab.config.psd1`.
- [ ] `.\scripts\Deploy.ps1 -Stage VM` succeeds.
- [ ] `VM-UBUNTU` is Generation 2.
- [ ] VM uses Dynamic Memory.
- [ ] VM is attached to `LabInternal`.
- [ ] VM boots from the Ubuntu ISO.

## Tailscale Stage

- [ ] Tailscale is installed and signed in.
- [ ] `tailscale status` shows the host online.
- [ ] `.\scripts\Deploy.ps1 -Stage Tailscale` succeeds.
- [ ] If RDP is enabled, firewall scope is `100.64.0.0/10`.
- [ ] Subnet route command is run if needed.
- [ ] Subnet route is approved in the admin console.

## Operations

- [ ] `.\scripts\Deploy.ps1 -Stage Monitoring` succeeds.
- [ ] `.\scripts\Deploy.ps1 -Stage Backup` succeeds.
- [ ] Backup output is present under the configured backup path.

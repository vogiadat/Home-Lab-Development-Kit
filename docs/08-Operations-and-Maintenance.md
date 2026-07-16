# Chapter 08 - Operations and Maintenance

## Goal

This chapter defines the recurring operational routines that keep the Home Lab Development Kit stable after deployment.

The system is small, but it still needs regular checks. Most failures in a laptop-based home lab come from predictable causes: disk space, heat, Windows restarts, Docker logs, stale backups, and dust.

## Operating Model

Diagram source: [`../diagrams/operations-flow.mmd`](../diagrams/operations-flow.mmd)

| Area | Practice |
| --- | --- |
| Monitoring | Run a quick health check weekly |
| Backup | Export important VMs and application data |
| Updates | Use planned maintenance windows |
| Cooling | Clean dust filter monthly |
| Storage | Keep at least 20% free SSD space |
| Remote access | Verify Tailscale before relying on it |

The goal is not enterprise-grade operations. The goal is a simple routine that catches problems before they become outages.

## Script Entry Points

Run from elevated PowerShell on the Windows host:

```powershell
.\scripts\Deploy.ps1 -Stage Monitoring
.\scripts\Deploy.ps1 -Stage Backup
```

`Monitoring` prints host, Hyper-V, NAT, and VM status.

`Backup` exports the configured Ubuntu VM to the backup path defined in:

```text
scripts/Config/HomeLab.config.psd1
```

## Weekly Checklist

- [ ] Check Windows host free disk space.
- [ ] Check VM state.
- [ ] Check Ubuntu SSH access.
- [ ] Check Docker containers.
- [ ] Check Docker disk usage.
- [ ] Check Tailscale connectivity.
- [ ] Check CPU and SSD temperature.
- [ ] Confirm no unexpected Windows restart happened.

Useful commands:

```powershell
.\scripts\Deploy.ps1 -Stage Monitoring
```

Inside Ubuntu:

```bash
docker compose -f /opt/homelab/compose.yaml ps
docker system df
df -h
free -h
```

## Monthly Checklist

- [ ] Clean the external dust filter.
- [ ] Inspect laptop vents.
- [ ] Confirm battery charge threshold is still active.
- [ ] Run a backup.
- [ ] Verify backup files exist.
- [ ] Apply Windows and Ubuntu updates during a planned window.
- [ ] Prune unused Docker images.
- [ ] Review exposed ports.

Docker cleanup:

```bash
docker image prune -f
```

Avoid:

```bash
docker system prune -a --volumes
```

unless you understand exactly what data will be deleted.

## Backup Strategy

There are two backup levels:

| Level | What | Use Case |
| --- | --- | --- |
| VM export | Full Ubuntu VM export | Disaster recovery or migration |
| Application data | `/opt/homelab` data | Faster service restore |

For v1.0, the repository includes a Windows-side VM export script. Application data backup can be added later once real services are deployed.

Recommended backup location:

```text
D:\HyperV\Backup
```

For stronger protection, copy backup output to an external drive or NAS after export.

## VM Export

PowerShell:

```powershell
.\scripts\Deploy.ps1 -Stage Backup
```

The script exports:

```text
VM-UBUNTU
```

to a timestamped folder under:

```text
D:\HyperV\Backup
```

Do not rely on a backup until you have tested at least one restore.

## Restore Guidance

To restore a VM export manually:

```powershell
Import-VM `
    -Path "D:\HyperV\Backup\<backup-folder>\Virtual Machines\<vm-id>.vmcx" `
    -Copy `
    -GenerateNewId
```

After restore:

- Connect VM to `LabInternal`.
- Confirm static IP does not conflict with the original VM.
- Boot and verify SSH.
- Verify Docker services.

For a real disaster recovery plan, document the exact restore path after testing it on your machine.

## Windows Update Routine

Suggested process:

1. Confirm remote access works.
2. Save or gracefully stop important VMs.
3. Install Windows updates.
4. Restart the host.
5. Confirm Hyper-V services are back.
6. Start VMs if needed.
7. Verify Tailscale, SSH, Docker, and services.

Useful commands:

```powershell
Get-VM
Start-VM -Name VM-UBUNTU
```

## Ubuntu Update Routine

Inside Ubuntu:

```bash
sudo apt update
sudo apt upgrade -y
sudo reboot
```

After reboot:

```bash
systemctl status ssh
docker compose -f /opt/homelab/compose.yaml ps
```

## Docker Operations

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

View logs:

```bash
docker compose logs --tail=100
```

Check resource usage:

```bash
docker stats
```

## Temperature and Dust

Use HWiNFO64 or another trusted monitor on Windows.

Track:

| Sensor | Target |
| --- | --- |
| CPU Package | 55-70 C under normal VM workload |
| SSD | Below 60 C |
| Thermal throttling | Not active |
| Fan noise | Stable, not constantly maxed |

If temperatures rise over time with the same workload, clean the filter and inspect vents before changing software settings.

## Common Mistakes

| Mistake | Impact |
| --- | --- |
| Never testing restore | Backups may be unusable |
| Ignoring disk usage | VM or Docker can fill SSD |
| Leaving many checkpoints | Hidden storage growth |
| Updating Windows without VM plan | Unexpected downtime |
| Never cleaning dust filter | Higher temperature and noise |
| Exposing services while debugging | Creates persistent security risk |

## Verification Checklist

- [ ] `Deploy.ps1 -Stage Monitoring` runs.
- [ ] VM export backup has been created.
- [ ] Backup location has enough space.
- [ ] Ubuntu SSH works after restart.
- [ ] Docker services restart correctly.
- [ ] Tailscale remote access still works.
- [ ] Dust filter is clean.
- [ ] Battery threshold remains active.

## Exit Criteria

The v1.0 deployment is operational when:

- The host can be monitored.
- The Ubuntu VM can be backed up.
- The system can survive planned Windows restarts.
- Remote access is verified.
- Maintenance tasks are documented and repeatable.

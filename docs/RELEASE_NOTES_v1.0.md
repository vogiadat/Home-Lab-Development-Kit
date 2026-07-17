# Release Notes - v1.0.0

## Home Lab Development Kit v1.0.0

Release date: 2026-07-17

This is the first complete release candidate for the Home Lab Development Kit.

## Scope

v1.0.0 focuses on a practical laptop-based home lab built around:

- Lenovo ThinkPad T14 Gen 2 reference hardware.
- Windows 11 Pro host.
- Hyper-V virtualization.
- Ubuntu Server VM.
- Docker and Docker Compose workloads.
- Tailscale secure remote access.
- DIY cooling and battery protection.

## Included

- Deployment Manual source in Markdown.
- PDF build pipeline using Pandoc, XeLaTeX, and Mermaid CLI.
- PowerShell deployment toolkit.
- Ubuntu helper scripts.
- Docker Compose baseline templates.
- Mermaid architecture diagrams.
- Maintenance and troubleshooting appendix.

## Main Documentation

The manual includes:

- Chapter 00 - Bill of Materials.
- Chapter 01 - System Overview.
- Chapter 02 - DIY Cooling and Battery Protection.
- Chapter 03 - Windows Host Optimization.
- Chapter 04 - Hyper-V Deployment.
- Chapter 05 - Ubuntu Server.
- Chapter 06 - Docker Platform.
- Chapter 07 - Tailscale Remote Access.
- Chapter 08 - Operations and Maintenance.
- Appendix - Commands, troubleshooting, and checklists.

## Deployment Scripts

Windows host:

```powershell
.\scripts\Deploy.ps1 -Stage Check
.\scripts\Deploy.ps1 -Stage System
.\scripts\Deploy.ps1 -Stage HyperV
.\scripts\Deploy.ps1 -Stage VM
.\scripts\Deploy.ps1 -Stage Tailscale
.\scripts\Deploy.ps1 -Stage Monitoring
.\scripts\Deploy.ps1 -Stage Backup
```

Ubuntu VM:

```bash
./scripts/Ubuntu/install-docker.sh
./scripts/Ubuntu/bootstrap-homelab-dir.sh
```

## Known Limitations

- PowerShell scripts still need validation on a real Windows 11 Pro host.
- Ubuntu scripts still need validation inside the actual Ubuntu VM.
- Docker Compose template should be tested with the user's final service list before production use.
- The generated PDF should be visually reviewed before publishing as a final GitHub Release asset.

## Recommended Release Process

1. Confirm GitHub Actions PDF build succeeds.
2. Download and visually review the PDF artifact.
3. Test key scripts on the target machine.
4. Create tag `v1.0.0`.
5. Let the release workflow create the GitHub Release and attach the PDF artifact.

If the tag already existed before the release workflow was added, run the `Release` workflow manually from GitHub Actions and provide `v1.0.0` as the tag input.

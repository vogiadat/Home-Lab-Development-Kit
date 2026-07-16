# PowerShell Scripts

This directory contains modular PowerShell scripts for deploying and operating the Home Lab Development Kit reference environment.

## Layout

```text
scripts/
├── Config/
│   └── HomeLab.config.psd1
├── Modules/
│   ├── 01-System/
│   ├── 02-HyperV/
│   ├── 03-VM/
│   ├── 04-Tailscale/
│   ├── 05-Monitoring/
│   └── 06-Backup/
└── Deploy.ps1
```

## Usage

Run PowerShell as Administrator before executing host configuration or Hyper-V scripts.

Check configuration:

```powershell
.\Deploy.ps1 -Stage Check
```

Apply Windows host baseline settings:

```powershell
.\Deploy.ps1 -Stage System
```

Apply Windows host baseline settings and enable Remote Desktop scoped to Tailscale:

```powershell
.\Deploy.ps1 -Stage System -EnableRemoteDesktop
```

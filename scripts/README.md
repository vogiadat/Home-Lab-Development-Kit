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

Create Hyper-V folders, enable Hyper-V, create the internal switch, assign the host gateway IP, and configure NAT:

```powershell
.\Deploy.ps1 -Stage HyperV
```

If Hyper-V is enabled for the first time, restart Windows before creating VMs.

Create the Ubuntu Server VM from the configured ISO:

```powershell
.\Deploy.ps1 -Stage VM
```

Before running this stage, download the Ubuntu Server ISO and make sure `UbuntuVM.IsoPath` in `Config/HomeLab.config.psd1` points to the correct file.

Ubuntu-side scripts are stored under:

```text
scripts/Ubuntu/
```

Run them inside the Ubuntu VM, not on the Windows host.

Print Tailscale subnet router guidance and optionally restrict RDP firewall rules to Tailscale:

```powershell
.\Deploy.ps1 -Stage Tailscale
.\Deploy.ps1 -Stage Tailscale -EnableRemoteDesktop
```

Run host and VM monitoring checks:

```powershell
.\Deploy.ps1 -Stage Monitoring
```

Export the Ubuntu VM to the configured backup folder:

```powershell
.\Deploy.ps1 -Stage Backup
```

# Chapter 04 - Hyper-V Deployment

## Goal

This chapter installs Hyper-V and creates the private lab network used by the Home Lab Development Kit.

The target design is:

Diagram source: [`../diagrams/hyper-v-nat.mmd`](../diagrams/hyper-v-nat.mmd)

![Hyper-V NAT architecture](assets/images/hyper-v-nat.png)

```text
Windows 11 Pro Host
    |
    | vEthernet (LabInternal) - 192.168.100.1/24
    v
Hyper-V Internal Switch
    |
    v
Lab VMs - 192.168.100.0/24
    |
    v
Windows NAT -> Home LAN -> Internet
```

VMs can access the internet through Windows NAT, but they are not directly attached to the home router LAN.

## Why Internal Switch + NAT

Hyper-V supports three common virtual switch types:

| Switch Type | VM Internet | VM Visible on Home LAN | Recommended |
| --- | --- | --- | --- |
| External | Yes | Yes | No for v1.0 |
| Internal | Yes, with NAT | No by default | Yes |
| Private | No | No | Only for isolated labs |

The v1.0 deployment uses an Internal Switch plus Windows NAT because it gives a good balance of usability and isolation.

Benefits:

- VMs have outbound internet access.
- VMs are isolated from normal home LAN devices by default.
- The IP plan is controlled by this project.
- Tailscale subnet routing can be added later.
- The setup is scriptable with PowerShell.

## Script Entry Point

Run PowerShell as Administrator:

```powershell
.\scripts\Deploy.ps1 -Stage HyperV
```

This stage performs four actions:

1. Create the Hyper-V folder layout.
2. Enable Hyper-V Windows feature.
3. Create the Internal Switch.
4. Configure the host vEthernet IP and Windows NAT.

Hyper-V installation may require a reboot. If the script enables Hyper-V for the first time, restart Windows before creating VMs.

## Folder Layout

The default folder layout is defined in:

```text
scripts/Config/HomeLab.config.psd1
```

Default paths:

| Path | Purpose |
| --- | --- |
| `D:\HyperV` | Root folder |
| `D:\HyperV\VHD` | Dynamic VHDX files |
| `D:\HyperV\ISO` | ISO installers |
| `D:\HyperV\Export` | Manual VM exports |
| `D:\HyperV\Backup` | Backup output |

If your laptop only has a `C:` drive, update the config before running the script. Do not blindly use `D:\HyperV` if that drive does not exist.

## Enable Hyper-V

Manual command:

```powershell
Enable-WindowsOptionalFeature `
    -Online `
    -FeatureName Microsoft-Hyper-V `
    -All `
    -NoRestart
```

Restart after enabling Hyper-V:

```powershell
Restart-Computer
```

Verification:

```powershell
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
```

Expected state:

```text
Enabled
```

## Create Internal Switch

Manual command:

```powershell
New-VMSwitch `
    -Name "LabInternal" `
    -SwitchType Internal
```

Verification:

```powershell
Get-VMSwitch -Name "LabInternal"
```

Expected result:

```text
Name          SwitchType
----          ----------
LabInternal   Internal
```

## Configure Host vEthernet IP

After creating the switch, Windows creates a host adapter named:

```text
vEthernet (LabInternal)
```

Assign the gateway IP:

```powershell
New-NetIPAddress `
    -InterfaceAlias "vEthernet (LabInternal)" `
    -IPAddress 192.168.100.1 `
    -PrefixLength 24
```

This address becomes the default gateway for VMs on the lab network.

## Configure Windows NAT

Create NAT for the lab subnet:

```powershell
New-NetNat `
    -Name "LabNAT" `
    -InternalIPInterfaceAddressPrefix "192.168.100.0/24"
```

Verification:

```powershell
Get-NetNat -Name "LabNAT"
```

## Reference IP Plan

| Role | IP |
| --- | --- |
| Host vEthernet gateway | `192.168.100.1` |
| Ubuntu Server VM | `192.168.100.10` |
| Optional Windows VM | `192.168.100.20` |
| Future VMs | `192.168.100.30-192.168.100.99` |

The first version of this kit uses static VM addresses for clarity. DHCP reservations can be added later if the lab grows.

## VM Resource Defaults

The recommended first VM is Ubuntu Server:

| Resource | Value |
| --- | --- |
| vCPU | 2 |
| Startup RAM | 2 GB |
| Minimum RAM | 1 GB |
| Maximum RAM | 6 GB |
| Disk | 100 GB dynamic VHDX |
| Network | `LabInternal` |
| Generation | 2 |

Avoid creating many VMs before verifying host RAM and SSD headroom.

## Verification Commands

Check Hyper-V feature:

```powershell
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
```

Check switches:

```powershell
Get-VMSwitch
```

Check host virtual adapter:

```powershell
Get-NetIPAddress -InterfaceAlias "vEthernet (LabInternal)"
```

Check NAT:

```powershell
Get-NetNat
```

Check folders:

```powershell
Get-ChildItem D:\HyperV
```

## Common Mistakes

| Mistake | Impact |
| --- | --- |
| Using External Switch for all VMs | VMs are directly exposed to the home LAN |
| Reusing the home LAN subnet for NAT | Routing conflicts |
| Forgetting to reboot after Hyper-V install | Hyper-V tools may not work correctly |
| Putting VHDX files on a nearly full SSD | VM performance and reliability degrade |
| Creating fixed-size VHDX files | Wastes disk space immediately |
| Running scripts without Administrator | Network and feature commands fail |

## Verification Checklist

- [ ] Hyper-V feature is enabled.
- [ ] Windows has been restarted after first Hyper-V installation.
- [ ] `LabInternal` switch exists.
- [ ] `vEthernet (LabInternal)` has `192.168.100.1/24`.
- [ ] `LabNAT` exists for `192.168.100.0/24`.
- [ ] Hyper-V folder layout exists.
- [ ] Host SSD still has enough free space.
- [ ] No lab subnet overlap with the home LAN.

## Exit Criteria

Before moving to Ubuntu Server:

- Hyper-V Manager opens successfully.
- `Get-VMSwitch` shows the internal switch.
- `Get-NetNat` shows the lab NAT.
- The VM storage paths are ready.
- You are ready to create the Ubuntu Server VM.

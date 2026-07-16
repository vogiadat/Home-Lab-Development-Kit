# Chapter 03 - Windows Host Optimization

## Goal

This chapter prepares Windows 11 Pro to behave like a reliable Hyper-V host for 24/7 operation.

The default Windows desktop configuration is not ideal for a home lab. It may sleep, hibernate, restart unexpectedly, keep the CPU boosting aggressively, or expose remote access more broadly than needed. This chapter changes the host into a predictable base layer for Hyper-V.

## What This Chapter Configures

| Area | Target State |
| --- | --- |
| Sleep on AC power | Never |
| Display timeout on AC power | Never or manually controlled |
| Hibernate | Disabled |
| Lid close on AC power | Do nothing |
| CPU boost | Disabled or limited |
| Maximum processor state | 99% on AC power |
| Remote Desktop | Enabled only when needed |
| RDP firewall | Restricted to Tailscale range |
| Windows Update | Controlled maintenance window |

Run PowerShell as Administrator before applying host changes.

## Script Entry Point

The repository includes an initial System stage:

```powershell
.\scripts\Deploy.ps1 -Stage System
```

This stage applies the baseline host settings implemented in:

```text
scripts/Modules/01-System/
```

Review the scripts before running them on a real machine. Some settings, such as Remote Desktop and firewall policy, should match your access model.

Remote Desktop is intentionally opt-in:

```powershell
.\scripts\Deploy.ps1 -Stage System -EnableRemoteDesktop
```

## BIOS and Firmware Check

Before changing Windows, check firmware settings.

On a ThinkPad, enter BIOS with `F1` during boot.

| Setting | Recommended Value |
| --- | --- |
| Intel Virtualization Technology | Enabled |
| Intel VT-d | Enabled |
| Secure Boot | Enabled |
| TPM 2.0 | Enabled |
| BIOS update | Current stable version |

Do not continue to Hyper-V deployment until virtualization support is enabled.

## Host Naming

Use a predictable host name.

Recommended:

```text
LAB-HOST
```

PowerShell:

```powershell
Rename-Computer -NewName "LAB-HOST" -Restart
```

Renaming requires a restart. Do this before configuring Tailscale names, firewall references, or documentation screenshots.

## Disable Sleep on AC Power

The host must not sleep while VMs are running.

PowerShell:

```powershell
powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-ac 0
```

`0` means never. For a headless or closed-lid home lab, this avoids accidental VM downtime.

## Disable Hibernate

Hibernate is useful for laptops, but it is not useful for this server-style deployment.

PowerShell:

```powershell
powercfg /hibernate off
```

Benefits:

- Removes hibernate behavior.
- Frees disk space used by `hiberfil.sys`.
- Reduces confusion between shutdown, sleep, and saved VM state.

## Lid Close Behavior

The laptop will normally run closed and vertical.

Target:

| Power State | Lid Close Action |
| --- | --- |
| On battery | Sleep |
| Plugged in | Do nothing |

PowerShell can set the AC lid action:

```powershell
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
powercfg /setactive SCHEME_CURRENT
```

The value `0` means do nothing.

You can also verify through:

```text
Control Panel
  -> Power Options
  -> Choose what closing the lid does
```

## CPU Boost and Thermal Policy

For a 24/7 laptop host, lower heat is usually more valuable than short bursts of maximum CPU speed.

Two conservative controls are used:

1. Disable processor boost mode when supported.
2. Set maximum processor state to 99% on AC power.

PowerShell:

```powershell
powercfg -attributes SUB_PROCESSOR PERFBOOSTMODE -ATTRIB_HIDE
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 0
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 99
powercfg /setactive SCHEME_CURRENT
```

Expected effect:

- Lower peak temperature.
- Less fan noise.
- Less thermal throttling risk.
- Slightly lower peak performance.

If you later need more CPU performance, change this policy deliberately and watch temperatures under load.

## Remote Desktop

Remote Desktop is useful for a Windows host, but it should not be exposed broadly.

Enable RDP:

```powershell
Set-ItemProperty `
    -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" `
    -Name "fDenyTSConnections" `
    -Value 0
```

The deployment scripts include a baseline module for enabling RDP and restricting the firewall rule to the Tailscale carrier-grade NAT range:

```text
100.64.0.0/10
```

This allows RDP from Tailscale clients while avoiding general LAN or internet exposure.

Do not configure router port forwarding to RDP.

## Windows Update Policy

For v1.0, keep Windows Update simple:

- Install updates during a planned maintenance window.
- Restart manually when possible.
- Confirm VMs are saved or shut down before restart.
- After restart, verify Hyper-V and VM state.

More advanced Group Policy and scheduled maintenance automation can be added later in the Operations chapter.

## Verification Commands

Check available sleep states:

```powershell
powercfg /a
```

Check active power scheme:

```powershell
powercfg /getactivescheme
```

Check Hyper-V readiness:

```powershell
systeminfo | findstr /i "Hyper-V"
```

Check RDP firewall rules:

```powershell
Get-NetFirewallRule -DisplayGroup "Remote Desktop" |
    Get-NetFirewallAddressFilter
```

## Common Mistakes

| Mistake | Impact |
| --- | --- |
| Closing the lid before changing lid action | Host sleeps and VMs stop |
| Leaving hibernate enabled | Wastes SSD space and complicates power behavior |
| Enabling RDP without firewall scope | Larger attack surface |
| Using High Performance plan blindly | Higher heat and fan noise |
| Ignoring Windows Update restart behavior | Unexpected downtime |
| Tuning CPU without measuring temperature | No baseline for future troubleshooting |

## Verification Checklist

- [ ] BIOS virtualization is enabled.
- [ ] Host has a predictable name.
- [ ] Sleep on AC power is disabled.
- [ ] Hibernate is disabled.
- [ ] Lid close on AC power is set to do nothing.
- [ ] CPU boost is disabled or intentionally limited.
- [ ] Maximum processor state is configured.
- [ ] RDP is enabled only if needed.
- [ ] RDP firewall scope is restricted to Tailscale.
- [ ] Windows Update restart behavior is understood.
- [ ] Host has been restarted once after major changes.

## Exit Criteria

Before moving to Hyper-V deployment:

- The host can run closed on AC power without sleeping.
- CPU temperature is stable under a normal workload.
- Remote access policy is clear.
- You can open an elevated PowerShell session reliably.
- You are ready to install Hyper-V and create the internal lab network.

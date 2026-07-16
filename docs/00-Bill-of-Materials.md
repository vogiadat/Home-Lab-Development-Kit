# Chapter 00 - Bill of Materials

## Goal

This chapter defines the minimum hardware, software, and consumables required to build the reference Home Lab Development Kit.

The target setup is intentionally modest: one repurposed laptop, one Ubuntu Server VM, Docker workloads, and secure remote access through Tailscale. The goal is not to build the most powerful home lab. The goal is to build a small system that can run 24/7 with low heat, low noise, and predictable maintenance.

## Reference Hardware

| Component | Reference Specification | Required | Notes |
| --- | --- | --- | --- |
| Laptop | Lenovo ThinkPad T14 Gen 2 | Yes | Reference platform for this manual |
| CPU | Intel Core i5-1145G7, 4 cores / 8 threads | Yes | Enough for light VM and container workloads |
| RAM | 32 GB | Yes | Recommended minimum for comfortable Hyper-V usage |
| Storage | 256 GB NVMe SSD | Yes | Works, but requires careful VHDX planning |
| Power adapter | Lenovo USB-C charger | Yes | Use a reliable original or high-quality charger |
| Network | Wi-Fi or Ethernet | Yes | Ethernet is preferred when available |
| Battery | Internal laptop battery | Yes | Acts as a small built-in UPS |

## Optional Hardware Upgrades

| Upgrade | Recommendation | Priority | Reason |
| --- | --- | --- | --- |
| SSD | 1 TB NVMe | High | Gives VM disks, Docker images, and backups room to grow |
| USB Ethernet adapter | Intel or Realtek-based USB 3.0 adapter | Medium | More stable than Wi-Fi for a 24/7 host |
| External backup drive | 1 TB or larger | Medium | Useful for VM export and disaster recovery |
| Vertical laptop stand | Metal or rigid plastic | Medium | Keeps the footprint small and improves airflow |
| Smart plug | Power monitoring capable | Low | Useful for measuring power consumption |

For the initial v1.0 build, the 256 GB SSD is acceptable if the system is kept lean. Do not create many Windows VMs, do not use fixed-size VHDX files, and keep at least 20% free disk space on the host SSD.

## DIY Cooling Parts

| Item | Suggested Specification | Quantity | Notes |
| --- | --- | ---: | --- |
| Static pressure fan | 120 mm PC fan, 12 V | 1 | Arctic P12, Noctua NF-F12, or similar |
| Magnetic dust filter | 120 mm mesh filter | 1 | Install before the fan intake |
| DC adapter | 12 V, 1-2 A | 1 | Dedicated power for the fan |
| PVC/Formex board | 5 mm thickness | 1 sheet | Used to build the plenum chamber |
| EPDM foam gasket | 3-5 mm thickness | 1-2 m | Seals air gaps and reduces vibration |
| Velcro straps | Reusable cable straps | As needed | Keeps the laptop and cables organized |
| Rubber feet | Anti-slip pads | 4-8 | Reduces vibration and protects surfaces |

The cooling design uses a filtered positive-pressure chamber. The external fan does not replace the laptop's internal fan. It feeds filtered air into the laptop intake area so the internal cooling system can work with less effort.

## Software Requirements

| Software | Purpose | Required |
| --- | --- | --- |
| Windows 11 Pro | Host operating system | Yes |
| Hyper-V | Virtualization platform | Yes |
| Ubuntu Server LTS | Main Linux VM | Yes |
| Docker Engine | Container runtime | Yes |
| Docker Compose | Container orchestration for small services | Yes |
| Tailscale | Secure remote access | Yes |
| Lenovo Commercial Vantage | Battery charge threshold | Yes |
| HWiNFO64 | Temperature and hardware monitoring | Recommended |
| Windows Terminal | Better shell experience | Recommended |
| Visual Studio Code | Editing scripts and documentation | Optional |

## Network Assumptions

The manual assumes the home router uses a normal private LAN, such as:

```text
192.168.1.0/24
```

The Hyper-V lab network will use a separate NAT subnet:

```text
192.168.100.0/24
```

Do not use the same subnet for the home LAN and the Hyper-V lab network. Overlapping networks cause routing problems, especially when Tailscale subnet routing is enabled.

## Reference IP Plan

| Role | Address |
| --- | --- |
| Hyper-V NAT subnet | `192.168.100.0/24` |
| Windows host vEthernet gateway | `192.168.100.1` |
| Ubuntu Server VM | `192.168.100.10` |
| Optional Windows VM | `192.168.100.20` |
| Future VM range | `192.168.100.30-192.168.100.99` |

The first version of this kit uses static addressing for clarity. DHCP automation can be added later with `dnsmasq` if the lab grows.

## Capacity Guardrails

| Resource | Guardrail |
| --- | --- |
| Host RAM reserve | Keep at least 6 GB for Windows |
| Total active VM RAM | Keep below 24-26 GB |
| Ubuntu VM vCPU | Start with 2 vCPU |
| Ubuntu VM RAM | 2 GB startup, 6 GB maximum |
| Ubuntu VM disk | 100 GB dynamic VHDX |
| Host SSD free space | Keep at least 50 GB free on a 256 GB SSD |

These limits are conservative by design. A home lab that stays responsive is more useful than a home lab that is technically overprovisioned but unstable.

## Pre-Deployment Checklist

- [ ] Windows 11 Pro is installed and activated.
- [ ] BIOS virtualization support is enabled.
- [ ] The laptop charger is reliable and stable.
- [ ] Lenovo Commercial Vantage is installed.
- [ ] Battery charge threshold can be configured.
- [ ] At least 120 GB of free SSD space is available before VM creation.
- [ ] Home LAN subnet is known.
- [ ] Tailscale account is available.
- [ ] Ubuntu Server ISO is downloaded.
- [ ] Important existing laptop data is backed up.

## Common Mistakes

| Mistake | Impact |
| --- | --- |
| Using Windows 11 Home | Hyper-V is not available by default |
| Keeping the battery at 100% all year | Accelerates battery wear and swelling risk |
| Creating fixed-size VHDX files | Wastes SSD space immediately |
| Running too many VMs | Causes CPU contention and memory pressure |
| Using the same subnet for LAN and lab NAT | Breaks routing and remote access |
| Ignoring dust filtering | Increases maintenance and thermal throttling |

## Exit Criteria

Before moving to the next chapter, you should have:

- Confirmed the laptop hardware matches the reference requirements.
- Decided whether the 256 GB SSD is enough for v1.0.
- Prepared the DIY cooling parts or accepted the temporary risk of running without them.
- Confirmed the lab subnet does not overlap with the home LAN.
- Downloaded the required installers and ISO files.

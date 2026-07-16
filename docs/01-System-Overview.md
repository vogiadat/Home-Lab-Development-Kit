# Chapter 01 - System Overview

## Goal

This chapter explains the target architecture for the Home Lab Development Kit.

By the end of this chapter, you should understand:

- What the system is designed to do.
- Which components run on the Windows host.
- Which components run inside the Ubuntu VM.
- How Hyper-V NAT and Tailscale fit together.
- Why the v1.0 architecture stays intentionally small.

## Design Principles

The system is designed around five principles:

| Principle | Meaning |
| --- | --- |
| Reliability first | A stable 24/7 system is more valuable than a heavily overprovisioned one |
| Low heat | Thermal headroom protects the CPU, SSD, fan, and battery |
| Minimal exposure | No public port forwarding is required for remote access |
| Scriptable setup | Host configuration should be repeatable with PowerShell |
| Documentation-first | Every operational decision should be captured in this repository |

This kit is not trying to replace a rack server. It is a compact learning and development environment that can run useful services with low power usage.

## Reference Architecture

```text
Remote Device
    |
    | Tailscale Mesh VPN
    v
Windows 11 Pro Host
    |
    | Hyper-V Internal Switch + NAT
    v
Ubuntu Server VM
    |
    | Docker Engine + Docker Compose
    v
Application Containers
```

## Component Responsibilities

| Component | Responsibility |
| --- | --- |
| Windows 11 Pro | Host OS, power management, drivers, Hyper-V, firewall, Tailscale |
| Hyper-V | VM lifecycle, CPU allocation, memory allocation, virtual switch, VHDX storage |
| Internal Switch | Private virtual network for lab VMs |
| Windows NAT | Internet access for VMs without exposing them directly to the home LAN |
| Ubuntu Server VM | Main Linux environment for Docker and infrastructure services |
| Docker Engine | Runs application and utility containers |
| Tailscale | Secure remote access to the host and optionally the VM subnet |

The Windows host should stay boring. It should run Hyper-V, Tailscale, monitoring tools, and administrative scripts. Application workloads should run inside the Ubuntu VM unless there is a strong reason to do otherwise.

## Network Architecture

The system uses three network layers:

| Layer | Example | Purpose |
| --- | --- | --- |
| Home LAN | `192.168.1.0/24` | Normal home router network |
| Hyper-V lab network | `192.168.100.0/24` | Private VM network behind Windows NAT |
| Tailscale network | `100.64.0.0/10` | Secure remote access overlay |

The lab network is intentionally isolated from the home LAN.

```text
Home Router
    |
    | Wi-Fi or Ethernet
    v
Windows Host
    |
    | vEthernet (LabInternal) - 192.168.100.1
    v
Hyper-V Internal Switch
    |
    v
Ubuntu VM - 192.168.100.10
```

VMs can reach the internet through Windows NAT, but devices on the home LAN cannot automatically reach the VMs. This makes the default setup safer and easier to reason about.

## Remote Access Model

Remote access is provided by Tailscale instead of public port forwarding.

```text
Laptop / Phone / Remote PC
    |
    | Tailscale
    v
Windows Host
    |
    | Optional subnet route
    v
Hyper-V Lab Network
```

For v1.0, there are two supported access patterns:

| Pattern | Description | Recommended For |
| --- | --- | --- |
| Host access | Connect to the Windows host through its Tailscale IP | RDP, administration, Hyper-V Manager |
| Subnet router | Advertise `192.168.100.0/24` through the Windows host | Direct SSH/RDP to VMs over Tailscale |

Do not expose RDP, SSH, or application ports directly from the home router to the internet. Tailscale is the remote access boundary.

## Workload Model

The v1.0 system is optimized for light to medium home lab workloads:

| Workload | Fit | Notes |
| --- | --- | --- |
| Docker Compose services | Good | Main target workload |
| Nginx reverse proxy | Good | Useful for local service routing |
| PostgreSQL for development | Good | Keep data size reasonable |
| Redis | Good | Lightweight |
| Node.js APIs | Good | Good fit for this host |
| GitHub Actions runner | Possible | Use with limits |
| Windows VM for testing | Possible | Run only when needed |
| Multi-node Kubernetes | Not recommended | Too much CPU/RAM overhead for v1.0 |
| Elasticsearch/Kafka clusters | Not recommended | Too heavy for this hardware |

The default architecture uses one main Ubuntu VM rather than many small VMs. This reduces RAM overhead, VHDX sprawl, backup complexity, and CPU contention.

## Resource Plan

| Resource | Host Reserve | Ubuntu VM | Optional Windows VM |
| --- | ---: | ---: | ---: |
| CPU | Shared | 2 vCPU | 2 vCPU |
| RAM | 6 GB minimum | 2 GB startup / 6 GB max | 4 GB startup / 8 GB max |
| Disk | 50 GB free target | 100 GB dynamic VHDX | 120 GB dynamic VHDX |

Do not interpret dynamic VHDX size as free capacity. The host SSD still needs real free space. If the host SSD reaches 90-95% usage, VM performance and reliability can degrade quickly.

## Security Boundaries

The system relies on layered boundaries:

| Boundary | Protection |
| --- | --- |
| Hyper-V Internal Switch | Keeps VMs off the home LAN by default |
| Windows NAT | Allows outbound VM internet access without inbound LAN exposure |
| Windows Defender Firewall | Controls host access such as RDP |
| Tailscale | Provides identity-based remote access |
| Ubuntu firewall | Optional extra control for VM services |
| Docker networks | Separates container traffic where needed |

The most important rule is simple:

> Do not use router port forwarding for this v1.0 deployment.

If a service must be accessed remotely, expose it through Tailscale or a deliberately designed reverse proxy later.

## Operational Model

The host is expected to run continuously with occasional planned maintenance.

| Area | Expected Practice |
| --- | --- |
| Windows Update | Controlled restart window |
| VM startup | Automatic start after host boot |
| VM shutdown | Save state or graceful shutdown |
| Backup | Weekly VM export or selected data backup |
| Monitoring | Check CPU, RAM, SSD, and temperature regularly |
| Cooling | Clean dust filter monthly |
| Battery | Keep charge threshold around 45-50% |

The system should be simple enough that a full rebuild is possible from this repository, the Windows installer, and the Ubuntu ISO.

## Deployment Sequence

The remaining chapters follow this order:

1. Prepare hardware and cooling.
2. Optimize Windows host settings.
3. Enable Hyper-V.
4. Create the internal switch and NAT.
5. Create the Ubuntu Server VM.
6. Install Docker and baseline services.
7. Configure Tailscale remote access.
8. Add operations, backup, monitoring, and maintenance routines.

Do not skip the host optimization step. Sleep, hibernate, battery settings, and uncontrolled restarts are common causes of unreliable home lab behavior.

## Architecture Decisions

| Decision | Choice | Reason |
| --- | --- | --- |
| Host OS | Windows 11 Pro | Best hardware support for the ThinkPad and built-in Hyper-V |
| Virtualization | Hyper-V | Native to Windows Pro and scriptable with PowerShell |
| VM network | Internal Switch + NAT | Safer than attaching VMs directly to the home LAN |
| Main workload OS | Ubuntu Server LTS | Stable, common, and well-supported for Docker |
| Container runtime | Docker Engine | Simple and widely documented |
| Remote access | Tailscale | Avoids public inbound ports and DDNS complexity |
| Documentation format | Markdown | Easy to version, review, and convert to PDF |
| Automation | PowerShell | Native to Windows host administration |

## Success Criteria

The v1.0 deployment is successful when:

- The Windows host runs without sleeping when the lid is closed.
- Hyper-V is installed and stable.
- The Ubuntu VM can reach the internet through NAT.
- Remote access works through Tailscale.
- No router port forwarding is required.
- Docker services run inside the Ubuntu VM.
- The host keeps enough RAM and SSD free space.
- The deployment steps are documented and repeatable from this repository.

## Chapter Checklist

- [ ] Understand the high-level architecture.
- [ ] Confirm the home LAN and lab subnet do not overlap.
- [ ] Accept the one-main-Ubuntu-VM design for v1.0.
- [ ] Confirm Tailscale is the remote access method.
- [ ] Avoid public router port forwarding.
- [ ] Keep Windows host responsibilities minimal.

## Exit Criteria

Before moving to Windows host optimization, confirm:

- The target host is Windows 11 Pro.
- The machine has at least 32 GB RAM.
- The lab subnet is planned as `192.168.100.0/24` or another non-overlapping private subnet.
- You understand that Docker will run inside Ubuntu Server, not directly as a separate VM layer.
- You accept that reliability and maintainability are prioritized over maximum VM count.

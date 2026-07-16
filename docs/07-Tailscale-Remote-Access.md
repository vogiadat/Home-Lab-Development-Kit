# Chapter 07 - Tailscale Remote Access

## Goal

This chapter configures secure remote access to the Windows host and the Hyper-V lab network without router port forwarding.

Tailscale is the remote access boundary for v1.0. RDP, SSH, and lab services should be accessed through Tailscale instead of public inbound ports.

## Target Design

Diagram source: [`../diagrams/tailscale-subnet-router.mmd`](../diagrams/tailscale-subnet-router.mmd)

![Tailscale subnet router architecture](assets/images/tailscale-subnet-router.svg)

```text
Remote device
  -> Tailscale mesh
    -> Windows host
      -> Optional subnet route
        -> Hyper-V lab network 192.168.100.0/24
```

## Access Patterns

| Pattern | Description | Use When |
| --- | --- | --- |
| Host access | Connect to the Windows host through its Tailscale IP | RDP, Hyper-V Manager, host administration |
| VM direct access | Install Tailscale inside Ubuntu | Simple single-VM access |
| Subnet router | Advertise `192.168.100.0/24` from Windows host | Access multiple VMs without installing Tailscale everywhere |

For v1.0, host access is required. Subnet routing is recommended once the lab VM network is stable.

## Install Tailscale on Windows

Install Tailscale from the official Windows installer.

After installation, sign in and confirm the host appears in the Tailscale admin console.

Verify from PowerShell:

```powershell
tailscale status
tailscale ip -4
```

Expected result:

- The host has a `100.x.y.z` Tailscale IP.
- Other devices in the tailnet are visible.

## Remote Desktop Firewall Policy

RDP should be reachable only through Tailscale.

Tailscale uses:

```text
100.64.0.0/10
```

The repository includes a PowerShell module that scopes Remote Desktop firewall rules to that range:

```powershell
.\scripts\Deploy.ps1 -Stage Tailscale -EnableRemoteDesktop
```

This stage does not install Tailscale. It configures the Windows firewall and prints the subnet router command to run after Tailscale is installed.

Do not forward TCP 3389 from the home router.

## Advertise the Hyper-V Lab Subnet

To make the Hyper-V lab network reachable from remote Tailscale devices, advertise the lab subnet from the Windows host.

PowerShell as Administrator:

```powershell
tailscale up --advertise-routes=192.168.100.0/24
```

Then approve the route in the Tailscale admin console:

```text
Machines
  -> LAB-HOST
  -> Subnet routes
  -> Enable 192.168.100.0/24
```

After approval, remote devices can route to:

```text
192.168.100.10
```

if firewall and VM networking allow it.

## SSH to Ubuntu Over Tailscale Subnet Route

From a remote Tailscale device:

```bash
ssh <ubuntu-user>@192.168.100.10
```

If this fails:

1. Confirm Tailscale route is approved.
2. Confirm the Windows host is online in Tailscale.
3. Confirm Ubuntu can ping `192.168.100.1`.
4. Confirm remote device has accepted routes.
5. Confirm Ubuntu firewall allows SSH.

On some clients, accepting subnet routes must be enabled manually.

## Alternative: Install Tailscale Inside Ubuntu

For a simpler first test, install Tailscale directly in Ubuntu:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

This gives Ubuntu its own Tailscale IP.

Use this when:

- You only need access to one VM.
- You want a quick validation.
- You do not want to configure subnet routing yet.

Use Windows subnet routing when:

- You want access to multiple VMs.
- You want a central route into `192.168.100.0/24`.
- You do not want to install Tailscale in every VM.

## MagicDNS

Enable MagicDNS in the Tailscale admin console if you want friendly names instead of IP addresses.

Example:

```text
lab-host.tailnet-name.ts.net
```

MagicDNS is useful for the Windows host. For VMs behind subnet routing, static lab IPs are still the clearest v1.0 approach.

## Exit Node

An exit node routes all internet traffic through a Tailscale machine.

This is not required for the Home Lab Development Kit v1.0.

Do not enable the Windows host as an exit node unless you have a clear reason. Subnet routing is enough for accessing the lab network.

## Verification Commands

Windows host:

```powershell
tailscale status
tailscale ip -4
Get-NetFirewallRule -DisplayGroup "Remote Desktop" |
    Get-NetFirewallAddressFilter
```

Remote device:

```bash
tailscale status
ping <windows-host-tailscale-ip>
ssh <ubuntu-user>@192.168.100.10
```

Ubuntu VM:

```bash
ip addr
ip route
systemctl status ssh
```

## Common Mistakes

| Mistake | Impact |
| --- | --- |
| Port forwarding RDP on the home router | Exposes a high-risk service to the internet |
| Advertising subnet route but not approving it | Remote clients cannot reach VM subnet |
| Forgetting client-side route acceptance | Route exists but client does not use it |
| Using overlapping home and lab subnets | Routing becomes ambiguous |
| Enabling exit node without need | Adds complexity and changes internet routing |
| Leaving RDP firewall open to any address | Larger attack surface |

## Verification Checklist

- [ ] Tailscale is installed on Windows.
- [ ] Windows host appears online in Tailscale admin console.
- [ ] Windows host has a Tailscale IP.
- [ ] RDP firewall scope is limited to `100.64.0.0/10` if RDP is enabled.
- [ ] No router port forwarding is used for RDP or SSH.
- [ ] Subnet route `192.168.100.0/24` is advertised if needed.
- [ ] Subnet route is approved in admin console.
- [ ] Remote device can reach the Windows host.
- [ ] Remote device can reach Ubuntu over SSH when subnet routing is enabled.

## Exit Criteria

Before moving to Operations and Maintenance:

- You can remotely reach the Windows host over Tailscale.
- RDP is not exposed outside Tailscale.
- You understand whether you are using direct VM Tailscale or Windows subnet routing.
- SSH access to Ubuntu works through the chosen remote access path.

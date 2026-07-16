[CmdletBinding()]
param(
    [string]$TailscaleCIDR = '100.64.0.0/10'
)

$ErrorActionPreference = 'Stop'

Write-Host "Restricting Remote Desktop firewall rules to $TailscaleCIDR..."

$Rules = Get-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue

if (-not $Rules) {
    throw 'Remote Desktop firewall rules were not found.'
}

$Rules | Set-NetFirewallRule -Enabled True

$Rules |
    Get-NetFirewallAddressFilter |
    Set-NetFirewallAddressFilter -RemoteAddress $TailscaleCIDR

Write-Host 'Remote Desktop firewall scope updated.'

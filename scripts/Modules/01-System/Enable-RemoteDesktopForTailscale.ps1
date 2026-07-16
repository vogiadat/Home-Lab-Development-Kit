[CmdletBinding()]
param(
    [string]$TailscaleCIDR = '100.64.0.0/10'
)

$ErrorActionPreference = 'Stop'

Write-Host 'Enabling Remote Desktop...'

Set-ItemProperty `
    -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
    -Name 'fDenyTSConnections' `
    -Value 0

Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'

Get-NetFirewallRule -DisplayGroup 'Remote Desktop' |
    Set-NetFirewallRule -Enabled True

Get-NetFirewallRule -DisplayGroup 'Remote Desktop' |
    Get-NetFirewallAddressFilter |
    Set-NetFirewallAddressFilter -RemoteAddress $TailscaleCIDR

Write-Host "Remote Desktop enabled and scoped to $TailscaleCIDR."

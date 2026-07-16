[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [hashtable]$Config
)

$ErrorActionPreference = 'Stop'

Write-Host ''
Write-Host 'Run this command on the Windows host after Tailscale is installed and signed in:'
Write-Host ''
Write-Host "tailscale up --advertise-routes=$($Config.NATSubnet)"
Write-Host ''
Write-Host 'Then approve the route in the Tailscale admin console.'
Write-Host ''

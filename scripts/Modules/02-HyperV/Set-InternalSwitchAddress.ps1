[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [hashtable]$Config
)

$ErrorActionPreference = 'Stop'

$InterfaceAlias = "vEthernet ($($Config.SwitchName))"
$Adapter = Get-NetAdapter -Name $InterfaceAlias -ErrorAction SilentlyContinue

if (-not $Adapter) {
    throw "Network adapter not found: $InterfaceAlias. Create the Hyper-V switch first."
}

$ExistingAddress = Get-NetIPAddress `
    -InterfaceAlias $InterfaceAlias `
    -AddressFamily IPv4 `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -eq $Config.HostIP }

if ($ExistingAddress) {
    Write-Host "$InterfaceAlias already has $($Config.HostIP)."
    return
}

Write-Host "Assigning $($Config.HostIP)/$($Config.PrefixLength) to $InterfaceAlias"

New-NetIPAddress `
    -InterfaceAlias $InterfaceAlias `
    -IPAddress $Config.HostIP `
    -PrefixLength $Config.PrefixLength | Out-Null

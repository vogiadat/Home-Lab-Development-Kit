[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [hashtable]$Config
)

$ErrorActionPreference = 'Stop'

$ExistingNat = Get-NetNat -Name $Config.NATName -ErrorAction SilentlyContinue

if ($ExistingNat) {
    if ($ExistingNat.InternalIPInterfaceAddressPrefix -ne $Config.NATSubnet) {
        throw "NAT '$($Config.NATName)' already exists but uses '$($ExistingNat.InternalIPInterfaceAddressPrefix)', not '$($Config.NATSubnet)'."
    }

    Write-Host "NAT already exists: $($Config.NATName)"
    return
}

Write-Host "Creating NAT '$($Config.NATName)' for $($Config.NATSubnet)"

New-NetNat `
    -Name $Config.NATName `
    -InternalIPInterfaceAddressPrefix $Config.NATSubnet | Out-Null

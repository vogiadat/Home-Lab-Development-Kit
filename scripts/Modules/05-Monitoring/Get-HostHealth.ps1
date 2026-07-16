[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [hashtable]$Config
)

$ErrorActionPreference = 'Stop'

Write-Host '=== Host volumes ==='
Get-Volume |
    Select-Object DriveLetter, FileSystemLabel, SizeRemaining, Size |
    Format-Table -AutoSize

Write-Host '=== Hyper-V switches ==='
Get-VMSwitch | Format-Table Name, SwitchType, NetAdapterInterfaceDescription -AutoSize

Write-Host '=== NAT ==='
Get-NetNat -Name $Config.NATName -ErrorAction SilentlyContinue |
    Format-Table Name, InternalIPInterfaceAddressPrefix -AutoSize

Write-Host '=== Lab adapter ==='
Get-NetIPAddress -InterfaceAlias "vEthernet ($($Config.SwitchName))" -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Format-Table InterfaceAlias, IPAddress, PrefixLength -AutoSize

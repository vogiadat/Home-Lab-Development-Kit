[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [hashtable]$Config
)

$ErrorActionPreference = 'Stop'

$VMName = $Config.UbuntuVM.Name
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Destination = Join-Path $Config.BackupPath "$VMName-$Timestamp"

if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    throw "VM not found: $VMName"
}

if (-not (Test-Path -Path $Config.BackupPath)) {
    New-Item -Path $Config.BackupPath -ItemType Directory -Force | Out-Null
}

Write-Host "Exporting $VMName to $Destination"
Export-VM -Name $VMName -Path $Destination
Write-Host "VM export complete: $Destination"

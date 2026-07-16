[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

Write-Host '=== VM status ==='
Get-VM |
    Select-Object Name, State, CPUUsage, MemoryAssigned, Uptime, Status |
    Format-Table -AutoSize

Write-Host '=== VM storage ==='
Get-VMHardDiskDrive |
    Select-Object VMName, ControllerType, Path |
    Format-Table -AutoSize

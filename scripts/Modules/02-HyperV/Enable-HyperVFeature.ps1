[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$Feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

if ($Feature.State -eq 'Enabled') {
    Write-Host 'Hyper-V is already enabled.'
    return
}

Write-Host 'Enabling Hyper-V. A reboot is required before creating VMs.'
Enable-WindowsOptionalFeature `
    -Online `
    -FeatureName Microsoft-Hyper-V `
    -All `
    -NoRestart

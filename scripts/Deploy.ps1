[CmdletBinding()]
param(
    [ValidateSet('Check', 'System', 'HyperV', 'VM', 'Tailscale', 'Monitoring', 'Backup')]
    [string]$Stage = 'Check'
)

$ErrorActionPreference = 'Stop'

$ConfigPath = Join-Path $PSScriptRoot 'Config/HomeLab.config.psd1'
$Config = Import-PowerShellDataFile -Path $ConfigPath

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-Host "Home Lab Development Kit deployment stage: $Stage"
Write-Host "Target computer name: $($Config.ComputerName)"

if (-not (Test-IsAdministrator)) {
    Write-Warning 'Run PowerShell as Administrator for deployment stages that change host configuration.'
}

switch ($Stage) {
    'Check' {
        Write-Host 'Configuration loaded successfully.'
        Write-Host "Hyper-V switch: $($Config.SwitchName)"
        Write-Host "NAT subnet: $($Config.NATSubnet)"
    }
    default {
        Write-Warning "Stage '$Stage' is reserved for a future implementation sprint."
    }
}

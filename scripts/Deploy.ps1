[CmdletBinding()]
param(
    [ValidateSet('Check', 'System', 'HyperV', 'VM', 'Tailscale', 'Monitoring', 'Backup')]
    [string]$Stage = 'Check',

    [switch]$EnableRemoteDesktop
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

if ($Stage -ne 'Check' -and -not (Test-IsAdministrator)) {
    throw "Stage '$Stage' must be run from an elevated PowerShell session."
}

function Invoke-Script {
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath,

        [object[]]$ArgumentList = @()
    )

    $ScriptPath = Join-Path $PSScriptRoot $RelativePath

    if (-not (Test-Path -Path $ScriptPath)) {
        throw "Required script not found: $ScriptPath"
    }

    Write-Host "Running $RelativePath"
    & $ScriptPath @ArgumentList
}

switch ($Stage) {
    'Check' {
        Write-Host 'Configuration loaded successfully.'
        Write-Host "Hyper-V switch: $($Config.SwitchName)"
        Write-Host "NAT subnet: $($Config.NATSubnet)"
    }
    'System' {
        Invoke-Script -RelativePath 'Modules/01-System/Disable-Hibernate.ps1'
        Invoke-Script -RelativePath 'Modules/01-System/Set-LidAndSleepPolicy.ps1'
        Invoke-Script -RelativePath 'Modules/01-System/Set-ProcessorPolicy.ps1'

        if ($EnableRemoteDesktop) {
            Invoke-Script -RelativePath 'Modules/01-System/Enable-RemoteDesktopForTailscale.ps1'
        }
        else {
            Write-Host 'Remote Desktop was not enabled. Re-run with -EnableRemoteDesktop if needed.'
        }
    }
    'HyperV' {
        Invoke-Script -RelativePath 'Modules/02-HyperV/New-HyperVFolders.ps1' -ArgumentList @($Config)
        Invoke-Script -RelativePath 'Modules/02-HyperV/Enable-HyperVFeature.ps1'
        Invoke-Script -RelativePath 'Modules/02-HyperV/New-InternalSwitch.ps1' -ArgumentList @($Config)
        Invoke-Script -RelativePath 'Modules/02-HyperV/Set-InternalSwitchAddress.ps1' -ArgumentList @($Config)
        Invoke-Script -RelativePath 'Modules/02-HyperV/New-LabNat.ps1' -ArgumentList @($Config)
        Write-Warning 'If Hyper-V was just enabled for the first time, restart Windows before creating VMs.'
    }
    'VM' {
        Invoke-Script -RelativePath 'Modules/03-VM/New-UbuntuVM.ps1' -ArgumentList @($Config)
    }
    default {
        Write-Warning "Stage '$Stage' is reserved for a future implementation sprint."
    }
}

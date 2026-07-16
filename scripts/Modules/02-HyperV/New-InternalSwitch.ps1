[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [hashtable]$Config
)

$ErrorActionPreference = 'Stop'

$ExistingSwitch = Get-VMSwitch -Name $Config.SwitchName -ErrorAction SilentlyContinue

if ($ExistingSwitch) {
    if ($ExistingSwitch.SwitchType -ne 'Internal') {
        throw "Switch '$($Config.SwitchName)' already exists but is '$($ExistingSwitch.SwitchType)', not Internal."
    }

    Write-Host "Internal switch already exists: $($Config.SwitchName)"
    return
}

Write-Host "Creating internal switch: $($Config.SwitchName)"
New-VMSwitch -Name $Config.SwitchName -SwitchType Internal | Out-Null

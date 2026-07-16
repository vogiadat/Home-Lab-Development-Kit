[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [hashtable]$Config
)

$ErrorActionPreference = 'Stop'

$Paths = @(
    $Config.VMRoot,
    $Config.VHDPath,
    $Config.ISOPath,
    $Config.ExportPath,
    $Config.BackupPath
)

foreach ($Path in $Paths) {
    if (-not (Test-Path -Path $Path)) {
        Write-Host "Creating folder: $Path"
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
    else {
        Write-Host "Folder already exists: $Path"
    }
}

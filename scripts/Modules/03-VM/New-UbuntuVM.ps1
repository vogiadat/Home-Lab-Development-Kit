[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [hashtable]$Config
)

$ErrorActionPreference = 'Stop'

$VMConfig = $Config.UbuntuVM
$VMName = $VMConfig.Name
$VHDFile = Join-Path $Config.VHDPath $VMConfig.VHDName
$IsoPath = $VMConfig.IsoPath

if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
    Write-Host "VM already exists: $VMName"
    return
}

if (-not (Get-VMSwitch -Name $Config.SwitchName -ErrorAction SilentlyContinue)) {
    throw "Hyper-V switch not found: $($Config.SwitchName). Run .\Deploy.ps1 -Stage HyperV first."
}

if (-not (Test-Path -Path $IsoPath)) {
    throw "Ubuntu ISO not found: $IsoPath. Download Ubuntu Server ISO and update scripts/Config/HomeLab.config.psd1 if needed."
}

if (Test-Path -Path $VHDFile) {
    throw "VHDX already exists: $VHDFile. Remove or rename it before creating $VMName."
}

if (-not (Test-Path -Path $Config.VMRoot)) {
    New-Item -Path $Config.VMRoot -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path -Path $Config.VHDPath)) {
    New-Item -Path $Config.VHDPath -ItemType Directory -Force | Out-Null
}

Write-Host "Creating VM: $VMName"

New-VM `
    -Name $VMName `
    -Generation 2 `
    -MemoryStartupBytes $VMConfig.StartupMemory `
    -NewVHDPath $VHDFile `
    -NewVHDSizeBytes $VMConfig.VHDSize `
    -SwitchName $Config.SwitchName `
    -Path $Config.VMRoot | Out-Null

Set-VMProcessor -VMName $VMName -Count $VMConfig.VCPU

Set-VMMemory `
    -VMName $VMName `
    -DynamicMemoryEnabled $true `
    -MinimumBytes $VMConfig.MinimumMemory `
    -StartupBytes $VMConfig.StartupMemory `
    -MaximumBytes $VMConfig.MaximumMemory

Set-VMFirmware `
    -VMName $VMName `
    -EnableSecureBoot On `
    -SecureBootTemplate 'MicrosoftUEFICertificateAuthority'

Add-VMDvdDrive -VMName $VMName -Path $IsoPath

$DVDDrive = Get-VMDvdDrive -VMName $VMName
$HardDrive = Get-VMHardDiskDrive -VMName $VMName

Set-VMFirmware `
    -VMName $VMName `
    -FirstBootDevice $DVDDrive `
    -BootOrder $DVDDrive, $HardDrive

Write-Host "Ubuntu VM created: $VMName"
Write-Host "Start it with: Start-VM -Name $VMName"

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

Write-Host 'Disabling hibernate...'
powercfg /hibernate off
Write-Host 'Hibernate disabled.'

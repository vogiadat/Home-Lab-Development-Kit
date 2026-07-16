[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

Write-Host 'Configuring AC sleep and lid-close policy...'

powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-ac 0
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
powercfg /setactive SCHEME_CURRENT

Write-Host 'AC sleep disabled and lid-close action set to do nothing.'

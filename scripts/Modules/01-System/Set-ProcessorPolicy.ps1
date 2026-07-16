[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

Write-Host 'Configuring processor policy for cooler 24/7 operation...'

powercfg -attributes SUB_PROCESSOR PERFBOOSTMODE -ATTRIB_HIDE
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 0
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 99
powercfg /setactive SCHEME_CURRENT

Write-Host 'Processor boost disabled and maximum processor state set to 99% on AC power.'

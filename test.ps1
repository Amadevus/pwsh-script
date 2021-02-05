[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $CI = ($env:CI -eq 'true')
)

if (Get-Module Pester | ? Version -LT '5.1') {
    Install-Module -Name Pester -Force -SkipPublisherCheck -MinimumVersion '5.1' -PassThru
        | Import-Module Pester -MinimumVersion '5.1'
}
Invoke-Pester -CI:$CI
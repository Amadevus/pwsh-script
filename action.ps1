#!/usr/bin/env pwsh

Import-Module $PSScriptRoot/lib/GitHubActionsCore

function Private:CreateContext($name) {
    $varName = "PWSH_SCRIPT_ACTION_$($name.ToUpper())"
    $value = (Get-ChildItem "Env:$varName").Value
    $ctx = $value | ConvertFrom-Json -AsHashtable -NoEnumerate
    Set-Variable -Name $name -Value $ctx -Scope Script -Option Constant
}

Private:CreateContext github
Private:CreateContext job
Private:CreateContext runner
Private:CreateContext strategy
Private:CreateContext matrix

try {
    $Private:scriptFile = New-Item $env:TEMP "$(New-Guid).ps1" -ItemType File
    Set-Content $Private:scriptFile "$env:PWSH_SCRIPT_ACTION_TEXT"
    $Private:result = Invoke-Expression $Private:scriptFile
    Set-ActionOutput 'result' $Private:result
}
catch {
    Set-ActionOutput 'error' $_.ToString()
    $ErrorView = 'NormalView'
    Set-ActionFailed ($_ | Out-String)
}
exit [System.Environment]::ExitCode
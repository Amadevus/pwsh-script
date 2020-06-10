#!/usr/bin/env pwsh

Import-Module $PSScriptRoot/lib/GitHubActionsCore

function CreateContext($name) {
    $ctx = Get-ActionInput $name | ConvertFrom-Json -AsHashtable -NoEnumerate
    Set-Variable -Name $name -Value $ctx -Scope Script -Option Constant
}

CreateContext github
CreateContext job
CreateContext runner
CreateContext strategy
CreateContext matrix

Remove-Item Function:CreateContext

try {
    $result = Invoke-Expression "$(Get-ActionInput 'script' -Required)"
    Set-ActionOutput 'result' $result
}
catch {
    Set-ActionOutput 'error' $_.ToString()
    $ErrorView = 'NormalView'
    Set-ActionFailed ($_ | Out-String)
}
exit [System.Environment]::ExitCode
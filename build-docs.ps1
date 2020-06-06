#!/usr/bin/env pwsh

$cmd = {
    $core = Import-Module ./lib/GitHubActionsCore -PassThru -Scope Local -Force

    $docsPath = 'docs/GitHubActionsCore'
    if (-not (Test-Path $docsPath)) { mkdir $docsPath | Out-Null }
    Write-Output "| Cmdlet | Synopsis |" > $docsPath/README.md
    Write-Output "|-|-|"                >> $docsPath/README.md
    $core.ExportedCommands.Values | ForEach-Object {
        Get-Help $_.Name | Select-Object @{
            Name       = "Row"
            Expression = {
                $n = $_.Name.Trim()
                $s = $_.Synopsis.Trim() -replace '\r?\n', ' '
                "| [$($n)]($($n).md) | $($s) |"
            }
        }
    } | Select-Object -Expand Row  >> $docsPath/README.md
    $core.ExportedCommands.Values | ForEach-Object {
        Get-Help -Full $_.Name | Select-Object @{
            Name       = "Row"
            Expression = {
                $n = $_.Name.Trim()
                "# $n"
                "``````"
                $_
                "``````"
            }
        } | Select-Object -Expand Row  > "$docsPath/$($_.Name).md"
    }
}
pwsh -c $cmd -wd $PSScriptRoot
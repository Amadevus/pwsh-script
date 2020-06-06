#!/usr/bin/env pwsh

$cmd = {
    if (-not (Test-Path node_modules -PathType Container))
    {
        npm install
    }
    npx '@zeit/ncc' build ./invoke-pwsh.js --out dist --minify --no-source-map-register
}
pwsh -c $cmd -wd $PSScriptRoot
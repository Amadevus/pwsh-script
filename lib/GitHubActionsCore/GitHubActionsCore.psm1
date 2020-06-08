#!/usr/bin/env pwsh

## Adapted from:
##    https://github.com/ebekker/pwsh-github-action-base/blob/b19583aaecd66696896e9b7dbc9f419e2fca458b/lib/ActionsCore.ps1
## 
## which in turn was adapted from:
##    https://github.com/actions/toolkit/blob/c65fe87e339d3dd203274c62d0f36f405d78e8a0/packages/core/src/core.ts

<#
.SYNOPSIS
Sets env variable for this action and future actions in the job.
Equivalent of `core.exportVariable(name, value)`.
.PARAMETER Name
The name of the variable to set.
.PARAMETER Value
The value of the variable. Non-string values will be converted to a string via ConvertTo-Json.
.PARAMETER SkipLocal
Do not set variable in current action's/step's environment.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#setting-an-environment-variable
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#exporting-variables
#>
function Set-ActionVariable {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Position = 1, Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$Value,
        
        [switch]$SkipLocal
    )
    $convertedValue = ConvertTo-ActionCommandValue $Value
    ## To take effect only in the current action/step
    if (-not $SkipLocal) {
        [System.Environment]::SetEnvironmentVariable($Name, $convertedValue)
    }

    ## To take effect for all subsequent actions/steps
    Send-ActionCommand set-env @{
        name = $Name
    } -Message $convertedValue
}

<#
.SYNOPSIS
Registers a secret which will get masked from logs.
Equivalent of `core.setSecret(secret)`.
.PARAMETER Secret
The value of the secret.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#masking-a-value-in-log
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#setting-a-secret
#>
function Add-ActionSecret {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Secret
    )

    Send-ActionCommand add-mask $Secret
}

<#
.SYNOPSIS
Prepends path to the PATH (for this action and future actions).
Equivalent of `core.addPath(path)`.
.PARAMETER Path
The new path to add.
.PARAMETER SkipLocal
Do not prepend path to current action's/step's environment PATH.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#adding-a-system-path
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#path-manipulation
#>
function Add-ActionPath {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        
        [switch]$SkipLocal
    )

    ## To take effect only in the current action/step
    if (-not $SkipLocal) {
        $oldPath = [System.Environment]::GetEnvironmentVariable('PATH')
        $newPath = "$Path$([System.IO.Path]::PathSeparator)$oldPath"
        [System.Environment]::SetEnvironmentVariable('PATH', $newPath)
    }

    ## To take effect for all subsequent actions/steps
    Send-ActionCommand add-path $Path
}

## Used to identify inputs from env vars in Action/Workflow context
if (-not (Get-Variable -Scope Script -Name INPUT_PREFIX -ErrorAction SilentlyContinue)) {
    Set-Variable -Scope Script -Option Constant -Name INPUT_PREFIX -Value 'INPUT_'
}

<#
.SYNOPSIS
Gets the value of an input. The value is also trimmed.
Equivalent of `core.getInput(name)`.
.PARAMETER Name
Name of the input to get
.PARAMETER Required
Whether the input is required. If required and not present, will throw.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#masking-a-value-in-log
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#inputsoutputs
#>
function Get-ActionInput {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [switch]$Required
    )
    
    $cleanName = ($Name -replace ' ', '_').ToUpper()
    $inputValue = Get-ChildItem "Env:$($INPUT_PREFIX)$($cleanName)" -ErrorAction SilentlyContinue
    if ($Required -and (-not $inputValue)) {
        throw "Input required and not supplied: $($Name)"
    }

    return "$($inputValue.Value)".Trim()
}

<#
.SYNOPSIS
Sets the value of an output.
Equivalent of `core.setOutput(name, value)`.
.PARAMETER Name
Name of the output to set.
.PARAMETER Value
Value to store. Non-string values will be converted to a string via ConvertTo-Json.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#setting-an-output-parameter
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#inputsoutputs
#>
function Set-ActionOutput {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Position = 1, Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$Value
    )

    Send-ActionCommand set-output @{
        name = $Name
    } -Message (ConvertTo-ActionCommandValue $Value)
}

<#
.SYNOPSIS
Enables or disables the echoing of commands into stdout for the rest of the step.
Echoing is disabled by default if ACTIONS_STEP_DEBUG is not set.
Equivalent of `core.setCommandEcho(enabled)`.
.PARAMETER Enabled
$true to enable echoing, $false to disable.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#masking-a-value-in-log
#>#
function Set-ActionCommandEcho {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [bool]$Enabled
    )

    Send-ActionCommand echo ($Enabled ? 'on' : 'off')
}

<#
.SYNOPSIS
Sets an action status to failed.
When the action exits it will be with an exit code of 1.
Equivalent of `core.setFailed(message)`.
.PARAMETER Message
Add issue message.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#masking-a-value-in-log
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#exit-codes
#>
function Set-ActionFailed {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Message = ""
    )
    [System.Environment]::ExitCode = 1
    Write-ActionError $Message
}

<#
.SYNOPSIS
Gets whether Actions Step Debug is on or not.
Equivalent of `core.isDebug()`.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#logging
#>
function Get-ActionIsDebug {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    return '1' -eq (Get-Item Env:RUNNER_DEBUG -ErrorAction SilentlyContinue).Value
}

<#
.SYNOPSIS
Writes debug message to user log.
Equivalent of `core.debug(message)`.
.PARAMETER Message
Debug message.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#setting-a-debug-message
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#logging
 #>
function Write-ActionDebug {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Message = ""
    )

    Send-ActionCommand debug $Message
}

<#
.SYNOPSIS
Adds an error issue.
Equivalent of `core.error(message)`.
.PARAMETER Message
Error issue message.
.PARAMETER File
Filename where the issue occured.
.PARAMETER Line
Line number of the File where the issue occured.
.PARAMETER Column
Column number in Line in File where the issue occured.
.NOTES
File, Line and Column parameters are supported by the actual workflow command,
but not available in `@actions/core` package.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#setting-an-error-message
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#logging
 #>
function Write-ActionError {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ParameterSetName = 'MsgOnly')]
        [Parameter(Position = 0, ParameterSetName = 'File')]
        [Parameter(Position = 0, ParameterSetName = 'Line')]
        [Parameter(Position = 0, ParameterSetName = 'Column')]
        [string]$Message = "",

        [Parameter(Position = 1, ParameterSetName = 'File', Mandatory)]
        [Parameter(Position = 1, ParameterSetName = 'Line', Mandatory)]
        [Parameter(Position = 1, ParameterSetName = 'Column', Mandatory)]
        [string]$File,

        [Parameter(Position = 2, ParameterSetName = 'Line', Mandatory)]
        [Parameter(Position = 2, ParameterSetName = 'Column', Mandatory)]
        [int]$Line,

        [Parameter(Position = 3, ParameterSetName = 'Column', Mandatory)]
        [int]$Column
    )
    $params = [ordered]@{ }
    if ($File) {
        $params['file'] = $File
    }
    if ($PSCmdlet.ParameterSetName -in 'Column', 'Line') {
        $params['line'] = $Line
    }
    if ($PSCmdlet.ParameterSetName -eq 'Column') {
        $params['col'] = $Column
    }
    Send-ActionCommand error $params -Message $Message
}

<#
.SYNOPSIS
Adds a warning issue.
Equivalent of `core.warning(message)`.
.PARAMETER Message
Warning issue message.
.PARAMETER File
Filename where the issue occured.
.PARAMETER Line
Line number of the File where the issue occured.
.PARAMETER Column
Column number in Line in File where the issue occured.
.NOTES
File, Line and Column parameters are supported by the actual workflow command,
but not available in `@actions/core` package.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#setting-a-warning-message
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#logging
 #>
function Write-ActionWarning {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ParameterSetName = 'MsgOnly')]
        [Parameter(Position = 0, ParameterSetName = 'File')]
        [Parameter(Position = 0, ParameterSetName = 'Line')]
        [Parameter(Position = 0, ParameterSetName = 'Column')]
        [string]$Message = "",

        [Parameter(Position = 1, ParameterSetName = 'File', Mandatory)]
        [Parameter(Position = 1, ParameterSetName = 'Line', Mandatory)]
        [Parameter(Position = 1, ParameterSetName = 'Column', Mandatory)]
        [string]$File,

        [Parameter(Position = 2, ParameterSetName = 'Line', Mandatory)]
        [Parameter(Position = 2, ParameterSetName = 'Column', Mandatory)]
        [int]$Line,

        [Parameter(Position = 3, ParameterSetName = 'Column', Mandatory)]
        [int]$Column
    )
    $params = [ordered]@{ }
    if ($File) {
        $params['file'] = $File
    }
    if ($PSCmdlet.ParameterSetName -in 'Column', 'Line') {
        $params['line'] = $Line
    }
    if ($PSCmdlet.ParameterSetName -eq 'Column') {
        $params['col'] = $Column
    }
    Send-ActionCommand warning $params -Message $Message
}

<#
.SYNOPSIS
Writes info to log with console.log.
Equivalent of `core.info(message)`.
Forwards to Write-Host.
.PARAMETER Message
Info message.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#masking-a-value-in-log
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#logging
 #>
function Write-ActionInfo {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Message = ""
    )

    Write-Host "$($Message)"
}

<#
.SYNOPSIS
Begin an output group.
Output until the next `groupEnd` will be foldable in this group.
Equivalent of `core.startGroup(name)`.
.DESCRIPTION
Output until the next `groupEnd` will be foldable in this group.
.PARAMETER Name
The name of the output group.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#masking-a-value-in-log
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#logging
 #>
function Enter-ActionOutputGroup {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    Send-ActionCommand group $Name
}

<#
.SYNOPSIS
End an output group.
Equivalent of `core.endGroup()`.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#masking-a-value-in-log
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#logging
 #>
function Exit-ActionOutputGroup {
    [CmdletBinding()]
    param()
    Send-ActionCommand endgroup
}

<#
.SYNOPSIS
Executes the argument script block within an output group.
Equivalent of `core.group(name, func)`.
.PARAMETER Name
Name of the output group.
.PARAMETER ScriptBlock
Script block to execute in between opening and closing output group.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#masking-a-value-in-log
.LINK
https://github.com/actions/toolkit/tree/master/packages/core#logging
#>
function Invoke-ActionGroup {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Position = 1, Mandatory)]
        [scriptblock]$ScriptBlock
    )

    Enter-ActionOutputGroup -Name $Name
    try {
        return $ScriptBlock.Invoke()
    }
    finally {
        Exit-ActionOutputGroup
    }
}
<#
.SYNOPSIS
Invokes a scriptblock that won't result in any output interpreted as a workflow command.
Useful for printing arbitrary text that may contain command-like text.
No quivalent in `@actions/core` package.
.PARAMETER EndToken
String token to stop workflow commands, used after scriptblock to start workflow commands back.
.PARAMETER ScriptBlock
Script block to invoke within a no-commands context.
.PARAMETER GenerateToken
Use this to automatically generate a GUID and use it as the EndToken.
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#stopping-and-starting-workflow-commands
#>
function Invoke-ActionNoCommandsBlock {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ParameterSetName = 'SetToken', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$EndToken,

        [Parameter(Position = 1, ParameterSetName = 'SetToken', Mandatory)]
        [Parameter(Position = 0, ParameterSetName = 'GenToken', Mandatory)]
        [scriptblock]$ScriptBlock,

        [Parameter(ParameterSetName = 'GenToken', Mandatory)]
        [switch]$GenerateToken
    )
    $tokenValue = $GenerateToken ? [System.Guid]::NewGuid().ToString() : $EndToken
    Send-ActionCommand stop-commands $tokenValue
    try {
        return $ScriptBlock.Invoke()
    }
    finally {
        Send-ActionCommand $tokenValue
    }
}

## Used to signal output that is a command to Action/Workflow context
if (-not (Get-Variable -Scope Script -Name CMD_STRING -ErrorAction SilentlyContinue)) {
    Set-Variable -Scope Script -Option Constant -Name CMD_STRING -Value '::'
}

<#
.SYNOPSIS
Sends a command to the hosting Workflow/Action context.
Equivalent to `core.issue(cmd, msg)`/`core.issueCommand(cmd, props, msg)`.
.DESCRIPTION
Command Format:
  ::workflow-command parameter1={data},parameter2={data}::{command value}

.EXAMPLE
PS> Send-ActionCommand warning 'This is the user warning message'
::warning::This is the user warning message
.EXAMPLE
PS> Send-ActionCommand set-secret @{name='mypassword'} 'definitelyNotAPassword!'
::set-secret name=mypassword::definitelyNotAPassword!
.LINK
https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#about-workflow-commands
#>
function Send-ActionCommand {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Command,

        [Parameter(ParameterSetName = "WithProps", Position = 1, Mandatory)]
        [hashtable]$Properties,

        [Parameter(ParameterSetName = "WithProps", Position = 2)]
        [Parameter(ParameterSetName = "SkipProps", Position = 1)]
        [string]$Message = ''
    )

    $cmdStr = ConvertTo-ActionCommandString $Command $Properties $Message
    Write-Host $cmdStr
}

###########################################################################
## Internal Implementation
###########################################################################

<#
.SYNOPSIS
Convert command, properties and message into a single-line workflow command.
.PARAMETER Command
The workflow command name.
.PARAMETER Properties
Properties to add to the command.
.PARAMETER Message
Message to add to the command.
#>
function ConvertTo-ActionCommandString {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0, Mandatory)]
        [string]$Command,

        [Parameter(Position = 1)]
        [hashtable]$Properties,

        [Parameter(Position = 2)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$Message
    )

    if (-not $Command) {
        $Command = 'missing.command'
    }

    $cmdStr = "$($CMD_STRING)$($Command)"
    if ($Properties.Count -gt 0) {
        $first = $true
        foreach ($key in $Properties.Keys) {
            $val = ConvertTo-ActionEscapedProperty $Properties[$key]
            if ($val) {
                if ($first) {
                    $first = $false
                    $cmdStr += ' '
                }
                else {
                    $cmdStr += ','
                }
                $cmdStr += "$($key)=$($val)"
            }
        }
    }
    $cmdStr += $CMD_STRING
    $cmdStr += ConvertTo-ActionEscapedData $Message

    return $cmdStr
}

<#
.SYNOPSIS
Sanitizes an input into a string so it can be passed into issueCommand safely.
Equivalent of `core.toCommandValue(input)`.
.PARAMETER Value
Input to sanitize into a string.
#>
function ConvertTo-ActionCommandValue {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$Value
    )
    if ($null -eq $Value) {
        return ''
    }
    if ($Value -is [string]) {
        return $Value
    }
    return ConvertTo-Json $Value -Depth 100 -Compress -EscapeHandling EscapeNonAscii
}

## Escaping based on https://github.com/actions/toolkit/blob/3e40dd39cc56303a2451f5b175068dbefdc11c18/packages/core/src/command.ts#L92-L105
function ConvertTo-ActionEscapedData {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$Value
    )
    return (ConvertTo-ActionCommandValue $Value).
    Replace("%", '%25').
    Replace("`r", '%0D').
    Replace("`n", '%0A')
}

function ConvertTo-ActionEscapedProperty {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$Value
    )
    return (ConvertTo-ActionCommandValue $Value).
    Replace("%", '%25').
    Replace("`r", '%0D').
    Replace("`n", '%0A').
    Replace(':', '%3A').
    Replace(',', '%2C')
}

Export-ModuleMember `
    Add-ActionPath,
Add-ActionSecret,
Enter-ActionOutputGroup,
Exit-ActionOutputGroup,
Get-ActionInput,
Get-ActionInputs,
Get-ActionIsDebug,
Invoke-ActionGroup,
Invoke-ActionNoCommandsBlock,
Send-ActionCommand,
Set-ActionCommandEcho,
Set-ActionFailed,
Set-ActionOutput,
Set-ActionVariable,
Write-ActionDebug,
Write-ActionError,
Write-ActionInfo,
Write-ActionWarning

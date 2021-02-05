| Cmdlet | Synopsis |
|-|-|
| [Add-ActionPath](Add-ActionPath.md) | Prepends path to the PATH (for this action and future actions). Equivalent of `core.addPath(path)`. |
| [Add-ActionSecret](Add-ActionSecret.md) | Registers a secret which will get masked from logs. Equivalent of `core.setSecret(secret)`. |
| [Enter-ActionOutputGroup](Enter-ActionOutputGroup.md) | Begin an output group. Output until the next `groupEnd` will be foldable in this group. Equivalent of `core.startGroup(name)`. |
| [Exit-ActionOutputGroup](Exit-ActionOutputGroup.md) | End an output group. Equivalent of `core.endGroup()`. |
| [Get-ActionInput](Get-ActionInput.md) | Gets the value of an input. The value is also trimmed. Equivalent of `core.getInput(name)`. |
| [Get-ActionIsDebug](Get-ActionIsDebug.md) | Gets whether Actions Step Debug is on or not. Equivalent of `core.isDebug()`. |
| [Invoke-ActionGroup](Invoke-ActionGroup.md) | Executes the argument script block within an output group. Equivalent of `core.group(name, func)`. |
| [Invoke-ActionNoCommandsBlock](Invoke-ActionNoCommandsBlock.md) | Invokes a scriptblock that won't result in any output interpreted as a workflow command. Useful for printing arbitrary text that may contain command-like text. No quivalent in `@actions/core` package. |
| [Send-ActionCommand](Send-ActionCommand.md) | Sends a command to the hosting Workflow/Action context. Equivalent to `core.issue(cmd, msg)`/`core.issueCommand(cmd, props, msg)`. |
| [Send-ActionFileCommand](Send-ActionFileCommand.md) | Sends a command to an Action Environment File. Equivalent to `core.issueFileCommand(cmd, msg)`. |
| [Set-ActionCommandEcho](Set-ActionCommandEcho.md) | Enables or disables the echoing of commands into stdout for the rest of the step. Echoing is disabled by default if ACTIONS_STEP_DEBUG is not set. Equivalent of `core.setCommandEcho(enabled)`. |
| [Set-ActionFailed](Set-ActionFailed.md) | Sets an action status to failed. When the action exits it will be with an exit code of 1. Equivalent of `core.setFailed(message)`. |
| [Set-ActionOutput](Set-ActionOutput.md) | Sets the value of an output. Equivalent of `core.setOutput(name, value)`. |
| [Set-ActionVariable](Set-ActionVariable.md) | Sets env variable for this action and future actions in the job. Equivalent of `core.exportVariable(name, value)`. |
| [Write-ActionDebug](Write-ActionDebug.md) | Writes debug message to user log. Equivalent of `core.debug(message)`. |
| [Write-ActionError](Write-ActionError.md) | Adds an error issue. Equivalent of `core.error(message)`. |
| [Write-ActionInfo](Write-ActionInfo.md) | Writes info to log with console.log. Equivalent of `core.info(message)`. Forwards to Write-Host. |
| [Write-ActionWarning](Write-ActionWarning.md) | Adds a warning issue. Equivalent of `core.warning(message)`. |

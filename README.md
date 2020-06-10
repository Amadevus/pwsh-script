# pwsh-script

GitHub Action to run PowerShell scripts that use the workflow run context - inspired by [actions/github-script].

![GitHub top language](https://img.shields.io/github/languages/top/Amadevus/pwsh-script?logo=powershell)
[![CI](https://github.com/Amadevus/pwsh-script/workflows/CI/badge.svg?branch=master)](https://github.com/Amadevus/pwsh-script/actions?query=workflow%3ACI)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/Amadevus/pwsh-script)](https://github.com/Amadevus/pwsh-script/releases/latest)
![GitHub commits since latest release (by date)](https://img.shields.io/github/commits-since/Amadevus/pwsh-script/latest)

In order to use this action, `script` input is provided. The value of that input should be
the body of a PowerShell script.

The following is initialized before your script is executed:
- `$github` is an object representing the workflow's [`github` context]
- `$job` is an object representing the workflow's [`job` context]
- `$runner` is an object representing the workflow's [`runner` context]
- `$strategy` is an object representing the workflow's [`strategy` context]
- `$matrix` is an object representing the workflow's [`matrix` context]

Environment variables are accessed in the standard PowerShell way (`$env:my_var`).

**Note** This action requires `pwsh` to actually be available and on PATH of the runner - which
is the case for all GitHub-provided runner VMs; for your own runners you need to take care of that yourself.

This action has an extensive self-testing suite in [CI workflow](.github/workflows/ci.yml).

[actions/github-script]: https://github.com/actions/github-script
[`@actions/core`]: https://github.com/actions/toolkit/tree/master/packages/core
[`github` context]: https://help.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#github-context
[`job` context]: https://help.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#job-context
[`runner` context]: https://help.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#runner-context
[`strategy` context]: https://help.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#strategy-context
[`matrix` context]: https://help.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#matrix-context

## Reading step results
The return value of the script will be made available in the step's outputs under the `result` key.
```yml
- uses: Amadevus/pwsh-script@v1
  id: my-script
  with:
    script: '1 + 1'
- run: echo "${{ steps.my-script.outputs.result }}"
  # should print 2
```

## Result encoding

If the script return value is a single string, it'll be set as the value of the `result` output directly.
In any other case, it'll be passed to `ConvertTo-Json $Value -Depth 100 -Compress -EscapeHandling EscapeNonAscii`
and the string result of that call will be set as the output value.
```yml
- uses: Amadevus/pwsh-script@v1
  id: bad-script
  with:
    script: return [ordered]@{ x = 'a1'; y = 'b2' }
  continue-on-error: true
- run: echo '${{ steps.bad-script.outputs.result }}'
  # should print {"x":"a1","y":"b2"}
```

## Error handling

If the script throws an error/exception, it'll be caught, printed to the log and the error message
will be set as an `error` output of the action.
```yml
- uses: Amadevus/pwsh-script@v1
  id: bad-script
  with:
    script: 'throw "this fails"'
  continue-on-error: true
- run: echo "${{ steps.bad-script.outputs.error }}"
  # should print 'this fails'
```

## Actions cmdlets
A module called `GitHubActionsCore` will be imported in the scope of your script. It provides commands
that are available for JavaScript Actions by [`@actions/core`] package, such as:
- `Set-ActionOutput`
- `Write-ActionWarning`
- `Set-ActionFailed`

For module documentation, see [GitHubActionsCore README](docs/GitHubActionsCore/README.md).

The module has a good test suite written in Pester.

## Examples

```yml
- uses: Amadevus/pwsh-script@v1
  id: script
  with:
    script: |
      Write-ActionDebug "This will be visible only when ACTIONS_STEP_DEBUG secret is set"

      # we have access to full context objects:
      if ($github.event.repository.full_name -ne $github.repository) {
        throw "something fishy's going on, repos don't match" # will cause step to fail
      }

      $someData = Get-MyCustomData
      # this data may contain action-command-like strings (e.g. '::warning::...')
      # we can prevent interpreting these by GitHub by printing them in NoCommandsBlock:
      Invoke-ActionNoCommandsBlock -GenerateToken {
        Write-Host $someData # this won't result in any commands
      }
      # now we can send commands again

      # let's set env:BE_AWESOME=always, but for all the following actions/steps as well:
      Set-ActionVariable BE_AWESOME always

      # also we'll add path to our custom tool to PATH for the following steps:
      $toolPath = Resolve-Path ./tools/bin
      Add-ActionPath $toolPath

      # let's also warn if it's too late for people to work in Greenwich ;)
      if ([datetime]::UtcNow.Hour -ge 22) {
        Write-ActionWarning "It's time to go to bed. Don't write code late at night! ⚠"
      }
```

## Changelog

Changelog is kept in [CHANGELOG.md](CHANGELOG.md)

## License

This action is licensed under [MIT license](LICENSE).
# pwsh-script

GitHub Action to run PowerShell scripts that use the workflow run context - inspired by [actions/github-script].

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

## Actions cmdlets
A module called `GitHubActionsCore` will be imported in the scope of your script. It provides commands
that are available for JavaScript Actions by [`@actions/core`] package, such as:
- `Set-ActionOutput`
- `Write-ActionWarning`
- `Set-ActionFailed`

For module documentation, see [GitHubActionsCore README](docs/GitHubActionsCore/README.md).

## Examples

TODO



[actions/github-script]: https://github.com/actions/github-script
[`@actions/core`]: https://github.com/actions/toolkit/tree/master/packages/core
[`github` context]: https://help.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#github-context
[`job` context]: https://help.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#job-context
[`runner` context]: https://help.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#runner-context
[`strategy` context]: https://help.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#strategy-context
[`matrix` context]: https://help.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#matrix-context
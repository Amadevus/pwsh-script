# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.2] - 2022-10-17

### Changed
* rename default branch to `main`
* use [Environment Files] for `Set-ActionOutput` command

## [2.0.1] - 2021-02-05

### Added
- `Send-ActionFileCommand` cmdlet that handles sending commands to [Environment Files] instead of console output ([#8]).

### Changed
- `Add-ActionPath` and `Set-ActionVariable` are updated for [Environment Files] Actions Runner change ([#8]).

[Environment Files]: https://docs.github.com/en/actions/reference/workflow-commands-for-github-actions#environment-files
[#8]: https://github.com/Amadevus/pwsh-script/pull/8

## [2.0.0] - 2020-09-10

### Changed
- Refactored into a 'composite' action which has following implications ([#4]):
  - Action runs slightly faster because there's no 'node' process in between (or io stream redirects).
  - Action has now just single `script` input, and you cannot "add" outputs other than automatic "result" and "error".

### Removed
- All optional inputs - until "composite" refactor, they were used to pass workflow contexts to the action.
  It's no longer necessary, since 'composite' action can "grab" them on it's own.
- Ability to set custom `outputs` from the script - now only `result` and `error` are set (as outlined in readme).

[#4]: https://github.com/Amadevus/pwsh-script/pull/4

## [1.0.0] - 2020-06-10

### Added
- Initial action code
- `GitHubActionsCore` PowerShell module

[Unreleased]: https://github.com/Amadevus/pwsh-script/compare/v2.0.2...HEAD
[2.0.2]: https://github.com/Amadevus/pwsh-script/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/Amadevus/pwsh-script/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/Amadevus/pwsh-script/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/Amadevus/pwsh-script/releases/tag/v1.0.0

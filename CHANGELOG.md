# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Refactored into a 'composite' action which has following implications ([#4]):
  - Action runs slightly faster because there's no 'node' process in between (or io stream redirects).
  - Action has now just single `script` input, and you cannot "add" outputs other than automatic "result" and "error".

### Removed
- All optional inputs - until 'composite' refactor, they were used to "pass" workflow contexts to the action.
  It's no longer necessary, since 'composite' action can "grab" them on it's own.

[#4]: https://github.com/Amadevus/pwsh-script/pull/4

## [1.0.0] - 2020-06-10

### Added
- Initial action code
- `GitHubActionsCore` PowerShell module

[Unreleased]: https://github.com/Amadevus/pwsh-script/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Amadevus/pwsh-script/releases/tag/v1.0.0
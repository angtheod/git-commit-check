# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) (as of version 0.1.0).

## [0.5.0] `2026-05-16`

### Changed
- Restructured the script template file. Developers now have to implement the 'before_run' and 'run' functions within their script.
  - Function 'before_run' must be implemented. Should initialize certain variables.
  - Function 'run' must be implemented. Should contain the check's logic. A typical use case is included in the template script file.
  - Function 'after_run' may be implemented. May contain any post-check actions.
- Move more logic from within the scripts to the core gitcc script and refactored 'check' function.
- Update the README.md file.

### Fixed
- Fix a bug in the lib function parse_npm_audit, that was showing an error message to the user when the NPM audit report file either did not contain a valid JSON object or did not contain certain expected json keys. 


## [0.4.0] `2026-05-11`

### Added
- Add new scripts (checks) for the following: eslint, prettier, tsc and vite.
- Add new lib functions add_about_info, split_about_info.
- Add a template script file (including comments) which can be used to create new scripts.

### Changed
- Improve existing scripts (checks).
- Make more dynamic the addition/removal of checks.
- Make dynamic the `about` section as well, by moving the logic from config.sh and gitcc to each one of the scripts.
- Rename `scripts/examples` directory to `scripts/prepared`
- Improve the extract_version lib function.
- Update the README.md file.

### Fixed
- Several bug fixes.


## [0.3.0] `2026-05-08`

### Changed
- Adjust the gitcc command to run properly when the git commit is run from the host machine (no container found).
- Move the example scripts into the scripts/examples directory.


## [0.2.0] `2026-05-07`

### Added
- Add a changelog file.

### Changed
- Allow dynamically adding/removing checks by placing/removing scripts from the scripts directory.
- Separate the checks logic into separate files that can be enabled/disabled via configuration.
- Move the configuration file to the root of the repository.
- Move the lib script to the root of the repository.
- Move the hooks directory to the root of the repository.
- Rename main script to gitcc.
- Optimize for performance.


## [0.1.0] `2025-04-20`

### Added
- A POSIX-compliant shell script for running configurable and extendable pre-commit checks on your git repository.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) (as of version 0.1.0).

## [0.8.0] `2026-05-27`

### Added
- Show total count of Passed, Warned and Failed checks, after all the checks have finished. 
- Add shell function `__after_checks` to add logic after all checks have finished running. Can be overriden by implementing user-level `after_checks` shell function
- Add shell function `__is_installed` to check if a command is installed.
- Add user prompt to confirm before continuing to commit, when there is 1 or more warnings produced by the checks.
- Add configuration option for the user prompt.

### Changed
- Refactor some small parts.
- Rename template to template.sh

### Fixed
- Fix bug in function __run where it logged an empty message when check passed.
- Fix pre-commit command path.


## [0.7.0] `2026-05-25`

### Added
- Add `bin/arm64` & `bin/x86_64` directories with the binaries for gitcc, core and libutils for arm64 and amd64 platforms respectively.
- Use the binaries instead of the shell scripts.
- Add core binary file.
- Add parse_composer_audit function in libutils.
- Add configuration for force running gitcc within container (enabled by default).

### Changed
- Move core logic from gitcc binary to core binary.
- The gitcc binary now contains the logic for booting the shell process and executing the right binaries according to configuration.
- Simplify even more the user-level scripts. Move logic from user-level scripts to libutils.
- Simplify configuration. Now only 4 variables need to be configured by the user (PROJECT_PATH, GITCC_PATH, CONTAINER_NAME & SHELL)
- Update README

### Removed
- Remove logic from the pre-commit hook script, to simplify the process for the user
  - Now it contains only one-line command that will start the correct gitcc process.

### Fixed
- Fix bug for composer_audit script with the total vulnerabilities count not showing.


## [0.6.0] `2026-05-20`

### Added
- Add '__handle_before_run', '__handle_run' & '__handle_after_run' shell functions.
  - Shell functions '__handle_run' and '__handle_after_run' check if there is a user-defined 'run' and 'after_run' function respectively. If not, then they call the default '__run' and '__after_run' functions respectively.
- Add directory `scripts/use` where the user should place all script-checks that gitcc should call.
- Add configuration option for enabling/disabling all checks entirely (produces warning when disabled).

### Changed
- All gitcc shell function names now begin with double underscore e.g., '__func' and by convention user shell function names should not begin with it.
- Simplify/minimize the shell code required to use a new check-script.
  - User now must implement only one shell function 'before_run'.
  - Shell functions 'run' and 'after_run' are optional to implement and may override '__run' and '__after_run' entirely or partially.
- Rename directory `scripts/prepared` to `scripts/library`.
- Improve library scripts.
- Improve configuration.
- Improve console interface.

### Fixed
- Fix bug when a user-level script defines a command that is not available/installed and shell can't find it. 
- Fix bug due to getting the version of a command by executing a sub-shell command on user-level.
  - Now only a string representation of the version command is required on user-level.


## [0.5.0] `2026-05-16`

### Changed
- Restructure the script template file. Developers now have to implement the 'before_run' and 'run' functions within their script.
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

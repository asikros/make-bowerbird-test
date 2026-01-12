# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

```markdown
## [Unreleased] - YYYY-MM-DD

### Added
### Changed
### Deprecated
### Fixed
### Security
```

## [Unreleased] - YYYY-MM-DD

### Added
### Changed
### Deprecated
### Fixed
### Security


## [0.3.0] - 2026-01-12

### Added
- Line continuation support in mock shell for recipes with backslash line breaks
- Cross-platform normalization of line continuations (handles differences between macOS and Ubuntu)

### Changed
- Mock shell implementation now uses file-based approach instead of inline shell script
- Mock shell script files are created via Make pattern rule with atomic writes for parallel safety
- Consolidated mock shell script generation into single `printf` statement for clarity

### Fixed
- Mock shell now correctly handles line continuations by normalizing backslash-space sequences
- Cross-platform compatibility between macOS and Ubuntu for mock shell execution
- Mock shell script files are created atomically to prevent race conditions in parallel test execution
- Proper quote escaping in generated bash scripts for the mock shell


## [0.2.0] - 2026-01-11

### Added
- Mock shell testing framework (`bowerbird-mock.mk`) for testing Make recipes without
  executing commands
- `bowerbird::test::add-mock-test` macro for creating mock shell tests
- `bowerbird::test::compare-file-content-from-var` macro for comparing file contents
  against Make variable values in eval contexts
- `bowerbird::test::find-test-files` macro with multiple paths and patterns support
- `bowerbird::test::find-test-targets` macro with pattern parameter support
- `bowerbird::test::find-cached-test-results-failed` macro for finding failed tests
- Command-line flags for test execution control:
  - `--bowerbird-fail-fast` to stop on first failure
  - `--bowerbird-fail-first` to run previously failed tests first
  - `--bowerbird-suppress-warnings` to suppress discovery warnings
- Comprehensive test coverage (230 tests total, up from 226)
- Pattern-rule optimization for test suite generation (99.3% smaller generated files)
- Support for multiple test file paths in `bowerbird::test::suite` macro
- Configuration fingerprint to prevent suite redefinition with different settings

### Changed
- **BREAKING**: Replaced `bowerbird::test::pattern-test-files` and
  `bowerbird::test::pattern-test-targets` macros with configuration variables:
  - `bowerbird-test.config.file-patterns` (default: `test*.mk`)
  - `bowerbird-test.config.target-patterns` (default: `test*`)
- **BREAKING**: Renamed constants from `BOWERBIRD_COMMA` and `BOWERBIRD_NEWLINE` to
  `bowerbird::test::COMMA` and `bowerbird::test::NEWLINE` using define blocks
- Converted `bowerbird-test.config.fail-exit-code` to constant
  `bowerbird-test.constant.fail-exit-code` with value `1`
- Renamed config variables to option variables for command-line override support:
  - `bowerbird-test.option.fail-fast`
  - `bowerbird-test.option.fail-first`
  - `bowerbird-test.option.suppress-warnings`
- Test suite generation now uses single pattern rule instead of explicit targets per
  test (33x faster generation, from ~15s to ~0.47s)
- Split monolithic `test-mock.mk` into focused files:
  - `test-mock-basic.mk` (core functionality)
  - `test-mock-output.mk` (output capture and formatting)
  - `test-mock-variables.mk` (variable expansion and special characters)
- Reorganized flag definitions in `bowerbird-suite.mk` for better readability
- Documentation moved to separate `make-bowerbird-docs` repository
- Simplified docstring format (removed `<arg>` angle brackets)
- Alphabetized macros in source files for better organization
- Suite macro now uses `bowerbird::test::find-test-files` and
  `bowerbird::test::find-test-targets` macros (reduced duplication)
- Sorted all configuration, option, and constant definitions alphabetically
- Prefer file blanking (`: >`) over removal (`rm -f`) for files being recreated
- Use single `printf` command instead of multiple `echo` commands for generation

### Deprecated
- Old pattern configuration macros removed (use config variables instead)

### Fixed
- Dollar sign escaping in mock test expected output (`$$HOME` → `$HOME`)
- Escaping issues in pattern rule recipes for `$(pgrep)` commands
- Path extraction in `find-cached-test-results` using `basename(notdir)` for nested
  directories
- Removed silent skips when suite variables already defined (ensures predictable
  behavior)
- Removed unnecessary `mkdir` commands from tests that don't create files
- Fixed Make 3.81 compatibility issues with pattern rules and complex recipes
- Error suppression in find commands with `2>/dev/null`
- Prevented duplicate test target generation when target-specific variables used


## [0.1.0] - 2024-06-06

### Added
- Test runner now enables undefined an variable warning and fails when an undefined
  variable is encountered.
- Created macros for comparing strings, sets/lists, files.
- Added tests for checking the printed output from the test runner.
- Added documentation to teh source macros.
### Changed
- Separated the test-runner source files from the comparison macos.
### Fixed
- Removed an unused reference to the obsolete NEWLINE macro.
- Removed  unnecessary comments and newlines from the test files.

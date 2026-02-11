# shellspec-integration Specification

## Purpose
TBD - created by archiving change add-shellspec-testing. Update Purpose after archive.
## Requirements
### Requirement: ShellSpec Project Configuration

The project SHALL have a `.shellspec` configuration file that configures the test runner.

#### Scenario: ShellSpec configuration exists

**WHEN** a developer checks the project root  
**THEN** a `.shellspec` file SHALL exist  
**AND** it SHALL configure bash as the shell  
**AND** it SHALL enable color output  

#### Scenario: Running shellspec command

**WHEN** a developer runs `shellspec` in the project root  
**THEN** the test runner SHALL discover and execute all `*_spec.sh` files in `spec/`  
**AND** it SHALL report test results  

---

### Requirement: Spec Helper Configuration

The project SHALL have a `spec/spec_helper.sh` file that provides common test utilities.

#### Scenario: Spec helper is loaded

**WHEN** a spec file includes the helper  
**THEN** common functions and setup SHALL be available  
**AND** the `_racelib.sh` functions SHALL be sourced  

---

### Requirement: Unit Tests for Core Library

The `_racelib.sh` functions SHALL have unit tests in `spec/racelib_spec.sh`.

#### Scenario: show_version function test

**WHEN** `show_version` is called  
**THEN** the output SHALL contain a version string  

#### Scenario: checkNixPresent with nix files

**WHEN** `checkNixPresent` is called in a directory with `.nix` files  
**AND** flake.nix does not exist  
**THEN** it SHALL print a warning message  

#### Scenario: set_tf_vars auto-selection

**WHEN** `set_tf_vars` is called  
**AND** a matching `.tfvars` file exists for the current backend  
**THEN** `TF_VAR` SHALL be set to the matching file path  

---

### Requirement: Unit Tests for Git Sync Functions

The git sync functions SHALL have unit tests in `spec/git_sync_spec.sh`.

#### Scenario: check_git_status with clean repo

**WHEN** `check_git_status` is called  
**AND** the git repository has no untracked files  
**AND** git sync is enabled  
**THEN** the function SHALL return success (exit 0)  

#### Scenario: check_git_status with untracked files

**WHEN** `check_git_status` is called  
**AND** the git repository has untracked files  
**AND** git sync is enabled  
**THEN** the function SHALL print an error message  
**AND** the function SHALL return failure (exit 1)  

#### Scenario: check_git_status when disabled

**WHEN** `check_git_status` is called  
**AND** `RACE_GIT_SYNC_ENABLED` is set to `false`  
**THEN** the function SHALL return success without checking git  

#### Scenario: get_stack_domain in CatStack directory

**WHEN** `get_stack_domain` is called  
**AND** the current directory is under `stack/01_shared_kms/`  
**THEN** it SHALL return `01_shared_kms`  

#### Scenario: get_stack_domain with override

**WHEN** `get_stack_domain` is called  
**AND** `RACE_STACK_DOMAIN` is set to `custom_domain`  
**THEN** it SHALL return `custom_domain`  

#### Scenario: get_current_environment from tfbackend

**WHEN** `get_current_environment` is called  
**AND** `.terraform/tfbackend.state` contains `nonprod.tfbackend`  
**THEN** it SHALL return `nonprod`  

---

### Requirement: Nix Flake Integration

ShellSpec SHALL be available via the Nix flake devShell.

#### Scenario: shellspec in nix develop

**WHEN** a developer runs `nix develop`  
**THEN** the `shellspec` command SHALL be available in PATH  

---

### Requirement: Test Documentation

The README SHALL document how to run and write tests.

#### Scenario: Running tests documentation

**WHEN** a developer reads the README  
**THEN** they SHALL find instructions for running `shellspec`  
**AND** they SHALL find instructions for running specific tests  

#### Scenario: Writing tests documentation

**WHEN** a developer wants to add new tests  
**THEN** the README SHALL explain the spec file structure  
**AND** it SHALL provide examples of common test patterns


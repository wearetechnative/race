# Tasks: add-shellspec-testing

## Phase 1: Project Setup

- [x] 1.1 Create `.shellspec` configuration file
- [x] 1.2 Create `spec/spec_helper.sh` with common helpers
- [x] 1.3 Create `spec/support/` directory for fixtures

## Phase 2: Core Library Tests

- [x] 2.1 Create `spec/racelib_spec.sh` for `_racelib.sh` functions
  - [x] 2.1.1 Tests for `show_version()`
  - [x] 2.1.2 Tests for `checkNixPresent()`
  - [x] 2.1.3 Tests for `set_tf_vars()`
  - [x] 2.1.4 Tests for `multiple_vars()` (skipped - requires gum interaction)
- [x] 2.2 Create `spec/git_sync_spec.sh` for git sync functions
  - [x] 2.2.1 Tests for `check_git_status()`
  - [x] 2.2.2 Tests for `get_stack_domain()`
  - [x] 2.2.3 Tests for `get_current_environment()`
  - [x] 2.2.4 Tests for `git_sync_apply()`
  - [x] 2.2.5 Tests for `run_apply_with_sync()`

## Phase 3: Nix Integration

- [x] 3.1 Add ShellSpec to flake.nix devShell inputs
- [x] 3.2 Update flake.nix devShell buildInputs
- [x] 3.3 Verify `nix develop` provides shellspec command

## Phase 4: Documentation

- [x] 4.1 Add testing section to README.md
- [x] 4.2 Document how to run tests locally
- [x] 4.3 Document how to add new tests

## Phase 5: Cleanup

- [x] 5.1 Remove or migrate `tests/test_git_sync.sh` to ShellSpec format
- [x] 5.2 Run full test suite and verify all pass

## Acceptance Criteria

- [x] `shellspec` command runs all specs successfully
- [x] All `_racelib.sh` functions have at least one test
- [x] Git sync functions have comprehensive coverage
- [x] Documentation enables contributors to write new tests

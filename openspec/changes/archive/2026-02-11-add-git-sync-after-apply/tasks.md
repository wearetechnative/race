# Tasks: Add Git Sync After Apply

## Implementation Tasks

### Phase 1: Core Library Functions

- [x] **1.1** Add `check_git_status()` function to `_racelib.sh`
  - Check if directory is a git repository
  - Detect untracked files and warn/error
  - Validation: Unit test with mock git scenarios

- [x] **1.2** Add `get_stack_domain()` function to `_racelib.sh`
  - Return `RACE_STACK_DOMAIN` env var if set
  - Fall back to current directory basename
  - Validation: Test with various directory structures

- [x] **1.3** Add `git_sync_apply()` function to `_racelib.sh`
  - Commit staged changes with descriptive message
  - Create timestamped tag in format `{env}_{stack}_{timestamp}`
  - Handle existing tag removal (local and remote)
  - Push commits and tags
  - Validation: Test in isolated git repository

- [x] **1.4** Add `run_apply_with_sync()` wrapper function to `_racelib.sh`
  - Call `check_git_status()` before apply
  - Execute passed command
  - Call `git_sync_apply()` on success
  - Preserve original exit code on failure
  - Validation: End-to-end test with mock terraform

### Phase 2: Integration

- [x] **2.1** Update `tfapply.sh` to use git sync wrapper
  - Replace direct terraform call with `run_apply_with_sync`
  - Extract environment from TF_BACKEND state
  - Validation: Manual test with real terraform apply

- [x] **2.2** Update `nixrun.sh` to use git sync for apply targets
  - Detect apply targets (pattern match on "Apply")
  - Wrap apply calls with git sync
  - Leave non-apply targets unchanged
  - Validation: Manual test with nix run apply

### Phase 3: Configuration & Polish

- [x] **3.1** Add `RACE_GIT_SYNC_ENABLED` configuration support
  - Default to enabled
  - Skip sync when set to `false`
  - Validation: Test enable/disable toggle

- [x] **3.2** Add `RACE_GIT_REMOTE` configuration support
  - Default to `origin`
  - Use configured remote for push
  - Validation: Test with custom remote name

- [x] **3.3** Update documentation
  - Add git sync section to README
  - Document environment variables
  - Add examples of tag format
  - Validation: Documentation review

### Phase 4: Testing & Validation

- [x] **4.1** Create integration test script
  - Test full flow with mock terraform
  - Verify tag creation and format
  - Test error scenarios (untracked files, apply failure)
  - Validation: All tests pass

- [x] **4.2** Manual acceptance testing
  - Test with real terraform apply
  - Test with nix run apply
  - Verify git history and tags
  - Validation: Successful end-to-end demonstration

## Dependencies

- Task 1.1-1.4 can be developed in parallel
- Task 2.1, 2.2 depend on Phase 1 completion
- Task 3.x depends on Phase 2 completion
- Task 4.x depends on all previous phases

## Verification Checklist

- [x] Git sync only runs after successful apply
- [x] Untracked files are detected before apply starts
- [x] Tag format matches `{env}_{stack}_{YYYYMMDD-HHhMMm}`
- [x] Existing tags are properly replaced
- [x] Apply failure preserves original exit code
- [x] Git sync can be disabled via environment variable
- [x] Non-apply nix targets are unaffected

# git-sync Specification

## Purpose
TBD - created by archiving change add-git-sync-after-apply. Update Purpose after archive.
## Requirements
### Requirement: Pre-Apply Git Status Check

The system SHALL verify git repository status before executing apply commands to prevent applying changes from an unclean working directory.

#### Scenario: Clean git working directory allows apply

**WHEN** the user runs `tfapply.sh` or `nixrun.sh` with an apply target
**AND** the current directory is a git repository
**AND** there are no untracked files
**THEN** the apply command proceeds normally

#### Scenario: Untracked files block apply

**WHEN** the user runs `tfapply.sh` or `nixrun.sh` with an apply target
**AND** there are untracked files in the repository
**THEN** the system displays an error message listing the untracked files
**AND** the apply command is aborted with exit code 1

#### Scenario: Non-git directory allows apply with warning

**WHEN** the user runs `tfapply.sh` or `nixrun.sh` with an apply target
**AND** the current directory is not a git repository
**THEN** the system displays a warning that git sync will be skipped
**AND** the apply command proceeds normally

---

### Requirement: Automatic Git Sync After Successful Apply

The system SHALL automatically commit changes and create a tagged release after a successful apply operation.

#### Scenario: Successful terraform apply triggers git sync

**WHEN** `terraform apply` completes successfully (exit code 0)
**AND** there are staged or modified tracked files
**THEN** the system commits all changes with message "Applied {environment} {domain}"
**AND** creates a tag in format `{environment}_{domain}_{YYYYMMDD-HHhMMm}`
**AND** pushes commits and tags to the remote repository

#### Scenario: Successful nix apply triggers git sync

**WHEN** `nix run .#<target>Apply` completes successfully (exit code 0)
**AND** there are staged or modified tracked files
**THEN** the system commits all changes with message "Applied {environment} {domain}"
**AND** creates a tag in format `{environment}_{domain}_{YYYYMMDD-HHhMMm}`
**AND** pushes commits and tags to the remote repository

#### Scenario: Failed apply skips git sync

**WHEN** the apply command fails (exit code non-zero)
**THEN** no git operations are performed
**AND** the original exit code is preserved

#### Scenario: No changes after apply skips commit

**WHEN** the apply command completes successfully
**AND** there are no staged or modified tracked files
**THEN** only a tag is created (no empty commit)
**AND** the tag is pushed to the remote repository

---

### Requirement: Tag Format and Management

The system SHALL create consistently formatted tags and MUST handle existing tags appropriately.

#### Scenario: Tag creation with correct format

**WHEN** git sync creates a tag
**THEN** the tag follows format `{environment}_{domain}_{YYYYMMDD-HHhMMm}`
**AND** environment is derived from the current tfbackend path (nonprod/prod)
**AND** domain is derived from CatStack `stack/` directory structure, `RACE_STACK_DOMAIN`, or directory name
**AND** timestamp uses current local time

#### Scenario: Existing tag is replaced

**WHEN** a tag with the same name already exists locally
**THEN** the existing local tag is deleted
**AND** the existing remote tag is deleted (if present)
**AND** a new tag is created with current timestamp

---

### Requirement: Git Sync Configuration

The system SHALL support configuration options for git sync behavior.

#### Scenario: Git sync disabled via environment variable

**WHEN** `RACE_GIT_SYNC_ENABLED` is set to `false`
**THEN** no git operations are performed after apply
**AND** apply command runs normally

#### Scenario: Custom stack domain via environment variable

**WHEN** `RACE_STACK_DOMAIN` environment variable is set
**THEN** the tag uses the specified domain value
**AND** ignores the CatStack directory structure detection

#### Scenario: Custom remote via environment variable

**WHEN** `RACE_GIT_REMOTE` environment variable is set
**THEN** git push uses the specified remote name
**AND** defaults to `origin` if not set

---

### Requirement: Non-Apply Nix Targets Unchanged

The system MUST NOT modify behavior of nix targets that are not apply operations.

#### Scenario: Plan target runs without git sync

**WHEN** the user runs `nixrun.sh` with a plan target (e.g., `nonprodPlan`)
**THEN** the nix command runs normally
**AND** no git operations are performed

#### Scenario: Non-IaC target runs without git sync

**WHEN** the user runs `nixrun.sh` with a non-IaC target
**THEN** the nix command runs normally
**AND** no git operations are performed

---


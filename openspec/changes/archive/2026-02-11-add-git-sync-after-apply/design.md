# Design: Add Git Sync After Apply

## Overview

This design describes the implementation of automatic git synchronization after successful infrastructure apply operations.

## Architecture

### Component Flow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  tfapply.sh     │     │   _racelib.sh   │     │   Git Remote    │
│  nixrun.sh      │────▶│  git_* funcs    │────▶│                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                      │
         │                      ▼
         │              ┌─────────────────┐
         └─────────────▶│ terraform/nix   │
                        └─────────────────┘
```

### New Functions in _racelib.sh

#### 1. `check_git_status()`
- Verifies working directory is a git repository
- Checks for untracked files that should be committed first
- Returns error if uncommitted untracked files exist

#### 2. `git_sync_apply(environment, domain)`
- Creates commit with message: "Applied {environment} {domain}"
- Generates tag: `{environment}_{domain}_{YYYYMMDD-HHhMMm}`
- Handles existing tag (removes local/remote before recreating)
- Pushes commits and tags to origin

#### 3. `run_apply_with_sync(command, environment, domain)`
- Wrapper that:
  1. Calls `check_git_status()`
  2. Runs the apply command
  3. On success (exit code 0), calls `git_sync_apply()`
  4. On failure, exits with original error code

#### 4. `get_catstack_domain()`
- Detects CatStack domain from directory structure
- If pwd is under `stack/`, extracts domain directory name (e.g., `01_shared_kms`)
- Falls back to basename of pwd if not in CatStack structure

### Integration Points

#### tfapply.sh
```bash
# Before: Direct terraform apply call
# After: Wrapped with git sync

environment=$(get_current_environment)  # from TF_BACKEND
domain=$(get_catstack_domain)           # from stack/ structure or directory
run_apply_with_sync "terraform apply ..." "$environment" "$domain"
```

#### nixrun.sh (apply targets only)
```bash
# Detect if target is an apply operation
if [[ "$TARGET" == *"Apply"* ]]; then
    domain=$(get_catstack_domain)
    run_apply_with_sync "nix run .#$TARGET" "$environment" "$domain"
else
    nix run .#$TARGET
fi
```

### Tag Format

Format: `{environment}_{domain}_{timestamp}`

- **environment**: `nonprod` or `prod` (extracted from `.terraform/tfbackend.state`)
- **domain**: CatStack domain name (e.g., `01_shared_kms`, `02_backend_config`)
- **timestamp**: `YYYYMMDD-HHhMMm` format (e.g., `20260211-14h30m`)

Example: `nonprod_01_shared_kms_20260211-14h30m`

### CatStack Integration

This design aligns with [CatStack conventions](https://github.com/wearetechnative/catstack):

```
project-root/
├── infra_environments/          # Environment-specific configuration
│   ├── nonprod/
│   │   └── nonprod.tfbackend    # Backend config for non-production
│   └── prod/
│       └── prod.tfbackend       # Backend config for production
├── stack/                       # Container for all domains
│   ├── 01_shared_kms/           # Domain with numeric prefix
│   ├── 02_backend_config/       # Higher numbered = more dependencies
│   └── 03_sqs_dlq/
```

### Environment Detection

1. Read `.terraform/tfbackend.state` for TF_BACKEND path value
2. Extract environment from path:
   - Path containing `infra_environments/nonprod/` → `nonprod`
   - Path containing `infra_environments/prod/` → `prod`
3. Fallback: Parse the tfbackend filename itself

### Domain Detection

Priority order:
1. Explicit `RACE_STACK_DOMAIN` environment variable (override)
2. Detect if running inside `stack/` hierarchy and use domain directory name
3. Fallback to current directory name (basename of pwd)

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Not a git repo | Warning message, proceed without sync |
| Untracked files | Error message, abort apply |
| Apply fails | No git sync, exit with apply error code |
| Git push fails | Warning message, local commit preserved |
| Tag exists | Remove existing tag, create new one |

## Configuration

Optional environment variables:

- `RACE_GIT_SYNC_ENABLED`: Set to `false` to disable (default: `true`)
- `RACE_STACK_DOMAIN`: Override stack domain name
- `RACE_GIT_REMOTE`: Remote name (default: `origin`)

## Trade-offs

### Considered: Interactive confirmation before push
- **Pro**: More control
- **Con**: Adds friction, inconsistent with automated workflows
- **Decision**: Skip for initial implementation, can add `--no-push` flag later

### Considered: Separate command for git sync
- **Pro**: More flexibility
- **Con**: Defeats purpose of automatic synchronization
- **Decision**: Integrate directly into apply flow

### Considered: Support for multiple remotes
- **Pro**: Flexibility for complex setups
- **Con**: Complexity, edge cases
- **Decision**: Support single remote (origin) initially

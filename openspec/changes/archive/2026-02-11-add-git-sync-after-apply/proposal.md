# Proposal: Add Git Sync After Apply

## Summary

Add automatic git commit, tag, and push functionality after successful `terraform apply` or `nix run` apply commands to ensure the repository stays in sync with cloud state.

## Motivation

When infrastructure changes are applied to the cloud, the local git repository should reflect this state. Currently, after a successful apply, users must manually commit and push changes. This creates risk of:

1. **State drift**: Local changes not tracked in version control
2. **Audit gaps**: No clear record of when infrastructure changes were applied
3. **Team coordination issues**: Other team members unaware of applied changes

## Solution

Implement git synchronization that:

1. Checks for untracked files before apply (safety check)
2. After successful apply, commits changes with a descriptive message
3. Creates a timestamped tag in format: `[environment]_[domain]_[YYYYMMDD-HHhMMm]`
4. Pushes commits and tags to remote

## CatStack Context

This feature integrates with the [CatStack framework](https://github.com/wearetechnative/catstack) conventions:

- **Domains**: CatStack organizes infrastructure into numbered domains (e.g., `01_shared_kms`, `02_backend_config`) under `stack/`
- **Environments**: Defined via `infra_environments/{env}/{env}.tfbackend` files (typically `nonprod` and `prod`)
- **Tag format**: `{environment}_{domain}_{timestamp}` (e.g., `nonprod_01_shared_kms_20260211-14h30m`)

## Scope

- **In scope**: 
  - New git sync functions in `_racelib.sh`
  - Integration with `tfapply.sh`
  - Integration with `nixrun.sh` (for apply targets)
  - Tag format: `{environment}_{domain}_{timestamp}`
  - Domain detection from CatStack `stack/` directory structure
  
- **Out of scope**:
  - Changes to plan/destroy commands
  - Interactive conflict resolution
  - Multi-remote push support

## References

- GitHub Issue: https://github.com/wearetechnative/race/issues/10
- Reference implementation: https://github.com/mipmip/mipnix/blob/fe56028878cdbecb358bff883517debedff5944a/RUNME.sh

## Status

- [x] Proposal created
- [ ] Review pending
- [ ] Approved
- [ ] Implementation started

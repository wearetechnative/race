# Design: add-shellspec-testing

## Overview

This document describes the architecture for integrating ShellSpec into RACE for unit testing bash functions.

## Directory Structure

```
race/
├── .shellspec              # ShellSpec configuration
├── spec/
│   ├── spec_helper.sh      # Common test helpers
│   ├── racelib_spec.sh     # Tests for _racelib.sh
│   ├── git_sync_spec.sh    # Tests for git sync functions
│   └── support/            # Test fixtures and mocks
│       └── fixtures/
└── flake.nix               # Updated with shellspec
```

## ShellSpec Configuration

`.shellspec` file:
```
--shell bash
--format progress
--color
--warning-as-failure
--jobs 4
```

## Test Organization

### Unit Test Files

| Spec File | Tests For |
|-----------|-----------|
| `racelib_spec.sh` | `set_tf_vars()`, `multiple_vars()`, `checkNixPresent()` |
| `git_sync_spec.sh` | `check_git_status()`, `get_stack_domain()`, `git_sync_apply()` |

### Mocking Strategy

Shell functions requiring external dependencies (git, terraform, nix) will be mocked:

```sh
Describe 'check_git_status'
  Mock git
    case "$1" in
      status) echo "nothing to commit, working tree clean" ;;
    esac
  End
  
  It 'returns success for clean repo'
    When call check_git_status
    The status should be success
  End
End
```

## Nix Integration

Add ShellSpec to flake.nix devShell:

```nix
devShells.default = pkgs.mkShell {
  buildInputs = [
    pkgs.shellspec  # or use fetchFromGitHub if not in nixpkgs
  ];
};
```

## OpenSpec Integration (Optional)

Add test execution to openspec validation by creating a custom validator or running shellspec as a pre-validation hook.

## Trade-offs

| Approach | Pros | Cons |
|----------|------|------|
| ShellSpec | Full BDD, mocking, coverage | Additional dependency |
| Bats | Simpler, widely known | Less features, no built-in mocking |
| Plain bash | No dependencies | Harder to maintain, no coverage |

**Decision**: ShellSpec provides the best balance of features for comprehensive testing of shell scripts.

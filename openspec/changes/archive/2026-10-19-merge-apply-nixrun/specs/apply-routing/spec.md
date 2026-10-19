# Spec Delta

## Purpose

Defines how `race apply` chooses between nix run and terraform apply for the
current stack, and which flake targets `race apply` and `race nixrun` offer.

## ADDED Requirements

### Requirement: Apply routes on flake.nix
`race apply` SHALL use the nix run route when the current directory contains `flake.nix`, and the terraform apply route otherwise.

#### Scenario: No flake.nix
- **WHEN** the user runs `race apply` in a directory without `flake.nix`
- **THEN** terraform apply runs with the selected tfvars file

#### Scenario: flake.nix with a selected backend
- **WHEN** the user runs `race apply` in a directory with `flake.nix`
- **AND** `.terraform/tfbackend.state` exists
- **THEN** the nix run route runs, offering only apply targets

### Requirement: Missing backend stops the nix route
When `flake.nix` exists but no terraform backend is selected, `race apply` SHALL stop with a non-zero exit code and tell the user to select a backend first with `race init`.

#### Scenario: flake.nix without backend
- **WHEN** the user runs `race apply` in a directory with `flake.nix`
- **AND** `.terraform/tfbackend.state` does not exist
- **THEN** an error mentions `race init`
- **AND** neither nix run nor terraform apply runs
- **AND** the exit code is non-zero

### Requirement: Override forces terraform apply
`race apply --override-tf` SHALL run terraform apply regardless of `flake.nix`, SHALL NOT ask the "nix files found" confirmation, and SHALL pass all other arguments to terraform.

#### Scenario: Override in a nix stack
- **WHEN** the user runs `race apply --override-tf` in a directory with `flake.nix`
- **THEN** terraform apply runs
- **AND** no confirmation about nix files is asked

#### Scenario: Extra arguments reach terraform
- **WHEN** the user runs `race apply --override-tf -target=module.x`
- **THEN** terraform apply receives `-target=module.x`
- **AND** it does not receive `--override-tf`

#### Scenario: Prompt kept without override
- **WHEN** the user runs `race apply` in a directory with `*.nix` files but without `flake.nix`
- **THEN** the "nix files found" confirmation is asked as before

### Requirement: Apply offers only apply targets
When reached through `race apply`, the nix run route SHALL offer only flake targets whose name ends in `apply` or `Apply`, both for the automatic backend match and for the selection menu.

#### Scenario: Backend match skips plan targets
- **WHEN** the backend is `nonprod`
- **AND** `flake.nix` defines `nonprodPlan` and `nonprodApply`
- **THEN** `race apply` proposes `nonprodApply`

#### Scenario: Menu without plan targets
- **WHEN** the user declines the proposed target
- **THEN** the menu lists only apply targets

#### Scenario: No apply targets
- **WHEN** `flake.nix` defines no apply targets
- **THEN** an error says no apply targets were found
- **AND** the exit code is non-zero

### Requirement: Nixrun keeps all targets
`race nixrun` SHALL offer all flake targets ending in `apply`, `Apply`, `plan` or `Plan`, as before.

#### Scenario: Menu lists plan and apply targets
- **WHEN** the user runs `race nixrun` and opens the menu
- **THEN** both plan and apply targets are listed

### Requirement: Backend match is deterministic
The automatic backend match SHALL prefer an apply target over a plan target for the same backend, independent of the system locale.

#### Scenario: Mixed-case target names
- **WHEN** the backend is `nonprod`
- **AND** `flake.nix` defines `nonprod_Plan` and `nonprod_apply`
- **THEN** `race nixrun` proposes `nonprod_apply` under every locale

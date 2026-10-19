# Spec Delta

## MODIFIED Requirements

### Requirement: Override forces terraform apply
`race apply --override-tf` SHALL run terraform apply regardless of `flake.nix`, SHALL NOT ask the "nix files found" confirmation, and SHALL pass all other arguments to terraform.

#### Scenario: Override in a nix stack
- **WHEN** the user runs `race apply --override-tf` in a directory with `flake.nix`
- **THEN** a message says `--override-tf` is used
- **AND** terraform apply runs
- **AND** no confirmation about nix files is asked

#### Scenario: Extra arguments reach terraform
- **WHEN** the user runs `race apply --override-tf -target=module.x`
- **THEN** terraform apply receives `-target=module.x`
- **AND** it does not receive `--override-tf`

#### Scenario: Prompt kept without override
- **WHEN** the user runs `race apply` in a directory with `*.nix` files but without `flake.nix`
- **THEN** the "nix files found" confirmation is asked as before

## ADDED Requirements

### Requirement: Nixrun rejects the override flag
`race nixrun` and `nixrun.sh` SHALL stop with a non-zero exit code when `--override-tf` is given, and SHALL point the user to `race apply --override-tf`.

#### Scenario: Override passed to nixrun
- **WHEN** the user runs `nixrun.sh apply --override-tf`
- **THEN** an error mentions `race apply --override-tf`
- **AND** nix run does not run
- **AND** the exit code is non-zero

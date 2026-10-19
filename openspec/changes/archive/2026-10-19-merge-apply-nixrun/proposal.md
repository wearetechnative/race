# Proposal

## Why

Users of nix-based stacks have to remember to run `race nixrun` instead of
`race apply`; running `race apply` in such a stack bypasses the flake that
sets up the environment. `race` should pick the right apply route itself.
Today it cannot even accept a flag, because the dispatcher only runs a
command when exactly one argument is given.

## What Changes

- The `race` dispatcher passes all arguments after the command name to the
  command. Unknown commands still show usage; commands that are not
  registered can no longer be executed through `race`.
- `race apply` routes on the current directory:
  - `flake.nix` present and a terraform backend selected: nix run with only
    apply targets offered.
  - `flake.nix` present but no backend selected: stop with a hint to run
    `race init` first.
  - no `flake.nix`: terraform apply, as today.
- New flag `race apply --override-tf` forces terraform apply and skips the
  "nix files found" confirmation prompt.
- `race nixrun` stays as an alias that offers all flake targets (plan and
  apply), as today.
- The automatic backend match in nixrun prefers apply targets over plan
  targets, independent of the sort locale.
- `race plan` is unchanged.

## Capabilities

### New Capabilities

- `cli-dispatch`: how the `race` command dispatches to its subcommands and
  passes arguments.
- `apply-routing`: how `race apply` and `race nixrun` choose between nix run
  and terraform apply, and which flake targets they offer.

### Modified Capabilities

(none; git sync still wraps both apply routes unchanged)

## Impact

- `race`: dispatcher, `apply`/`plan`/`destroy`/`nixrun` pass arguments.
- `_racelib.sh`: new routing and nix-target functions; `checkNixPresent`
  honours the override.
- `nixrun.sh`: apply-only mode, deterministic backend match.
- `spec/`: new shellspec suites for dispatch and routing.
- `README.md`, `CHANGELOG.md`, `VERSION-race`, `package.nix`.

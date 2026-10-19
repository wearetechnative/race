# Proposal

## Why

`nixrun.sh apply --override-tf` only warned that its arguments were ignored and
then started nix run, so a user who meant to force terraform apply could run
the flake target instead. `race apply --override-tf` also gave no sign that the
override was active.

## What Changes

- `nixrun.sh` (and so `race nixrun`) stops with an error when `--override-tf` is
  given, pointing to `race apply --override-tf`.
- `race apply --override-tf` prints that the override is used before running
  terraform apply.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `apply-routing`: the override announces itself, and nixrun rejects it.

## Impact

- `_racelib.sh` (`race_apply`), `nixrun.sh`
- `spec/apply_routing_spec.sh`, `spec/nixrun_spec.sh`
- `CHANGELOG.md`

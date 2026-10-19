# Design

## Context

- `race` uses the vendored RUNME.sh one-liner: `runme` evaluates `$1` only
  when exactly one argument is given, and evaluates it as arbitrary shell.
- `tfapply.sh` and `nixrun.sh` are standalone scripts that run top-level code
  and source `_racelib.sh`. Only `_racelib.sh` is unit-tested
  (`spec/spec_helper.sh` sources it).
- `nixrun.sh` builds its target list with a regex over `flake.nix` and takes
  the first element after `sort -u` as the backend match.

## Goals / Non-Goals

**Goals:**
- Keep the decision logic in `_racelib.sh` so shellspec can test it without
  running terraform or nix.
- Keep `tfapply.sh` and `nixrun.sh` callable on their own.

**Non-Goals:**
- Changing `race plan`, the git sync wrapper or the loose backend prefix
  match (`^prod` also matches `production_apply`).

## Decisions

**Dispatcher checks the registered command list.** `runme` dispatches only
when `$1` is in `CMDS`, then calls it with `shift`ed `"$@"` and returns its
exit code. Alternative: keep `eval "$ARG1" || usage` and append args; rejected
because it executes any shell command and prints usage on every failed apply.

**`race_apply` in `_racelib.sh`.** It strips `--override-tf`, checks
`flake.nix` and `.terraform/tfbackend.state`, and calls
`$thisdir/tfapply.sh` or `$thisdir/nixrun.sh`. Tests point `thisdir` at stub
scripts. Alternative: a new `raceapply.sh`; rejected because a top-level
script is harder to unit-test and adds a file to `package.nix`.

**Override reaches `checkNixPresent` through `RACE_OVERRIDE_TF=true`.**
`race_apply` sets it only for the `tfapply.sh` child process, and
`checkNixPresent` returns early when it is `true`. Alternative: a `tfapply.sh`
flag; rejected because the remaining arguments go to terraform verbatim.

**Nixrun mode through `RACE_NIXRUN_MODE=apply`.** `race_apply` sets it;
`race nixrun` leaves it unset, which means "all targets". Target selection
moves into `_racelib.sh`:
- `nix_flake_targets <mode>` lists targets (`LC_ALL=C sort -u`), filtered to
  `[Aa]pply$` in apply mode.
- `nix_backend_target <mode> <backend>` returns the first apply match, else
  the first plan match.

**Extra arguments on the nix route are ignored with a warning.** `nix run`
targets take no terraform arguments today; forwarding them is out of scope.
`nixrun.sh` prints the warning, so it covers `race apply` and `race nixrun`.

## Risks / Trade-offs

- [Dispatcher rejects `race <shell command>` that used to work by accident]
  → Intentional; only registered commands were ever documented.
- [`RACE_OVERRIDE_TF` exported by a user disables the nix prompt for plan
  too] → Documented as internal; `race_apply` sets it per call only.

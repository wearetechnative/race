# Tasks

## 1. Dispatcher passes arguments (bean wtoorren-zh7s)

- [x] 1.1 Rewrite `runme` in `race` to dispatch registered commands with the remaining arguments and preserve exit codes; verify with `spec/race_cli_spec.sh`
- [x] 1.2 Pass `"$@"` from the `plan`, `apply`, `destroy` and `nixrun` commands to their scripts; verify `race version` and usage still work
- [x] 1.3 Add `spec/race_cli_spec.sh` covering no command, unknown command, shell command not executed, argument passing and exit codes; verify `shellspec spec/race_cli_spec.sh` passes

## 2. Nixrun apply-only mode (bean wtoorren-h9f0)

- [x] 2.1 Add `nix_flake_targets` and `nix_backend_target` to `_racelib.sh`; verify with `spec/nixrun_spec.sh`
- [x] 2.2 Use them in `nixrun.sh` with `RACE_NIXRUN_MODE`, exit with an error when no targets are found, and mention `race init` when the backend is missing; verify `bash -n nixrun.sh` and `shellcheck nixrun.sh`
- [x] 2.3 Add `spec/nixrun_spec.sh` covering full vs apply mode, apply-over-plan preference and locale independence; verify it passes

## 3. Apply routing (bean wtoorren-bs7w)

- [x] 3.1 Add `race_apply` to `_racelib.sh` and call it from `race apply`; verify with `spec/apply_routing_spec.sh`
- [x] 3.2 Make `checkNixPresent` return early when `RACE_OVERRIDE_TF=true`; verify with a shellspec case
- [x] 3.3 Add `spec/apply_routing_spec.sh` with stub `tfapply.sh`/`nixrun.sh` covering all four routes, argument stripping and the nix-route warning; verify it passes

## 4. Documentation and release (bean wtoorren-mraj)

- [x] 4.1 Update README commands, workflow and examples for `race apply`, `--override-tf` and `race nixrun`; verify the documented commands match `race usage`
- [x] 4.2 Add a CHANGELOG entry and bump `VERSION-race` and `package.nix`; verify `race version` shows the new version

## 5. Integration (bean wtoorren-8udc)

- [x] 5.1 Run the full shellspec suite and shellcheck on changed scripts; verify no new failures compared to the baseline (3 pre-existing git-sync failures)
- [x] 5.2 Run `openspec validate merge-apply-nixrun --strict`; verify it passes

## Workflow follow-up

- Archive the change and commit it.
- Close the epic and its child beans.

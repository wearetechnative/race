# Tasks

## 1. Override messages (bean wtoorren-qdnr)

- [x] 1.1 Make `nixrun.sh` exit with an error pointing to `race apply --override-tf` when `--override-tf` is given; verify with a case in `spec/nixrun_spec.sh`
- [x] 1.2 Print a message in `race_apply` when `--override-tf` is used; verify with the updated cases in `spec/apply_routing_spec.sh`
- [x] 1.3 Add a CHANGELOG entry; verify the full shellspec suite shows no new failures and `openspec validate override-tf-feedback --strict` passes

## Workflow follow-up

- Archive the change.

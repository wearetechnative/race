# Changelog Race

## 0.3.0
- merge apply and nixrun: race apply uses nix run (apply targets only) when flake.nix exists, else terraform apply
- add race apply --override-tf to force terraform apply, with an override banner and without the nix-files prompt
- race apply stops with a race init hint when flake.nix exists but no backend is selected
- race nixrun keeps all plan and apply targets, rejects --override-tf; backend match prefers apply
- race passes arguments to its commands; unknown commands show usage
- disable git auto sync after apply
- migrate openspec tooling to the opsx workflow

## 0.2.2
- add shellcheck
- add auto sync after apply
- integrate openspec

## 0.2.1
- add destroy command
- add terraform_raw command

## 0.1.5
- update nixrun functionality to catch t more patterns in the flake.nix

## 0.1.4
- add nix run functionality. nixrun option will look for the terraform backup and matches it with the options available in flake.nix and starts the nix run command with the matching option.

## 0.1.3
- add terraform command protection when project has nix files

## 0.1.1
- fix usage
- Feature add usage in help
- make VERSION unique for flake distribution

## 0.1.0
- initial project setup

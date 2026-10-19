# cli-dispatch Specification

## Purpose
Defines how the `race` command selects a subcommand and hands the remaining
command-line arguments to it.

## Requirements

### Requirement: Subcommand arguments are passed through
The `race` command SHALL run the registered subcommand named by its first argument and SHALL pass all remaining arguments, in order, to that subcommand.

#### Scenario: Command without arguments
- **WHEN** the user runs `race version`
- **THEN** the `version` command runs

#### Scenario: Command with arguments
- **WHEN** the user runs `race apply --override-tf -target=module.x`
- **THEN** the `apply` command runs
- **AND** it receives `--override-tf` and `-target=module.x` as arguments

#### Scenario: Exit code is preserved
- **WHEN** a subcommand exits with a non-zero code
- **THEN** `race` exits with that same code
- **AND** usage is not printed

### Requirement: Only registered commands can be run
The `race` command SHALL show usage and exit non-zero when no command is given or when the first argument is not a registered command.

#### Scenario: No command
- **WHEN** the user runs `race` without arguments
- **THEN** usage is printed

#### Scenario: Unknown command
- **WHEN** the user runs `race doesnotexist`
- **THEN** usage is printed
- **AND** the exit code is non-zero

#### Scenario: Shell command is not executed
- **WHEN** the user runs `race ls`
- **THEN** usage is printed
- **AND** `ls` is not executed

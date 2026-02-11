# Proposal: add-shellspec-testing

## Summary

Implement ShellSpec (https://github.com/shellspec/shellspec) as the unit testing framework for RACE bash scripts and integrate it with the openspec workflow.

## Motivation

Currently, RACE lacks a formal unit testing framework. The existing `tests/test_git_sync.sh` uses ad-hoc bash test patterns. ShellSpec provides:

- BDD-style readable test syntax
- Proper mocking and stubbing for shell functions
- Code coverage reporting
- Parallel test execution
- Support for bash 4.0+ (RACE requirement)

Integrating with openspec enables automated test execution during spec validation.

## Scope

### In Scope
- Initialize ShellSpec project structure
- Create spec files for `_racelib.sh` functions
- Add `.shellspec` configuration
- Create `spec/spec_helper.sh` with common helpers
- Add Nix flake support for ShellSpec
- Document testing workflow in README
- Integrate with openspec validation (optional)

### Out of Scope
- E2E/integration tests requiring actual terraform/nix execution
- CI/CD pipeline configuration (separate change)

## References

- GitHub Issue: https://github.com/wearetechnative/race/issues/11
- ShellSpec: https://github.com/shellspec/shellspec
- ShellSpec DSL: https://github.com/shellspec/shellspec#dsl-syntax

## Change ID

`add-shellspec-testing`

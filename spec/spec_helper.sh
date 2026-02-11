# shellcheck shell=bash
# spec/spec_helper.sh - Common test helpers for RACE ShellSpec tests

# Set project root using ShellSpec's project root variable
# shellcheck disable=SC2154
RACE_ROOT="${SHELLSPEC_PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
export RACE_ROOT

# Source the library under test
# shellcheck source=../_racelib.sh
. "${RACE_ROOT}/_racelib.sh"

# Helper: Create a temporary test directory
setup_test_dir() {
  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR" || return 1
}

# Helper: Cleanup temporary test directory
cleanup_test_dir() {
  if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
    rm -rf "$TEST_DIR"
  fi
}

# Helper: Initialize a git repository for testing
setup_git_repo() {
  git init -q
  git config user.email "test@example.com"
  git config user.name "Test User"
  echo "initial" > README.md
  git add README.md
  git commit -q -m "Initial commit"
}

# Helper: Create a CatStack-like directory structure
setup_catstack_structure() {
  local domain="${1:-01_test_domain}"
  mkdir -p "stack/$domain"
  mkdir -p "infra_environments/nonprod"
  mkdir -p "infra_environments/prod"
  echo "nonprod.tfbackend" > "infra_environments/nonprod/nonprod.tfbackend"
  echo "prod.tfbackend" > "infra_environments/prod/prod.tfbackend"
}

# Helper: Create tfbackend state file
setup_tfbackend_state() {
  local env="${1:-nonprod}"
  mkdir -p .terraform
  echo "../../infra_environments/${env}/${env}.tfbackend" > .terraform/tfbackend.state
}

# Helper: Create tfvars files for testing
setup_tfvars_files() {
  echo "{}" > nonprod.tfvars.json
  echo "{}" > prod.tfvars.json
}

# Disable git sync by default in tests to avoid side effects
export RACE_GIT_SYNC_ENABLED="${RACE_GIT_SYNC_ENABLED:-false}"

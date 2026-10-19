# shellcheck shell=bash
# spec/race_cli_spec.sh - Tests for the race command dispatcher

Describe 'race command dispatcher'
  Include spec/spec_helper.sh

  setup() {
    TEST_DIR=$(mktemp -d)
    cp "${RACE_ROOT}/race" "${RACE_ROOT}/_racelib.sh" "${RACE_ROOT}/VERSION-race" "$TEST_DIR/"
    # Stub tfapply.sh: print the arguments it receives, exit with STUB_EXIT
    cat > "$TEST_DIR/tfapply.sh" <<'EOF'
#!/usr/bin/env bash
echo "tfapply args: $*"
exit "${STUB_EXIT:-0}"
EOF
    chmod +x "$TEST_DIR/tfapply.sh"
    cd "$TEST_DIR" || return 1
  }

  cleanup() {
    unset STUB_EXIT
    cd /
    rm -rf "$TEST_DIR"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'runs a command without arguments'
    When run script "$TEST_DIR/race" version
    The output should include "race v"
    The status should be success
  End

  It 'shows usage and fails without a command'
    When run script "$TEST_DIR/race"
    The output should include "Usage:"
    The status should be failure
  End

  It 'shows usage and fails for an unknown command'
    When run script "$TEST_DIR/race" doesnotexist
    The output should include "Usage:"
    The status should be failure
  End

  It 'does not execute shell commands'
    When run script "$TEST_DIR/race" touch executed
    The output should include "Usage:"
    The status should be failure
    The path "$TEST_DIR/executed" should not be exist
  End

  It 'passes arguments to the command'
    When run script "$TEST_DIR/race" terraform_raw -target=module.x
    The output should include "terraform [command] -target=module.x"
    The status should be success
  End

  It 'preserves the exit code without printing usage'
    export STUB_EXIT=3
    When run script "$TEST_DIR/race" apply --override-tf
    The output should include "tfapply args:"
    The output should not include "Usage:"
    The status should equal 3
  End
End

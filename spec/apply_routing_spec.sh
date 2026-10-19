# shellcheck shell=bash
# spec/apply_routing_spec.sh - Tests for race apply routing (nix run vs terraform apply)

Describe 'race apply routing'
  Include spec/spec_helper.sh

  setup() {
    TEST_DIR=$(mktemp -d)
    STUB_DIR="$TEST_DIR/stubs"
    WORK_DIR="$TEST_DIR/work"
    mkdir -p "$STUB_DIR" "$WORK_DIR"
    # Stub scripts: print which route ran, the env it got and its arguments
    for script in tfapply.sh nixrun.sh; do
      cat > "$STUB_DIR/$script" <<EOF
#!/usr/bin/env bash
echo "$script override=\${RACE_OVERRIDE_TF:-} mode=\${RACE_NIXRUN_MODE:-} args=\$*"
EOF
      chmod +x "$STUB_DIR/$script"
    done
    # Stub gum: record that the nix-files confirmation was asked
    printf '#!/usr/bin/env bash\necho "gum $*"\n' > "$STUB_DIR/gum"
    chmod +x "$STUB_DIR/gum"
    PATH="$STUB_DIR:$PATH"
    export PATH
    # shellcheck disable=SC2034 # read by race_apply
    thisdir="$STUB_DIR"
    cd "$WORK_DIR" || return 1
  }

  cleanup() {
    unset RACE_OVERRIDE_TF RACE_NIXRUN_MODE
    cd /
    rm -rf "$TEST_DIR"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'race_apply'
    It 'runs terraform apply without flake.nix'
      When call race_apply
      The output should equal "tfapply.sh override= mode= args="
      The status should be success
    End

    It 'passes arguments to terraform apply'
      When call race_apply -target=module.x -auto-approve
      The output should equal "tfapply.sh override= mode= args=-target=module.x -auto-approve"
    End

    It 'runs nix run in apply mode with flake.nix and a backend'
      touch flake.nix
      mkdir .terraform && echo nonprod > .terraform/tfbackend.state
      When call race_apply
      The output should equal "nixrun.sh override= mode=apply args="
      The status should be success
    End

    It 'stops with a race init hint with flake.nix but no backend'
      touch flake.nix
      When call race_apply
      The output should include "Set the backend first: race init"
      The output should not include "tfapply.sh"
      The output should not include "nixrun.sh"
      The status should be failure
    End

    It 'forces terraform apply with --override-tf in a nix stack'
      touch flake.nix
      mkdir .terraform && echo nonprod > .terraform/tfbackend.state
      When call race_apply --override-tf
      The line 2 of output should equal "  OVERRIDE ACTIVE: --override-tf"
      The line 5 of output should equal "tfapply.sh override=true mode= args="
    End

    It 'strips --override-tf from the terraform arguments'
      touch flake.nix
      When call race_apply -target=module.x --override-tf -auto-approve
      The line 2 of output should equal "  OVERRIDE ACTIVE: --override-tf"
      The line 5 of output should equal "tfapply.sh override=true mode= args=-target=module.x -auto-approve"
    End

    It 'preserves the exit code of the apply script'
      printf '#!/usr/bin/env bash\nexit 4\n' > "$STUB_DIR/tfapply.sh"
      When call race_apply
      The status should equal 4
    End
  End

  Describe 'checkNixPresent'
    It 'asks for confirmation when nix files exist'
      touch default.nix
      When call checkNixPresent
      The output should include "NIX-files found"
      The output should include "gum confirm"
    End

    It 'skips the confirmation with RACE_OVERRIDE_TF=true'
      touch flake.nix
      export RACE_OVERRIDE_TF=true
      When call checkNixPresent
      The output should equal ""
      The status should be success
    End
  End

  Describe 'race apply (end to end)'
    setup_race() {
      cp "${RACE_ROOT}/race" "${RACE_ROOT}/_racelib.sh" "${RACE_ROOT}/VERSION-race" "$STUB_DIR/"
    }
    BeforeEach 'setup_race'

    It 'routes through the race command'
      touch flake.nix
      mkdir .terraform && echo nonprod > .terraform/tfbackend.state
      When run script "$STUB_DIR/race" apply
      The output should equal "nixrun.sh override= mode=apply args="
    End

    It 'passes --override-tf through the race command'
      touch flake.nix
      When run script "$STUB_DIR/race" apply --override-tf -target=module.x
      The line 2 of output should equal "  OVERRIDE ACTIVE: --override-tf"
      The line 5 of output should equal "tfapply.sh override=true mode= args=-target=module.x"
    End

    It 'keeps race nixrun in full mode'
      When run script "$STUB_DIR/race" nixrun
      The output should equal "nixrun.sh override= mode= args="
    End

    It 'runs the real tfapply.sh without the nix prompt on --override-tf'
      cp "${RACE_ROOT}/tfapply.sh" "$STUB_DIR/"
      printf '#!/usr/bin/env bash\necho "terraform $*"\n' > "$STUB_DIR/terraform"
      chmod +x "$STUB_DIR/terraform"
      touch flake.nix
      echo '{}' > nonprod.tfvars.json
      When run script "$STUB_DIR/race" apply --override-tf -target=module.x
      The output should include "OVERRIDE ACTIVE: --override-tf"
      The output should include "terraform apply -var-file="
      The output should include "nonprod.tfvars.json -target=module.x"
      The output should not include "gum confirm"
    End
  End
End

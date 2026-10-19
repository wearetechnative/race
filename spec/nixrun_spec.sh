# shellcheck shell=bash
# spec/nixrun_spec.sh - Tests for nix flake target selection and nixrun.sh

Describe 'nix flake targets'
  Include spec/spec_helper.sh

  setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR" || return 1
    cat > flake.nix <<'EOF'
{
  outputs = { self }: {
    apps = { inherit nonprodPlan nonprodApply prodPlan prodApply; };
  };
}
EOF
  }

  cleanup() {
    cd /
    rm -rf "$TEST_DIR"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'nix_flake_targets'
    It 'lists plan and apply targets in full mode'
      When call nix_flake_targets all
      The output should equal "$(printf 'nonprodApply\nnonprodPlan\nprodApply\nprodPlan')"
    End

    It 'lists only apply targets in apply mode'
      When call nix_flake_targets apply
      The output should equal "$(printf 'nonprodApply\nprodApply')"
    End

    It 'prints nothing without flake.nix'
      rm flake.nix
      When call nix_flake_targets all
      The output should equal ""
    End

    It 'sorts independent of the locale'
      echo 'inherit nonprod_apply nonprod_Plan;' > flake.nix
      When call env LC_ALL=en_US.UTF-8 bash -c ". '${RACE_ROOT}/_racelib.sh'; nix_flake_targets all"
      The output should equal "$(printf 'nonprod_Plan\nnonprod_apply')"
    End
  End

  Describe 'nix_backend_target'
    It 'prefers the apply target in full mode'
      When call nix_backend_target all nonprod
      The output should equal "nonprodApply"
    End

    It 'returns the apply target in apply mode'
      When call nix_backend_target apply prod
      The output should equal "prodApply"
    End

    It 'prefers apply over plan when C-locale sorting puts plan first'
      echo 'inherit nonprod_apply nonprod_Plan;' > flake.nix
      When call nix_backend_target all nonprod
      The output should equal "nonprod_apply"
    End

    It 'falls back to a plan target in full mode'
      echo 'inherit stagingPlan;' > flake.nix
      When call nix_backend_target all staging
      The output should equal "stagingPlan"
    End

    It 'returns nothing in apply mode when only a plan target matches'
      echo 'inherit stagingPlan;' > flake.nix
      When call nix_backend_target apply staging
      The output should equal ""
    End

    It 'returns nothing without a backend'
      When call nix_backend_target all ""
      The output should equal ""
    End
  End

  Describe 'nixrun.sh'
    setup_nixrun() {
      mkdir -p .terraform bin
      echo "nonprod" > .terraform/tfbackend.state
      # Stub nix: print the command instead of running it
      printf '#!/usr/bin/env bash\necho "nix $*"\n' > bin/nix
      chmod +x bin/nix
      PATH="$TEST_DIR/bin:$PATH"
      export PATH
    }
    BeforeEach 'setup_nixrun'

    It 'runs the matched apply target after confirmation'
      Data "y"
      When run script "${RACE_ROOT}/nixrun.sh"
      The output should include "Found target based on .terraform/tfbackend.state: nonprodApply"
      The output should include "nix run .#nonprodApply"
      The status should be success
    End

    It 'shows plan and apply targets in the menu in full mode'
      Data
        #|n
        #|q
      End
      When run script "${RACE_ROOT}/nixrun.sh"
      The output should include "nonprodPlan"
      The output should include "prodPlan"
      The output should include "prodApply"
    End

    It 'shows only apply targets in the menu in apply mode'
      export RACE_NIXRUN_MODE=apply
      Data
        #|n
        #|q
      End
      When run script "${RACE_ROOT}/nixrun.sh"
      The output should include "1. nonprodApply"
      The output should include "2. prodApply"
      The output should not include "Plan"
    End

    It 'fails when apply mode finds no apply targets'
      export RACE_NIXRUN_MODE=apply
      echo 'inherit nonprodPlan;' > flake.nix
      When run script "${RACE_ROOT}/nixrun.sh"
      The output should include "No apply targets found in flake.nix"
      The status should be failure
    End

    It 'points to race init when no backend is selected'
      rm .terraform/tfbackend.state
      When run script "${RACE_ROOT}/nixrun.sh"
      The output should include "race init"
      The status should be failure
    End

    It 'stops when --override-tf is given'
      When run script "${RACE_ROOT}/nixrun.sh" apply --override-tf
      The output should include "--override-tf is an option of race apply"
      The output should include "race apply --override-tf"
      The output should not include "nix run .#"
      The status should be failure
    End

    It 'stops on --override-tf also without flake.nix'
      rm flake.nix
      When run script "${RACE_ROOT}/nixrun.sh" --override-tf
      The output should include "race apply --override-tf"
      The status should be failure
    End

    It 'warns that extra arguments are ignored'
      Data "y"
      When run script "${RACE_ROOT}/nixrun.sh" -target=module.x
      The output should include "Extra arguments are ignored for nix run: -target=module.x"
      The output should include "nix run .#nonprodApply"
    End
  End
End

# shellcheck shell=bash
# spec/racelib_spec.sh - Unit tests for _racelib.sh core functions

Describe '_racelib.sh core functions'
  Include spec/spec_helper.sh

  Describe 'show_version'
    # Mock the VERSION-race file
    setup() {
      TEST_DIR=$(mktemp -d)
      export thisdir="$TEST_DIR"
      echo "1.0.0" > "$TEST_DIR/VERSION-race"
    }

    cleanup() {
      rm -rf "$TEST_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'outputs version information'
      When call show_version
      The output should include "race v1.0.0"
      The status should be success
    End

    It 'includes Technative credit'
      When call show_version
      The output should include "Technative"
      The status should be success
    End

    It 'includes github URL'
      When call show_version
      The output should include "github.com/wearetechnative/race"
      The status should be success
    End
  End

  Describe 'checkNixPresent'
    setup() {
      TEST_DIR=$(mktemp -d)
      cd "$TEST_DIR" || return 1
    }

    cleanup() {
      cd /
      rm -rf "$TEST_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'does nothing when no nix files present'
      When call checkNixPresent
      The output should equal ""
      The status should be success
    End

    It 'warns when nix files are present'
      Skip "Requires gum interaction - tested manually"
    End
  End

  Describe 'set_tf_vars'
    setup() {
      TEST_DIR=$(mktemp -d)
      cd "$TEST_DIR" || return 1
      mkdir -p .terraform
    }

    cleanup() {
      cd /
      rm -rf "$TEST_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'finds single tfvars file'
      echo '{}' > nonprod.tfvars.json
      When call set_tf_vars
      The variable TF_VAR should include "nonprod.tfvars.json"
      The output should include "Using TF variable-file"
      The status should be success
    End

    It 'matches tfvars with tfbackend environment'
      echo '{}' > nonprod.tfvars.json
      echo '{}' > prod.tfvars.json
      echo "../../infra_environments/nonprod/nonprod.tfbackend" > .terraform/tfbackend.state
      When call set_tf_vars
      The variable TF_VAR should include "nonprod.tfvars.json"
      The output should include "Using TF variable-file"
      The status should be success
    End

    It 'finds tfvars in CatStack structure'
      mkdir -p stack/01_domain infra_environments/nonprod
      echo '{}' > infra_environments/nonprod/nonprod.tfvars.json
      cd stack/01_domain
      mkdir -p .terraform
      echo "../../infra_environments/nonprod/nonprod.tfbackend" > .terraform/tfbackend.state
      When call set_tf_vars
      The variable TF_VAR should include "nonprod.tfvars.json"
      The output should include "Using TF variable-file"
      The status should be success
    End
  End

  Describe 'multiple_vars'
    It 'is defined'
      The function multiple_vars should be defined
    End
    
    # Note: multiple_vars is interactive (uses select), tested via integration
  End
End

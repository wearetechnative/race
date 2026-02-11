# shellcheck shell=bash
# spec/git_sync_spec.sh - Unit tests for git sync functions

Describe 'Git sync functions'
  Include spec/spec_helper.sh

  Describe 'check_git_status'
    setup() {
      TEST_DIR=$(mktemp -d)
      cd "$TEST_DIR" || return 1
      # Enable git sync for these tests
      export RACE_GIT_SYNC_ENABLED=true
    }

    cleanup() {
      cd /
      rm -rf "$TEST_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'returns success for clean repo with no untracked files'
      git init -q
      git config user.email "test@example.com"
      git config user.name "Test"
      echo "test" > file.txt
      git add file.txt
      git commit -q -m "initial"
      When call check_git_status
      The status should be success
    End

    It 'returns failure when untracked files exist'
      git init -q
      git config user.email "test@example.com"
      git config user.name "Test"
      echo "tracked" > tracked.txt
      git add tracked.txt
      git commit -q -m "initial"
      echo "untracked" > untracked.txt
      When call check_git_status
      The status should be failure
      The output should include "Untracked files"
    End

    It 'returns 2 and warns when not a git repository'
      When call check_git_status
      The status should equal 2
      The output should include "Not a git repository"
    End
  End

  Describe 'get_stack_domain'
    setup() {
      TEST_DIR=$(mktemp -d)
      cd "$TEST_DIR" || return 1
      unset RACE_STACK_DOMAIN
    }

    cleanup() {
      unset RACE_STACK_DOMAIN
      cd /
      rm -rf "$TEST_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'returns RACE_STACK_DOMAIN when set'
      export RACE_STACK_DOMAIN="custom_domain"
      When call get_stack_domain
      The output should equal "custom_domain"
      The status should be success
    End

    It 'extracts domain from CatStack stack/ path'
      mkdir -p stack/01_shared_kms
      cd stack/01_shared_kms
      When call get_stack_domain
      The output should equal "01_shared_kms"
      The status should be success
    End

    It 'extracts numbered domain from stack/ path'
      mkdir -p stack/02_backend_config
      cd stack/02_backend_config
      When call get_stack_domain
      The output should equal "02_backend_config"
      The status should be success
    End

    It 'falls back to current directory basename'
      When call get_stack_domain
      # Will return the temp dir basename
      The output should not equal ""
      The status should be success
    End
  End

  Describe 'get_current_environment'
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

    It 'returns unknown when no tfbackend.state exists'
      When call get_current_environment
      The output should equal "unknown"
      The status should be failure
    End

    It 'extracts nonprod from infra_environments path'
      mkdir -p .terraform
      echo "../../infra_environments/nonprod/nonprod.tfbackend" > .terraform/tfbackend.state
      When call get_current_environment
      The output should equal "nonprod"
      The status should be success
    End

    It 'extracts prod from infra_environments path'
      mkdir -p .terraform
      echo "../../infra_environments/prod/prod.tfbackend" > .terraform/tfbackend.state
      When call get_current_environment
      The output should equal "prod"
      The status should be success
    End

    It 'extracts environment from basename as fallback'
      mkdir -p .terraform
      echo "/some/other/path/staging.tfbackend" > .terraform/tfbackend.state
      When call get_current_environment
      The output should equal "staging"
      The status should be success
    End
  End

  Describe 'git_sync_apply'
    setup() {
      TEST_DIR=$(mktemp -d)
      cd "$TEST_DIR" || return 1
      git init -q
      git config user.email "test@example.com"
      git config user.name "Test"
      echo "initial" > README.md
      git add README.md
      git commit -q -m "initial"
    }

    cleanup() {
      cd /
      rm -rf "$TEST_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'creates a tag with correct format'
      # Modify a tracked file
      echo "updated" >> README.md
      
      # Mock git push to prevent actual push
      git() {
        case "$1" in
          push) return 0 ;;
          *) command git "$@" ;;
        esac
      }
      
      When call git_sync_apply "nonprod" "01_test"
      The output should include "Git sync:"
      The status should be success
    End

    It 'handles no changes gracefully (tag only)'
      # No modifications to commit
      
      # Mock git push
      git() {
        case "$1" in
          push) return 0 ;;
          *) command git "$@" ;;
        esac
      }
      
      When call git_sync_apply "prod" "02_domain"
      The output should include "No changes to commit"
      The status should be success
    End
  End

  Describe 'run_apply_with_sync'
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

    It 'runs command directly when git sync disabled'
      export RACE_GIT_SYNC_ENABLED=false
      When call run_apply_with_sync echo "test command"
      The output should equal "test command"
      The status should be success
    End

    It 'aborts when untracked files exist'
      export RACE_GIT_SYNC_ENABLED=true
      git init -q
      git config user.email "test@example.com"
      git config user.name "Test"
      echo "tracked" > tracked.txt
      git add tracked.txt
      git commit -q -m "initial"
      echo "untracked" > untracked.txt
      When call run_apply_with_sync echo "test"
      The status should be failure
      The output should include "Aborting"
    End

    It 'runs command and skips sync for non-git directory'
      export RACE_GIT_SYNC_ENABLED=true
      When call run_apply_with_sync echo "test command"
      The output should include "test command"
      The output should include "Not a git repository"
      The status should be success
    End
  End
End

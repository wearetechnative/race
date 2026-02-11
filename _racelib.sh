#!/usr/bin/env bash

# Git Sync Configuration
RACE_GIT_SYNC_ENABLED="${RACE_GIT_SYNC_ENABLED:-true}"
RACE_GIT_REMOTE="${RACE_GIT_REMOTE:-origin}"

# check_git_status - Verify git repository status before apply
# Returns 0 if safe to proceed, 1 if untracked files exist, 2 if not a git repo (warning only)
function check_git_status() {
  # Check if we're in a git repository
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Warning: Not a git repository. Git sync will be skipped."
    return 2
  fi

  # Check for untracked files
  local untracked_files
  untracked_files=$(git ls-files --others --exclude-standard)

  if [[ -n "$untracked_files" ]]; then
    echo "Error: Untracked files detected. Please commit or ignore them before applying."
    echo "Untracked files:"
    echo "$untracked_files" | sed 's/^/  /'
    return 1
  fi

  return 0
}

# get_stack_domain - Determine the stack domain name
# Priority: 1) RACE_STACK_DOMAIN env var, 2) CatStack stack/ directory, 3) current directory basename
function get_stack_domain() {
  # Check for explicit override
  if [[ -n "${RACE_STACK_DOMAIN:-}" ]]; then
    echo "$RACE_STACK_DOMAIN"
    return 0
  fi

  # Check if we're in a CatStack stack/ directory structure
  local current_dir
  current_dir=$(pwd)

  if [[ "$current_dir" == *"/stack/"* ]]; then
    # Extract domain name from path (e.g., /path/to/project/stack/01_shared_kms -> 01_shared_kms)
    local domain
    domain=$(echo "$current_dir" | sed 's|.*/stack/||' | cut -d'/' -f1)
    if [[ -n "$domain" ]]; then
      echo "$domain"
      return 0
    fi
  fi

  # Fallback to current directory basename
  basename "$current_dir"
}

# get_current_environment - Determine environment from tfbackend state
# Returns: nonprod, prod, or the basename of the tfbackend file
function get_current_environment() {
  local tf_backend
  tf_backend=$(cat .terraform/tfbackend.state 2>/dev/null)

  if [[ -z "$tf_backend" ]]; then
    echo "unknown"
    return 1
  fi

  # Extract environment from path (e.g., infra_environments/nonprod/nonprod.tfbackend -> nonprod)
  if [[ "$tf_backend" == *"infra_environments/"* ]]; then
    local env
    env=$(echo "$tf_backend" | sed 's|.*infra_environments/||' | cut -d'/' -f1)
    echo "$env"
    return 0
  fi

  # Fallback: extract basename without extension
  basename "$tf_backend" | sed 's/\.[^.]*$//'
}

# git_sync_apply - Commit, tag, and push after successful apply
# Arguments: $1 = environment, $2 = domain
function git_sync_apply() {
  local environment="${1:-unknown}"
  local domain="${2:-unknown}"
  local timestamp
  timestamp=$(date +"%Y%m%d-%Hh%Mm")
  local tag="${environment}_${domain}_${timestamp}"
  local commit_msg="Applied ${environment} ${domain}"

  echo "Git sync: Committing and tagging as ${tag}..."

  # Stage all modified tracked files
  git add -u

  # Check if there are changes to commit
  if git diff --cached --quiet; then
    echo "No changes to commit. Creating tag only."
  else
    if ! git commit -m "$commit_msg"; then
      echo "Warning: Git commit failed."
      return 1
    fi
  fi

  # Handle existing tag - remove locally and remotely
  if git tag -l | grep -q "^${tag}$"; then
    echo "Removing existing local tag: ${tag}"
    git tag -d "$tag" 2>/dev/null || true
  fi

  # Remove remote tag if it exists
  git push "${RACE_GIT_REMOTE}" --delete "$tag" 2>/dev/null || true

  # Create new tag
  if ! git tag "$tag"; then
    echo "Warning: Failed to create tag ${tag}."
    return 1
  fi

  # Push commits and tags
  echo "Pushing to ${RACE_GIT_REMOTE}..."
  if ! git push "${RACE_GIT_REMOTE}"; then
    echo "Warning: Git push failed. Local commit preserved."
    return 1
  fi

  if ! git push "${RACE_GIT_REMOTE}" "$tag"; then
    echo "Warning: Failed to push tag ${tag}."
    return 1
  fi

  echo "Git sync complete: ${tag}"
  return 0
}

# run_apply_with_sync - Wrapper that runs apply command with git sync
# Arguments: $@ = the apply command to run
# Returns: exit code of the apply command
function run_apply_with_sync() {
  local apply_exit_code

  # Skip git sync if disabled
  if [[ "${RACE_GIT_SYNC_ENABLED}" == "false" ]]; then
    eval "$@"
    return $?
  fi

  # Pre-apply git status check
  check_git_status
  local git_status=$?

  if [[ $git_status -eq 1 ]]; then
    # Untracked files - abort
    echo "Aborting apply due to untracked files."
    return 1
  fi

  local skip_sync=false
  if [[ $git_status -eq 2 ]]; then
    # Not a git repo - proceed but skip sync
    skip_sync=true
  fi

  # Run the apply command
  eval "$@"
  apply_exit_code=$?

  # Only sync on success
  if [[ $apply_exit_code -eq 0 && "$skip_sync" == "false" ]]; then
    local environment
    local domain
    environment=$(get_current_environment)
    domain=$(get_stack_domain)
    git_sync_apply "$environment" "$domain"
  fi

  return $apply_exit_code
}

function show_version(){
  version=`cat $thisdir/VERSION-race`
  echo
  echo "    race v${version}"
  echo "    Standard Base utilities"
  echo
  echo "    http://github.com/wearetechnative/race"
  echo
  echo "    by Wouter, Pim, et al."
  echo "    © Technative 2024"
  echo
}

function checkNixPresent() {
  for file in *.nix; do
    if [[ -e "$file" ]]; then
      echo "NIX-files found in the current directory."
      gum confirm "Are you sure to execute terraform command?" || exit
    fi
  done
}

function multiple_vars() {

  PS3="Select a var-file number: "
  # echo "-: Unset"
  select item in "${TF_VARS_BASE[@]}"; do
    if [[ -n ${item} ]]; then
      # echo "Using var-file: $item"
      ((REPLY--))
      TF_VAR=${TF_VARS[${REPLY}]} #${item}
      break
    fi
  done
}

#TF_VAR=""
#TF_VARS=()
#TF_VARS_BASE=()

function set_tf_vars(){

  unset TF_VAR TF_VARS

  # Extract the base directory containing '*.tfvars' files
  base_directory=$(pwd)
  if [[ "$base_directory" == *"stack"* ]]; then
    base_directory=$(dirname "${base_directory%stack*}stack")
  fi

  # Set TF_ENV variable
  # Find all '*.tfvars' files in the base directory
  TF_VARS=($(find "${base_directory}" -type f -name "*.tfvars.json" -o -name "*.tfvars" | sort))
  TF_VARS_BASE=($(find "${base_directory}" -type f -name "*.tfvars.json" -o -name "*.tfvars" -exec basename {} \; | sort))
  TF_VARS_LEN=${#TF_VARS[*]}

  if [[ ${TF_VARS_LEN} -eq 1 ]]; then
    echo "just one backend"
    TF_VAR=${TF_VARS}
  fi

  TF_BACKEND=$(cat .terraform/tfbackend.state 2>/dev/null)

  if [[ ! -z ${TF_BACKEND} ]]; then
    TF_ENV=$(basename $(echo $TF_BACKEND) | awk -F '.' '{print $1}' 2>&1)

    for var in "${TF_VARS[@]}"; do
      if [[ $var == *"${TF_ENV}"* ]]; then
        TF_VAR="$var"
      fi
    done
    if [[ -z ${TF_VAR} ]]; then
      multiple_vars
    fi
  fi

  if [[ ${TF_VARS_LEN} -ge 2 && -z ${TF_VAR} ]]; then
    echo "multiple backends, not matching"
    multiple_vars
  fi

  echo "Using TF variable-file: ${TF_VAR}"
}



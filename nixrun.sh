#!/usr/bin/env bash




# Source shared library for git sync functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_racelib.sh"




# Function to run nix target with optional git sync
run_nix_target() {
  local target="$1"

  if is_apply_target "$target"; then
    # For apply targets, use git sync wrapper
    run_apply_with_sync "nix run .#$target"
  else
    # For non-apply targets (plan, etc.), run directly
    nix run .#"$target"
  fi
}

# Function to check if target is an apply target
is_apply_target() {
  local target="$1"
  [[ "$target" =~ [Aa]pply$ ]]
}



# Function to display menu and get user choice
display_menu_and_get_choice() {
  # Display menu
  echo "Select a target to run:"
  for i in "${!APPLY_TARGETS[@]}"; do
    echo "$((i+1)). ${APPLY_TARGETS[$i]}"
  done
  echo "q. quit"

  # Get user choice
  read -p "Enter your choice [1-${#APPLY_TARGETS[@]} or -]: " choice

  # Handle quit option
  if [[ "$choice" == "q" ]]; then
    echo "Exiting."
    exit 0
  fi

  # Validate input
  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#APPLY_TARGETS[@]} ]; then
    echo "Invalid choice. Exiting."
    exit 1
  fi

  return 0
}





# Check if flake.nix exists
if [ ! -f "flake.nix" ]; then
  echo "Error: flake.nix not found. This script must be run from a directory containing a flake.nix file."
  exit 1
fi

# Check if .terraform/tfbackend.state exists and get its content
if [ ! -f ".terraform/tfbackend.state" ]; then
  echo "Error: No terraform backend selected. .terraform/tfbackend.state not found."
  echo "Set the backend first: race init"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  echo "Warning: Extra arguments are ignored for nix run: $*"
fi

# RACE_NIXRUN_MODE=apply (set by race apply) offers apply targets only
RACE_NIXRUN_MODE="${RACE_NIXRUN_MODE:-all}"

BACKEND_CONTENT=$(cat .terraform/tfbackend.state)

# Get the targets from flake.nix
mapfile -t APPLY_TARGETS < <(nix_flake_targets "$RACE_NIXRUN_MODE")
if [[ ${#APPLY_TARGETS[@]} -eq 0 ]]; then
  if [[ "$RACE_NIXRUN_MODE" == "apply" ]]; then
    echo "Error: No apply targets found in flake.nix."
  else
    echo "Error: No apply or plan targets found in flake.nix."
  fi
  exit 1
fi








# Look for a target matching the backend, preferring apply over plan
TARGET=$(nix_backend_target "$RACE_NIXRUN_MODE" "$BACKEND_CONTENT")












if [ -n "$TARGET" ]; then
  echo "Found target based on .terraform/tfbackend.state: $TARGET"
  echo "About to run: nix run .#$TARGET"
  read -p "Proceed? (y/n): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Running: nix run .#$TARGET"
    run_nix_target "$TARGET"
    exit $?
  else
    echo "Command cancelled. Showing all available targets."
    # Continue to the menu below
  fi
fi

# Display menu and get initial choice
display_menu_and_get_choice

# Process user choice
while true; do
  selected_target=${APPLY_TARGETS[$((choice-1))]}
  echo "About to run: nix run .#$selected_target"
  read -p "Proceed? (y/n): " confirm

  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Running: nix run .#$selected_target"
    run_nix_target "$selected_target"
    exit $?
  else
    echo "Command cancelled. Showing all available targets."
    display_menu_and_get_choice
  fi
done

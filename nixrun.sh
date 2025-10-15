#!/usr/bin/env bash

# Check if flake.nix exists
if [ ! -f "flake.nix" ]; then
  echo "Error: flake.nix not found. This script must be run from a directory containing a flake.nix file."
  exit 1
fi

# Check if .terraform/tfbackend.state exists and get its content
if [ ! -f ".terraform/tfbackend.state" ]; then
  echo "Warning: Can't determine terraform backend status. .terraform/tfbackend.state not found."
  exit 1
fi

BACKEND_CONTENT=$(cat .terraform/tfbackend.state)

# Look for a matching target in flake.nix that has the pattern: inherit <content>.*_apply;
#TARGET=$(grep -o "inherit ${BACKEND_CONTENT}.*_apply;" flake.nix 2>/dev/null | sed 's/inherit //;s/;//')
TARGET=($(grep -Eo '\b([A-Za-z0-9_]*(apply|plan|Apply|Plan))\b' flake.nix |grep -v ^apply |sort -u |grep -i ^${BACKEND_CONTENT}))

if [ -n "$TARGET" ]; then
  echo "Found target based on .terraform/tfbackend.state: $TARGET"
  echo "About to run: nix run .#$TARGET"
  read -p "Proceed? (y/n): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Running: nix run .#$TARGET"
    nix run .#"$TARGET"
    exit 0
  else
    echo "Command cancelled. Showing all available targets."
    # Continue to the menu below
  fi
fi

# Get all apply targets from flake.nix
#APPLY_TARGETS=($(awk '/inherit.*apply/ { gsub(/;/, ""); print $2 }' flake.nix))
APPLY_TARGETS=($(grep -Eo '\b([A-Za-z0-9_]*(apply|plan|Apply|Plan))\b' flake.nix |grep -v ^apply |sort -u ))

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

# Display menu and get initial choice
display_menu_and_get_choice

# Process user choice
while true; do
  selected_target=${APPLY_TARGETS[$((choice-1))]}
  echo "About to run: nix run .#$selected_target"
  read -p "Proceed? (y/n): " confirm
  
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Running: nix run .#$selected_target"
    nix run .#"$selected_target"
    exit 0
  else
    echo "Command cancelled. Showing all available targets."
    display_menu_and_get_choice
  fi
done

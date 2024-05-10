#!/usr/bin/env sh


clipboardEditor="pbcopy"

set -eu

itemType="$1"
itemQuery="$2"


#RBW_MENU_COMMAND="gum filter"
IFS='

'
# Creator: Robert Buchberger <robert@buchberger.cc>
#                            @robert@spacey.space
#
# Select an item from bitwarden with wofi, return value for passed query
# Dependencies: rbw installed and configured
#
# Usage: rbw-menu [query]
#   query: "code" or anything on the login object; username, password, totp, etc
#     - code will return a TOTP code
#     - anything else will return the value of the query
#   default: username

# Check if rbw is locked, redirect stderr and stdout to /dev/null. Unlock if
# necessary.
rbw unlocked >/dev/null 2>&1 || rbw unlock

chosen_item=$(
		rbw list |gum filter --value "${itemQuery}" --no-fuzzy 
)

# Exit if user didn't select anything
[ "$chosen_item" = "" ] && exit 1

case "$itemType" in
code)
  rbwOutput=$(rbw code "$chosen_item")
	;;
*)
	# Select chosen item from vault, return login.query
  rbwOutput=$(rbw get "$chosen_item" --raw | jq --join-output ".data.$query")
	;;
esac

if [[ ! -z ${clipboardEditor} ]]; then
  echo "clipboard"
  echo ${rbwOutput} | pbcopy #$(which ${clipboardEditor})
fi
  echo ${rbwOutput}

#!/usr/bin/env sh

itemType=""
itemQuery=""

while getopts 't:q:' opt; do
  case "$opt" in
  t) 
    itemType="$OPTARG" 
  ;;
  q) 
    itemQuery="$OPTARG" 
  ;;
  esac
done
shift "$(($OPTIND - 1))"

# Check for mandatory variables
 
check_variables() {
    local var_names=("$@")  # Namen van de variabelen
    local all_vars_set=true  # Standaard gaan we ervan uit dat alle variabelen zijn ingesteld

    # Itereer door de namen van de variabelen
    for var_name in "${var_names[@]}"; do
        # Haal de waarde van de variabele op
        local value="${!var_name}"

        # Controleer of de waarde van de variabele leeg is
        if [ -z "$value" ]; then
            echo "$var_name is niet gevuld. Het script stopt."
            all_vars_set=false
            break
        fi
    done

    # Als alle variabelen zijn ingesteld, gaat het script door
    if [[ -z $all_vars_set ]] ; then
        exit 
    fi
}

check_variables itemType itemQuery



<<<<<<< HEAD
=======
#clipboardEditor="pbcopy"
clipboardEditor="xclip"
>>>>>>> 3250374 (fix copy clipboard functionality)

set -eu

#itemType="$1"
#itemQuery="$2"


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

<<<<<<< HEAD
echo ${rbwOutput}
=======
if [[ ! -z ${clipboardEditor} ]]; then
  echo ${rbwOutput} | ${clipboardEditor} #$(which ${clipboardEditor})
fi
  echo ${rbwOutput}
>>>>>>> 3250374 (fix copy clipboard functionality)

#!/usr/bin/env bash
#Version: 202403141

function check_prerequisites(){
  if [[ -z ${AWS_PROFILE} ]]; then
    echo "!!! AWS_PROFILE NOT SET"
    script_error+=1
  fi

  if [[ ${script_error} -gt 0 ]]; then
   echo "!!! There are fatal errors. Exiting"
   exit 1
  fi
}
function get_current_directory() {
  # Get the current directory
  current_directory=$(pwd)

  # Check if the string "$(pwd)" contains 'stack'
  if [[ "$current_directory" == *"stack"* ]]; then
    # Extract the parent directory of 'stack'
    base_directory=$(dirname "${current_directory%stack*}stack")
    #echo "Parent directory of 'stack': $parent_directory"
  else
    echo "'stack' not found in the current directory path"
    base_directory=${current_directory}
  fi
  echo "DEBUG: ${base_directory}"
}

function create_environments_list() {
  environments=$(find  ${base_directory} -maxdepth 3 -type f -name "*.tfvars.json" | sort)
  if [[ -z ${environments} ]]; then
    echo "!! No environments files found"
    exit 1
  fi

  env_name=()

  for item in ${environments}; do
    env_name+=("$(basename $item)")
  done
  environments=($environments)
  envs_len=${#environments[*]}
}

IFSBAK=$IFS
IFS=$'\n'
IFS=$IFSBAK

environments=($environments)
envs_len=${#environments[*]}


function main {
  check_prerequisites
  get_current_directory
  create_environents_list
  selection_menu
}

function usage {
  echo "Usage: $(basename $0) [-h|--help]"
  echo "For normal usage, just run aps and make your selection followed by Enter."
  # exit 1
}

#function set_tfbackend_prompt {
#  TF_BACKENDPROMPTBAK=
#  TF_BACKEND=$(terraform show | grep -A2 "module.terraformbackend.module.state_lock.aws_dynamodb_table.this" | tail -1 | awk -F ":" '{print $5}')
#}

function set_tfbenv {
  backend_file=$1
  backend_file_basename=$(basename ${backend_file}|sed 's/.tfvars.json//g')
  if [[ -z ${backend_file} ]]; then
    echo "!!! Error backend-file"
    exit 1
  fi
  #terraform init -backend-config="${backend_file}" -reconfigure || echo "Could not set terraform backend. Not setup yet?"
  echo ${backend_file_basename} >.terraform/tfbackend.state
  # TF_ENV=$(echo $TF_BACKEND |awk -F '.' '{print $1}')
  # export TF_ENV
}

function set_prompt {
  echo "-: Unset TF_ENVIRONMENT"
  for ((i = 0; i < $envs_len; i++)); do
    echo "$i: ${environments[$i]}"
  done
  read_selection
}

function selection_menu {
  echo ------------- Select Backend -------------
  echo "Type the number of the backend you want to use from the list below, and press enter"
  echo

  # Show the menu
  echo "-: Unset backend"
  for ((i = 0; i < $envs_len; i++)); do
    echo "$i: ${env_name[$i]}"
  done
  read_selection
}

function read_selection {
  echo
  printf 'Selection: '
  read choice
  case $choice in
  '' | *[!0-9\-]*)
    clear
    echo Invalid selection. Make a valid selection from the list above or press ctrl+c to exit
    echo '-> Error: Not a number, and not "-"'
    echo
    selection_menu
    ;;
  esac
  in_range=false
  while [ $in_range != true ]; do
    if [[ $choice == '-' ]]; then
      echo "Deactivating backend"
      echo rm ${backend_file}
      in_range=true
    elif (($choice >= 0)) && (($choice <= ${envs_len})); then
      # Set AWS_SDK_LOAD_CONFIG to true to make this useful for tools such as Terraform and Serverless framework

      echo "Activating backend ${choice}: ${environments[choice]}"
      export TF_BACKEND="${environments[choice]}"
      set_tfenv ${environments[choice]} ${choice}
      in_range=true
    else
      clear
      echo Invalid selection. Select a valid profile number or press ctrl+c to exit
      echo "-> Error:  Number must be one of 0-"$((${#environments[@]} - 1))""
      echo
      selection_menu
    fi
  done
}

if [ $# -gt 0 ]; then
  while [ ! $# -eq 0 ]; do
    case "$1" in
    --help | -h)
      usage
      ;;
    --no-sdk | -n)
      sdk=0
      # Kick off the main function:
      main
      ;;
    esac
    shift
  done
else
  # Kick off the main function:
  main
fi

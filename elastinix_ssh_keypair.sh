#!/usr/bin/env bash

currentDir=$(basename ${PWD})
projectDir=$(dirname ${PWD})
projectName=$(basename ${projectDir})
localDataDir="${projectDir}/local_data"
keyFile="${localDataDir}/${projectName}-key"


function checkPrerequisites() {
  if [[ ! ${currentDir} == "scripts" ]]; then
    echo "!! Error: This script must be executed from the <project_dir>/scripts directory."
    exit 1
  fi

  if [[ ! -d ${localDataDir} ]]; then
    echo "-- Notice: The local data directory (${localDataDir}) does not exist. It will now be created."
    mkdir ${localDataDir}
  fi
  echo -e "Current AWS profile: \e[1m\e[41m${AWS_PROFILE}\e[0m"
  echo "!! Please review the details before proceeding."
  gum confirm || exit
}


function keyExists() {
  parameterName="/key_pair/${projectName}-key"
  awsOutput=$(aws ssm get-parameter --name "$parameterName" 2>&1)
  if [[ "$awsOutput" != *"ParameterNotFound"* ]]; then
    keyName=$(basename $(jq -r '.Parameter.Name' <<< "$awsOutput"))
    echo -e "Info: Key successfully found in AWS Parameter Store: \e[1m\e[32m${keyName}\e[0m"
    return 0 # key present
  else
    echo -e "INFO: Key not found in AWS Parameter Store."
    return 1 # key not present
  fi
}


function setDownloadLocation() {
  echo "Configuring download location."
  downloadLocation=$(gum input --placeholder "Enter target location:" --value "${HOME}/.ssh/" --header "Enter directory to save the key:")
  if [[ ! -d ${downloadLocation} ]]; then mkdir -p "$downloadLocation"; chmod 0700 ${downloadLocation}; fi
  permissions=$(stat -c "%a" "$downloadLocation")
  if [ "$permissions" -ne 700 ]; then
    echo "Error: The directory $downloadLocation does not have the required permissions (0700). Current permissions: $permissions."
  fi
}

function downloadKey() {
  gum confirm "Do you wish to download the key?" && downloadChoice="yes"
  if [[ "$downloadChoice" == "yes" ]]; then
    setDownloadLocation
    if [[ -f ${downloadLocation}/${projectName}-key ]]; then
      echo "Error: A key with the same name already exists in the selected download location."
    else
      aws ssm get-parameter --name "$parameterName" --with-decryption --query 'Parameter.Value' --output text > "$downloadLocation/${projectName}-key"
      chmod 600  $downloadLocation/${projectName}-key
      echo "Success: Parameter value has been downloaded to $downloadLocation${projectName}-key"
    fi
  else
    echo "Notice: Key download has been skipped."
  fi
}



function generateKey() {
  if [[ ! -f ${keyFile} ]]; then
    echo -e "Generating SSH key: \e[1m\e[42m$(basename ${keyFile})\e[0m"


    ssh-keygen -t ed25519 -f ${keyFile} -N "" -C ""
    uploadKey
    echo "Please download the generated key from the ./ssh folder in your home directory."
    downloadKey
  else
    echo "Error: SSH key already exists in this project."
    if keyExists "$1"; then
      uploadKey
    fi
  fi
}

function uploadKey() {
  echo "Preparing to upload key to AWS Parameter Store."
  gum confirm "Would you like to upload the keys to AWS Parameter Store?" && uploadKeyConfirmation="yes"
  if [[ ${uploadKeyConfirmation} == "yes" ]]; then
    echo "Uploading to AWS Parameter Store..."
    awsOutput=$(aws ssm put-parameter --name "/key_pair/${projectName}-key" --value "file://${keyFile}" --type "SecureString" --overwrite 2>&1)
    awsOutput=$(aws ssm put-parameter --name "/key_pair/${projectName}-key.pub" --value "file://${keyFile}.pub" --type "String" --overwrite 2>&1)
    echo "Success: Key uploaded to AWS Parameter Store:"
    echo -e "\e[1m\e[32m$(aws ssm describe-parameters --parameter-filters Key=Name,Option=Contains,Values="${projectName}-key" --output json | jq -r '.Parameters[].Name')\e[0m"
  else
    echo "Notice: Key upload has been canceled."
  fi
}


##

echo "Script execution started."
checkPrerequisites
if keyExists "$1"; then
  echo "Success: Key exists."
  downloadKey
else
  echo "Error: Key does not exist."
  generateKey
fi


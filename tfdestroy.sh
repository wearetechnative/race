#!/usr/bin/env bash

thisdir="$(dirname "$0")"
source "$thisdir/_racelib.sh"
checkNixPresent
set_tf_vars

if [[ ! -z ${TF_VAR} ]]; then
  terraform destroy -var-file=${TF_VAR} $@
else
  terraform destroy $@
fi

#!/usr/bin/env bash

# INCLUDE LIB
thisdir="$(dirname "$0")"
source "$thisdir/_racelib.sh"

set_tf_vars
if [[ ! -z ${TF_VAR} ]]; then
  terraform plan -var-file=${TF_VAR} $@
else
  terraform plan $@
fi

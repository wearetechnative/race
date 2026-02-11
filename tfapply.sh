#!/usr/bin/env bash

# INCLUDE LIB
thisdir="$(dirname "$0")"
source "$thisdir/_racelib.sh"
checkNixPresent
set_tf_vars

if [[ ! -z ${TF_VAR} ]]; then
  run_apply_with_sync terraform apply -var-file=${TF_VAR} $@
else
  run_apply_with_sync terraform apply $@
fi

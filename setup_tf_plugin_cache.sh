#!/usr/bin/env bash

PLUGIN_CACHE_DIR=~/.terraform.d/plugin-cache/
PLUGIN_CACHE_VAR="plugin_cache_dir"

if [ ! -d ~/.terraform.d/ ]
then
    echo "The directory ~/.terraform.d/ does not exist. Creating."
    mkdir -vp ${PLUGIN_CACHE_DIR}
elif [ ! -d ${PLUGIN_CACHE_DIR} ]
then
    echo "The directory ${PLUGIN_CACHE_DIR} does not exist. Creating."
    mkdir -v ${PLUGIN_CACHE_DIR}
else
    echo "The directory ${PLUGIN_CACHE_DIR} already exists."
fi

if [ -f ~/.terraformrc ]
then
    if grep -qE '^plugin_cache_dir\s*=\s*' ~/.terraformrc
    then
        echo "Current ~/.terraformrc already contains an plugin_cache_dir reference."
        echo -e "\nAborting!"
    else
        echo "Appending ${PLUGIN_CACHE_VAR} to ~/.terraformrc."
        echo -e "\n${PLUGIN_CACHE_VAR}=\"${PLUGIN_CACHE_DIR}\"" >> ~/.terraformrc
        echo "New contents:"
        cat ~/.terraformrc
        echo -e "\nDone!"
    fi
else
    echo "Creating new ~/.terraformrc."
    echo "${PLUGIN_CACHE_VAR}=\"${PLUGIN_CACHE_DIR}\"" >> ~/.terraformrc
    echo "New contents:"
    cat ~/.terraformrc
    echo -e "\nDone!"
fi

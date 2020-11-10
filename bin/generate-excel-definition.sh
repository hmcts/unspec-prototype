#!/bin/bash

set -eu

environment=${1:-demo}

if [[ ${environment} != "aat" && ${environment} != "demo" ]]; then
  echo "Environment '${environment}' is not supported!"
  exit 1
fi

excludedFilenamePatterns="-e UserProfile.json"

root_dir=$(realpath $(dirname ${0})/..)
config_dir=${root_dir}/definition
build_dir=${root_dir}/excel-definition
commit_hash=$(git rev-parse --short HEAD)
import_definition_output_file=${build_dir}/unspec-prototype-$(date +"%d-%m-%y_%H-%M-%S")-${commit_hash}.xlsx

mkdir -p ${build_dir}

# build the ccd definition file
${root_dir}/bin/utils/process-definition.sh ${config_dir} ${import_definition_output_file} "${excludedFilenamePatterns}"


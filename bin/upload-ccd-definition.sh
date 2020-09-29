#!/bin/bash

set -eu

environment=${1:-demo}

if [[ ${environment} != "aat" && ${environment} != "demo" ]]; then
  echo "Environment '${environment}' is not supported!"
  exit 1
fi

excludedFilenamePatterns="-e UserProfile.json"

root_dir=$(realpath $(dirname ${0})/..)
config_dir=${root_dir}/definition/sheets
build_dir=${root_dir}/build/ccd-import-config
import_definition_output_file=${build_dir}/ccd-unspec-${environment}.xlsx

mkdir -p ${build_dir}

$(${root_dir}/bin/variables/load-${environment}-environment-variables.sh)
$(${root_dir}/bin/variables/export-vault-value.sh ${environment})
$(${root_dir}/bin/variables/export-proxy.sh)

# build the ccd definition file
${root_dir}/bin/utils/process-definition.sh ${config_dir} ${import_definition_output_file} "${excludedFilenamePatterns}"

${root_dir}/bin/utils/ccd-import-definition.sh ${import_definition_output_file}


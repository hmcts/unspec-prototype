#!/usr/bin/env bash

function require () {
  local command=${1}
  local installMessage=${2}
  hash ${command} 2>/dev/null || {
    logError "${command} is not installed. ${installMessage}. Aborting."
    exit 1
  }
}

function UnspecKeyVaultRead() {
  az keyvault secret show --vault-name unspec-${ENVIRONMENT} --name ${1} --query value -o tsv
}

function CCDKeyVaultRead() {
  az keyvault secret show --vault-name ccd-${ENVIRONMENT} --name ${1} --query value -o tsv
}

function S2SKeyVaultRead() {
  az keyvault secret show --vault-name s2s-${ENVIRONMENT} --name ${1} --query value -o tsv
}

require az "On mac run \`brew install azure-cli\`"
require python3 "On mac run \`brew install python3\`"
require jq "On mac run \`brew install jq\`"

az account show &> /dev/null || {
    echo "Please run \`az login\` and follow the instructions first"
    exit 1
}
echo "export S2S_SECRET=$(UnspecKeyVaultRead 'microservicekey-unspec-service')"
echo "export CCD_CONFIGURER_IMPORTER_USERNAME=$(UnspecKeyVaultRead 'ccd-importer-username')"
echo "export CCD_CONFIGURER_IMPORTER_PASSWORD=$(UnspecKeyVaultRead 'ccd-importer-password')"

echo "export CCD_API_GATEWAY_IDAM_CLIENT_SECRET=$(CCDKeyVaultRead 'ccd-api-gateway-oauth2-client-secret')"

echo "export CCD_API_GATEWAY_S2S_SECRET=$(S2SKeyVaultRead 'microservicekey-ccd-gw')"
echo "export CCD_DATA_STORE_S2S_SECRET=$(S2SKeyVaultRead 'microservicekey-ccd-data')"
echo "export CCD_DEFINITION_STORE_S2S_SECRET=$(S2SKeyVaultRead 'microservicekey-ccd-definition')"

#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Include common.sh script
source "$(dirname "${0}")/common.sh"

: ${DOTENV_API_URL?"You need to set the DOTENV_API_URL environment variable."}
: ${DOTENV_API_TOKEN?"You need to set the DOTENV_API_TOKEN environment variable."}
: ${DOTENV_PROJECT?"You need to set the DOTENV_PROJECT environment variable."}
: ${DOTENV_ENVIRONMENT?"You need to set the DOTENV_ENVIRONMENT environment variable."}
: ${DOTENV_FILE_SOURCE?"You need to set the DOTENV_FILE_SOURCE environment variable."}
: ${DOTENV_FILE_TARGET?"You need to set the DOTENV_FILE_TARGET environment variable."}

# Set default values
: ${DOTENV_TYPE:=env}

dotenv() {
  if [[ ! -f ${DOTENV_FILE_SOURCE} ]]; then
    fail "Unable to find ${DOTENV_FILE_SOURCE}"
  fi

  cp ${DOTENV_FILE_SOURCE} ${DOTENV_FILE_TARGET}

  url="${DOTENV_API_URL}/${DOTENV_PROJECT}/${DOTENV_ENVIRONMENT}"

  info "Connecting to ${url}"

  # Get dotenv variables from the dotenv application, add status code to the end of the response
  response=$(curl -s -w "\n%{http_code}" ${url} \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${DOTENV_API_TOKEN}")

  # Get status code from last lines
  http_code=$(echo "${response}" | tail -n1)

  if [[ ${http_code} != 200 ]]; then
    fail "Can't connect to ${url}"
  fi

  # Strip status code from response
  response=$(echo "${response}" | sed '$ d')

  # Replace variable from the dotenv file
  for item_encoded in $(echo "${response}" | jq -r '.[] | @base64'); do
    item=$(echo "${item_encoded}" | base64 -d)
    variable=$(echo "${item}" | jq -r '.variable')
    value=$(echo "${item}" | jq -r '.value')

    replace "${variable}" "${value}"
  done

  # Replace EXTRAS_ variable added to pipe configuration
  info "Get variables from EXTRAS_*"

  # Loop through all environment variable looking for EXTRAS_*
  for variable in $(compgen -e); do
    if [[ ${variable} == EXTRAS_* ]]; then
      replace "${variable#EXTRAS_}" "${!variable}"
    fi
  done
}

replace() {
  # Escape value for sed pattern
  value=$(echo "$2" | sed -e 's/[\/&]/\\&/g')

  case ${DOTENV_TYPE} in
    js)

      # Escape single quotes in value because we use KEY: 'VALUE',
      value=$(echo "${value}" | sed -e "s/'/\\'/g")

      if grep -q "$1:.*$" ${DOTENV_FILE_TARGET}; then
        sed -i -e "s/$1:.*/$1: '${value}',/" ${DOTENV_FILE_TARGET}
        success "$1"
      else
        error "$1 not found in ${DOTENV_FILE_SOURCE}"
      fi

      ;;
    env)

      # Escape double quotes in value because we use KEY="VALUE"
      value=$(echo "${value}" | sed -e 's/"/\\"/g')

      if grep -q "^$1=.*$" ${DOTENV_FILE_TARGET}; then
        sed -i -e "s/^$1=.*/$1=\"${value}\"/" ${DOTENV_FILE_TARGET}
        success "$1"
      else
        error "$1 not found in ${DOTENV_FILE_SOURCE}"
      fi

      ;;
  esac
}

dotenv
#!/bin/bash
set -o errexit

eb_utils::env_find_passive() {
  local eb_args="${1}"
  local envs_all="$(eb list ${eb_args})"
  local envs_all=${envs_all/\* /}
  local env_result=''
  for x in ${envs_all}; do
    local status=$(eb status ${x} ${eb_args})
    if [[ "${status}" == *"CNAME: passive"* ]]; then
      local env_result="${x}"
      break
    fi
  done
  echo "${env_result}"
}

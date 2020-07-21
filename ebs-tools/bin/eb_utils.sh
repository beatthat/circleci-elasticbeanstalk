
eb_utils::env_find_env_with_cname_prefix_usage() {
  echo "eb_utils::env_find_env_with_cname_prefix [-x eb args] cname_prefix" 1>&2
}

eb_utils::env_find_env_with_cname_prefix() {
  local OPTIND OPTKEY eb_args
  while getopts ":x:" OPTKEY; do
    case ${OPTKEY} in
    'x' )
      eb_args="${OPTARG}"
      ;;
    '?')
      echo "Invalid option: ${OPTARG}" 1>&2
      eb_utils::env_find_passive_usage
      return 1
      ;;
    ':')
      echo "Invalid option: ${OPTARG} requires an argument" 1>&2
      eb_utils::env_find_passive_usage
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1))
  local cname_prefix="${1}"
  if [[ -z "${cname_prefix}" ]]; then
    echo "positional parameter for cname_prefix is required" 1>&2
    eb_utils::env_find_passive_usage
    return 1
  fi
  local envs_all="$(eb list ${eb_args})"
  local envs_all=${envs_all/\* /}
  local env_result=''
  for x in ${envs_all}; do
    local status=$(eb status ${x} ${eb_args})
    if [[ "${status}" == *"CNAME: ${cname_prefix}"* ]]; then
      local env_result="${x}"
      break
    fi
  done
  echo "${env_result}"
}

eb_utils::env_find_active() {
  eb_utils::env_find_env_with_cname_prefix "$@" active
}

eb_utils::env_find_passive() {
  eb_utils::env_find_env_with_cname_prefix "$@" passive
}

eb_utils::swap_active_and_passive() {
  local active="$(eb_utils::env_find_active)"
  local passive="$(eb_utils::env_find_passive)"
  if [[ -x "${active}" ]]; then
    echo "eb_utils:swap_active_and_passive failed to find 'active' env" 1>&2
    return 1
  fi
  if [[ -x "${passive}" ]]; then
    echo "eb_utils:swap_active_and_passive failed to find 'passive' env" 1>&2
    return 1
  fi
  eb swap ${passive} --destination_name ${active}
}
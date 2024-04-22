#!/usr/bin/env bash

#
#  This file is part of Kubepak.
#
#  Kubepak is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  Kubepak is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with Kubepak.  If not, see <https://www.gnu.org/licenses/>.
#

set -eo pipefail

# Kubepak start-up batch script

__SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly __SCRIPT_NAME

__SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
readonly __SCRIPT_DIR

#-----------------------------------------------------------------------------
# Private Variables

__opt_config_file=""
__opt_cache_root_path="${__SCRIPT_DIR}/.cache"
__is_cache_root_path_default=true

#-----------------------------------------------------------------------------
# Private Methods

__command_line_parse() {
    local __opts
    if ! __opts="$(getopt --options e:o:n:x:p:k:s:f:h --longoptions environment:,organization:,project:,context:,package:,set:,set-string:,config-file:,cache-root-path:,clean-cache,no-deps,help -n "${__SCRIPT_NAME}" -- "${@}")"; then
        printf "\033[0;31mERROR\033[0m: %b\n" "failed parsing options" >&2
        exit 1
    fi

    eval set -- "${__opts}"

    while true; do
        case "${1}" in
        -e | --environment | -o | --organization | -n | --project | -x | --context | -p | --package | -k | --set | -s | --set-string)
            shift 2
            ;;
        -f | --config-file)
            __opt_config_file="${2/"~"/${HOME}}"
            if [[ ! -e "${__opt_config_file}" ]]; then
                printf "\033[0;31mERROR\033[0m: %b\n" "config file '${__opt_config_file}' does not exist" >&2
                exit 1
            fi
            shift 2
            ;;
        --cache-root-path)
            __opt_cache_root_path="${2/"~"/${HOME}}"
            __is_cache_root_path_default=false
            shift 2
            ;;
        --clean-cache | --no-deps | -h | --help)
            shift
            ;;
        --)
            break
            ;;
        *)
            printf "\033[0;31mERROR\033[0m: %b\n" "internal error" >&2
            exit 1
            ;;
        esac
    done
}

#-----------------------------------------------------------------------------
# main

main() {
    __command_line_parse "${@}"

    # Make sure that the ssh-agent is started
    if [[ -z "${SSH_AUTH_SOCK}" ]]; then
        eval "$(ssh-agent -s)" >/dev/null
    fi

    mkdir -p "${HOME}/.kube" "${__opt_cache_root_path}"

    __opt_config_file="$(
        cd "$(dirname "${__opt_config_file}")"
        pwd
    )/$(basename "${__opt_config_file}")"

    __opt_cache_root_path="$(
        cd "${__opt_cache_root_path}"
        pwd
    )"

    # shellcheck disable=SC2046
    docker run \
        --name "kubepak" \
        --network "host" \
        --rm \
        -e "HOME=${HOME}" \
        -e "SSH_AUTH_SOCK=/ssh-agent" \
        -u "$(id -u):$(id -g)" \
        -v "${HOME}:${HOME}" \
        -v "${SSH_AUTH_SOCK}:/ssh-agent" \
        -v "/etc/group:/etc/group:ro" \
        -v "/etc/passwd:/etc/passwd:ro" \
        -v "$(dirname "${__opt_config_file}"):$(dirname "${__opt_config_file}")":ro \
        -v "${__opt_cache_root_path}:${__opt_cache_root_path}" \
        -w "$(pwd)" \
        kubepak:latest "${@}" $( (${__is_cache_root_path_default} && echo "--cache-root-path ${__opt_cache_root_path}") || :)
}

main "${@}"

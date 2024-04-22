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

__SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly __SCRIPT_NAME

__SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
readonly __SCRIPT_DIR

source "${__SCRIPT_DIR}/support/scripts/array.sh"
source "${__SCRIPT_DIR}/support/scripts/log.sh"
source "${__SCRIPT_DIR}/support/scripts/string.sh"
source "${__SCRIPT_DIR}/support/scripts/yaml.sh"

#-----------------------------------------------------------------------------
# Private Variables

__opt_environment=""
__opt_organization=""
__opt_project=""
__opt_context=""
__opt_packages=()
__opt_packages_to_ignore=()
__opt_kvp=()
__opt_kvp_string=()
__opt_cache_root_path="${__SCRIPT_DIR}/.cache"
__opt_clean_cache=false
__opt_no_deps=false
__opt_config_file=""

#-----------------------------------------------------------------------------
# Private Methods

__usage_print() {
    cat <<EOF
Usage: ${__SCRIPT_NAME} <command> [OPTION]...

Available Commands:
  install                                      install packages
  list                                         list the packages and their dependencies in their installation order
  upgrade                                      upgrade packages

Options:
  -e, --environment <environment>              specify the deployment environment:
                                                 dev (development)
                                                 int (integration)
                                                 tst (testing)
                                                 stg (staging)
                                                 prd (production)
  -o, --organization <organization>            specify the organization
  -n, --project <project>                      specify the project
  -x, --context <context>                      specify the installation or upgrade context
  -p, --package <package>                      specify a package to install or upgrade
                                                 note: to specify multiple values you can use this option several times
  -i, --package-to-ignore <package-to-ignore>  specify a package to ignore during installation or upgrade
                                                 note: to specify multiple values you can use this option several times
  -k, --set <key>=<value>                      specify a value that take precedence over the installation defaults
                                                 note: to specify multiple values you can use this option several times
  -s, --set-string <key>=<value>               specify a string value that take precedence over the installation defaults
                                                 note: to specify multiple values you can use this option several times
  -f, --config-file <config-file>              specify the path of the configuration file
  --cache-root-path                            specify the root path of the cache directory
  --clean-cache                                clean the cache after installation or upgrade
  --no-deps                                    ignore dependencies
  -h, --help                                   display this help and exit
EOF
}

__command_line_parse() {
    local __opts
    if ! __opts="$(getopt --options e:o:n:x:p:i:k:s:f:h --longoptions environment:,organization:,project:,context:,package:,package-to-ignore:,set:,set-string:,config-file:,cache-root-path:,clean-cache,no-deps,help -n "${__SCRIPT_NAME}" -- "${@}")"; then
        log_error "failed parsing options"
    fi

    eval set -- "${__opts}"

    while true; do
        case "${1}" in
        -e | --environment)
            __opt_environment="${2,,}"
            shift 2
            ;;
        -o | --organization)
            __opt_organization="${2,,}"
            shift 2
            ;;
        -n | --project)
            __opt_project="${2,,}"
            shift 2
            ;;
        -x | --context)
            __opt_context="${2}"
            shift 2
            ;;
        -p | --package)
            __opt_packages+=("${2}")
            shift 2
            ;;
        -i | --package-to-ignore)
            __opt_packages_to_ignore+=("${2}")
            shift 2
            ;;
        -k | --set)
            __opt_kvp+=("${2}")
            shift 2
            ;;
        -s | --set-string)
            __opt_kvp_string+=("${2}")
            shift 2
            ;;
        -f | --config-file)
            __opt_config_file="${2/"~"/${HOME}}"
            if [[ ! -e "${__opt_config_file}" ]]; then
                log_error "config file '${__opt_config_file}' does not exist"
            fi
            shift 2
            ;;
        --cache-root-path)
            __opt_cache_root_path="${2/"~"/${HOME}}"
            shift 2
            ;;
        --clean-cache)
            __opt_clean_cache=true
            shift
            ;;
        --no-deps)
            __opt_no_deps=true
            shift
            ;;
        -h | --help)
            __usage_print
            exit 0
            ;;
        --)
            break
            ;;
        *)
            log_error "internal error"
            ;;
        esac
    done

    if [[ $# -lt 2 ]]; then
        log_error "missing arguments"
    fi

    if [[ $# -gt 2 ]]; then
        log_error "too many arguments"
    fi

    __arg_command="${2}"
}

__config_file_parse() {
    local __tmp

    if [[ -z "${__opt_environment}" ]]; then
        __tmp="$(yaml_read "${__opt_config_file}" ".environment")"
        __opt_environment="${__tmp,,}"
    fi

    if [[ -z "${__opt_organization}" ]]; then
        __tmp="$(yaml_read "${__opt_config_file}" ".organization")"
        __opt_organization="${__tmp,,}"
    fi

    if [[ -z "${__opt_project}" ]]; then
        __tmp="$(yaml_read "${__opt_config_file}" ".project")"
        __opt_project="${__tmp,,}"
    fi

    if [[ -z "${__opt_context}" ]]; then
        __opt_context="$(yaml_read "${__opt_config_file}" ".context")"
    fi

    mapfile -t __tmp < <(yaml_read "${__opt_config_file}" ".packages[]")
    if [[ -n "${__tmp[*]}" ]]; then
        __opt_packages=("${__tmp[@]}" "${__opt_packages[@]}")
    fi

    mapfile -t __tmp < <(yaml_read "${__opt_config_file}" ".packagesToIgnore[]")
    if [[ -n "${__tmp[*]}" ]]; then
        __opt_packages_to_ignore=("${__tmp[@]}" "${__opt_packages_to_ignore[@]}")
    fi

    mapfile -t __tmp < <(yaml_read "${__opt_config_file}" ".values[]")
    if [[ -n "${__tmp[*]}" ]]; then
        __opt_kvp=("${__tmp[@]}" "${__opt_kvp[@]}")
    fi

    mapfile -t __tmp < <(yaml_read "${__opt_config_file}" ".stringValues[]")
    if [[ -n "${__tmp[*]}" ]]; then
        __opt_kvp_string=("${__tmp[@]}" "${__opt_kvp_string[@]}")
    fi
}

__command_options_validate() {
    if [[ -n "${__opt_environment}" ]]; then
        case "${__opt_environment}" in
        "dev" | "int" | "tst" | "stg" | "prd")
            :
            ;;
        *)
            log_error "environment '${__opt_environment}' is invalid"
            ;;
        esac
    fi

    local __package
    for __package in "${__opt_packages[@]}"; do
        if [[ ! -e "${__SCRIPT_DIR}/packages/${__package}/${__package}.sh" ]]; then
            log_error "package '${__package}' does not exist"
        fi
    done

    case "${__arg_command}" in
    "install" | "upgrade")
        if [[ -z "${__opt_environment}" ]]; then
            log_error "no environment specified"
        fi

        if [[ -z "${__opt_organization}" ]]; then
            log_error "no organization specified"
        fi

        if [[ -z "${__opt_project}" ]]; then
            log_error "no project specified"
        fi

        if [[ ${#__opt_packages[@]} -eq 0 ]]; then
            log_error "no package specified"
        fi
        ;;
    "list")
        if [[ ${#__opt_packages[@]} -eq 0 ]]; then
            log_error "no package specified"
        fi
        ;;
    *)
        log_error "invalid command"
        ;;
    esac
}

__cache_init() {
    local __packages=("${@}")

    mkdir -p "${CACHE_CWD}"

    yaml_write "${CACHE_CWD}/values.yaml" ".kubernetes.server" "https://kubernetes.default.svc"
    yaml_write "${CACHE_CWD}/values.yaml" ".environment" "${__opt_environment}"
    yaml_write "${CACHE_CWD}/values.yaml" ".organization" "${__opt_organization}"
    yaml_write "${CACHE_CWD}/values.yaml" ".project" "${__opt_project}"
    yaml_write "${CACHE_CWD}/values.yaml" ".context" "${__opt_context}"

    local __kvp
    for __kvp in "${__opt_kvp[@]}"; do
        local __key
        __key="$(string_trim "${__kvp%%=*}")"

        local __value
        __value="$(string_trim "${__kvp#*=}")"

        yaml_write "${CACHE_CWD}/values.yaml" ".packages.${__key}" "${__value}"
    done

    local __kvp_string
    for __kvp_string in "${__opt_kvp_string[@]}"; do
        local __key
        __key="$(string_trim "${__kvp_string%%=*}")"

        local __value
        __value="$(string_trim "${__kvp_string#*=}")"

        yaml_write "${CACHE_CWD}/values.yaml" ".packages.${__key}" "${__value}" true
    done

    __inner_set_envs() {
        local __package="${1}"
        local __current_package="${2:-"${__package}"}"

        local __base_packages=()
        __package_option_get_values "__base_packages" "base-packages" "${__package}" "${__current_package}"

        local __base_package
        for __base_package in "${__base_packages[@]}"; do
            __inner_set_envs "${__package}" "${__base_package}"
        done

        local __envs=()
        __package_option_get_values "__envs" "envs" "${__package}" "${__current_package}"

        local __env
        for __env in "${__envs[@]}"; do
            echo "export ${__env}" >>"${CACHE_CWD}/${__package}/envs.sh"
        done
    }

    local __package
    for __package in "${__packages[@]}"; do
        mkdir -p "${CACHE_CWD}/${__package}"

        # Set environment variables
        echo -e "#!/usr/bin/env bash\n" >"${CACHE_CWD}/${__package}/envs.sh"
        echo -e "set -eo pipefail\n" >>"${CACHE_CWD}/${__package}/envs.sh"

        __inner_set_envs "${__package}"

        echo >>"${CACHE_CWD}/${__package}/envs.sh"

        # shellcheck disable=SC1090
        source "${CACHE_CWD}/${__package}/envs.sh"

        # Set package namespace
        local __attributes=()
        __package_option_get_values "__attributes" "attributes" "${__package}"

        if array_contains "shared" "${__attributes[@]}"; then
            yaml_write "${CACHE_CWD}/values.yaml" ".packages.${__package}.namespace" "shr-${__package}"
        else
            yaml_write "${CACHE_CWD}/values.yaml" ".packages.${__package}.namespace" "${__opt_environment}-${__opt_organization}-${__opt_project}-${__package}"
        fi
    done
}

__package_hook_execute() {
    local __package="${1}"
    local __hook="${2}"
    local __package_ipath="${3:-"${__package}"}"

    local __current_package="${__package_ipath##*.}"

    local __base_packages=()
    __package_option_get_values "__base_packages" "base-packages" "${__package}" "${__current_package}"

    local __base_package
    for __base_package in "${__base_packages[@]}"; do
        __package_hook_execute "${__package}" "${__hook}" "${__package_ipath}.${__base_package}"
    done

    local __package_prefix="${__package^^}"
    __package_prefix="${__package_prefix//-/_}"

    K8S_PACKAGE_NAME="$(cut -c1-63 <<<"${__package//_/-}")" \
    K8S_PACKAGE_NAMESPACE="$(yaml_read "${CACHE_CWD}/values.yaml" ".packages.${__package}.namespace")" \
    PACKAGE_CACHE_DIR="${CACHE_CWD}/${__package}" \
    PACKAGE_DIR="${__SCRIPT_DIR}/packages/${__package_ipath##*.}" \
    PACKAGE_IPATH="${__package_ipath}" \
    PACKAGE_NAME="${__package}" \
    PACKAGE_PREFIX="${__package_prefix}" \
    PACKAGE_VALUES_FILE_NAME="values-$(printf "%02d" "$(string_count_occurrences_of "${__package_ipath}" ".")")-$(shasum <<<"${__package_ipath}" | head -c 40).yaml" \
    VAULT_TOKEN="$(yaml_read "${CACHE_CWD}/values.yaml" ".packages.vault.rootToken")" \
        "${__SCRIPT_DIR}/packages/${__current_package}/${__current_package}.sh" "${__hook}"
}

__package_option_get_values() {
    local -n __values_ref="${1}"
    local __option="${2}"
    local __package="${3}"
    local __current_package="${4:-"${__package}"}"

    local __package_prefix="${__package^^}"
    __package_prefix="${__package_prefix//-/_}"

    local __values __condition
    while IFS=";" read -r __values __condition; do
        local __value
        for __value in ${__values}; do
            if [[ -z "${__condition}" ]] || eval [[ "${__condition}" ]]; then
                __values_ref+=("$(PACKAGE_NAME="${__package}" PACKAGE_PREFIX="${__package_prefix}" eval echo "${__value}")")
            fi
        done
    done < <(sed -E -n "s/^[\t ]*#[ \t]*@package-option[ \t]+${__option}[ \t]*=[ \t]*\"(.*)\"([ \t]+\[(.*)\]|)/\1;\3/p" "${__SCRIPT_DIR}/packages/${__current_package}/${__current_package}.sh")
}

__package_dependency_get() {
    local -n __dependencies_ref="${1}"
    local __package="${2}"
    local __weak=${3:-false}

    __inner_package_dependency_get() {
        local __package="${1}"
        local __weak=${2:-false}
        local __current_package="${3:-"${__package}"}"

        local __base_packages=()
        __package_option_get_values "__base_packages" "base-packages" "${__package}" "${__current_package}"

        local __base_package
        for __base_package in "${__base_packages[@]}"; do
            local __attributes=()
            __package_option_get_values "__attributes" "attributes" "${__package}" "${__base_package}"

            if array_contains "final" "${__attributes[@]}"; then
                log_error "'${__current_package}' cannot derive from '${__base_package}'"
            fi
            __inner_package_dependency_get "${__package}" "${__weak}" "${__base_package}"
        done

        local __dependencies=()
        __package_option_get_values "__dependencies" "$([[ ${__weak} == true ]] && echo "weak-")dependencies" "${__package}" "${__current_package}"

        echo -n "${__dependencies[*]} "
    }

    # shellcheck disable=SC2034
    IFS=" " read -r -a __dependencies_ref <<<"$(__inner_package_dependency_get "${__package}" "${__weak}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
}

__package_dependencies_resolve() {
    local __packages=("registry-credentials" "${@}")
    local __resolved_packages=()
    local __unresolved_packages=()

    __inner_resolve_dependencies() {
        local __package="${1}"

        if ! array_contains "${__package}" "${__resolved_packages[@]}"; then
            __unresolved_packages+=("${__package}")

            if ! ${__opt_no_deps}; then
                # Strong dependencies
                local __strong_dependencies=()
                __package_dependency_get __strong_dependencies "${__package}" false

                local __dependency
                for __dependency in "${__strong_dependencies[@]}"; do
                    if ! array_contains "${__dependency}" "${__resolved_packages[@]}"; then
                        if array_contains "${__dependency}" "${__unresolved_packages[@]}"; then
                            log_error "circular reference detected: '${__package}' -> '${__dependency}'"
                        fi
                        __inner_resolve_dependencies "${__dependency}"
                    fi
                done

                # Weak dependencies
                local __weak_dependencies=()
                __package_dependency_get __weak_dependencies "${__package}" true

                for __dependency in "${__weak_dependencies[@]}"; do
                    __packages+=("${__dependency}")
                done
            fi

            __resolved_packages+=("${__package}")
            __unresolved_packages=("${__unresolved_packages[@]//${__package}/}")

            echo "${__package}"
        fi
    }

    while true; do
        local __prev_size=${#__packages[@]}

        for __package in "${__packages[@]}"; do
            __inner_resolve_dependencies "${__package}"
        done

        [[ $((${#__packages[@]})) != $((__prev_size)) ]] || break
    done
}

__port_forward_start() {
    local __package="${1}"
    local __current_package="${2:-"${__package}"}"

    local __base_packages=()
    __package_option_get_values "__base_packages" "base-packages" "${__package}" "${__current_package}"

    local __base_package
    for __base_package in "${__base_packages[@]}"; do
        __port_forward_start "${__package}" "${__base_package}"
    done

    local __port_forwards=()
    __package_option_get_values "__port_forwards" "port-forwards" "${__package}" "${__current_package}"

    local __port_forward
    for __port_forward in "${__port_forwards[@]}"; do
        local __service
        __service="${__port_forward%%:*}"

        local __remote_port
        __remote_port="${__port_forward##*:}"

        : >"${CACHE_CWD}/${__package}/port_forward-${__remote_port}.log"
        kubectl port-forward "svc/${__service}" -n "$(yaml_read "${CACHE_CWD}/values.yaml" ".packages.${__package}.namespace")" ":${__remote_port}" >>"${CACHE_CWD}/${__package}/port_forward-${__remote_port}.log" &
        echo "$!" >>"${CACHE_CWD}/${__package}/port_forwards.pid"

        timeout 5 grep -q 'Forwarding from' <(tail -f "${CACHE_CWD}/${__package}/port_forward-${__remote_port}.log")

        local __local_port
        __local_port="$(grep -Po 'Forwarding from [0-9.]+:\K([0-9]+)' <"${CACHE_CWD}/${__package}/port_forward-${__remote_port}.log")"

        local __env_var
        __env_var="${__port_forward#*:}"
        __env_var="${__env_var%%:*}"

        sed -i "5i export ${__env_var}=\"${__local_port}\"" "${CACHE_CWD}/${__package}/envs.sh"

        # shellcheck disable=SC1090
        source "${CACHE_CWD}/${__package}/envs.sh"
    done
}

__port_forward_stop() {
    local __package="${1}"

    if [[ -f "${CACHE_CWD}/${__package}/port_forwards.pid" ]]; then
        while read -r __pid; do
            kill "${__pid}" >/dev/null 2>&1 || :
        done <"${CACHE_CWD}/${__package}/port_forwards.pid"

        rm -f "${CACHE_CWD}/${__package}/port_forwards.pid"
    fi
}

__command_install_upgrade() {
    local __command="${1}"

    # Get the list of packages to be installed or upgraded (including dependencies)
    local __packages
    readarray -t __packages < <(__package_dependencies_resolve "${__opt_packages[@]}")

    # Remove packages that are to be ignored during installation or upgrade
    array_remove_items __packages "${__opt_packages_to_ignore[@]}"

    # Initialize the installation/upgrade cache
    __cache_init "${__packages[@]}"

    # Execute the 'initialize' hook for each package
    local __package
    for __package in "${__packages[@]}"; do
        log_info "initializing ${__package}"
        __package_hook_execute "${__package}" "hook_initialize"
    done

    # Execute the 'pre-install/pre-upgrade, install/upgrade, and post-install/post-upgrade' hooks for each package
    for __package in "${__packages[@]}"; do
        if [[ ! -e "${CACHE_CWD}/${__package}/.hook_pre_${__command}" ]]; then
            log_info "pre-$( ([[ "${__command}" == "install" ]] && echo "installing") || echo "upgrading") ${__package}"
            __package_hook_execute "${__package}" "hook_pre_${__command}"
            touch "${CACHE_CWD}/${__package}/.hook_pre_${__command}"
        fi

        if [[ ! -e "${CACHE_CWD}/${__package}/.hook_${__command}" ]]; then
            log_info "$( ([[ "${__command}" == "install" ]] && echo "installing") || echo "upgrading") ${__package}"
            __package_hook_execute "${__package}" "hook_${__command}"
            touch "${CACHE_CWD}/${__package}/.hook_${__command}"
        fi

        # Start port-forwarding for packages that require it
        __port_forward_start "${__package}"

        if [[ ! -e "${CACHE_CWD}/${__package}/.hook_post_${__command}" ]]; then
            log_info "post-$( ([[ "${__command}" == "install" ]] && echo "installing") || echo "upgrading") ${__package}"
            __package_hook_execute "${__package}" "hook_post_${__command}"
            touch "${CACHE_CWD}/${__package}/.hook_post_${__command}"
        fi
    done

    # Execute the 'finalize' hook for each package
    for __package in "${__packages[@]}"; do
        log_info "finalizing ${__package}"
        __package_hook_execute "${__package}" "hook_finalize"
    done

    # Delete the upgrade phase tracking files, so that further upgrades can be carried out
    if [[ "${__command}" == "upgrade" ]]; then
        find "${CACHE_CWD}" -name ".hook_*upgrade" -exec rm -f {} \;
    fi

    # Stop port-forwarding for packages that required it
    for __package in "${__packages[@]}"; do
        __port_forward_stop "${__package}"
    done
}

__command_list() {
    local __packages
    readarray -t __packages < <(__package_dependencies_resolve "${__opt_packages[@]}")

    array_remove_items __packages "${__opt_packages_to_ignore[@]}"

    local __package
    for __package in "${__packages[@]}"; do
        echo "${__package}"
    done
}

#-----------------------------------------------------------------------------
# main

main() {
    # Parse command-line options
    __command_line_parse "${@}"

    # Parse configuration file
    if [[ -n "${__opt_config_file}" ]]; then
        __config_file_parse
    fi

    # Validate options and arguments
    __command_options_validate

    # Set global variables
    export CACHE_CWD="${__opt_cache_root_path}/${__opt_environment}/${__opt_organization}/${__opt_project}"
    export COMMAND="${__arg_command}"
    export CONTEXT="${__opt_context}"
    export ENVIRONMENT="${__opt_environment}"
    export ORGANIZATION="${__opt_organization}"
    export PROJECT="${__opt_project}"

    # Execute the specified command
    case "${__arg_command}" in
    "install" | "upgrade")
        __command_install_upgrade "${__arg_command}"
        ;;
    "list")
        __command_list
        ;;
    esac

    # Clean the installation/upgrade cache (if requested)
    if ${__opt_clean_cache}; then
        rm -rf "${CACHE_CWD}"
    fi
}

main "${@}"

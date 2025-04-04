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

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/../../support/scripts/package.sh"

#-----------------------------------------------------------------------------
# Package Options

# @package-option dependencies="ory-oathkeeper"

#-----------------------------------------------------------------------------
# Private Constants

readonly __OPENAPI_OATHKEEPER_DEFAULT_SOURCE_BASE_PATH="."
readonly __OPENAPI_OATHKEEPER_DEFAULT_SOURCE_REGEX_FILTER=".*\.(yaml|yml|json)$"

#-----------------------------------------------------------------------------
# Global Variables

__openapi_spec_file_index=0

#-----------------------------------------------------------------------------
# Private Methods

__file_process_callback() {
    local __openapi_spec_path="${1}"

    local __oathkeeper_access_rules_path="${PACKAGE_CACHE_DIR}/rules/${PACKAGE_NAME}-rules-${__openapi_spec_file_index}"

    openapi-oathkeeper generate -c "${PACKAGE_CACHE_DIR}/openapi-oathkeeper-config.yaml" -f "${__openapi_spec_path}" -o "${__oathkeeper_access_rules_path}"

    if ! package_cache_values_file_contains ".packages.ory-oathkeeper.accessRules.filePaths[]" "${__oathkeeper_access_rules_path}"; then
        package_cache_values_file_add ".packages.ory-oathkeeper.accessRules.filePaths" "[\"${__oathkeeper_access_rules_path}\"]" true
    fi

    __openapi_spec_file_index=$((__openapi_spec_file_index + 1))
}

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    # Generate the configuration file required by the `openapi-oathkeeper` tool
    local -A __config_mappings=(
        ["prefix"]=".prefix"
        ["serverUrls"]=".server_urls"
        ["upstream"]=".upstream"
        ["authenticators"]=".authenticators"
        ["authorizer"]=".authorizer"
        ["mutators"]=".mutators"
        ["errors"]=".errors"
    )

    : >"${PACKAGE_CACHE_DIR}/openapi-oathkeeper-config.yaml"

    local __key __path_expr __value
    for __key in "${!__config_mappings[@]}"; do
        __path_expr="${__config_mappings[${__key}]}"
        __value="$(package_cache_values_file_read_json ".packages.${PACKAGE_IPATH}.config.${__key}")"

        if [[ "${__value}" != "\"\"" && "${__value}" != "{}" && "${__value}" != "[]" ]]; then
            yaml_write "${PACKAGE_CACHE_DIR}/openapi-oathkeeper-config.yaml" "${__path_expr}" "${__value}"
        fi
    done

    # Clone the source repository containing OpenAPI specifications
    local __source_url
    __source_url="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.source.url")"

    local __source_branch
    __source_branch="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.source.branch")"

    local __source_base_path
    __source_base_path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.source.basePath" "${__OPENAPI_OATHKEEPER_DEFAULT_SOURCE_BASE_PATH}")"

    local __source_regex_filter
    __source_regex_filter="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.source.regexFilter" "${__OPENAPI_OATHKEEPER_DEFAULT_SOURCE_REGEX_FILTER}")"

    if ! grep -q "$(git_url_get_hostname "${__source_url}")" "${HOME}/.ssh/known_hosts" >/dev/null 2>&1; then
        mkdir -p "${HOME}/.ssh"
        ssh-keyscan -t rsa "$(git_url_get_hostname "${__source_url}")" >>"${HOME}/.ssh/known_hosts"
    fi

    rm -rf "${PACKAGE_CACHE_DIR:?}/source"
    if [[ -n "${__source_branch}" ]]; then
        git clone --depth 1 --branch "${__source_branch}" "${__source_url}" "${PACKAGE_CACHE_DIR}/source"
    else
        git clone --depth 1 "${__source_url}" "${PACKAGE_CACHE_DIR}/source"
    fi

    rm -rf "${PACKAGE_CACHE_DIR:?}/rules"
    mkdir -p "${PACKAGE_CACHE_DIR}/rules"
    file_process_regex "__file_process_callback" "${__source_regex_filter}" "${PACKAGE_CACHE_DIR}/source/${__source_base_path}" true
}

package_hook_execute "${@}"

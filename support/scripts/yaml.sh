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

#-----------------------------------------------------------------------------
# Public Methods

yaml_add() {
    local __file="${1}"
    local __path_expr="${2}"
    local __value="${3}"
    local __force_string="${4:-false}"

    if ! ${__force_string} && [[ "${__value}" =~ ^-?[0-9]+([.][0-9]+)?$ || "${__value,,}" =~ ^(true|false)$ || "${__value,,}" =~ ^[[:space:]]*\{.*\}[[:space:]]*$ || "${__value,,}" =~ ^[[:space:]]*\[.*\][[:space:]]*$ ]]; then
        yq eval "${__path_expr} += ${__value}" "${__file}"
    else
        yq eval "${__path_expr} += \"${__value//\"/\\\"}\"" "${__file}"
    fi
}

yaml_contains() {
    local __file="${1}"
    local __path_expr="${2}"
    local __value="${3}"

    yq eval "${__path_expr} | (. == \"${__value}\")" "${__file}" | grep -q "true"
}

yaml_count() {
    local __file="${1}"
    local __path_expr="${2}"

    yq eval "${__path_expr} | length" "${__file}"
}

yaml_delete() {
    local __file="${1}"
    local __path_expr="${2}"

    yq eval "del(${__path_expr})" "${__file}"
}

yaml_merge() {
    local __files=("${@}")

    # shellcheck disable=SC2016
    yq eval-all '. as $item ireduce ({}; . *+ $item )' "${__files[@]}"
}

yaml_move() {
    local __file="${1}"
    local __src_path_expr="${2}"
    local __dst_path_expr="${3}"

    local __stdin
    __stdin="$(cat "${__file}")"

    if [[ $(echo "${__stdin}" | yq eval "${__src_path_expr} | length" -) -gt 0 ]]; then
        # shellcheck disable=SC2016
        echo "${__stdin}" | yq eval '. as $root | '"${__src_path_expr}"' as $orig_data | del($root'"${__src_path_expr}"') | with($root; '"${__dst_path_expr}"' |= . *+ $orig_data) | $root' -
    else
        echo "${__stdin}" | yq eval -
    fi
}

yaml_prefix() {
    local __file="${1}"
    local __prefix="${2}"

    local __stdin
    __stdin="$(cat "${__file}")"

    local __path_expr
    __path_expr="$(yq eval -n "${__prefix} = \".\"" -o json | sed 's/\"\.\"/\./g')"

    echo "${__stdin}" | yq eval "${__path_expr}" -
}

yaml_read() {
    local __file="${1}"
    local __path_expr="${2}"
    local __default_value="${3:-}"

    yq eval "${__path_expr} // \"${__default_value}\"" "${__file}"
}

yaml_read_json() {
    local __file="${1}"
    local __path_expr="${2}"
    local __compact="${3:-false}"
    local __default_value="${4:-"{}"}"

    if ! ${__compact}; then
        yq eval -o json "${__path_expr} // ${__default_value}" "${__file}"
    else
        yq eval -I0 -o json "${__path_expr} // ${__default_value}" "${__file}"
    fi
}

yaml_write() {
    local __file="${1}"
    local __path_expr="${2}"
    local __value="${3}"
    local __force_string="${4:-false}"

    touch "${__file}"
    if ! ${__force_string} && [[ "${__value}" =~ ^-?[0-9]+([.][0-9]+)?$ || "${__value,,}" =~ ^(true|false)$ || "${__value,,}" =~ ^[[:space:]]*\{.*\}[[:space:]]*$ || "${__value,,}" =~ ^[[:space:]]*\[.*\][[:space:]]*$ ]]; then
        yq eval --inplace "${__path_expr} = ${__value}" "${__file}"
    else
        yq eval --inplace "${__path_expr} = \"${__value//\"/\\\"}\"" "${__file}"
    fi
}

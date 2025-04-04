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

file_process_regex() {
    local __callback_name="${1}"
    local __regex_filter="${2:-".*"}"
    local __start_dir="${3:-"."}"
    local __recursive="${4:-false}"
    local __regex_type="${5:-"posix-extended"}"
    local __case_sensitive="${6:-true}"
    local __callback_extra_args_ref_name="${7:-}"

    local __find_args=("${__start_dir}")

    if ! ${__recursive}; then
        __find_args+=("-maxdepth" "1")
    fi

    __find_args+=("-regextype" "${__regex_type}")

    if ${__case_sensitive}; then
        __find_args+=("-regex" "${__regex_filter}")
    else
        __find_args+=("-iregex" "${__regex_filter}")
    fi

    __find_args+=("-type" "f")

    local -a __callback_extra_args__=()

    if [[ -n "${__callback_extra_args_ref_name}" ]]; then
        if declare -p "${__callback_extra_args_ref_name}" 2>/dev/null | grep -q '^declare -[aA]'; then
            local -n __callback_extra_args_ref="${__callback_extra_args_ref_name}"
            __callback_extra_args__=("${__callback_extra_args_ref[@]}")
        fi
    fi

    while IFS= read -r -d $'\0' __file; do
        if [[ -n "${__file}" ]]; then
            "${__callback_name}" "${__file}" "${__callback_extra_args__[@]}"
        fi
    done < <(find "${__find_args[@]}" -print0 2>/dev/null)
}

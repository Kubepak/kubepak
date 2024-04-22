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

array_contains() {
    local __value="${1}"
    shift
    local __array=("${@}")

    local __item
    for __item in "${__array[@]}"; do
        [[ "${__item}" == "${__value}" ]] && return 0
    done

    return 1
}

array_remove_items() {
    local -n __array_ref="${1}"
    local __items_to_remove=("${@:2}")

    for ((__i = ${#__array_ref[@]} - 1; __i >= 0; __i--)); do
        for __item in "${__items_to_remove[@]}"; do
            if [[ "${__array_ref[__i]}" == "${__item}" ]]; then
                unset '__array_ref[__i]'
            fi
        done
    done
}

array_reverse() {
    local -n __array_ref="${1}"

    local -a __tmp, __item
    for __item in "${__array_ref[@]}"; do
        __tmp=("${__item}" "${__tmp[@]}")
    done

    __array_ref=("${__tmp[@]}")
}

array_sort() {
    local -n __array_ref="${1}"
    local __descending=${2:-false}

    local __tmp
    if [[ ${__descending} == true ]]; then
        __tmp="$(printf '%s\n' "${__array_ref[@]}" | sort -r)"
    else
        __tmp="$(printf '%s\n' "${__array_ref[@]}" | sort)"
    fi

    readarray -t __array_ref <<<"${__tmp}"
}

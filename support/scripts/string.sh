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

string_count_occurrences_of() {
    local __string="${1}"
    local __character=${2}

    echo "${__string}" | tr -cd "${__character}" | wc -m
}

string_trim() {
    local __string="${*}"

    # Remove leading whitespace characters
    __string="${__string#"${__string%%[![:space:]]*}"}"

    # Remove trailing whitespace characters
    __string="${__string%"${__string##*[![:space:]]}"}"

    echo -n "${__string}"
}

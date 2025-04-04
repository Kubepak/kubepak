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

hash_generate_short_sha() {
    local __input="${1}"
    local __sha_length="${2:-8}"

    echo -n "${__input}" | sha1sum | cut -c1-"${__sha_length}" | tr -d '\n'
}

hash_generate_unique_basename() {
    local __path="$1"
    local __sha_length="${2:-8}"

    local __basename
    __basename="$(basename "${__path}")"

    echo -n "${__basename%%.*}-$(hash_generate_short_sha "${__path}" "${__sha_length}")${__basename#"${__basename%%.*}"}"
}

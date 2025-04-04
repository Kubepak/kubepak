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
# Private Constants

readonly __SPECIAL_CHARACTERS="!@#$%^&*"

#-----------------------------------------------------------------------------
# Public Methods

password_generate() {
    local __size="${1:-32}"

    shuf -e {A..Z} {a..z} {0..9} "$(echo "${__SPECIAL_CHARACTERS}" | fold -w1)" -r -n "${__size}" | tr -d '\n'
}

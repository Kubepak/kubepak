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

log_error() {
    local __message="${1}"

    printf "\033[0;31mERROR\033[0m: %b\n" "${__message}" >&2
    exit 1
}

log_info() {
    local __message="${1}"

    printf "\033[0;34mINFO\033[0m: %b\n" "${__message}" >&2
}

log_warning() {
    local __message="${1}"

    printf "\033[0;33mWARNING\033[0m: %b\n" "${__message}" >&2
}

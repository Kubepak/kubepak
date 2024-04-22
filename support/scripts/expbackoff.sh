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

expbackoff() {
    local __max_attempts="${EXPBACKOFF_MAX_ATTEMPTS:-5}"
    local __attempt=0
    local __timeout=1
    local __exit_code=0

    while [[ "${__attempt}" < "${__max_attempts}" ]]; do
        set +e
        "${@}"
        __exit_code="$?"
        set -eo pipefail

        if [[ "${__exit_code}" == 0 ]]; then
            break
        fi

        __attempt="$((__attempt + 1))"
        __timeout="$((2 ** __attempt - 1))"

        echo "Failure! Retrying in ${__timeout}..." 1>&2
        sleep "${__timeout}"
    done

    if [[ "${__exit_code}" != 0 ]]; then
        echo "You have failed me for the last time! (${*})" 1>&2
    fi

    return "${__exit_code}"
}

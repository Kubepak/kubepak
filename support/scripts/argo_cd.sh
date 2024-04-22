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

argo_cd_application_wait() {
    local __application_name="${1}"
    local __max_attempts="${2:-120}"
    local __attempt=0

    printf "Waiting for \"%s\" to be healthy" "${__application_name}"

    until [[ "$(kubectl get applications.argoproj.io -n "shr-argo-cd" "${__application_name}" -o jsonpath="{.status.health.status}")" == "Healthy" ]]; do
        if [[ ${__attempt} -eq __max_attempts ]]; then
            echo "Max attempts reached"
            return 1
        fi

        printf '.'
        __attempt=$((__attempt + 1))
        sleep 2
    done
    printf '\n'

    # NOTE: F$%^&#@* workaround. Argo CD returns, in some cases, a healthy status even if the deployment is in an error
    #       state. To work around the issue, we check the application's conditions returned by Argo CD.
    if [[ -n "$(kubectl get applications.argoproj.io -n "shr-argo-cd" "${__application_name}" -o jsonpath="{.status.conditions}" | jq '. | length')" ]]; then
        kubectl get applications.argoproj.io -n "shr-argo-cd" "${__application_name}" -o jsonpath="{range .status.conditions[*]}{.message}{'\n'}{end}"
        return 1
    fi
}

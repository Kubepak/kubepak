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

# @package-option attributes="final"

# @package-option dependencies="cert-manager"

#-----------------------------------------------------------------------------
# Public Hooks

hook_install() {
    package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart"

    local __i
    for __i in $(seq "$(package_cache_values_file_count ".packages.${PACKAGE_IPATH}.issuers.acme")"); do
        local __issuer_name
        __issuer_name="${K8S_PACKAGE_NAME}-$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.issuers.acme[$((__i - 1))].name")"

        k8s_resource_wait "default" "ClusterIssuer" "${__issuer_name}"
    done
}

hook_upgrade() {
    hook_install
}

package_hook_execute "${@}"

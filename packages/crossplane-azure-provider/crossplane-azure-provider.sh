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

# @package-option attributes="shared"

# @package-option dependencies="crossplane"

#-----------------------------------------------------------------------------
# Private Constants

readonly __CROSSPLANE_AZURE_PROVIDER_VERSION="1.2.0"

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.version" "${__CROSSPLANE_AZURE_PROVIDER_VERSION}"

    k8s_namespace_create "${K8S_PACKAGE_NAMESPACE}"
}

hook_install() {
    package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart-0"

    local __attempt=0
    until [[ $(kubectl get crd "providerconfigs.azure.upbound.io" -o jsonpath='{.status.conditions[?(@.type=="Established")].status}' 2>/dev/null) == "True" ]]; do
        if [[ ${__attempt} -eq 30 ]]; then
            echo "Max attempts reached"
            exit 1
        fi

        printf '.'
        __attempt=$((__attempt + 1))
        sleep 2
    done
    printf '\n'
}

hook_post_install() {
    package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart-1"
}

hook_upgrade() {
    hook_install
}

hook_post_upgrade() {
    hook_post_install
}

package_hook_execute "${@}"

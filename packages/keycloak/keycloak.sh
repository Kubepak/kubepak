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

# @package-option dependencies="argo-cd"
# @package-option dependencies="emissary-ingress" [ ! ",${CONTEXT}," =~ ",multiple-ingress-controllers," ]
# @package-option dependencies="ingress-management" [ ",${CONTEXT}," =~ ",multiple-ingress-controllers," ]

#-----------------------------------------------------------------------------
# Private Constants

readonly __KEYCLOAK_CHART_LEGACY_VERSION="25.2.0"

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.chartVersion" "${__KEYCLOAK_CHART_LEGACY_VERSION}"

    k8s_namespace_create "${K8S_PACKAGE_NAMESPACE}"

    registry_credentials_add_namespace "${K8S_PACKAGE_NAMESPACE}"
}

hook_pre_install() {
    local -A __files=()

    local __i
    for __i in $(seq "$(package_cache_values_file_count ".packages.${PACKAGE_IPATH}.configPaths")"); do
        local __resolved_config_path
        eval __resolved_config_path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.configPaths[$((__i - 1))]")"

        __files+=(["$(basename "${__resolved_config_path}")"]="${__resolved_config_path}")
    done

    if [[ ${#__files[@]} -gt 0 ]]; then
        k8s_configmap_create_from_files "${K8S_PACKAGE_NAMESPACE}" "${K8S_PACKAGE_NAME}-import-configs" "__files"
    fi
}

hook_install() {
    package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart"

    argo_cd_application_wait "${K8S_PACKAGE_NAME}"
}

hook_upgrade() {
    hook_install
}

package_hook_execute "${@}"

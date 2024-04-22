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
# @package-option attributes="shared"

# @package-option base-packages="postgresql" [ ,${CONTEXT}, =~ ,nexus-local-database, ]

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    if [[ ,${CONTEXT}, =~ ,nexus-local-database, ]]; then
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.metadata.host" "${K8S_PACKAGE_NAME}.${K8S_PACKAGE_NAMESPACE}.svc.cluster.local." true
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.metadata.port" "5432" true
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.metadata.root.username" "postgres" true
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.metadata.root.password" "$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.postgresql.auth.postgresPassword" "postgres")" true
    fi
}

hook_pre_install() {
    if [[ ,${CONTEXT}, =~ ,nexus-local-database, ]]; then
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.postgresql.primary.extendedConfigmap" "${PACKAGE_NAME}-extended-config"

        k8s_configmap_create_from_file "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_NAME}-extended-config" "override.conf" "${PACKAGE_DIR}/files/config/extended-config.txt"
    fi
}

hook_pre_upgrade() {
    hook_pre_install
}

package_hook_execute "${@}"

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

source "support/scripts/package.sh"

#-----------------------------------------------------------------------------
# Package Options

# @package-option attributes="final"

# @package-option base-packages="postgresql" [ ,${CONTEXT}, =~ ,vault-local-database, ]

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    if [[ ,${CONTEXT}, =~ ,vault-local-database, ]]; then
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.metadata.host" "${K8S_PACKAGE_NAME}.${K8S_PACKAGE_NAMESPACE}.svc.cluster.local." true
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.metadata.port" "5432" true
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.metadata.root.username" "postgres" true
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.metadata.root.password" "$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.postgresql.auth.postgresPassword" "postgres")" true
    fi
}

package_hook_execute "${@}"
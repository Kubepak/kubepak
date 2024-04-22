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

registry_credentials_add_namespace() {
    local __namespace="${1:-"${K8S_PACKAGE_NAMESPACE}"}"

    if ! package_cache_values_file_contains ".packages.registry-credentials.namespaces[]" "${__namespace}"; then
        package_cache_values_file_add ".packages.registry-credentials.namespaces" "[\"${__namespace}\"]" true
    fi
}

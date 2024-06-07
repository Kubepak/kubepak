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

# @package-option dependencies="nexus"

# @package-option attributes="final"

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    k8s_namespace_create "${K8S_PACKAGE_NAMESPACE}"

    registry_credentials_add_namespace "${K8S_PACKAGE_NAMESPACE}"
}

hook_install() {
    package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart"

    k8s_resource_wait "${K8S_PACKAGE_NAMESPACE}" "cronjob" "${K8S_PACKAGE_NAME}"

}


# hook_pre_upgrade() {
#     hook_pre_install
# }

hook_upgrade() {
   hook_install
}

package_hook_execute "${@}"

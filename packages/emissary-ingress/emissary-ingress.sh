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
# @package-option dependencies="cert-manager-issuers" [ ,${CONTEXT}, =~ ,cert-manager, ]
# @package-option dependencies="prometheus-stack" [ ,${CONTEXT}, =~ ,prometheus-metrics, ]

#-----------------------------------------------------------------------------
# Private Constants

readonly __EMISSARY_INGRESS_CHART_VERSION="8.9.1"

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.chartVersion" "${__EMISSARY_INGRESS_CHART_VERSION}"

    k8s_namespace_create "${K8S_PACKAGE_NAMESPACE}"

    registry_credentials_add_namespace "${K8S_PACKAGE_NAMESPACE}"

    helm repo add "emissary-ingress" "https://app.getambassador.io"
    helm repo update "emissary-ingress"

    local __app_version
    __app_version="$(helm search repo "emissary-ingress" --version "${__EMISSARY_INGRESS_CHART_VERSION}" --output json |
        jq -r '.[] | select(.name == "emissary-ingress/emissary-ingress").app_version')"

    kubectl apply -f "https://app.getambassador.io/yaml/emissary/${__app_version}/emissary-crds.yaml"

    k8s_resource_wait_for "emissary-system" "deployment" "emissary-apiext" "condition=available" "90s"
}

hook_install() {
    package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart"

    argo_cd_application_wait "${K8S_PACKAGE_NAME}"
}

hook_upgrade() {
    hook_install
}

package_hook_execute "${@}"

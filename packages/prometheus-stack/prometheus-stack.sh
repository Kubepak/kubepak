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
# @package-option weak-dependencies="emissary-ingress" [ ",${CONTEXT}," =~ ",single-ingress-controller," ]
# @package-option weak-dependencies="ingress-management" [ ",${CONTEXT}," =~ ",multiple-ingress-controllers," ]

#-----------------------------------------------------------------------------
# Private Constants

readonly __PROMETHEUS_STACK_CHART_VERSION="60.4.0"
readonly __PROMETHEUS_STACK_OPERATOR_CRDS="12.0.0"

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.chartVersion" "${__PROMETHEUS_STACK_CHART_VERSION}"

    k8s_namespace_create "${K8S_PACKAGE_NAMESPACE}"

    registry_credentials_add_namespace "${K8S_PACKAGE_NAMESPACE}"

    helm repo add "prometheus-community" "https://prometheus-community.github.io/helm-charts"
    helm repo update "prometheus-community"

    helm template "${K8S_PACKAGE_NAME}" "prometheus-community/prometheus-operator-crds" \
        --namespace "${K8S_PACKAGE_NAMESPACE}" \
        --version "${__PROMETHEUS_STACK_OPERATOR_CRDS}" |
        kubectl apply --server-side -n "${K8S_PACKAGE_NAMESPACE}" -f -
}

hook_install() {
    package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart"

    argo_cd_application_wait "${K8S_PACKAGE_NAME}"
}

hook_upgrade() {
    hook_install
}

package_hook_execute "${@}"

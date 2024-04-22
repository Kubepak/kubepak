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

# @package-option weak-dependencies="emissary-ingress" [ ",${CONTEXT}," =~ ",single-ingress-controller," ]
# @package-option weak-dependencies="ingress-management" [ ",${CONTEXT}," =~ ",multiple-ingress-controllers," ]
# @package-option weak-dependencies="prometheus-stack" [ ,${CONTEXT}, =~ ,prometheus-metrics, ]

#-----------------------------------------------------------------------------
# Private Constants

readonly __ARGO_CD_CHART_VERSION="7.3.1"

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.chartVersion" "${__ARGO_CD_CHART_VERSION}"

    k8s_namespace_create "${K8S_PACKAGE_NAMESPACE}"

    registry_credentials_add_namespace "${K8S_PACKAGE_NAMESPACE}"
}

hook_pre_install() {
    helm repo add "argo" "https://argoproj.github.io/argo-helm"
    helm repo update "argo"

    helm template "${K8S_PACKAGE_NAME}" "argo/argo-cd" \
        --namespace "${K8S_PACKAGE_NAMESPACE}" \
        --include-crds \
        --version "${__ARGO_CD_CHART_VERSION}" \
        --set "fullnameOverride=argocd" \
        --set "global.imagePullSecrets[0].name=registry-credentials" \
        --set "dex.enabled=false" \
        --set "installCRDs=false" |
        kubectl apply -n "${K8S_PACKAGE_NAMESPACE}" -f -

    k8s_resource_wait "${K8S_PACKAGE_NAMESPACE}" "deployment" "argocd-applicationset-controller"
    k8s_resource_wait "${K8S_PACKAGE_NAMESPACE}" "deployment" "argocd-notifications-controller"
    k8s_resource_wait "${K8S_PACKAGE_NAMESPACE}" "deployment" "argocd-redis"
    k8s_resource_wait "${K8S_PACKAGE_NAMESPACE}" "deployment" "argocd-repo-server"
    k8s_resource_wait "${K8S_PACKAGE_NAMESPACE}" "deployment" "argocd-server"
}

hook_install() {
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.admin.enabled" "true"

    package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart"

    argo_cd_application_wait "${K8S_PACKAGE_NAME}" 240
}

hook_upgrade() {
    hook_install
}

hook_finalize() {
    if [[ "$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.auth.oidc.enabled")" == "true" ]]; then
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.admin.enabled" "false"

        package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart"
    fi
}

package_hook_execute "${@}"

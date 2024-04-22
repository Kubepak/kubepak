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

# @package-option dependencies="argo-cd"
# @package-option dependencies="custom-coredns" [ ,${CONTEXT}, =~ ,custom-coredns, ]
# @package-option dependencies="emissary-ingress" [ ",${CONTEXT}," =~ ",single-ingress-controller," ]
# @package-option dependencies="ingress-management" [ ",${CONTEXT}," =~ ",multiple-ingress-controllers," ]
# @package-option dependencies="prometheus-stack" [ ,${CONTEXT}, =~ ,prometheus-metrics, ]

#-----------------------------------------------------------------------------
# Private Constants

readonly __ARGO_WORKFLOWS_CHART_VERSION="0.41.11"

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.chartVersion" "${__ARGO_WORKFLOWS_CHART_VERSION}"
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.auth.oidc.providers.dex.clientId" "$(uuid_generate)" true
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.auth.oidc.providers.dex.clientSecret" "$(password_generate 40)" true

    k8s_namespace_create "${K8S_PACKAGE_NAMESPACE}"

    registry_credentials_add_namespace "${K8S_PACKAGE_NAMESPACE}"
}

hook_install() {
    package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart"

    argo_cd_application_wait "${K8S_PACKAGE_NAME}"
}

hook_post_install() {
    # NOTE1: During upgrades of Argo-Workflows, we take the opportunity to rotate the OIDC client ID and secret for
    #        enhanced security. But thanks to the Helm Chart's flawed design, merely updating values rarely suffices.
    #        We're left with no option but to grit our teeth and roll out the server process post-upgrade to ensure
    #        proper integration of the new credentials.
    kubectl rollout restart deployment -n "${K8S_PACKAGE_NAMESPACE}" "${K8S_PACKAGE_NAME}-server"

    argo_cd_application_wait "${K8S_PACKAGE_NAME}"

    # NOTE2: The close coupling of Argo-Workflows and Argo-CD's Dex server introduces another F$%^&#@* headache during
    #        upgrades: racing conditions. To sidestep these issues, we're forced to rollout the Dex server after the
    #        Argo-Workflows upgrade, ensuring system stability.
    kubectl rollout restart deployment -n "$(package_cache_values_file_read ".packages.argo-cd.namespace")" "argocd-dex-server"
}

hook_upgrade() {
    hook_install
}

hook_post_upgrade() {
    hook_post_install
}

package_hook_execute "${@}"

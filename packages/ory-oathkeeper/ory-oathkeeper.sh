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
# @package-option dependencies="emissary-ingress" [ ! ",${CONTEXT}," =~ ",multiple-ingress-controllers," ]
# @package-option dependencies="ingress-public" [ ",${CONTEXT}," =~ ",multiple-ingress-controllers," ]

#-----------------------------------------------------------------------------
# Private Constants

readonly __ORY_OATHKEEPER_CHART_VERSION="0.60.0"

readonly __ORY_OATHKEEPER_DEFAULT_TLS_CA_DST_FILE_PATH="/etc/ssl/certs/ca-certificates.crt"

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.chartVersion" "${__ORY_OATHKEEPER_CHART_VERSION}"

    k8s_namespace_create "${K8S_PACKAGE_NAMESPACE}"

    registry_credentials_add_namespace "${K8S_PACKAGE_NAMESPACE}"
}

hook_pre_install() {
    local __tls_ca_src_file_path
    __tls_ca_src_file_path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.tls.ca.srcFilePath")"

    if [[ -n "${__tls_ca_src_file_path}" ]]; then
        local __tls_ca_dst_file_path
        __tls_ca_dst_file_path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.tls.ca.dstFilePath" "${__ORY_OATHKEEPER_DEFAULT_TLS_CA_DST_FILE_PATH}")"

        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.tls.ca.dstFilePath" "${__tls_ca_dst_file_path}"

        k8s_configmap_create_from_file "${K8S_PACKAGE_NAMESPACE}" "${K8S_PACKAGE_NAME}-ca-certificates" "$(basename "${__tls_ca_dst_file_path}")" "${__tls_ca_src_file_path}"
    fi

    # Build the "access-rules" ConfigMap
    local -A __files=()

    local __i
    for __i in $(seq "$(package_cache_values_file_count ".packages.${PACKAGE_IPATH}.accessRules.filePaths")"); do
        local __file_path
        __file_path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.accessRules.filePaths[$((__i - 1))]")"

        local __resolved_file_path
        eval __resolved_file_path="${__file_path}"

        __files+=(["$(hash_generate_unique_basename "${__file_path}")"]="${__resolved_file_path}")
    done

    if [[ ${#__files[@]} -gt 0 ]]; then
        k8s_configmap_create_from_files "${K8S_PACKAGE_NAMESPACE}" "${K8S_PACKAGE_NAME}-access-rules" "__files"
    fi
}

hook_install() {
    package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart"

    argo_cd_application_wait "${K8S_PACKAGE_NAME}"
}

hook_pre_upgrade() {
    hook_pre_install
}

hook_upgrade() {
    hook_install
}

hook_post_upgrade() {
    kubectl rollout restart deployment -n "${K8S_PACKAGE_NAMESPACE}" "${K8S_PACKAGE_NAME}"

    argo_cd_application_wait "${K8S_PACKAGE_NAME}"
}

package_hook_execute "${@}"

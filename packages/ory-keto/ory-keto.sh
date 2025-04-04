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
# @package-option dependencies="ory-keto-database"

#-----------------------------------------------------------------------------
# Private Constants

readonly __ORY_KETO_CHART_VERSION="0.60.0"

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.chartVersion" "${__ORY_KETO_CHART_VERSION}"

    k8s_namespace_create "${K8S_PACKAGE_NAMESPACE}"

    registry_credentials_add_namespace "${K8S_PACKAGE_NAMESPACE}"
}

hook_pre_install() {
    local __database_host
    __database_host="$(package_cache_values_file_read ".packages.ory-keto-database.metadata.host")"

    local __database_port
    __database_port="$(package_cache_values_file_read ".packages.ory-keto-database.metadata.port")"

    local __database_root_username
    __database_root_username="$(package_cache_values_file_read ".packages.ory-keto-database.metadata.root.username")"

    local __database_root_password
    __database_root_password="$(package_cache_values_file_read ".packages.ory-keto-database.metadata.root.password")"

    local __database_parameters
    __database_parameters="$(package_cache_values_file_read ".packages.ory-keto-database.metadata.parameters")"

    # Create the Ory Keto database
    database_create "postgresql" "${PACKAGE_NAME}" "${__database_host}" "${__database_port}" "" "${__database_root_username}" "${__database_root_password}"

    # Create a password for the Ory Keto database user if not already set
    local __database_keto_password
    if ! k8s_resource_exists "${K8S_PACKAGE_NAMESPACE}" "secret" "${PACKAGE_NAME}-database-keto-password"; then
        __database_keto_password="$(password_generate "32")"

        k8s_secret_create "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_NAME}-database-keto-password" "kubernetes.io/basic-auth" '{
          "username": "'"$(echo "keto" | base64)"'",
          "password": "'"$(echo "${__database_keto_password}" | base64)"'"
        }'
    else
        __database_keto_password="$(kubectl get secret -n "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_NAME}-database-keto-password" --template='{{ .data.password | base64decode }}')"
    fi

    # Create the Ory Keto database user
    database_create_user "postgresql" "${PACKAGE_NAME}" "${__database_host}" "${__database_port}" "" "rw" "${__database_root_username}" "${__database_root_password}" "keto" "${__database_keto_password}"

    # Write DSN to package cache
    local __dsn="postgres://keto:${__database_keto_password}@${__database_host}:${__database_port}/${PACKAGE_NAME}"
    if [[ -n "${__database_parameters}" ]]; then
        __dsn="${__dsn}?${__database_parameters}"
    fi

    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.dsn" "${__dsn}"

    # Build the "permission-models" ConfigMap
    local -A __files=()

    local __i
    for __i in $(seq "$(package_cache_values_file_count ".packages.${PACKAGE_IPATH}.permissionModels.filePaths")"); do
        local __file_path
        __file_path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.permissionModels.filePaths[$((__i - 1))]")"

        local __resolved_file_path
        eval __resolved_file_path="${__file_path}"

        __files+=(["$(hash_generate_unique_basename "${__file_path}")"]="${__resolved_file_path}")
    done

    if [[ ${#__files[@]} -gt 0 ]]; then
        k8s_configmap_create_from_files "${K8S_PACKAGE_NAMESPACE}" "${K8S_PACKAGE_NAME}-namespaces" "__files"
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

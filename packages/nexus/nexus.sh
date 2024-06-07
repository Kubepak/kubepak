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
# @package-option dependencies="emissary-ingress" [ ",${CONTEXT}," =~ ",single-ingress-controller," ]
# @package-option dependencies="ingress-public" [ ",${CONTEXT}," =~ ",multiple-ingress-controllers," ]
# @package-option dependencies="nexus-database"
# @package-option dependencies="prometheus-stack" [ ,${CONTEXT}, =~ ,prometheus-metrics, ]

# @package-option port-forwards="${PACKAGE_NAME}-hl:${PACKAGE_PREFIX}_PORT:8081"

#-----------------------------------------------------------------------------
# Private Constants

readonly __NEXUS_CHART_VERSION="69.0.0"

readonly -A __NEXUS_API_LUT=(
    ["01,.nexus.api.blobstores.azure"]="nexus_blobstore_create_update,true,azure"
    ["02,.nexus.api.blobstores.file"]="nexus_blobstore_create_update,true,file"
    ["03,.nexus.api.blobstores.group"]="nexus_blobstore_create_update,true,group"
    ["04,.nexus.api.blobstores.s3"]="nexus_blobstore_create_update,true,s3"
    ["05,.nexus.api.repositories.docker.group"]="nexus_repository_create_update,true,docker,group"
    ["06,.nexus.api.repositories.docker.hosted"]="nexus_repository_create_update,true,docker,hosted"
    ["07,.nexus.api.repositories.docker.proxy"]="nexus_repository_create_update,true,docker,proxy"
    ["08,.nexus.api.repositories.go.group"]="nexus_repository_create_update,true,go,group"
    ["09,.nexus.api.repositories.go.hosted"]="nexus_repository_create_update,true,go,hosted"
    ["10,.nexus.api.repositories.go.proxy"]="nexus_repository_create_update,true,go,proxy"
    ["11,.nexus.api.repositories.helm.group"]="nexus_repository_create_update,true,helm,group"
    ["12,.nexus.api.repositories.helm.hosted"]="nexus_repository_create_update,true,helm,hosted"
    ["13,.nexus.api.repositories.helm.proxy"]="nexus_repository_create_update,true,helm,proxy"
    ["14,.nexus.api.repositories.maven.group"]="nexus_repository_create_update,true,maven,group"
    ["15,.nexus.api.repositories.maven.hosted"]="nexus_repository_create_update,true,maven,hosted"
    ["16,.nexus.api.repositories.maven.proxy"]="nexus_repository_create_update,true,maven,proxy"
    ["17,.nexus.api.repositories.npm.group"]="nexus_repository_create_update,true,npm,group"
    ["18,.nexus.api.repositories.npm.hosted"]="nexus_repository_create_update,true,npm,hosted"
    ["19,.nexus.api.repositories.npm.proxy"]="nexus_repository_create_update,true,npm,proxy"
    ["20,.nexus.api.repositories.nuget.group"]="nexus_repository_create_update,true,nuget,group"
    ["21,.nexus.api.repositories.nuget.hosted"]="nexus_repository_create_update,true,nuget,hosted"
    ["22,.nexus.api.repositories.nuget.proxy"]="nexus_repository_create_update,true,nuget,proxy"
    ["23,.nexus.api.repositories.pypi.group"]="nexus_repository_create_update,true,pypi,group"
    ["24,.nexus.api.repositories.pypi.hosted"]="nexus_repository_create_update,true,pypi,hosted"
    ["25,.nexus.api.repositories.pypi.proxy"]="nexus_repository_create_update,true,pypi,proxy"
    ["26,.nexus.api.rpc"]="nexus_rpc,true"
    ["27,.nexus.api.security.anonymous"]="nexus_security_anonymous_enable,false"
    ["28,.nexus.api.security.realms.active"]="nexus_security_realms_activate,false"
    ["29,.nexus.api.security.roles"]="nexus_security_role_create_update,true"
    ["30,.nexus.api.security.saml"]="nexus_security_saml_create_update,false"
    ["31,.nexus.api.security.users"]="nexus_security_user_create_update,true"
    ["32,.nexus.api.security.user-tokens"]="nexus_security_user_tokens_enable,false"
)

#-----------------------------------------------------------------------------
# Private Methods

__nexus_config_apply() {
    local __nexus_admin_username="${1}"
    local __nexus_admin_password="${2}"

    local __config_path
    eval __config_path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.config.path")"

    if [[ ! -e "${__config_path}" ]]; then
        return 1
    fi

    local __key
    local __nexus_api_lut_ordered_keys=()
    while IFS= read -r __key; do
        __nexus_api_lut_ordered_keys+=("${__key}")
    done < <(
        for __key in "${!__NEXUS_API_LUT[@]}"; do
            echo "${__key}"
        done | sort -n -k3
    )

    for __key in "${__nexus_api_lut_ordered_keys[@]}"; do
        local __path_expr
        __path_expr="${__key#*,}"

        local __callback
        __callback="$(cut -d ',' -f1 <<<"${__NEXUS_API_LUT[${__key}]}")"

        local __has_multiple_entries
        __has_multiple_entries="$(cut -d ',' -f2 <<<"${__NEXUS_API_LUT[${__key}]}")"

        local __callback_params
        readarray -td, __callback_params <<<"$(cut -d ',' -f3- <<<"${__NEXUS_API_LUT[${__key}]}")"

        if [[ $(yaml_count "${__config_path}" "${__path_expr}") -gt 0 ]]; then
            if ${__has_multiple_entries}; then
                local __i
                for __i in $(seq "$(yaml_count "${__config_path}" "${__path_expr}")"); do
                    # shellcheck disable=SC2048,SC2086
                    "${__callback}" "${__nexus_admin_username}" "${__nexus_admin_password}" "http://127.0.0.1:${NEXUS_PORT}" ${__callback_params[*]} "$(yaml_read_json "${__config_path}" "${__path_expr}[$((__i - 1))]")"
                done
            else
                # shellcheck disable=SC2048,SC2086
                "${__callback}" "${__nexus_admin_username}" "${__nexus_admin_password}" "http://127.0.0.1:${NEXUS_PORT}" ${__callback_params[*]} "$(yaml_read_json "${__config_path}" "${__path_expr}")"
            fi
        fi
    done
}

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.chartVersion" "${__NEXUS_CHART_VERSION}"

    # Save the Docker subdomains in the cache to enable the creation of the Ingress mappings
    {
        local __config_path
        eval __config_path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.config.path")"

        if [[ ! -e "${__config_path}" ]]; then
            return 1
        fi

        local __repository_type
        for __repository_type in $(yaml_read "${__config_path}" ".nexus.api.repositories[\"docker\"][] | key"); do
            local __i
            for __i in $(seq "$(yaml_count "${__config_path}" ".nexus.api.repositories[\"docker\"][\"${__repository_type}\"]")"); do
                package_cache_values_file_write ".packages.${PACKAGE_IPATH}.docker.registries[$((__i - 1))]" \
                    "$(yaml_read "${__config_path}" ".nexus.api.repositories[\"docker\"][\"${__repository_type}\"][$((__i - 1))].docker.subdomain")"
            done
        done
    }

    k8s_namespace_create "${K8S_PACKAGE_NAMESPACE}"

    registry_credentials_add_namespace "${K8S_PACKAGE_NAMESPACE}"
}

hook_pre_install() {
    local __database_host
    __database_host="$(package_cache_values_file_read ".packages.nexus-database.metadata.host")"

    local __database_port
    __database_port="$(package_cache_values_file_read ".packages.nexus-database.metadata.port")"

    local __database_root_username
    __database_root_username="$(package_cache_values_file_read ".packages.nexus-database.metadata.root.username")"

    local __database_root_password
    __database_root_password="$(package_cache_values_file_read ".packages.nexus-database.metadata.root.password")"

    # Create the Nexus database
    database_create "postgresql" "nexus" "${__database_host}" "${__database_port}" "" "${__database_root_username}" "${__database_root_password}"

    # Create a password for the Nexus database user if not already set
    local __database_nexus_password
    if ! k8s_resource_exists "${K8S_PACKAGE_NAMESPACE}" "secret" "${PACKAGE_NAME}-database-nexus-password"; then
        __database_nexus_password="$(password_generate "32")"

        k8s_secret_create "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_NAME}-nexus-database-password" "kubernetes.io/basic-auth" '{
          "username": "'"$(echo "nexus" | base64)"'",
          "password": "'"$(echo "${__database_nexus_password}" | base64)"'"
        }'
    else
        __database_nexus_password="$(kubectl get secret -n "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_NAME}-nexus-database-password" --template='{{ .data.password | base64decode }}')"
    fi

    # Create the Nexus database user
    database_create_user "postgresql" "nexus" "${__database_host}" "${__database_port}" "" "rw" "${__database_root_username}" "${__database_root_password}" "nexus" "${__database_nexus_password}"

    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.database.username" "nexus"
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.database.password" "${__database_nexus_password}"

    # Generate credentials for the metrics-reader user if "prometheus-metrics" is specified
    if [[ ,${CONTEXT}, =~ ,prometheus-metrics, ]]; then
        local __metrics_reader_password
        __metrics_reader_password="$(password_generate "32")"

        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.auth.metrics-reader.username" "metrics-reader"
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.auth.metrics-reader.password" "${__metrics_reader_password}"
    fi
}

hook_install() {
    package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart"

    argo_cd_application_wait "${K8S_PACKAGE_NAME}"
}

hook_post_install() {
    # Retrieve the administrator password for Nexus
    local __nexus_admin_password="admin"
    if k8s_resource_exists "${K8S_PACKAGE_NAMESPACE}" "secret" "${PACKAGE_NAME}-admin-password"; then
        __nexus_admin_password="$(kubectl get secret -n "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_NAME}-admin-password" --template='{{ .data.password | base64decode }}')"
    fi

    # Apply the Nexus configuration
    __nexus_config_apply "admin" "${__nexus_admin_password}"

    # Create a metrics reader role and user when "prometheus-metrics" is specified
    if [[ ,${CONTEXT}, =~ ,prometheus-metrics, ]]; then
        nexus_security_role_create_update "admin" "${__nexus_admin_password}" "http://127.0.0.1:${NEXUS_PORT}" '{
          "id": "nx-metrics-reader",
          "name": "nx-metrics-reader",
          "description": "Metrics Reader Role",
          "readOnly": true,
          "privileges": [
            "nx-metrics-all"
          ]
        }'

        nexus_security_user_create_update "admin" "${__nexus_admin_password}" "http://127.0.0.1:${NEXUS_PORT}" '{
          "userId": "metrics-reader",
          "firstName": "Metrics Reader",
          "lastName": "User",
          "emailAddress": "metrics-reader@example.org",
          "password": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.auth.metrics-reader.password")"'",
          "source": "default",
          "status": "active",
          "readOnly": false,
          "roles": [
            "nx-metrics-reader"
          ]
        }'
    fi

    # If SAML is enabled, change the administrator password to a random one if it is currently set as 'admin'
    if nexus_security_saml_exists "admin" "${__nexus_admin_password}" "http://127.0.0.1:${NEXUS_PORT}"; then
        if [[ "${__nexus_admin_password}" == "admin" ]]; then
            __nexus_admin_password="$(password_generate "32")"

            k8s_secret_create "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_NAME}-admin-password" "kubernetes.io/basic-auth" '{
              "username": "'"$(echo "admin" | base64)"'",
              "password": "'"$(echo "${__nexus_admin_password}" | base64)"'"
            }'

            nexus_security_user_change_password "admin" "admin" "http://127.0.0.1:${NEXUS_PORT}" "admin" "${__nexus_admin_password}"
        fi
    fi

    # Save the credentials of the Nexus administrator in the global cache so that other packages can retrieve them
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.auth.admin.username" "admin" true
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.auth.admin.password" "${__nexus_admin_password}" true
}

hook_pre_upgrade() {
    hook_pre_install
}

hook_upgrade() {
    hook_install
}

hook_post_upgrade() {
    hook_post_install
}

package_hook_execute "${@}"
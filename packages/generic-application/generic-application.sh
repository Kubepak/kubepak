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

# @package-option dependencies="argo-cd"

#-----------------------------------------------------------------------------
# Private Constants

readonly __GENERIC_APPLICATION_CHART_REPO_URL="git@github.com:kubepak/charts-generic_application.git"
readonly __GENERIC_APPLICATION_CHART_VERSION="v0.1.0"

readonly __GENERIC_APPLICATION_DEFAULT_TLS_CA_PEM_DST_FILE_PATH="/ssl/certs/ca-certificates.crt"
readonly __GENERIC_APPLICATION_DEFAULT_TLS_CA_TRUSTSTORE_DST_FILE_PATH="/ssl/certs/truststore.jks"

readonly __K8S_SERVICE_ACCOUNT_NAME="${K8S_PACKAGE_NAME}"
readonly __K8S_VAULT_ROLE="${K8S_PACKAGE_NAMESPACE}"

#-----------------------------------------------------------------------------
# Private Methods

__configmap_mount_file() {
    local __name="${1}"
    local __src_file_path="${2}"
    local __dst_file_path="${3}"

    k8s_configmap_create_from_file "${K8S_PACKAGE_NAMESPACE}" "${K8S_PACKAGE_NAME}-${__name}" "$(basename "${__dst_file_path}")" "${__src_file_path}"

    package_cache_values_file_add ".packages.${PACKAGE_IPATH}.pod.volumes" '[
      {
        "name": "'"${__name}"'",
        "configMap": {
          "name": "'"${K8S_PACKAGE_NAME}-${__name}"'"
        }
      }
    ]'

    package_cache_values_file_add ".packages.${PACKAGE_IPATH}.pod.container.volumeMounts" '[
      {
        "name": "'"${__name}"'",
        "readOnly": true,
        "mountPath": "'"$(dirname "${__dst_file_path}")"'"
      }
    ]'
}

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.chartRepoURL" "${__GENERIC_APPLICATION_CHART_REPO_URL}"
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.chartVersion" "${__GENERIC_APPLICATION_CHART_VERSION}"

    k8s_namespace_create "${K8S_PACKAGE_NAMESPACE}"

    registry_credentials_add_namespace "${K8S_PACKAGE_NAMESPACE}"
}

hook_pre_install() {
    # Install trusted Certificate Authority (CA) bundles if specified
    local __tls_ca_pem_src_file_path
    __tls_ca_pem_src_file_path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.tls.ca.pem.srcFilePath")"

    local __tls_ca_pem_dst_file_path
    if [[ -n "${__tls_ca_pem_src_file_path}" ]]; then
        __tls_ca_pem_dst_file_path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.tls.ca.pem.dstFilePath" "${__GENERIC_APPLICATION_DEFAULT_TLS_CA_PEM_DST_FILE_PATH}")"
        __configmap_mount_file "ca-certificates" "${__tls_ca_pem_src_file_path}" "${__tls_ca_pem_dst_file_path}"
    fi

    local __tls_ca_truststore_src_file_path
    __tls_ca_truststore_src_file_path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.tls.ca.trustStore.srcFilePath")"

    local __tls_ca_truststore_dst_file_path
    if [[ -n "${__tls_ca_truststore_src_file_path}" ]]; then
        __tls_ca_truststore_dst_file_path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.tls.ca.trustStore.dstFilePath" "${__GENERIC_APPLICATION_DEFAULT_TLS_CA_TRUSTSTORE_DST_FILE_PATH}")"
        __configmap_mount_file "truststore" "${__tls_ca_truststore_src_file_path}" "${__tls_ca_truststore_dst_file_path}"
    fi

    local __vault_policies=()

    local __vault_engines_db_enabled
    __vault_engines_db_enabled="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.vault.engines.db.enabled" "false")"

    local __vault_engines_kv_enabled
    __vault_engines_kv_enabled="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.vault.engines.kv.enabled" "false")"

    if [[ "${__vault_engines_db_enabled}" == "true" || "${__vault_engines_kv_enabled}" == "true" ]]; then
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.vault.address" "http://vault.$(package_cache_values_file_read ".packages.vault.namespace").svc.cluster.local.:8200"
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.vault.role" "${__K8S_VAULT_ROLE}"

        if [[ "${__vault_engines_kv_enabled}" == "true" ]]; then
            if [[ "$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.vault.engines.kv.readOnly" "false")" == "true" ]]; then
                __vault_policies+=("kubernetes-accessor-secret-read")
            else
                __vault_policies+=("kubernetes-accessor-secret-write")
            fi

            package_cache_values_file_write ".packages.${PACKAGE_IPATH}.vault.engines.kv.secretPath" "secret/${K8S_PACKAGE_NAMESPACE}"
        fi
    fi

    local __vault_agent_enabled
    __vault_agent_enabled="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.vaultAgent.enabled" "false")"

    local __i
    for __i in $(seq "$(package_cache_values_file_count ".packages.${PACKAGE_IPATH}.databases")"); do
        local __database_auth_rootUsername
        __database_auth_rootUsername="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.databases[$((__i - 1))].auth.rootUsername")"

        local __database_auth_rootPassword
        __database_auth_rootPassword="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.databases[$((__i - 1))].auth.rootPassword")"

        local __database_name
        __database_name="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.databases[$((__i - 1))].name")"

        local __database_engine
        __database_engine="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.databases[$((__i - 1))].engine")"

        local __database_hostname
        __database_hostname="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.databases[$((__i - 1))].hostname")"

        local __database_port
        __database_port="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.databases[$((__i - 1))].port" "$(database_get_default_port "${__database_engine}")")"

        local __database_options
        __database_options="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.databases[$((__i - 1))].options")"

        local __database_local_options
        if [[ -n "${__tls_ca_pem_src_file_path}" ]]; then
            __database_local_options="${__database_options//${__tls_ca_pem_dst_file_path}/${__tls_ca_pem_src_file_path}}"
        fi

        local __database_mode
        __database_mode="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.databases[$((__i - 1))].mode" "rw")"

        database_create "${__database_engine}" "${__database_name}" "${__database_hostname}" "${__database_port}" "${__database_local_options}" "${__database_auth_rootUsername}" "${__database_auth_rootPassword}"

        local __database_auth_username
        __database_auth_username="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.databases[$((__i - 1))].auth.username")"

        local __database_auth_password
        __database_auth_password="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.databases[$((__i - 1))].auth.password")"

        if [[ -n "${__database_auth_username}" && -n "${__database_auth_password}" ]]; then
            database_create_user "${__database_engine}" "${__database_name}" "${__database_hostname}" "${__database_port}" "${__database_local_options}" "${__database_mode}" "${__database_auth_rootUsername}" "${__database_auth_rootPassword}" "${__database_auth_username}" "${__database_auth_password}"
        fi

        if [[ "${__vault_agent_enabled}" == "true" && "${__vault_engines_db_enabled}" == "true" ]]; then
            local __database_id
            __database_id="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.databases[$((__i - 1))].id" "${__database_name}")"

            local __vault_database_options
            __vault_database_options="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.vault.engines.db.config.databases[$((__i - 1))].options")"

            local __vault_database_default_ttl
            __vault_database_default_ttl="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.vault.engines.db.config.databases[$((__i - 1))].default_ttl" "1h")"

            local __vault_database_maximum_ttl
            __vault_database_maximum_ttl="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.vault.engines.db.config.databases[$((__i - 1))].max_ttl" "1h")"

            database_create_super_user "${__database_engine}" "${__database_hostname}" "${__database_port}" "${__database_local_options}" "${__database_auth_rootUsername}" "${__database_auth_rootPassword}" "vault-${__database_mode}" "will-be-rotated"

            database_vault_configure "${__database_engine}" "${__database_name}" "${__database_hostname}" "${__database_port}" "${__vault_database_options}" "${__database_mode}" "vault-${__database_mode}" "will-be-rotated" "${__vault_database_default_ttl}" "${__vault_database_maximum_ttl}"

            package_cache_values_file_add ".packages.${PACKAGE_IPATH}.vaultAgent.db.template.dataSources" '[
              {
                "id": "'"${__database_id}"'",
                "name": "'"${__database_name}"'",
                "engine": "'"${__database_engine}"'",
                "hostname": "'"${__database_hostname}"'",
                "port": "'"${__database_port}"'",
                "options": "'"${__database_options}"'",
                "mode": "'"${__database_mode}"'"
              }
            ]'

            __vault_policies+=("${__database_hostname%.}-${__database_port}-${__database_name}-${__database_mode}-database-creds-read")
        fi
    done

    if [[ ${#__vault_policies[@]} -gt 0 ]]; then
        vault write "auth/kubernetes/role/${__K8S_VAULT_ROLE}" \
            bound_service_account_names="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.serviceAccount.name" "${__K8S_SERVICE_ACCOUNT_NAME}")" \
            bound_service_account_namespaces="${K8S_PACKAGE_NAMESPACE}" \
            policies="$(
                IFS=','
                echo "${__vault_policies[*]}"
            )" \
            token_max_ttl=4h \
            ttl=1h
    fi
}

hook_install() {
    package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart"

    argo_cd_application_wait "${K8S_PACKAGE_NAME}" "$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.argo-cd.waitMaxAttempts" "120")"
}

hook_upgrade() {
    hook_install
}

package_hook_execute "${@}"

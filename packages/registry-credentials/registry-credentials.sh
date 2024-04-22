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

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    # NOTE: Remove the installation marker files to ensure the registry credentials package executes during installation,
    #       thereby guaranteeing proper propagation of registry credentials to the namespaces of newly created packages.
    rm -f "${PACKAGE_CACHE_DIR}"/.hook_*
}

hook_pre_install() {
    local __registry
    for __registry in $(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.registries[] | key"); do
        local __i
        for __i in $(seq "$(package_cache_values_file_count ".packages.${PACKAGE_IPATH}.registries.${__registry}")"); do
            case "${__registry}" in
            dpr)
                local __docker_server
                __docker_server="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.registries.${__registry}[$((__i - 1))].server" "https://index.docker.io/v1/")"

                local __docker_username
                __docker_username="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.registries.${__registry}[$((__i - 1))].username")"

                local __docker_password
                __docker_password="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.registries.${__registry}[$((__i - 1))].password")"

                local __namespace
                for __namespace in $(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.namespaces[]"); do
                    k8s_secret_create_docker_registry "${__namespace}" "registry-creds-${__registry}-$((__i - 1))" "${__docker_server}" "${__docker_username}" "${__docker_password}"
                done
                ;;
            ecr)
                local __aws_account
                __aws_account="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.registries.${__registry}[$((__i - 1))].awsAccount")"

                local __aws_region
                __aws_region="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.registries.${__registry}[$((__i - 1))].awsRegion")"

                local __aws_access_key_id
                __aws_access_key_id="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.registries.${__registry}[$((__i - 1))].awsAccessKeyId")"

                local __aws_secret_access_key
                __aws_secret_access_key="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.registries.${__registry}[$((__i - 1))].awsSecretAccessKey")"

                local __ecr_password
                __ecr_password="$(AWS_ACCESS_KEY_ID="${__aws_access_key_id}" AWS_SECRET_ACCESS_KEY="${__aws_secret_access_key}" aws ecr get-login-password --region "${__aws_region}")"

                local __namespace
                for __namespace in $(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.namespaces[]"); do
                    k8s_secret_create_docker_registry "${__namespace}" "registry-creds-${__registry}-$((__i - 1))" "https://${__aws_account}.dkr.ecr.${__aws_region}.amazonaws.com" "AWS" "${__ecr_password}"
                done
                ;;
            esac
        done
    done
}

hook_install() {
    if [[ $(package_cache_values_file_count ".packages.${PACKAGE_IPATH}.registries.ecr") -gt 0 ]]; then
        package_helm_install "${K8S_PACKAGE_NAME}" "${K8S_PACKAGE_NAMESPACE}" "${PACKAGE_DIR}/files/helm-chart"

        k8s_resource_wait "default" "cronjob" "${K8S_PACKAGE_NAME}"
    fi
}

hook_pre_upgrade() {
    hook_pre_install
}

hook_upgrade() {
    hook_install
}

package_hook_execute "${@}"

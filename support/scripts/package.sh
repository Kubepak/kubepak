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

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/adapters/databases/database.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/argo_cd.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/array.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/expbackoff.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/k8s.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/log.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/nexus.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/password.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/registry_credentials.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/string.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/uuid.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/yaml.sh"

#-----------------------------------------------------------------------------
# Public Methods

package_cache_values_file_add() {
    local __path_expr="${1}"
    local __value="${2}"
    local __global_cache="${3:-false}"

    if ${__global_cache}; then
        yaml_add "${CACHE_CWD}/values.yaml" "${__path_expr}" "${__value}" false >"${PACKAGE_CACHE_DIR}/tmpfile.yaml" && mv "${PACKAGE_CACHE_DIR}/tmpfile.yaml" "${CACHE_CWD}/values.yaml"
    else
        yaml_add "${PACKAGE_CACHE_DIR}/${PACKAGE_VALUES_FILE_NAME}" "${__path_expr}" "${__value}" false >"${PACKAGE_CACHE_DIR}/${PACKAGE_VALUES_FILE_NAME}.tmp" && mv "${PACKAGE_CACHE_DIR}/${PACKAGE_VALUES_FILE_NAME}.tmp" "${PACKAGE_CACHE_DIR}/${PACKAGE_VALUES_FILE_NAME}"
    fi
}

package_cache_values_file_add_string() {
    local __path_expr="${1}"
    local __value="${2}"
    local __global_cache="${3:-false}"

    if ${__global_cache}; then
        yaml_add "${CACHE_CWD}/values.yaml" "${__path_expr}" "${__value}" true >"${PACKAGE_CACHE_DIR}/tmpfile.yaml" && mv "${PACKAGE_CACHE_DIR}/tmpfile.yaml" "${CACHE_CWD}/values.yaml"
    else
        yaml_add "${PACKAGE_CACHE_DIR}/${PACKAGE_VALUES_FILE_NAME}" "${__path_expr}" "${__value}" true >"${PACKAGE_CACHE_DIR}/${PACKAGE_VALUES_FILE_NAME}.tmp" && mv "${PACKAGE_CACHE_DIR}/${PACKAGE_VALUES_FILE_NAME}.tmp" "${PACKAGE_CACHE_DIR}/${PACKAGE_VALUES_FILE_NAME}"
    fi
}

package_cache_values_file_contains() {
    local __path_expr="${1}"
    local __value="${2}"

    local __package_values_files
    mapfile -t __package_values_files < <(find "${PACKAGE_CACHE_DIR}" -name "values-*-*.yaml" -print | sort -r)

    if [ ${#__package_values_files[@]} -eq 0 ]; then
        yaml_contains "${CACHE_CWD}/values.yaml" "${__path_expr}" "${__value}"
    else
        yaml_merge "${__package_values_files[@]}" "${CACHE_CWD}/values.yaml" | yaml_contains - "${__path_expr}" "${__value}"
    fi
}

package_cache_values_file_count() {
    local __path_expr="${1}"

    local __package_values_files
    mapfile -t __package_values_files < <(find "${PACKAGE_CACHE_DIR}" -name "values-*-*.yaml" -print | sort -r)

    if [ ${#__package_values_files[@]} -eq 0 ]; then
        yaml_count "${CACHE_CWD}/values.yaml" "${__path_expr}"
    else
        yaml_merge "${__package_values_files[@]}" "${CACHE_CWD}/values.yaml" | yaml_count - "${__path_expr}"
    fi
}

package_cache_values_file_read() {
    local __path_expr="${1}"
    local __default="${2:-}"

    local __package_values_files
    mapfile -t __package_values_files < <(find "${PACKAGE_CACHE_DIR}" -name "values-*-*.yaml" -print | sort -r)

    if [ ${#__package_values_files[@]} -eq 0 ]; then
        yaml_read "${CACHE_CWD}/values.yaml" "${__path_expr}" "${__default}"
    else
        yaml_merge "${__package_values_files[@]}" "${CACHE_CWD}/values.yaml" | yaml_read - "${__path_expr}" "${__default}"
    fi
}

package_cache_values_file_read_json() {
    local __path_expr="${1}"
    local __compact="${2:-false}"
    local __default="${3:-"{}"}"

    local __package_values_files
    mapfile -t __package_values_files < <(find "${PACKAGE_CACHE_DIR}" -name "values-*-*.yaml" -print | sort -r)

    if [ ${#__package_values_files[@]} -eq 0 ]; then
        yaml_read_json "${CACHE_CWD}/values.yaml" "${__path_expr}" "${__compact}" "${__default}"
    else
        yaml_merge "${__package_values_files[@]}" "${CACHE_CWD}/values.yaml" | yaml_read_json - "${__path_expr}" "${__compact}" "${__default}"
    fi
}

package_cache_values_file_write() {
    local __path_expr="${1}"
    local __value="${2}"
    local __global_cache="${3:-false}"

    if ${__global_cache}; then
        yaml_write "${CACHE_CWD}/values.yaml" "${__path_expr}" "${__value}" false
    else
        yaml_write "${PACKAGE_CACHE_DIR}/${PACKAGE_VALUES_FILE_NAME}" "${__path_expr}" "${__value}" false
    fi
}

package_cache_values_file_write_string() {
    local __path_expr="${1}"
    local __value="${2}"
    local __global_cache="${3:-false}"

    if ${__global_cache}; then
        yaml_write "${CACHE_CWD}/values.yaml" "${__path_expr}" "${__value}" true
    else
        yaml_write "${PACKAGE_CACHE_DIR}/${PACKAGE_VALUES_FILE_NAME}" "${__path_expr}" "${__value}" true
    fi
}

package_helm_install() {
    local __package_name="${1:-"${K8S_PACKAGE_NAME}"}"
    local __namespace="${2:-"${K8S_PACKAGE_NAMESPACE}"}"
    local __chart="${3:-"${PACKAGE_DIR}/files/helm-chart"}"

    local __package_values_files
    mapfile -t __package_values_files < <(find "${PACKAGE_CACHE_DIR}" -name "values-*-*.yaml" -print | sort -r)

    if [[ $(string_count_occurrences_of "${PACKAGE_IPATH}" ".") -gt 0 ]]; then
        if [ ${#__package_values_files[@]} -eq 0 ]; then
            yaml_delete "${CACHE_CWD}/values.yaml" ".packages.${PACKAGE_IPATH##*.}" |
                yaml_move - ".packages.${PACKAGE_IPATH}" ".packages.${PACKAGE_IPATH##*.}" >"${PACKAGE_CACHE_DIR}/tmpfile.yaml"
        else
            yaml_delete "${CACHE_CWD}/values.yaml" ".packages.${PACKAGE_IPATH##*.}" |
                yaml_merge "${__package_values_files[@]}" - |
                yaml_move - ".packages.${PACKAGE_IPATH}" ".packages.${PACKAGE_IPATH##*.}" >"${PACKAGE_CACHE_DIR}/tmpfile.yaml"
        fi
    else
        if [ ${#__package_values_files[@]} -eq 0 ]; then
            yaml_read "${CACHE_CWD}/values.yaml" "." |
                yaml_move - ".packages.${PACKAGE_IPATH}" ".packages.${PACKAGE_IPATH##*.}" >"${PACKAGE_CACHE_DIR}/tmpfile.yaml"
        else
            yaml_read "${CACHE_CWD}/values.yaml" "." |
                yaml_merge "${__package_values_files[@]}" - |
                yaml_move - ".packages.${PACKAGE_IPATH}" ".packages.${PACKAGE_IPATH##*.}" >"${PACKAGE_CACHE_DIR}/tmpfile.yaml"
        fi
    fi

    helm dependency update "${__chart}"
    helm template "${__package_name}" "${__chart}" \
        --namespace "${__namespace}" \
        --values "${PACKAGE_CACHE_DIR}/tmpfile.yaml" |
        kubectl apply -f -

    rm -rf "${PACKAGE_CACHE_DIR}/tmpfile.yaml"
}

package_hook_execute() {
    local __hook="${1}"

    if declare -f -F "${__hook}" >/dev/null; then
        "${@}"
    fi
}

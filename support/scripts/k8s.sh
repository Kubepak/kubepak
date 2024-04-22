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

#-----------------------------------------------------------------------------
# Public Methods

k8s_annotate() {
    local __namespace="${1}"
    local __resource_type="${2}"
    local __resource_name="${3}"
    local __annotations_ref_name="${4:-}"

    if [[ -n "${__annotations_ref_name}" ]]; then
        local -n __annotations_ref="${__annotations_ref_name}"
        local __annotation_key

        for __annotation_key in "${!__annotations_ref[@]}"; do
            kubectl annotate "${__resource_type}" -n "${__namespace}" "${__resource_name}" "${__annotation_key}=${__annotations_ref["${__annotation_key}"]}" --overwrite
        done
    fi
}

k8s_configmap_create_from_file() {
    local __namespace="${1}"
    local __configmap_name="${2}"
    local __key="${3}"
    local __file_path="${4}"
    local __labels_ref_name="${5:-}"
    local __annotations_ref_name="${6:-}"

    kubectl create configmap -n "${__namespace}" "${__configmap_name}" --from-file="${__key}"="${__file_path}" --dry-run=client -o yaml | kubectl apply -f -

    # shellcheck disable=SC2034
    local -A __std_labels=(
        ["app.kubernetes.io/name"]="${__configmap_name}"
        ["app.kubernetes.io/part-of"]="${ORGANIZATION}.${PROJECT}"
        ["app.kubernetes.io/managed-by"]="kubepak"
    )

    k8s_label "${__namespace}" "configmap" "${__configmap_name}" "__std_labels"
    k8s_label "${__namespace}" "configmap" "${__configmap_name}" "${__labels_ref_name}"

    k8s_annotate "${__namespace}" "configmap" "${__configmap_name}" "${__annotations_ref_name}"
}

k8s_configmap_create_from_files() {
    local __namespace="${1}"
    local __configmap_name="${2}"
    local -n __files_ref="${3}"
    local __labels_ref_name="${4:-}"
    local __annotations_ref_name="${5:-}"

    local __cmd=("kubectl create configmap -n ${__namespace} ${__configmap_name}")
    local __key
    for __key in "${!__files_ref[@]}"; do
        __cmd+=("--from-file=${__key}=${__files_ref["${__key}"]}")
    done
    __cmd+=("--dry-run=client -o yaml")

    ${__cmd[*]} | kubectl apply -f -

    # shellcheck disable=SC2034
    local -A __std_labels=(
        ["app.kubernetes.io/name"]="${__configmap_name}"
        ["app.kubernetes.io/part-of"]="${ORGANIZATION}.${PROJECT}"
        ["app.kubernetes.io/managed-by"]="kubepak"
    )

    k8s_label "${__namespace}" "configmap" "${__configmap_name}" "__std_labels"
    k8s_label "${__namespace}" "configmap" "${__configmap_name}" "${__labels_ref_name}"

    k8s_annotate "${__namespace}" "configmap" "${__configmap_name}" "${__annotations_ref_name}"
}

k8s_label() {
    local __namespace="${1}"
    local __resource_type="${2}"
    local __resource_name="${3}"
    local __labels_ref_name="${4:-}"

    if [[ -n "${__labels_ref_name}" ]]; then
        local -n __labels_ref="${__labels_ref_name}"
        local __label_key

        for __label_key in "${!__labels_ref[@]}"; do
            kubectl label "${__resource_type}" -n "${__namespace}" "${__resource_name}" "${__label_key}=${__labels_ref["${__label_key}"]}" --overwrite
        done
    fi
}

k8s_namespace_create() {
    local __namespace="${1}"

    kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ${__namespace}
  labels:
    app.kubernetes.io/name: ${__namespace}
    app.kubernetes.io/part-of: ${ORGANIZATION}.${PROJECT}
    app.kubernetes.io/managed-by: kubepak
EOF
}

k8s_namespace_delete() {
    local __namespace="${1}"

    kubectl delete namespace "${__namespace}" >/dev/null 2>&1
}

k8s_resource_delete() {
    local __namespace="${1}"
    local __resource_type="${2}"
    local __resource_name="${3}"
    local __timeout="${4:-}"

    if [[ -z "${__timeout}" ]]; then
        kubectl delete "${__resource_type}" -n "${__namespace}" "${__resource_name}" >/dev/null 2>&1
    else
        kubectl delete "${__resource_type}" -n "${__namespace}" --timeout="${__timeout}" "${__resource_name}" >/dev/null 2>&1
    fi
}

k8s_resource_exists() {
    local __namespace="${1}"
    local __resource_type="${2}"
    local __resource_name="${3}"
    local __timeout="${4:-}"

    if [[ -z "${__timeout}" ]]; then
        kubectl get "${__resource_type}" -n "${__namespace}" "${__resource_name}" >/dev/null 2>&1
    else
        kubectl get "${__resource_type}" -n "${__namespace}" --timeout="${__timeout}" "${__resource_name}" >/dev/null 2>&1
    fi
}

k8s_resource_wait() {
    local __namespace="${1}"
    local __resource_type="${2}"
    local __resource_name="${3}"
    local __max_attempts="${4:-120}"
    local __attempt=0

    printf "Waiting for %s \"%s\" in namespace \"%s\" to be created" "${__resource_type}" "${__resource_name}" "${__namespace}"

    until k8s_resource_exists "${__namespace}" "${__resource_type}" "${__resource_name}"; do
        if [[ ${__attempt} -eq __max_attempts ]]; then
            echo "Max attempts reached"
            exit 1
        fi

        printf '.'
        __attempt=$((__attempt + 1))
        sleep 2
    done
    printf '\n'

    case "${__resource_type}" in
    daemonset | deployment | statefulset)
        kubectl rollout status -n "${__namespace}" "${__resource_type}" "${__resource_name}"
        ;;
    esac
}

k8s_resource_wait_for() {
    local __namespace="${1}"
    local __resource_type="${2}"
    local __resource_name="${3}"
    local __condition="${4:-"condition=complete"}"
    local __timeout="${5:-}"

    if k8s_resource_exists "${__namespace}" "${__resource_type}" "${__resource_name}" "${__timeout}"; then
        if [[ -z "${__timeout}" ]]; then
            kubectl wait --for="${__condition}" -n "${__namespace}" "${__resource_type}" "${__resource_name}"
        else
            kubectl wait --for="${__condition}" -n "${__namespace}" --timeout="${__timeout}" "${__resource_type}" "${__resource_name}"
        fi
    fi
}

k8s_secret_create() {
    local __namespace="${1}"
    local __secret_name="${2}"
    local __secret_type="${3}"
    local __secret_data="${4}"

    kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${__secret_name}
  namespace: ${__namespace}
  labels:
    app.kubernetes.io/name: ${__secret_name}
    app.kubernetes.io/part-of: ${ORGANIZATION}.${PROJECT}
    app.kubernetes.io/managed-by: kubepak
type: ${__secret_type}
data:
  ${__secret_data}
EOF
}

k8s_secret_create_docker_registry() {
    local __namespace="${1}"
    local __secret_name="${2}"
    local __docker_server="${3}"
    local __docker_username="${4}"
    local __docker_password="${5}"

    kubectl delete secret --ignore-not-found -n "${__namespace}" "${__secret_name}"
    kubectl create secret docker-registry -n "${__namespace}" "${__secret_name}" --docker-server="${__docker_server}" --docker-username="${__docker_username}" --docker-password="${__docker_password}"
}

k8s_secret_create_sa_token() {
    local __namespace="${1}"
    local __secret_name="${2}"
    local __service_account_name="${3}"

    kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${__secret_name}
  namespace: ${__namespace}
  labels:
    app.kubernetes.io/name: ${__secret_name}
    app.kubernetes.io/part-of: ${ORGANIZATION}.${PROJECT}
    app.kubernetes.io/managed-by: kubepak
  annotations:
    kubernetes.io/service-account.name: ${__service_account_name}
type: kubernetes.io/service-account-token
EOF
}

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

#-----------------------------------------------------------------------------
# Public Hooks

hook_pre_install() {
    local -A __files

    local __i
    for __i in $(seq "$(package_cache_values_file_count ".packages.${PACKAGE_IPATH}.configFiles")"); do
        local __key
        __key="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.configFiles[$((__i - 1))].key").server"

        local __path
        eval __path="$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.configFiles.[$((__i - 1))].path")"

        __files+=(["${__key}"]="${__path}")
    done

    if [[ $(package_cache_values_file_count ".packages.${PACKAGE_IPATH}.configFiles") -gt 0 ]]; then
        k8s_configmap_create_from_files "kube-system" "coredns-custom" "__files"
    fi
}

hook_install() {
    if ! kubectl get configmap -n "kube-system" "coredns" -o yaml | grep -q "import custom/\*.server"; then
        kubectl patch configmap -n "kube-system" "coredns" \
            --patch="$(kubectl get configmap -n "kube-system" "coredns" -o yaml | yaml_add - ".data.Corefile" "import custom/*.server\n" | yaml_read_json - ".")"
    fi

    kubectl patch deployments.apps -n "kube-system" "coredns" \
        --patch-file "${PACKAGE_DIR}/files/patch/deployment-coredns.yaml"
}

hook_pre_upgrade() {
    hook_pre_install
}

hook_upgrade() {
    kubectl rollout restart deployment -n "kube-system" "coredns"
}

package_hook_execute "${@}"

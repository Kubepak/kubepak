#!/usr/bin/env bash

#
# Copyright (C) 2024 Generix Group – All rights reserved.
#
# Generix Group, through its subsidiaries, may own patents, have filed patent registrations or be the owner of brands,
# copyrights or other intellectual property rights concerning all or part of the elements which are included in this
# document.  Unless otherwise explicitly stated in a license contract written by Generix Group or one of its
# subsidiaries, supplying you with this document does not grant you any license over these patents, brands, copyrights
# or other intellectual property rights.
#

set -eo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/../../support/scripts/package.sh"

#-----------------------------------------------------------------------------
# Package Options

# @package-option attributes="final"

# @package-option base-packages="mysql" [ ,${CONTEXT}, =~ ,solochain-local-database, ]

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    if [[ ,${CONTEXT}, =~ ,solochain-local-database, ]]; then
        package_cache_values_file_write_string ".packages.${PACKAGE_IPATH}.mysql.primary.maxAllowedPacket" "134217728"
        package_cache_values_file_write_string ".packages.${PACKAGE_IPATH}.mysql.secondary.maxAllowedPacket" "134217728"

        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.metadata.host" "${K8S_PACKAGE_NAME}.${K8S_PACKAGE_NAMESPACE}.svc.cluster.local." true
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.metadata.port" "3306" true
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.metadata.root.username" "root" true
        package_cache_values_file_write ".packages.${PACKAGE_IPATH}.metadata.root.password" "$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.mysql.auth.rootPassword" "root")" true
    fi
}

package_hook_execute "${@}"

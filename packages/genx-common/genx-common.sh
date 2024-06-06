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

# @package-option base-packages="generic-application"

#-----------------------------------------------------------------------------
# Private Constants

readonly __GENX_COMMON_CHART_REPO_URL="git@github.com:generix-group/genx-gpe-charts-generic_application.git"
readonly __GENX_COMMON_CHART_VERSION="v0.1.1"

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.generic-application.chartRepoURL" "${__GENX_COMMON_CHART_REPO_URL}"
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.generic-application.chartVersion" "${__GENX_COMMON_CHART_VERSION}"
}

package_hook_execute "${@}"

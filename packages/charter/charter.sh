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

# @package-option base-packages="generic-application"

# @package-option dependencies="charter-database"
# @package-option dependencies="keycloak"
# @package-option dependencies="ory-keto"
# @package-option dependencies="vault"

#-----------------------------------------------------------------------------
# Private Constants

readonly __CHARTER_DEFAULT_POD_CONTAINER_IMAGE_REGISTRY="docker.io"
readonly __CHARTER_DEFAULT_POD_CONTAINER_IMAGE_REPOSITORY="srheaume/charter"
readonly __CHARTER_DEFAULT_POD_CONTAINER_IMAGE_TAG="0.1.0"

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    # Initialize base package values
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.generic-application" '{
      "pod": {
        "container": {
          "image": {
            "registry": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.image.registry" "${__CHARTER_DEFAULT_POD_CONTAINER_IMAGE_REGISTRY}")"'",
            "repository": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.image.repository" "${__CHARTER_DEFAULT_POD_CONTAINER_IMAGE_REPOSITORY}")"'",
            "tag": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.image.tag" "${__CHARTER_DEFAULT_POD_CONTAINER_IMAGE_TAG}")"'"
          },
          "env": [
            {
              "name": "KEYCLOAK_SERVER_URL",
              "value": "'"https://$(package_cache_values_file_read ".packages.keycloak.ingress.host")/"'"
            },
            {
              "name": "KEYCLOAK_REALM_NAME",
              "value": "'"$(package_cache_values_file_read ".packages.${PACKAGE_NAME}.keycloak.realmName")"'"
            },
            {
              "name": "KEYCLOAK_CLIENT_ID",
              "value": "'"$(package_cache_values_file_read ".packages.${PACKAGE_NAME}.keycloak.clientId")"'"
            },
            {
              "name": "KEYCLOAK_CLIENT_SECRET_KEY",
              "value": "'"$(package_cache_values_file_read ".packages.${PACKAGE_NAME}.keycloak.clientSecret")"'"
            },
            {
              "name": "KEYCLOAK_VERIFY_SSL",
              "value": "false"
            },
            {
              "name": "KETO_WRITE_API_URL",
              "value": "http://ory-keto-write-headless.shr-ory-keto.svc.cluster.local.:4467"
            },
            {
              "name": "KETO_CHECK_API_URL",
              "value": "http://ory-keto-read-headless.shr-ory-keto.svc.cluster.local.:4466"
            }
          ]
        }
      },
      "services": [
        {
          "name": "api",
          "type": "ClusterIP",
          "ports": [
            {
              "name": "http",
              "protocol": "TCP",
              "port": 8080,
              "targetPort": 8080
            }
          ]
        }
      ],
      "ingress": {
        "host": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.ingress.host")"'",
        "networkPlane": "public",
        "mappings": [
          {
            "serviceName": "api",
            "servicePort": 8080,
            "grpc": "false",
            "prefix": "/",
            "rewrite": "/",
            "bypassAuth": "false",
            "requestHeaders": {},
            "timeoutMs": '"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.ingress.timeoutMs" "null")"',
            "idleTimeoutMs": '"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.ingress.idleTimeoutMs" "null")"',
            "connectTimeoutMs": '"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.ingress.connectTimeoutMs" "null")"'
          }
        ]
      },
      "databases": [
        {
          "auth": {
            "rootUsername": "'"$(package_cache_values_file_read ".packages.charter-database.metadata.root.username")"'",
            "rootPassword": "'"$(package_cache_values_file_read ".packages.charter-database.metadata.root.password")"'"
          },
          "id": "charter",
          "name": "'"${ENVIRONMENT}_charter"'",
          "engine": "postgresql",
          "hostname": "'"$(package_cache_values_file_read ".packages.charter-database.metadata.host")"'",
          "port": '"$(package_cache_values_file_read ".packages.charter-database.metadata.port")"',
          "options": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.database.options")"'",
          "mode": "rw"
        }
      ],
      "vault": {
        "engines": {
          "db": {
            "enabled": true
          }
        }
      },
      "vaultAgent": {
        "enabled": true,
        "db": {
          "template": {
            "type": "generic"
          }
        }
      }
    }'
}

package_hook_execute "${@}"

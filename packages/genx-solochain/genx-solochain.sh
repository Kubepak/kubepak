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

# @package-option base-packages="genx-common"

# @package-option dependencies="genx-solochain-database"
# @package-option dependencies="vault"

#-----------------------------------------------------------------------------
# Private Constants

readonly __GENX_SOLOCHAIN_DEFAULT_INSTANCE_NAME="Production"
readonly __GENX_SOLOCHAIN_DEFAULT_POD_CONTAINER_IMAGE_REGISTRY="docker.io"
readonly __GENX_SOLOCHAIN_DEFAULT_POD_CONTAINER_IMAGE_REPOSITORY="gsch/gsh-core"
readonly __GENX_SOLOCHAIN_DEFAULT_POD_CONTAINER_IMAGE_TAG=""
readonly __GENX_SOLOCHAIN_DEFAULT_PROBES_STARTUP_FAILURE_THRESHOLD="120"
readonly __GENX_SOLOCHAIN_DEFAULT_PROBES_STARTUP_PERIOD_SECONDS="5"
readonly __GENX_SOLOCHAIN_DEFAULT_WEB_EXTERNAL_URL="https://${PACKAGE_NAME}.${ENVIRONMENT}.${PROJECT}.${ORGANIZATION}.local:8443"

#-----------------------------------------------------------------------------
# Public Hooks

hook_initialize() {
    # Initialize base package values
    package_cache_values_file_write ".packages.${PACKAGE_IPATH}.genx-common" '{
      "generic-application": {
        "argo-cd": {
          "waitMaxAttempts": 300
        },
        "pod": {
          "container": {
            "image": {
              "registry": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.image.registry" "${__GENX_SOLOCHAIN_DEFAULT_POD_CONTAINER_IMAGE_REGISTRY}")"'",
              "repository": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.image.repository" "${__GENX_SOLOCHAIN_DEFAULT_POD_CONTAINER_IMAGE_REPOSITORY}")"'",
              "tag": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.image.tag" "${__GENX_SOLOCHAIN_DEFAULT_POD_CONTAINER_IMAGE_TAG}")"'"
            },
            "securityContext": {
              "capabilities": {
                "drop": [ "ALL" ],
                "add": [ "NET_BIND_SERVICE" ]
              },
              "readOnlyRootFilesystem": false,
              "allowPrivilegeEscalation": false
            },
            "env": [
              {
                "name": "ALLOW_MULTIPLE_VERSIONS",
                "value": "false"
              },
              {
                "name": "APPLICATION_URL",
                "value": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.web.externalUrl" "${__GENX_SOLOCHAIN_DEFAULT_WEB_EXTERNAL_URL}")"'"
              },
              {
                "name": "CONFIG_DIRECTORIES",
                "value": "/vault/secrets"
              },
              {
                "name": "instance_id",
                "value": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.instance.id")"'"
              },
              {
                "name": "instance_name",
                "value": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.instance.name" "${__GENX_SOLOCHAIN_DEFAULT_INSTANCE_NAME}")"'"
              },
              {
                "name": "MANAGEMENT_API_KEY",
                "value": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.managementApi.accessToken")"'"
              }
            ],
            "startupProbe": {
              "httpGet": {
                "path": "/healthz/startup",
                "port": 8080
              },
              "failureThreshold": '"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.probes.startup.failureThreshold" "${__GENX_SOLOCHAIN_DEFAULT_PROBES_STARTUP_FAILURE_THRESHOLD}")"',
              "periodSeconds": '"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.probes.startup.periodSeconds" "${__GENX_SOLOCHAIN_DEFAULT_PROBES_STARTUP_PERIOD_SECONDS}")"'
            },
            "livenessProbe": {
              "httpGet": {
                "path": "/healthz/liveness",
                "port": 8080
              }
            },
            "readinessProbe": {
              "httpGet": {
                "path": "/healthz/readiness",
                "port": 8080
              }
            }
          }
        },
        "services": [
          {
            "name": "web",
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
          "networkPlane": "'"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.ingress.networkPlane")"'",
          "mappings": [
            {
              "serviceName": "web",
              "servicePort": 8080,
              "timeoutMs": '"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.ingress.timeoutMs" "null")"',
              "idleTimeoutMs": '"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.ingress.idleTimeoutMs" "null")"',
              "connectTimeoutMs": '"$(package_cache_values_file_read ".packages.${PACKAGE_IPATH}.ingress.connectTimeoutMs" "null")"',
              "cors": '"$(package_cache_values_file_read_json ".packages.${PACKAGE_IPATH}.ingress.cors")"'
            }
          ]
        },
        "databases": [
          {
            "auth": {
              "rootUsername": "'"$(package_cache_values_file_read ".packages.genx-solochain-database.metadata.root.username")"'",
              "rootPassword": "'"$(package_cache_values_file_read ".packages.genx-solochain-database.metadata.root.password")"'"
            },
            "id": "solochain",
            "name": "'"${ENVIRONMENT}_solochain"'",
            "engine": "mysql",
            "hostname": "'"$(package_cache_values_file_read ".packages.genx-solochain-database.metadata.host")"'",
            "port": '"$(package_cache_values_file_read ".packages.genx-solochain-database.metadata.port")"',
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
              "type": "solochain"
            }
          }
        }
      }
    }'
}

package_hook_execute "${@}"

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
# Private Methods

__nexus_rest_api() {
    local __method="${1}"
    local __admin_username="${2}"
    local __admin_password="${3}"
    local __api_base_url="${4}"
    local __resource_path="${5}"
    local __data="${6:-}"
    local __content_type="${7:-"application/json"}"

    curl -f -s \
        -X "${__method}" \
        -u "${__admin_username}:${__admin_password}" \
        -H "Content-Type: ${__content_type}" \
        -d "${__data}" \
        "${__api_base_url}/${__resource_path}"
}

#-----------------------------------------------------------------------------
# Public Methods

# Blob Store

nexus_blobstore_create_update() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __blobstore_type="${4}"
    local __json_config="${5}"

    local __blobstore_name
    __blobstore_name="$(echo "${__json_config}" | yaml_read - ".name")"

    local __method="POST"
    local __resource_path="service/rest/v1/blobstores/${__blobstore_type}"

    if nexus_blobstore_exists "${__admin_username}" "${__admin_password}" "${__api_base_url}" "${__blobstore_type}" "${__blobstore_name}"; then
        __method="PUT"
        __resource_path="service/rest/v1/blobstores/${__blobstore_type}/${__blobstore_name}"
    fi

    __nexus_rest_api \
        "${__method}" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "${__resource_path}" \
        "${__json_config}"
}

nexus_blobstore_exists() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __blobstore_type="${4}"
    local __blobstore_name="${5}"

    __nexus_rest_api \
        "GET" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "service/rest/v1/blobstores/${__blobstore_type}/${__blobstore_name}" &>/dev/null
}

# Repository Management

nexus_repository_create_update() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __repository_format="${4}"
    local __repository_type="${5}"
    local __json_config="${6}"

    local __repository_name
    __repository_name="$(echo "${__json_config}" | yaml_read - ".name")"

    local __method="POST"
    local __resource_path="service/rest/v1/repositories/${__repository_format}/${__repository_type}"

    if nexus_repository_exists "${__admin_username}" "${__admin_password}" "${__api_base_url}" "${__repository_format}" "${__repository_type}" "${__repository_name}"; then
        __method="PUT"
        __resource_path="service/rest/v1/repositories/${__repository_format}/${__repository_type}/${__repository_name}"
    fi

    __nexus_rest_api \
        "${__method}" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "${__resource_path}" \
        "${__json_config}"
}

nexus_repository_exists() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __repository_format="${4}"
    local __repository_type="${5}"
    local __repository_name="${6}"

    __nexus_rest_api \
        "GET" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "service/rest/v1/repositories/${__repository_format}/${__repository_type}/${__repository_name}" &>/dev/null
}

# Security Management: Anonymous Access

nexus_security_anonymous_enable() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __json_config="${4}"

    __nexus_rest_api \
        "PUT" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "service/rest/v1/security/anonymous" \
        "${__json_config}" >/dev/null
}

# Security Management: Realms

nexus_security_realms_activate() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __json_config="${4}"

    __nexus_rest_api \
        "PUT" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "service/rest/v1/security/realms/active" \
        "${__json_config}"
}

# Security Management: SAML

nexus_security_saml_create_update() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __json_config="${4}"

    __nexus_rest_api \
        "PUT" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "service/rest/v1/security/saml" \
        "${__json_config}"
}

nexus_security_saml_exists() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"

    __nexus_rest_api \
        "GET" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "service/rest/v1/security/saml" &>/dev/null
}

# Security Management: Roles

nexus_security_role_create_update() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __json_config="${4}"

    local __role_id
    __role_id="$(echo "${__json_config}" | yaml_read - ".id")"

    local __method="POST"
    local __resource_path="service/rest/v1/security/roles"

    if nexus_security_role_exists "${__admin_username}" "${__admin_password}" "${__api_base_url}" "${__role_id}"; then
        __method="PUT"
        __resource_path="service/rest/v1/security/roles/${__role_id}"
    fi

    __nexus_rest_api \
        "${__method}" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "${__resource_path}" \
        "${__json_config}" >/dev/null
}

nexus_security_role_exists() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __role_id="${4}"

    __nexus_rest_api \
        "GET" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "service/rest/v1/security/roles/${__role_id}" &>/dev/null
}

# Security Management: Users

nexus_security_user_change_password() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __user_id="${4}"
    local __password="${5}"

    __nexus_rest_api \
        "PUT" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "service/rest/v1/security/users/${__user_id}/change-password" \
        "${__password}" \
        "text/plain"
}

nexus_security_user_create_update() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __json_config="${4}"

    local __user_id
    __user_id="$(echo "${__json_config}" | yaml_read - ".userId")"

    local __method="POST"
    local __resource_path="service/rest/v1/security/users"

    if nexus_security_user_exists "${__admin_username}" "${__admin_password}" "${__api_base_url}" "${__user_id}"; then
        __method="PUT"
        __resource_path="service/rest/v1/security/users/${__user_id}"
    fi

    __nexus_rest_api \
        "${__method}" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "${__resource_path}" \
        "${__json_config}" >/dev/null
}

nexus_security_user_exists() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __user_id="${4}"

    if [[ $(__nexus_rest_api \
        "GET" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "service/rest/v1/security/users?userId=${__user_id}" | yaml_count - ".") -eq 0 ]]; then
        return 1
    fi
}

# Security Management: User Tokens

nexus_security_user_tokens_enable() {
    local __admin_username="${1}"
    local __admin_password="${2}"
    local __api_base_url="${3}"
    local __json_config="${4}"

    __nexus_rest_api \
        "PUT" \
        "${__admin_username}" \
        "${__admin_password}" \
        "${__api_base_url}" \
        "service/rest/v1/security/user-tokens" \
        "${__json_config}" >/dev/null
}

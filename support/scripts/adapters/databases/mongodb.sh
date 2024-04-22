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

__mongodb_vault_configure() {
    local __database_name="${1}"
    local __database_hostname="${2}"
    local __database_port="${3}"
    local __database_options="${4}"
    local __database_mode="${5}"
    local __database_vault_username="${6}"
    local __database_vault_password="${7}"
    local __default_ttl="${8}"
    local __max_ttl="${9}"

    local __role="readWrite"
    if [[ "${__database_mode}" == "ro" ]]; then
        __role="read"
    fi

    __database_vault_configure \
        "mongodb" \
        "${__database_name}" \
        "${__database_hostname}" \
        "${__database_port}" \
        "${__database_mode}" \
        "${__database_vault_username}" \
        "${__database_vault_password}" \
        "mongodb://{{username}}:{{password}}@${__database_hostname}:${__database_port}/admin$( ([[ -n "${__database_options}" ]] && echo "?${__database_options}") || :)" \
        '{"db":"'"${__database_name}"'","roles":[{"role":"'"${__role}"'"}]}' \
        '{"db":"'"${__database_name}"'"}' \
        "${__default_ttl}" \
        "${__max_ttl}"
}

__mongodb_create() {
    local __database_name="${1}"
    local __database_hostname="${2}"
    local __database_port="${3}"
    local __database_options="${4}"
    local __database_root_username="${5}"
    local __database_root_password="${6}"

    local __connection_string
    __connection_string="mongodb://${__database_root_username}:${__database_root_password}@${__database_hostname}:${__database_port}?authSource=admin$( ([[ -n "${__database_options}" ]] && echo "&${__database_options}") || :)"
    if [[ "${__database_hostname}" =~ .*\.svc\.cluster\.local\.?$ ]]; then
        local __package_prefix="${__database_hostname%%.*}"
        __package_prefix="${__package_prefix^^}"
        __package_prefix="${__package_prefix//-/_}"

        __connection_string="mongodb://${__database_root_username}:${__database_root_password}@127.0.0.1:$(eval echo "\$${__package_prefix}_PORT")?authSource=admin$( ([[ -n "${__database_options}" ]] && echo "&${__database_options}") || :)"
    fi

    mongosh \
        --quiet \
        --eval "if (db.getMongo().getDBNames().indexOf('${__database_name}') < 0) { db.getSiblingDB('${__database_name}').createCollection('delete_me') }" \
        "${__connection_string}"
}

__mongodb_create_user() {
    local __database_name="${1}"
    local __database_hostname="${2}"
    local __database_port="${3}"
    local __database_options="${4}"
    local __database_mode="${5}"
    local __database_root_username="${6}"
    local __database_root_password="${7}"
    local __database_new_username="${8}"
    local __database_new_password="${9}"

    local __connection_string
    __connection_string="mongodb://${__database_root_username}:${__database_root_password}@${__database_hostname}:${__database_port}?authSource=admin$( ([[ -n "${__database_options}" ]] && echo "&${__database_options}") || :)"
    if [[ "${__database_hostname}" =~ .*\.svc\.cluster\.local\.?$ ]]; then
        local __package_prefix="${__database_hostname%%.*}"
        __package_prefix="${__package_prefix^^}"
        __package_prefix="${__package_prefix//-/_}"

        __connection_string="mongodb://${__database_root_username}:${__database_root_password}@127.0.0.1:$(eval echo "\$${__package_prefix}_PORT")?authSource=admin$( ([[ -n "${__database_options}" ]] && echo "&${__database_options}") || :)"
    fi

    local __role="readWrite"
    if [[ "${__database_mode}" == "ro" ]]; then
        __role="read"
    fi

    mongosh \
        --quiet \
        --eval "if (db.getUser('${__database_new_username}') == null) { db.createUser({user:'${__database_new_username}',pwd:'${__database_new_password}',roles:[{role:'${__role}',db:'${__database_name}'}]}); }" \
        "${__connection_string}"
}

__mongodb_create_super_user() {
    local __database_hostname="${1}"
    local __database_port="${2}"
    local __database_options="${3}"
    local __database_root_username="${4}"
    local __database_root_password="${5}"
    local __database_new_username="${6}"
    local __database_new_password="${7}"

    local __connection_string
    __connection_string="mongodb://${__database_root_username}:${__database_root_password}@${__database_hostname}:${__database_port}?authSource=admin$( ([[ -n "${__database_options}" ]] && echo "&${__database_options}") || :)"
    if [[ "${__database_hostname}" =~ .*\.svc\.cluster\.local\.?$ ]]; then
        local __package_prefix="${__database_hostname%%.*}"
        __package_prefix="${__package_prefix^^}"
        __package_prefix="${__package_prefix//-/_}"

        __connection_string="mongodb://${__database_root_username}:${__database_root_password}@127.0.0.1:$(eval echo "\$${__package_prefix}_PORT")?authSource=admin$( ([[ -n "${__database_options}" ]] && echo "&${__database_options}") || :)"
    fi

    mongosh \
        --quiet \
        --eval "if (db.getUser('${__database_new_username}') == null) { db.getSiblingDB('admin').createUser({user:'${__database_new_username}',pwd:'${__database_new_password}',roles:[{role:'userAdminAnyDatabase',db:'admin'}]}); }" \
        "${__connection_string}"
}

__mongodb_get_default_port() {
    echo "27017"
}

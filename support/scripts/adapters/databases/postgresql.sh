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

__postgresql_vault_configure() {
    local __database_name="${1}"
    local __database_hostname="${2}"
    local __database_port="${3}"
    local __database_options="${4}"
    local __database_mode="${5}"
    local __database_vault_username="${6}"
    local __database_vault_password="${7}"
    local __default_ttl="${8}"
    local __max_ttl="${9}"

    local __creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN ENCRYPTED PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT ALL PRIVILEGES ON SCHEMA public TO \"{{name}}\"; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\"; ALTER DEFAULT PRIVILEGES FOR USER \"{{name}}\" IN SCHEMA public GRANT SELECT ON TABLES TO \"${__database_name}-ro\";"
    if [[ "${__database_mode}" == "ro" ]]; then
        __creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN ENCRYPTED PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' IN ROLE \"${__database_name}-ro\";"
    fi

    __database_vault_configure \
        "postgresql" \
        "${__database_name}" \
        "${__database_hostname}" \
        "${__database_port}" \
        "${__database_mode}" \
        "${__database_vault_username}" \
        "${__database_vault_password}" \
        "postgresql://{{username}}:{{password}}@${__database_hostname}:${__database_port}/${__database_name}$( ([[ -n "${__database_options}" ]] && echo "?${__database_options}") || :)" \
        "${__creation_statements}" \
        "ALTER ROLE \"{{name}}\" NOLOGIN;" \
        "ALTER ROLE \"{{name}}\" VALID UNTIL '{{expiration}}';" \
        "ALTER ROLE \"{{name}}\" ENCRYPTED PASSWORD '{{password}}';" \
        "${__default_ttl}" \
        "${__max_ttl}"
}

__postgresql_create() {
    local __database_name="${1}"
    local __database_hostname="${2}"
    local __database_port="${3}"
    local __database_options="${4}"
    local __database_root_username="${5}"
    local __database_root_password="${6}"

    local __connection_string
    __connection_string="postgresql://${__database_root_username}:${__database_root_password}@${__database_hostname}:${__database_port}/postgres$( ([[ -n "${__database_options}" ]] && echo "?${__database_options}") || :)"
    if [[ "${__database_hostname}" =~ .*\.svc\.cluster\.local\.?$ ]]; then
        local __package_prefix="${__database_hostname%%.*}"
        __package_prefix="${__package_prefix^^}"
        __package_prefix="${__package_prefix//-/_}"

        __connection_string="postgresql://${__database_root_username}:${__database_root_password}@127.0.0.1:$(eval echo "\$${__package_prefix}_PORT")/postgres$( ([[ -n "${__database_options}" ]] && echo "?${__database_options}") || :)"
    fi

    if [[ "$(psql -tXA "${__connection_string}" -c "SELECT 1 FROM pg_database WHERE datname = '${__database_name}';")" != "1" ]]; then
        psql "${__connection_string}" -c "CREATE DATABASE \"${__database_name}\";"
    fi

    if [[ "$(psql -tXA "${__connection_string}" -c "SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = '${__database_name}-ro';")" != "1" ]]; then
        psql "${__connection_string}" -c "CREATE ROLE \"${__database_name}-ro\" NOLOGIN;"
        psql "${__connection_string}" -c "GRANT USAGE ON SCHEMA public TO \"${__database_name}-ro\";"
    fi
}

__postgresql_create_user() {
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
    __connection_string="postgresql://${__database_root_username}:${__database_root_password}@${__database_hostname}:${__database_port}/${__database_name}$( ([[ -n "${__database_options}" ]] && echo "?${__database_options}") || :)"
    if [[ "${__database_hostname}" =~ .*\.svc\.cluster\.local\.?$ ]]; then
        local __package_prefix="${__database_hostname%%.*}"
        __package_prefix="${__package_prefix^^}"
        __package_prefix="${__package_prefix//-/_}"

        __connection_string="postgresql://${__database_root_username}:${__database_root_password}@127.0.0.1:$(eval echo "\$${__package_prefix}_PORT")/${__database_name}$( ([[ -n "${__database_options}" ]] && echo "?${__database_options}") || :)"
    fi

    local __creation_statements="CREATE ROLE \"${__database_new_username}\" WITH LOGIN ENCRYPTED PASSWORD '${__database_new_password}'; GRANT ALL PRIVILEGES ON SCHEMA public TO \"${__database_new_username}\"; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"${__database_new_username}\"; ALTER DEFAULT PRIVILEGES FOR USER \"${__database_new_username}\" IN SCHEMA public GRANT SELECT ON TABLES TO \"${__database_name}-ro\";"
    if [[ "${__database_mode}" == "ro" ]]; then
        __creation_statements="CREATE ROLE \"${__database_new_username}\" WITH LOGIN ENCRYPTED PASSWORD '${__database_new_password}' IN ROLE \"${__database_name}-ro\";"
    fi

    if [[ "$(psql -tXA "${__connection_string/\/${__database_name}\?/\/postgres\?}" -c "SELECT 1 FROM pg_roles WHERE rolname = '${__database_new_username}';")" != "1" ]]; then
        psql "${__connection_string}" -c "${__creation_statements}"
    fi
}

__postgresql_create_super_user() {
    local __database_hostname="${1}"
    local __database_port="${2}"
    local __database_options="${3}"
    local __database_root_username="${4}"
    local __database_root_password="${5}"
    local __database_new_username="${6}"
    local __database_new_password="${7}"

    local __connection_string
    __connection_string="postgresql://${__database_root_username}:${__database_root_password}@${__database_hostname}:${__database_port}$( ([[ -n "${__database_options}" ]] && echo "?${__database_options}") || :)"
    if [[ "${__database_hostname}" =~ .*\.svc\.cluster\.local\.?$ ]]; then
        local __package_prefix="${__database_hostname%%.*}"
        __package_prefix="${__package_prefix^^}"
        __package_prefix="${__package_prefix//-/_}"

        __connection_string="postgresql://${__database_root_username}:${__database_root_password}@127.0.0.1:$(eval echo "\$${__package_prefix}_PORT")$( ([[ -n "${__database_options}" ]] && echo "?${__database_options}") || :)"
    fi

    if [[ "$(psql -d "postgres" -tXA "${__connection_string}" -c "SELECT 1 FROM pg_roles WHERE rolname = '${__database_new_username}';")" != "1" ]]; then
        psql -d "postgres" "${__connection_string}" -c "CREATE ROLE \"${__database_new_username}\" WITH SUPERUSER CREATEDB CREATEROLE LOGIN ENCRYPTED PASSWORD '${__database_new_password}';"
    fi
}

__postgresql_get_default_port() {
    echo "5432"
}

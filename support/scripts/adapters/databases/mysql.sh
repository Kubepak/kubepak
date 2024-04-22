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

__mysql_vault_configure() {
    local __database_name="${1}"
    local __database_hostname="${2}"
    local __database_port="${3}"
    local __database_options="${4}"
    local __database_mode="${5}"
    local __database_vault_username="${6}"
    local __database_vault_password="${7}"
    local __default_ttl="${8}"
    local __max_ttl="${9}"

    local __creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT ALL PRIVILEGES ON \`${__database_name}\`.* TO '{{name}}'@'%'; FLUSH PRIVILEGES;"
    if [[ "${__database_mode}" == "ro" ]]; then
        __creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT SELECT ON \`${__database_name}\`.* TO '{{name}}'@'%'; FLUSH PRIVILEGES;"
    fi

    __database_vault_configure \
        "mysql" \
        "${__database_name}" \
        "${__database_hostname}" \
        "${__database_port}" \
        "${__database_mode}" \
        "${__database_vault_username}" \
        "${__database_vault_password}" \
        "{{username}}:{{password}}@tcp(${__database_hostname}:${__database_port})/$( ([[ -n "${__database_options}" ]] && echo "?${__database_options}") || :)" \
        "${__creation_statements}" \
        "DROP USER '{{name}}'@'%'" \
        "" \
        "ALTER USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'" \
        "${__default_ttl}" \
        "${__max_ttl}"
}

__mysql_create() {
    local __database_name="${1}"
    local __database_hostname="${2}"
    local __database_port="${3}"
    local __database_options="${4}"
    local __database_root_username="${5}"
    local __database_root_password="${6}"

    local __mysql_cmd_options=()
    if [[ "${__database_hostname}" =~ .*\.svc\.cluster\.local\.?$ ]]; then
        local __package_prefix="${__database_hostname%%.*}"
        __package_prefix="${__package_prefix^^}"
        __package_prefix="${__package_prefix//-/_}"

        __mysql_cmd_options+=("-h 127.0.0.1")
        __mysql_cmd_options+=("-P $(eval echo "\$${__package_prefix}_PORT")")
    else
        __mysql_cmd_options+=("-h ${__database_hostname}")
        __mysql_cmd_options+=("-P ${__database_port}")
    fi
    __mysql_cmd_options+=("-u ${__database_root_username}")

    local __database_option
    for __database_option in ${__database_options//&/ }; do
        __mysql_cmd_options+=("--${__database_option}")
    done

    local __creation_statements="CREATE DATABASE IF NOT EXISTS \`${__database_name}\`;"

    # shellcheck disable=SC2048,SC2086
    mysql --defaults-extra-file=<(echo $'[client]\npassword='"${__database_root_password}") ${__mysql_cmd_options[*]} -e "${__creation_statements}"
}

__mysql_create_user() {
    local __database_name="${1}"
    local __database_hostname="${2}"
    local __database_port="${3}"
    local __database_options="${4}"
    local __database_mode="${5}"
    local __database_root_username="${6}"
    local __database_root_password="${7}"
    local __database_new_username="${8}"
    local __database_new_password="${9}"

    local __mysql_cmd_options=()
    if [[ "${__database_hostname}" =~ .*\.svc\.cluster\.local\.?$ ]]; then
        local __package_prefix="${__database_hostname%%.*}"
        __package_prefix="${__package_prefix^^}"
        __package_prefix="${__package_prefix//-/_}"

        __mysql_cmd_options+=("-h 127.0.0.1")
        __mysql_cmd_options+=("-P $(eval echo "\$${__package_prefix}_PORT")")
    else
        __mysql_cmd_options+=("-h ${__database_hostname}")
        __mysql_cmd_options+=("-P ${__database_port}")
    fi
    __mysql_cmd_options+=("-u ${__database_root_username}")

    local __database_option
    for __database_option in ${__database_options//&/ }; do
        __mysql_cmd_options+=("--${__database_option}")
    done

    local __exists_statements="SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '${__database_new_username}')"

    local __creation_statements="CREATE USER '${__database_new_username}'@'%' IDENTIFIED BY '${__database_new_password}'; GRANT ALL PRIVILEGES ON \`${__database_name}\`.* TO '${__database_new_username}'@'%'; FLUSH PRIVILEGES;"
    if [[ "${__database_mode}" == "ro" ]]; then
        __creation_statements="CREATE USER '${__database_new_username}'@'%' IDENTIFIED BY '${__database_new_password}'; GRANT SELECT ON \`${__database_name}\`.* TO '${__database_new_username}'@'%'; FLUSH PRIVILEGES;"
    fi

    # shellcheck disable=SC2048,SC2086
    if [[ $(mysql --defaults-extra-file=<(echo $'[client]\npassword='"${__database_root_password}") ${__mysql_cmd_options[*]} -r -s -N -e "${__exists_statements}") != "1" ]]; then
        mysql --defaults-extra-file=<(echo $'[client]\npassword='"${__database_root_password}") ${__mysql_cmd_options[*]} -e "${__creation_statements}"
    fi
}

__mysql_create_super_user() {
    local __database_hostname="${1}"
    local __database_port="${2}"
    local __database_options="${3}"
    local __database_root_username="${4}"
    local __database_root_password="${5}"
    local __database_new_username="${6}"
    local __database_new_password="${7}"

    local __mysql_cmd_options=()
    if [[ "${__database_hostname}" =~ .*\.svc\.cluster\.local\.?$ ]]; then
        local __package_prefix="${__database_hostname%%.*}"
        __package_prefix="${__package_prefix^^}"
        __package_prefix="${__package_prefix//-/_}"

        __mysql_cmd_options+=("-h 127.0.0.1")
        __mysql_cmd_options+=("-P $(eval echo "\$${__package_prefix}_PORT")")
    else
        __mysql_cmd_options+=("-h ${__database_hostname}")
        __mysql_cmd_options+=("-P ${__database_port}")
    fi
    __mysql_cmd_options+=("-u ${__database_root_username}")

    local __database_option
    for __database_option in ${__database_options//&/ }; do
        __mysql_cmd_options+=("--${__database_option}")
    done

    local __exists_statements="SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '${__database_new_username}')"

    local __creation_statements="CREATE USER '${__database_new_username}'@'%' IDENTIFIED BY '${__database_new_password}'; GRANT ALL PRIVILEGES ON *.* TO '${__database_new_username}'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"

    # shellcheck disable=SC2048,SC2086
    if [[ $(mysql --defaults-extra-file=<(echo $'[client]\npassword='"${__database_root_password}") ${__mysql_cmd_options[*]} -r -s -N -e "${__exists_statements}") != "1" ]]; then
        mysql --defaults-extra-file=<(echo $'[client]\npassword='"${__database_root_password}") ${__mysql_cmd_options[*]} -e "${__creation_statements}"
    fi
}

__mysql_get_default_port() {
    echo "3306"
}

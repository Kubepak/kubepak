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

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/mongodb.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/mysql.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/postgresql.sh"

#-----------------------------------------------------------------------------
# Private Methods

__database_vault_configure() {
    local __database_engine="${1}"
    local __database_name="${2}"
    local __database_hostname="${3}"
    local __database_port="${4}"
    local __database_mode="${5}"
    local __database_vault_username="${6}"
    local __database_vault_password="${7}"
    local __connection_url="${8}"
    local __creation_statements="${9}"
    local __revocation_statements="${10}"
    local __renew_statements="${11}"
    local __rotation_statements="${12}"
    local __default_ttl="${13}"
    local __max_ttl="${14}"

    if ! vault secrets list -format json | jq -e ".[\"database/\"]" >/dev/null; then
        vault secrets enable "database"
    fi

    if ! vault read "database/config/${__database_hostname%.}-${__database_port}-${__database_name}-${__database_mode}" >/dev/null; then
        vault write "database/config/${__database_hostname%.}-${__database_port}-${__database_name}-${__database_mode}" \
            plugin_name="${__database_engine}-database-plugin" \
            allowed_roles="${__database_hostname%.}-${__database_port}-${__database_name}-${__database_mode}" \
            connection_url="${__connection_url}" \
            username="${__database_vault_username}" \
            password="${__database_vault_password}"

        vault write -force "database/rotate-root/${__database_hostname%.}-${__database_port}-${__database_name}-${__database_mode}"

        vault write "database/roles/${__database_hostname%.}-${__database_port}-${__database_name}-${__database_mode}" \
            db_name="${__database_hostname%.}-${__database_port}-${__database_name}-${__database_mode}" \
            creation_statements="${__creation_statements}" \
            revocation_statements="${__revocation_statements}" \
            renew_statements="${__renew_statements}" \
            rotation_statements="${__rotation_statements}" \
            default_ttl="${__default_ttl}" \
            max_ttl="${__max_ttl}"

        echo "path \"database/creds/${__database_hostname%.}-${__database_port}-${__database_name}-${__database_mode}\" {capabilities = [\"read\"]}" |
            vault policy write "${__database_hostname%.}-${__database_port}-${__database_name}-${__database_mode}-database-creds-read" -
    fi
}

#-----------------------------------------------------------------------------
# Public Methods

database_vault_configure() {
    local __database_engine="${1}"

    "__${__database_engine}_vault_configure" "${@:2}"
}

database_create() {
    local __database_engine="${1}"

    "__${__database_engine}_create" "${@:2}"
}

database_create_user() {
    local __database_engine="${1}"

    "__${__database_engine}_create_user" "${@:2}"
}

database_create_super_user() {
    local __database_engine="${1}"

    "__${__database_engine}_create_super_user" "${@:2}"
}

database_get_default_port() {
    local __database_engine="${1}"

    "__${__database_engine}_get_default_port"
}

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
# Private Constants

readonly __GIT_URL_PARSER_REGEX="^(git|ssh|http[s]?)(@|:\/\/)(([a-zA-Z0-9_]+)(@))?([^:\/]+)(:([0-9]+))?[:\/]([^\.]+)(\.git)?$"

#-----------------------------------------------------------------------------
# Private Methods

__git_url_parse() {
    local __url="${1}"

    [[ "${__url}" =~ ${__GIT_URL_PARSER_REGEX} ]]
}

#-----------------------------------------------------------------------------
# Public Methods

git_url_get_scheme() {
    __git_url_parse "${1}" && echo "${BASH_REMATCH[1]}"
}

git_url_get_user() {
    __git_url_parse "${1}" && echo "${BASH_REMATCH[4]}"
}

git_url_get_hostname() {
    __git_url_parse "${1}" && echo "${BASH_REMATCH[6]}"
}

git_url_get_port() {
    __git_url_parse "${1}" && echo "${BASH_REMATCH[8]}"
}

git_url_get_host() {
    __git_url_parse "${1}" && [[ -n "${BASH_REMATCH[8]}" ]] && echo "${BASH_REMATCH[6]}:${BASH_REMATCH[8]}" || echo "${BASH_REMATCH[6]}"
}

git_url_get_repository_path() {
    __git_url_parse "${1}" && echo "${BASH_REMATCH[9]}"
}

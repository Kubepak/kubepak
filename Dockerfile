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

ARG UBUNTU_VERSION="24.04"

FROM ubuntu:${UBUNTU_VERSION} as awscli-installer

RUN apt-get update \
 && apt-get install -y curl unzip \
 && curl -sSfL -o "awscli-exe-linux-x86_64.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
 && unzip "awscli-exe-linux-x86_64.zip" \
 && ./aws/install --bin-dir "/aws-cli-bin/"

FROM ubuntu:${UBUNTU_VERSION}

ARG HELM_VERSION
ARG KUBECTL_VERSION
ARG MONGOSH_VERSION
ARG VAULT_VERSION
ARG YQ_VERSION

SHELL ["/bin/bash", "-c"]

# Prerequisites

RUN apt-get update \
 && apt-get install -y curl git jq mysql-client openssh-client postgresql-client

## awscli

COPY --from=awscli-installer "/usr/local/aws-cli/" "/usr/local/aws-cli/"
COPY --from=awscli-installer "/aws-cli-bin/" "/usr/local/bin/"

## azure-cli

RUN curl -sSfL "https://aka.ms/InstallAzureCLIDeb" | bash

## helm

RUN [[ -z "${HELM_VERSION}" ]] && __version="$(curl -sSfL "https://api.github.com/repos/helm/helm/releases/latest" | jq -r '.tag_name')" || __version="v${HELM_VERSION}" \
 && curl -sSfL "https://get.helm.sh/helm-${__version}-linux-amd64.tar.gz" | tar xzf - -C "/usr/local/bin" --strip 1 "linux-amd64/helm"

## kubectl

RUN [[ -z "${KUBECTL_VERSION}" ]] && __version="$(curl -sSfL https://dl.k8s.io/release/stable.txt)" || __version="v${KUBECTL_VERSION}" \
 && curl -sSfL -o "/usr/local/bin/kubectl" "https://dl.k8s.io/release/${__version}/bin/linux/amd64/kubectl" \
 && chmod +x "/usr/local/bin/kubectl"

## mongosh

RUN [[ -z "${MONGOSH_VERSION}" ]] && __version="$(curl -sSfL "https://api.github.com/repos/mongodb-js/mongosh/releases/latest" | jq -r '.tag_name')" || __version="v${MONGOSH_VERSION}" \
 && curl -sSfL -o "mongodb-mongosh_${__version:1}_amd64.deb" "https://github.com/mongodb-js/mongosh/releases/download/${__version}/mongodb-mongosh_${__version:1}_amd64.deb" \
 && dpkg -i "mongodb-mongosh_${__version:1}_amd64.deb"

## vault

RUN [[ -z "${VAULT_VERSION}" ]] && __version="$(curl -sSfL "https://api.github.com/repos/hashicorp/vault/releases/latest" | jq -r '.tag_name')" || __version="v${VAULT_VERSION}" \
 && curl -sSfL -o "vault_${__version:1}_linux_amd64.zip" "https://releases.hashicorp.com/vault/${__version:1}/vault_${__version:1}_linux_amd64.zip" \
 && apt-get install -y unzip \
 && unzip -q "vault_${__version:1}_linux_amd64.zip" -d "/usr/local/bin" \
 && apt-get --purge autoremove -y unzip \
 && rm -f "vault_${__version:1}_linux_amd64.zip"

## yq

RUN [[ -z "${YQ_VERSION}" ]] && __version="$(curl -sSfL "https://api.github.com/repos/mikefarah/yq/releases/latest" | jq -r '.tag_name')" || __version="v${YQ_VERSION}" \
 && curl -sSfL -o "/usr/local/bin/yq" "https://github.com/mikefarah/yq/releases/download/${__version}/yq_linux_amd64" \
 && chmod +x "/usr/local/bin/yq"

# kubepak

COPY "AUTHORS.md" "/opt/kubepak/"
COPY "LICENSE.md" "/opt/kubepak/"
COPY "kubepak.sh" "/opt/kubepak/"
COPY "kubepakw.sh" "/opt/kubepak/"
COPY "support" "/opt/kubepak/support"
COPY "packages" "/opt/kubepak/packages"

WORKDIR "/opt/kubepak"

# HACK: As we cannot predict the uid and gid that will be used, we must grant all permissions to files that are subject
#       to be modified.

RUN find . -type d -wholename "*/files/helm-chart" -exec mkdir -p "{}/charts" "{}/tmpcharts" \; -exec touch "{}/Chart.lock" \; -exec chmod 777 "{}/charts" "{}/Chart.lock" "{}/tmpcharts" \; \
 && chmod 777 "/usr/local/bin"

ENTRYPOINT [ "/opt/kubepak/kubepak.sh" ]
CMD [ "--help" ]

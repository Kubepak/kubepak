# Quickstart

Welcome to the Quick Start Guide for Kubepak, a powerful tool designed to simplify application deployment in Kubernetes
environments. This guide showcases Kubepak's remarkable efficiency in managing complex dependencies, ensuring a smooth
deployment experience. As you explore this guide, you'll witness Kubepak's proficiency in orchestrating deployment
scenarios seamlessly, exemplified by deploying Argo CD, Emissary-Ingress, and Vault.

## Prerequisites

Before starting, make sure you've fulfilled the Kubepak prerequisites as outlined in
the [Prerequisites](prerequisites.md)
documentation. Additionally, for this quickstart, ensure you have the `openssl` package installed on your Linux
distribution and install [`minikube`](https://kubernetes.io/docs/tasks/tools/install-minikube/).

## Add Your User (with Root Privileges) to Docker Group

To start Minikube with the Docker driver, grant your user access to the Unix socket created by the Docker daemon at
startup. Add your user to the Docker group and apply the changes:

```bash
sudo usermod -aG "docker" "${USER}" && newgrp "docker"
```

## Start Minikube

Now that the prerequisites are installed, and your user is added to the Docker group, start Minikube:

```bash
minikube start \
  --kubernetes-version="v1.30.0" \
  --driver="docker" \
  --memory="8G" \
  --cpus="6" \
  --addons="registry"
```

When choosing to install using the Kubepak Docker image, the most direct approach for Kubepak to connect with a Minikube
cluster within a Docker container is to integrate the certificates used for cluster authentication directly into your
kubeconfig. Minikube can effortlessly manage this process for you by enabling the following option:

```text
--embed-certs="true"
```

## Generate TLS Certificate and Private Key

To facilitate traffic routing to both the Argo CD and Vault services, we employ an ingress controller (Emissary Ingress)
with TLS enabled. Consequently, it is imperative to include a TLS/SSL certificate in the ingress controller
configuration. Let's generate a self-signed certificate for this purpose:

```bash
openssl req \
  -newkey rsa:4096 \
  -x509 \
  -sha256 \
  -days 3650 \
  -nodes \
  -out "${HOME}/acme-quickstart.crt" \
  -keyout "${HOME}/acme-quickstart.key" \
  -subj "/O=Acme/CN=*.dev.quickstart.acme.local"
```

## List Packages and Their Dependencies in Installation Order

You can preview the installation sequence without actually executing it by utilizing the list command. To display the
installation sequence of packages and their dependencies, use the following command:

```bash
./kubepak.sh list \
  --package "argo-cd" \
  --package "emissary-ingress" \
  --package "vault"
```

## Install Packages on Your Cluster

To install Argo CD, Emissary-Ingress, and Vault using Kubepak, execute the following command:

```bash
./kubepak.sh install \
  --environment "dev" \
  --organization "acme" \
  --project "quickstart" \
  --package "argo-cd" \
  --package "emissary-ingress" \
  --package "vault" \
  --set argo-cd.applicationController.pod.container.resources.requests.memory="512Mi" \
  --set argo-cd.applicationController.pod.container.resources.limits.cpu="1600m" \
  --set argo-cd.applicationController.pod.container.resources.limits.memory="2Gi" \
  --set argo-cd.server.pod.container.resources.requests.cpu="800m" \
  --set argo-cd.server.pod.container.resources.requests.memory="512Mi" \
  --set argo-cd.server.pod.container.resources.limits.cpu="1600m" \
  --set argo-cd.server.pod.container.resources.limits.memory="2Gi" \
  --set emissary-ingress.hosts[0].name="default" \
  --set emissary-ingress.hosts[0].tls.crt_b64="$(base64 -w0 <"${HOME}/acme-quickstart.crt")" \
  --set emissary-ingress.hosts[0].tls.key_b64="$(base64 -w0 <"${HOME}/acme-quickstart.key")" \
  --set emissary-ingress.service.type="ClusterIP" \
  --set emissary-ingress.service.httpPort="8080" \
  --set emissary-ingress.service.httpsPort="8443"
```

### Notes

1. When utilizing Kubepak's Docker image, employ the Kubepak wrapper script `kubepakw.sh`.

## Setup Your Local DNS Using /etc/hosts

Add the following entry to the /etc/hosts file:

```
127.0.0.1 argo-cd.dev.quickstart.acme.local
127.0.0.1 vault.dev.quickstart.acme.local
```

## Start Port-Forwarding for Emissary Ingress

```bash
kubectl port-forward -n "dev-emissary-ingress" "svc/emissary-ingress" 8443:8443
```

## Open a Browser to the Argo CD External UI

Login by visiting [`https://argo-cd.dev.quickstart.acme.local:8443`](https://argo-cd.dev.quickstart.acme.local:8443) in
a browser and use the following credentials:

* username: admin
* password: admin

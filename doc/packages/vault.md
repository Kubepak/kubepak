# 'vault' Package

## Description

A package for Vault, a tool for secrets management, encryption as a service, and privileged access management.

## Values

| Name                                | Type    | Default                                                                     | Description                                                                                                                          |
|-------------------------------------|---------|-----------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| vault.image.repository              | string  |                                                                             | Image repository                                                                                                                     |
| vault.image.tag                     | string  |                                                                             | Image tag                                                                                                                            |
| vault.injector.image.repository     | string  |                                                                             | Injector image repository                                                                                                            |
| vault.injector.image.tag            | string  |                                                                             | Injector image tag                                                                                                                   |
| vault.ingress.host                  | string  | vault.\<environment\>.\<project\>.\<organization\>.local:<ingressHttpsPort> | Ingress host                                                                                                                         |
| vault.auth.oidc.clientId            | string  |                                                                             |                                                                                                                                      |
| vault.auth.oidc.clientSecret        | string  |                                                                             |                                                                                                                                      |
| vault.auth.oidc.discoveryUrl        | string  |                                                                             |                                                                                                                                      |
| vault.auth.oidc.oidcScopes          | string  |                                                                             |                                                                                                                                      |
| vault.auth.oidc.roles               | list    | []                                                                          |                                                                                                                                      |
| vault.ha.enabled                    | bool    |                                                                             |                                                                                                                                      |
| vault.ha.replicas                   | integer |                                                                             |                                                                                                                                      |
| vault.ha.raft                       | bool    |                                                                             |                                                                                                                                      |
| vault.storage.postgresql.enabled    | bool    |                                                                             |                                                                                                                                      |
| vault.storage.postgresql.username   | string  |                                                                             |                                                                                                                                      |
| vault.storage.postgresql.password   | string  |                                                                             |                                                                                                                                      |
| vault.storage.postgresql.dbname     | string  |                                                                             |                                                                                                                                      |
| vault.storage.postgresql.host       | string  |                                                                             |                                                                                                                                      |
| vault.storage.postgresql.ha_enabled | bool    |                                                                             |                                                                                                                                      |
| vault.tls.ca.srcFilePath            | string  |                                                                             | SSL/TLS trusted certificate authorities source file path (PEM bundle)                                                                |
| vault.tls.ca.dstFilePath            | string  | /ssl/certs/ca-certificates.crt                                              | SSL/TLS trusted certificate authorities destination file path (PEM bundle)                                                           |
| vault.seal.\<mechanism\>            | object  | {}                                                                          | See [`https://developer.hashicorp.com/vault/docs/configuration/seal`](https://developer.hashicorp.com/vault/docs/configuration/seal) |
| vault.serviceAccount.annotations    | object  | {}                                                                          | Service account annotations                                                                                                          |

## Installation

Please be aware that **it is important to note the unseal/recovery key and root token** during installation. This
information appears in the output logs. See the example below:

```text
kubepak.sh: INFO: post-installing vault

================================================================================
Unseal Key 1: <UNSEAL_KEY>

Initial Root Token: <VAULT_ROOT_TOKEN>

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 1 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
================================================================================
```

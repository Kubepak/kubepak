# 'keycloak' Package

## Important Note

Intended for development or testing only.

This package utilizes the Bitnami Legacy image repository by default. The standard Bitnami Keycloak image is no longer
available for free via Docker Hub.

## Description

A package for KeyCloak, an open-source identity and access management solution for modern applications and services,
built on top of industry security standard protocols.

## Values

| Name                             | Type   | Default                                                                        | Description                                                         |
|----------------------------------|--------|--------------------------------------------------------------------------------|---------------------------------------------------------------------|
| keycloak.image.registry          | string |                                                                                | Image registry                                                      |
| keycloak.image.repository        | string |                                                                                | Image repository                                                    |
| keycloak.image.tag               | string |                                                                                | Image tag                                                           |
| keycloak.ingress.host            | string | keycloak.\<environment\>.\<project\>.\<organization\>.local:<ingressHttpsPort> | Ingress host                                                        |
| keycloak.configPaths             | list   | []                                                                             | List of configuration files to be imported into Keycloak at startup |
| keycloak.auth.adminPassword      | string | admin                                                                          | Admin password                                                      |
| keycloak.pod.nodeSelector        | object | {}                                                                             | Node selection constraint                                           |
| keycloak.pod.tolerations         | list   | []                                                                             | Pod tolerations                                                     |
| keycloak.pod.affinity            | object | {}                                                                             | Pod affinity                                                        |
| keycloak.pod.container.resources | object | {}                                                                             | Resource requests and limits                                        |

### Notes

1. For `keycloak.configPaths`, ensure files follow Keycloak naming conventions (
   see [Keycloak docs](https://www.keycloak.org/server/importExport#_import_file_naming_conventions)).

# 'ory-oathkeeper' Package

## Description

A package for Ory Oathkeeper, a BeyondCorp/Zero Trust Identity & Access Proxy (IAP) that authenticates and authorizes
requests, and mutates them before forwarding them to your web services, acting as a policy enforcement point.

## Values

| Name                                    | Type   | Default                            | Description                                                                                                                                                                                              |
|-----------------------------------------|--------|------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ory-oathkeeper.image.repository         | string |                                    | Image repository                                                                                                                                                                                         |
| ory-oathkeeper.image.tag                | string |                                    | Image tag                                                                                                                                                                                                |
| ory-oathkeeper.accessRules.filePaths    | list   | []                                 | File paths whose content is loaded into ConfigMaps and referenced as local files (file:// URLs) in repositories.                                                                                         |
| ory-oathkeeper.accessRules.repositories | list   | []                                 | Remote repositories of rules (e.g., S3, Azure Blob, GCS). Do not use file:// URLs here. See [`https://www.ory.sh/docs/oathkeeper/api-access-rules`](https://www.ory.sh/docs/oathkeeper/api-access-rules) |
| ory-oathkeeper.tls.ca.srcFilePath       | string |                                    | SSL/TLS trusted certificate authorities source file path (PEM bundle)                                                                                                                                    |
| ory-oathkeeper.tls.ca.dstFilePath       | string | /etc/ssl/certs/ca-certificates.crt | SSL/TLS trusted certificate authorities destination file path (PEM bundle)                                                                                                                               |
| ory-oathkeeper.pod.nodeSelector         | object | {}                                 | Node selection constraint                                                                                                                                                                                |
| ory-oathkeeper.pod.tolerations          | list   | []                                 | Pod tolerations                                                                                                                                                                                          |
| ory-oathkeeper.pod.affinity             | object | {}                                 | Pod affinity                                                                                                                                                                                             |
| ory-oathkeeper.pod.container.resources  | object | {}                                 | Resource requests and limits                                                                                                                                                                             |

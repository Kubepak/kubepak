# 'argo-cd' Package

## Description

A package for Argo CD, a declarative, GitOps continuous delivery tool for Kubernetes.

## Values

| Name                                                             | Type   | Default                                                                               | Description                                                         |
|------------------------------------------------------------------|--------|---------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| argo-cd.ingress.host                                             | string | argo-cd.\<environment\>.\<project\>.\<organization\>.local:<ingressHttpsPort>         | Ingress host                                                        |
| argo-cd.web.externalUrl                                          | string | https://argo-cd.\<environment\>.\<project\>.\<organization\>.local:<ingressHttpsPort> | Web external URL                                                    |
| argo-cd.privateRepositories[`{i}`].type                          | string | git                                                                                   | Private repository type: `git` or `helm`                            |
| argo-cd.privateRepositories[`{i}`].name                          | string |                                                                                       | Private repository name                                             |
| argo-cd.privateRepositories[`{i}`].url                           | string |                                                                                       | Private repository URL                                              |
| argo-cd.privateRepositories[`{i}`].https.username                | string |                                                                                       | Private repository HTTPS username                                   |
| argo-cd.privateRepositories[`{i}`].https.password                | string |                                                                                       | Private repository HTTPS password                                   |
| argo-cd.privateRepositories[`{i}`].ssh.sshPrivateKey_b64         | string |                                                                                       | Private repository SSH private key, in base64 without line wrapping |
| argo-cd.sshExtraHosts[`{i}`].serverName                          | string |                                                                                       | SSH extra host server name                                          |
| argo-cd.sshExtraHosts[`{i}`].certType                            | string |                                                                                       | SSH extra host cert type                                            |
| argo-cd.sshExtraHosts[`{i}`].certInfo                            | string |                                                                                       | SSH extra host cert info                                            |
| argo-cd.auth.oidc.enabled                                        | bool   | false                                                                                 | OIDC enabled flag                                                   |
| argo-cd.auth.oidc.providers.microsoft[`{i}`].name                | string |                                                                                       | Microsoft OIDC connector name                                       |
| argo-cd.auth.oidc.providers.microsoft[`{i}`].tenant              | string |                                                                                       | Microsoft OIDC tenant ID                                            |
| argo-cd.auth.oidc.providers.microsoft[`{i}`].clientId            | string |                                                                                       | Microsoft OIDC auth client ID                                       |
| argo-cd.auth.oidc.providers.microsoft[`{i}`].clientSecret        | string |                                                                                       | Microsoft OIDC auth client secret                                   |
| argo-cd.auth.oidc.providers.microsoft[`{i}`].rbac.adminGroups    | list   | []                                                                                    | Azure groups for the role 'admin'                                   |
| argo-cd.auth.oidc.providers.microsoft[`{i}`].rbac.readonlyGroups | list   | []                                                                                    | Azure groups for the role 'readonly'                                |
| argo-cd.global.image.repository                                  | string |                                                                                       | Global image repository                                             |
| argo-cd.global.image.tag                                         | string |                                                                                       | Global image tag                                                    |
| argo-cd.global.pod.nodeSelector                                  | object | {}                                                                                    | Global node selection constraint                                    |
| argo-cd.global.pod.tolerations                                   | list   | []                                                                                    | Global pod tolerations                                              |
| argo-cd.global.pod.affinity                                      | object | {}                                                                                    | Global node affinity                                                |
| argo-cd.applicationController.pod.container.resources            | object | {}                                                                                    | Application controller resource requests and limits                 |
| argo-cd.dex.image.repository                                     | string |                                                                                       | Dex image repository                                                |
| argo-cd.dex.image.tag                                            | string |                                                                                       | Dex image tag                                                       |
| argo-cd.dex.pod.container.resources                              | object | {}                                                                                    | Dex resource requests and limits                                    |
| argo-cd.notificationsController.pod.container.resources          | object | {}                                                                                    | Notifications controller resource requests and limits               |
| argo-cd.redis.image.repository                                   | string |                                                                                       | Redis image repository                                              |
| argo-cd.redis.image.tag                                          | string |                                                                                       | Redis image tag                                                     |
| argo-cd.redis.pod.container.resources                            | object | {}                                                                                    | Redis resource requests and limits                                  |
| argo-cd.repoServer.pod.container.resources                       | object | {}                                                                                    | Repo server resource requests and limits                            |
| argo-cd.server.pod.container.resources                           | object | {}                                                                                    | Server resource requests and limits                                 |

### Notes

1. The `argo-cd.privateRepositories[{i}].ssh.sshPrivateKey_b64` value must be encoded in base64 without line wrapping.

   Here is an example:
   ```bash
   base64 -w0 <"${HOME}/.ssh/id_rsa"
   ```

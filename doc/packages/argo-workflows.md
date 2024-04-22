# 'argo-workflows' Package

## Description

A package for Argo Workflows, a Kubernetes-native workflow engine supporting DAG and step-based workflows.

## Values

| Name                                              | Type   | Default                                                                              | Description                             |
|---------------------------------------------------|--------|--------------------------------------------------------------------------------------|-----------------------------------------|
| argo-workflows.ingress.host                       | string | argo-workflows.\<environment\>.\<project\>.\<organization\>.local:<ingressHttpsPort> | Ingress host                            |
| argo-workflows.auth.oidc.enabled                  | bool   | false                                                                                | OIDC enabled flag                       |
| argo-workflows.auth.oidc.insecureSkipVerify       | bool   | false                                                                                | TLS verification enabled flag           |
| argo-workflows.auth.oidc.rbac.adminGroups         | list   | []                                                                                   | OIDC groups for the role 'admin'        |
| argo-workflows.auth.oidc.rbac.readonlyGroups      | list   | []                                                                                   | OIDC groups for the role 'readonly'     |
| argo-workflows.controller.image.registry          | string |                                                                                      | Controller image registry               |
| argo-workflows.controller.image.repository        | string |                                                                                      | Controller image repository             |
| argo-workflows.controller.image.tag               | string |                                                                                      | Controller image tag                    |
| argo-workflows.controller.pod.nodeSelector        | string | {}                                                                                   | Controller node selection constraint    |
| argo-workflows.controller.pod.tolerations         | list   | []                                                                                   | Controller pod tolerations              |
| argo-workflows.controller.pod.affinity            | object | {}                                                                                   | Controller pod affinity                 |
| argo-workflows.controller.pod.container.resources | object | {}                                                                                   | Controller resource requests and limits |
| argo-workflows.server.image.registry              | string |                                                                                      | Server image registry                   |
| argo-workflows.server.image.repository            | string |                                                                                      | Server image repository                 |
| argo-workflows.server.image.tag                   | string |                                                                                      | Server image tag                        |
| argo-workflows.server.pod.nodeSelector            | string | {}                                                                                   | Server node selection constraint        |
| argo-workflows.server.pod.tolerations             | list   | []                                                                                   | Server pod tolerations                  |
| argo-workflows.server.pod.affinity                | object | {}                                                                                   | Server pod affinity                     |
| argo-workflows.server.pod.container.resources     | object | {}                                                                                   | Server resource requests and limits     |

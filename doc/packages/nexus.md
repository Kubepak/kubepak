# 'nexus' Package

## Description

A package for Sonatype Nexus, a centralized, scalable repository management.

## Values

| Name                                        | Type   | Default                                                                     | Description                                                 |
|---------------------------------------------|--------|-----------------------------------------------------------------------------|-------------------------------------------------------------|
| nexus.license_b64                           | string |                                                                             | Nexus licence file content, in base64 without line wrapping |
| nexus.cluster.enabled                       | bool   | true                                                                        | Cluster enabled flag                                        |
| nexus.ingress.host                          | string | nexus.\<environment\>.\<project\>.\<organization\>.local:<ingressHttpsPort> | Ingress host                                                |
| nexus.config.path                           | string |                                                                             | Nexus configuration path                                    |
| nexus.global.image.repository               | string |                                                                             | Global image repository                                     |
| nexus.global.image.tag                      | string |                                                                             | Global image tag                                            |
| nexus.server.image.repository               | string |                                                                             | Server image repository                                     |
| nexus.server.image.tag                      | string |                                                                             | Server image tag                                            |
| nexus.server.pod.container.resources        | object | {}                                                                          | Server resource requests and limits                         |
| nexus.auditLogger.pod.container.resources   | object | {}                                                                          | Audit logger resource requests and limits                   |
| nexus.requestLogger.pod.container.resources | object | {}                                                                          | Request logger resource requests and limits                 |
| nexus.taskLogger.pod.container.resources    | object | {}                                                                          | Task logger resource requests and limits                    |

### Notes

1. The `nexus.license_b64` value must be encoded in base64 without line wrapping.

   Here is an example:
   ```bash
   base64 -w0 <"${HOME}/.ssh/id_rsa"
   ```

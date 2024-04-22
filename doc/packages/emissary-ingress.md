# 'emissary-ingress' Package

## Description

A package for Emissary-Ingress, a Kubernetes-native API gateway for microservices built on the Envoy Proxy.

## Values

| Name                                                     | Type   | Default                                                                    | Description                                                      |
|----------------------------------------------------------|--------|----------------------------------------------------------------------------|------------------------------------------------------------------|
| emissary-ingress.id                                      | string | default                                                                    | Emissary-Ingress ID                                              |
| emissary-ingress.image.repository                        | string |                                                                            | Image repository                                                 |
| emissary-ingress.image.tag                               | string |                                                                            | Image tag                                                        |
| emissary-ingress.agent.image.repository                  | string |                                                                            | Agent image repository                                           |
| emissary-ingress.agent.image.tag                         | string |                                                                            | Agent image tag                                                  |
| emissary-ingress.hosts[`{i}`].name                       | string |                                                                            | Host name                                                        |
| emissary-ingress.hosts[`{i}`].hostname                   | string | *.\<environment\>.\<project\>.\<organization\>.local:\<service.httpsPort\> | Host hostname                                                    |
| emissary-ingress.hosts[`{i}`].tls.certManager.enabled    | bool   | false                                                                      | Host TLS cert-manager enabled flag                               |
| emissary-ingress.hosts[`{i}`].tls.certManager.issuerName | string |                                                                            | Host TLS cert-manager issuer name                                |
| emissary-ingress.hosts[`{i}`].tls.crt_b64                | string |                                                                            | Host TLS certificate, in base64 without line wrapping            |
| emissary-ingress.hosts[`{i}`].tls.key_b64                | string |                                                                            | Host TLS key, in base64 without line wrapping                    |
| emissary-ingress.hosts[`{i}`].tls.minVersion             | string | "1.2"                                                                      | Minimum TLS protocol version                                     |
| emissary-ingress.hosts[`{i}`].tls.maxVersion             | string | "1.3"                                                                      | Maximum TLS protocol version                                     |
| emissary-ingress.service.annotations                     | object | {}                                                                         | Service annotations                                              |
| emissary-ingress.service.service.selector                | object | {}                                                                         | Service selector                                                 |
| emissary-ingress.service.type                            | string | LoadBalancer                                                               | Service type                                                     |
| emissary-ingress.service.httpPort                        | int    | 8080                                                                       | HTTP port on which Emissary-Ingress is listening on              |
| emissary-ingress.service.httpNodePort                    | int    |                                                                            | Used if service type is NodePort                                 |
| emissary-ingress.service.httpsPort                       | int    | 8443                                                                       | HTTPS port on which Emissary-Ingress is listening on             |
| emissary-ingress.service.httpsNodePort                   | int    |                                                                            | Used if service type is NodePort                                 |
| emissary-ingress.service.tcpPorts[`{i}`].port            | int    |                                                                            | TCP port on which Emissary-Ingress is listening on               |
| emissary-ingress.service.tcpPorts[`{i}`].nodePort        | int    |                                                                            | Used if service type is NodePort                                 |
| emissary-ingress.service.loadBalancerIP                  | string |                                                                            | IP address to assign (if cloud provider supports it)             |
| emissary-ingress.service.loadBalancerSourceRanges        | list   | []                                                                         | Passed to cloud provider load balancer if created (e.g: AWS ELB) |
| emissary-ingress.service.externalIPs                     | list   | []                                                                         | Service external IPs                                             |
| emissary-ingress.service.externalTrafficPolicy           | object |                                                                            | External traffic policy for the service                          |
| emissary-ingress.service.sessionAffinity                 | string |                                                                            | Session affinity                                                 |
| emissary-ingress.service.sessionAffinityConfig           | object |                                                                            | Session affinity config                                          |
| emissary-ingress.admin.service.create                    | bool   | true                                                                       | If true, create a service for Emissary-Ingress's admin UI        |
| emissary-ingress.admin.service.annotations               | object | {}                                                                         | Admin service annotations                                        |
| emissary-ingress.admin.service.selector                  | object | {}                                                                         | Admin service selector                                           |
| emissary-ingress.admin.service.type                      | string | ClusterIP                                                                  | Admin service type                                               |
| emissary-ingress.admin.service.port                      | int    | 8877                                                                       | Admin service port                                               |
| emissary-ingress.admin.service.nodePort                  | int    |                                                                            | Used if admin service type is NodePort                           |
| emissary-ingress.admin.service.snapshotPort              | int    | 8005                                                                       | Admin service snapshot port                                      |
| emissary-ingress.admin.service.loadBalancerIP            | string |                                                                            | IP address to assign (if cloud provider supports it)             |
| emissary-ingress.admin.service.loadBalancerSourceRanges  | list   | []                                                                         | Passed to cloud provider load balancer if created (e.g: AWS ELB) |
| emissary-ingress.pod.nodeSelector                        | object | {}                                                                         | Node selection constraint                                        |
| emissary-ingress.pod.tolerations                         | list   | []                                                                         | Pod tolerations                                                  |
| emissary-ingress.pod.affinity                            | object | {}                                                                         | Node affinity                                                    |
| emissary-ingress.pod.container.resources                 | object | {}                                                                         | Resource requests and limits                                     |

### Notes

1. To get automatic creation and renewal of TLS certificates, you can set the
   `emissary-ingress.hosts[{i}].tls.certManager.enabled` flag to true and add "cert-manager" to the installation
   context. In this case, the values `emissary-ingress.hosts[{i}].tls.crt_b64` and
   `emissary-ingress.hosts[{i}].tls.key_b64` are ignored.

2. The `emissary-ingress.hosts[{i}].tls_b64.crt` and `emissary-ingress.hosts[{i}].tls.key_b64` values must be encoded in
   base64 without line wrapping.

   Here is an example:
   ```bash
   base64 -w0 <"host.crt"
   ```

# 'prometheus-stack' Package

## Description

A package for a Prometheus stack, a collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules
combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with
Prometheus using the Prometheus Operator.

## Values

| Name                                                                   | Type   | Default                                                                                                | Description                                                |
|------------------------------------------------------------------------|--------|--------------------------------------------------------------------------------------------------------|------------------------------------------------------------|
| prometheus-stack.grafana.enabled                                       | bool   | false                                                                                                  | Grafana enabled flag                                       |
| prometheus-stack.grafana.image.registry                                | string |                                                                                                        | Image registry                                             |
| prometheus-stack.grafana.image.repository                              | string |                                                                                                        | Image repository                                           |
| prometheus-stack.grafana.image.tag                                     | string |                                                                                                        | Image tag                                                  |
| prometheus-stack.grafana.ingress.host                                  | string | prometheus-stack-grafana.\<environment\>.\<project\>.\<organization\>.local:<ingressHttpsPort>         | Ingress host                                               |
| prometheus-stack.grafana.web.externalUrl                               | string | https://prometheus-stack-grafana.\<environment\>.\<project\>.\<organization\>.local:<ingressHttpsPort> | Web external URL                                           |
| prometheus-stack.grafana.auth.oidc.enabled                             | bool   |                                                                                                        | OIDC enabled flag                                          |
| prometheus-stack.grafana.auth.oidc.providers.generic.name              | string |                                                                                                        | Generic OIDC connector name                                |
| prometheus-stack.grafana.auth.oidc.providers.generic.apiUrl            | string |                                                                                                        | Generic OIDC API URL                                       |
| prometheus-stack.grafana.auth.oidc.providers.generic.authUrl           | string |                                                                                                        | Generic OIDC auth URL                                      |
| prometheus-stack.grafana.auth.oidc.providers.generic.tokenUrl          | string |                                                                                                        | Generic OIDC token URL                                     |
| prometheus-stack.grafana.auth.oidc.providers.generic.clientId          | string |                                                                                                        | Generic OIDC auth client ID                                |
| prometheus-stack.grafana.auth.oidc.providers.generic.clientSecret      | string |                                                                                                        | Generic OIDC auth client secret                            |
| prometheus-stack.grafana.auth.oidc.providers.generic.scopes            | string |                                                                                                        | Generic OIDC scopes                                        |
| prometheus-stack.grafana.auth.oidc.providers.generic.roleAttributePath | string |                                                                                                        | Generic OIDC JMESPath expression                           |
| prometheus-stack.grafana.auth.oidc.providers.microsoft.name            | string |                                                                                                        | Microsoft OIDC connector name                              |
| prometheus-stack.grafana.auth.oidc.providers.microsoft.tenant          | string |                                                                                                        | Microsoft OIDC tenant ID                                   |
| prometheus-stack.grafana.auth.oidc.providers.microsoft.clientId        | string |                                                                                                        | Microsoft OIDC auth client ID                              |
| prometheus-stack.grafana.auth.oidc.providers.microsoft.clientSecret    | string |                                                                                                        | Microsoft OIDC auth client secret                          |
| prometheus-stack.grafana.dataSources[`{i}`].name                       | string | Loki                                                                                                   | Data source name                                           |
| prometheus-stack.grafana.dataSources[`{i}`].type                       | string | loki                                                                                                   | Data source type                                           |
| prometheus-stack.grafana.dataSources[`{i}`].url                        | string | http://loki-gateway.dev-loki.svc.cluster.local                                                         | Data source URL                                            |
| prometheus-stack.grafana.dataSources[`{i}`].tenantName                 | string | loki                                                                                                   | Tenant name that matches the one in other related packages |

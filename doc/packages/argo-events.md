# 'argo-events' Package

## Description

A package for Argo Events, an event-driven workflow automation framework for Kubernetes.

## Values

| Name                                           | Type   | Default                                                                           | Description                             |
|------------------------------------------------|--------|-----------------------------------------------------------------------------------|-----------------------------------------|
| argo-events.ingress.host                       | string | argo-events.\<environment\>.\<project\>.\<organization\>.local:<ingressHttpsPort> | Ingress host                            |
| argo-events.global.image.repository            | string |                                                                                   | Global image repository                 |
| argo-events.global.image.tag                   | string |                                                                                   | Global image tag                        |
| argo-events.controller.pod.nodeSelector        | string | {}                                                                                | Controller node selection constraint    |
| argo-events.controller.pod.tolerations         | list   | []                                                                                | Controller pod tolerations              |
| argo-events.controller.pod.affinity            | object | {}                                                                                | Controller pod affinity                 |
| argo-events.controller.pod.container.resources | object | {}                                                                                | Controller resource requests and limits |
| argo-events.webhook.enabled                    | bool   | false                                                                             | Webhook enabled flag                    |
| argo-events.webhook.pod.nodeSelector           | string | {}                                                                                | Webhook node selection constraint       |
| argo-events.webhook.pod.tolerations            | list   | []                                                                                | Webhook pod tolerations                 |
| argo-events.webhook.pod.affinity               | object | {}                                                                                | Webhook pod affinity                    |
| argo-events.webhook.pod.container.resources    | object | {}                                                                                | Webhook resource requests and limits    |

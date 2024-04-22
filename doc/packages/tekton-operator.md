# 'tekton-operator' Package

## Description

A package for Tekton Operator, a powerful and flexible open-source framework for creating CI/CD systems, allowing
developers to build, test, and deploy across cloud providers and on-premise systems.

## Important Note

While Tekton offers a robust continuous integration and delivery (CI/CD) pipeline solution, it currently has limitations
regarding namespace deployment. Tekton controllers operate within a single namespace, which can hinder multi-environment
deployments.

## Values

| Name                                                 | Type   | Default                                                                                | Description                           |
|------------------------------------------------------|--------|----------------------------------------------------------------------------------------|---------------------------------------|
| tekton-operator.dashboard.ingress.host               | string | tekton-dashboard.\<environment\>.\<project\>.\<organization\>.local:<ingressHttpsPort> | Tekton dashboard ingress host         |
| tekton-operator.global.pod.nodeSelector              | object | {}                                                                                     | Global node selection constraint      |
| tekton-operator.global.pod.tolerations               | list   | []                                                                                     | Global pod tolerations                |
| tekton-operator.global.pod.affinity                  | object | {}                                                                                     | Global pod affinity                   |
| tekton-operator.operator.image.registry              | string |                                                                                        | Operator image registry               |
| tekton-operator.operator.image.repository            | string |                                                                                        | Operator image repository             |
| tekton-operator.operator.image.tag                   | string |                                                                                        | Operator image tag                    |
| tekton-operator.operator.pod.container.resources     | object | {}                                                                                     | Operator resource requests and limits |
| tekton-operator.pruner.image.registry                | string |                                                                                        | Pruner image registry                 |
| tekton-operator.pruner.image.repository              | string |                                                                                        | Pruner image repository               |
| tekton-operator.pruner.image.tag                     | string |                                                                                        | Pruner image tag                      |
| tekton-operator.webhook.image.registry               | string |                                                                                        | Webhook image registry                |
| tekton-operator.webhook.image.repository             | string |                                                                                        | Webhook image repository              |
| tekton-operator.webhook.image.tag                    | string |                                                                                        | Webhook image tag                     |
| tekton-operator.webhookProxy.pod.container.resources | object | {}                                                                                     | Webhook resource requests and limits  |
| tekton-operator.webhookProxy.image.registry          | string |                                                                                        | Webhook Proxy image registry          |
| tekton-operator.webhookProxy.image.repository        | string |                                                                                        | Webhook Proxy image repository        |
| tekton-operator.webhookProxy.image.tag               | string |                                                                                        | Webhook Proxy image tag               |

# 'ory-keto' Package

## Description

A package for Ory Keto, an open-source access control system that implements Google Zanzibar-style authorization. It is
part of the Ory ecosystem and is designed to provide fine-grained, flexible, and scalable permissions management for
applications and services.

## Values

| Name                                | Type   | Default | Description                     |
|-------------------------------------|--------|---------|---------------------------------|
| ory-keto.image.repository           | string |         | Image repository                |
| ory-keto.image.tag                  | string |         | Image tag                       |
| ory-keto.permissionModels.filePaths | list   | []      | File paths to permission models |
| ory-keto.pod.nodeSelector           | object | {}      | Node selection constraint       |
| ory-keto.pod.tolerations            | list   | []      | Pod tolerations                 |
| ory-keto.pod.affinity               | object | {}      | Pod affinity                    |
| ory-keto.pod.container.resources    | object | {}      | Resource requests and limits    |

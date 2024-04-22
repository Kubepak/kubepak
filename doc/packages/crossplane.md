# 'crossplane' Package

## Description

A package for Crossplane, a cloud native control plane framework that allows you to build control planes without needing
to write code.

## Values

| Name                                           | Type   | Default | Description                               |
|------------------------------------------------|--------|---------|-------------------------------------------|
| crossplane.image.registry                      | string |         | Image registry                            |
| crossplane.image.repository                    | string |         | Image repository                          |
| crossplane.image.tag                           | string |         | Image tag                                 |
| crossplane.pod.nodeSelector                    | object | {}      | Node selection constraint                 |
| crossplane.pod.tolerations                     | list   | []      | Node tolerations                          |
| crossplane.pod.affinity                        | object | {}      | Node affinity                             |
| crossplane.pod.container.resources             | object | {}      | Resource requests and limits              |
| crossplane.rbacManager.pod.nodeSelector        | object | {}      | RBAC manager node selection constraint    |
| crossplane.rbacManager.pod.tolerations         | list   | []      | RBAC manager node tolerations             |
| crossplane.rbacManager.pod.affinity            | object | {}      | RBAC manager node affinity                |
| crossplane.rbacManager.pod.container.resources | object | {}      | RBAC manager resource requests and limits |

# 'mysql' Package

## Important Note

Intended for development or testing only.

## Description

A package for MySQL, a fast, reliable, scalable, and easy to use open source relational database system.

## Values

| Name                                    | Type   | Default | Description                            |
|-----------------------------------------|--------|---------|----------------------------------------|
| mysql.image.registry                    | string |         | Image registry                         |
| mysql.image.repository                  | string |         | Image repository                       |
| mysql.image.tag                         | string |         | Image tag                              |
| mysql.auth.rootPassword                 | string | root    | Password for the "root" admin user     |
| mysql.primary.maxAllowedPacket          | int    |         | Primary max allowed packet             |
| mysql.primary.persistence.size          | string | 8Gi     | Primary persistence volume size        |
| mysql.primary.pod.nodeSelector          | object | {}      | Primary node selection constraint      |
| mysql.primary.pod.tolerations           | list   | []      | Primary pod tolerations                |
| mysql.primary.pod.affinity              | object | {}      | Primary pod affinity                   |
| mysql.primary.pod.container.resources   | object | {}      | Primary resource requests and limits   |
| mysql.secondary.maxAllowedPacket        | int    |         | Secondary max allowed packet           |
| mysql.secondary.persistence.size        | string | 8Gi     | Secondary persistence volume size      |
| mysql.secondary.pod.nodeSelector        | object | {}      | Secondary node selection constraint    |
| mysql.secondary.pod.tolerations         | list   | []      | Secondary pod tolerations              |
| mysql.secondary.pod.affinity            | object | {}      | Secondary pod affinity                 |
| mysql.secondary.pod.container.resources | object | {}      | Secondary resource requests and limits |

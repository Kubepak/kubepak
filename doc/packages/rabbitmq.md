# 'rabbitmq' Package

## Important Note

Intended for development or testing only.

This package utilizes the Bitnami Legacy image repository by default. The standard Bitnami RabbitMQ image is no longer
available for free via Docker Hub.

## Description

A package for RabbitMQ, an open source message broker software implementing the advanced message queuing protocol
(AMQP).

## Values

| Name                             | Type   | Default                                                                              | Description                  |
|----------------------------------|--------|--------------------------------------------------------------------------------------|------------------------------|
| rabbitmq.image.registry          | string |                                                                                      | Image registry               |
| rabbitmq.image.repository        | string |                                                                                      | Image repository             |
| rabbitmq.image.tag               | string |                                                                                      | Image tag                    |
| rabbitmq.auth.adminPassword      | string | admin                                                                                | Password for the admin user  |
| rabbitmq.manager.ingress.host    | string | rabbit-manager.\<environment\>.\<project\>.\<organization\>.local:<ingressHttpsPort> | Ingress host                 |
| rabbitmq.pod.nodeSelector        | object | {}                                                                                   | Node selection constraint    |
| rabbitmq.pod.tolerations         | list   | []                                                                                   | Pod tolerations              |
| rabbitmq.pod.affinity            | object | {}                                                                                   | Pod affinity                 |
| rabbitmq.pod.container.resources | object | {}                                                                                   | Resource requests and limits |

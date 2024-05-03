# 'kafka-operator' Package

## Description

A package for Kafka Operator, an event store and distributed message broker solution.

## Values

| Name                                    | Type   | Default | Description                                                       |
|-----------------------------------------|--------|---------|-------------------------------------------------------------------|
| kafka-operator.image.registry           | string |         | Image registry                                                    |
| kafka-operator.image.repository         | string |         | Image repository                                                  |
| kafka-operator.image.tag                | string |         | Image tag                                                         |
| kafka-operator.replicas                 | int    | 1       | Number of replicas                                                |
| kafka-operator.watchAnyNamespaces       | bool   | false   | Toggle if it should only scan his own namespace of all namespaces |
| kafka-operator.dashboards.enabled       | bool   | false   | Should we create default dashboards                               |
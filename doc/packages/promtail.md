# 'promtail' Package

## Disclaimer

Intended for development or testing only.

## Description

A package for Promtail, an agent which ships the contents of local logs to a Loki instance.

## Values

| Name                               | Type   | Default                                        | Description                                                   |
|------------------------------------|--------|------------------------------------------------|---------------------------------------------------------------|
| promtail.image.registry            | string |                                                | Image registry                                                |
| promtail.image.repository          | string |                                                | Image repository                                              |
| promtail.image.tag                 | string |                                                | Image tag                                                     |
| promtail.clients[`{i}`].url        | string | http://loki-gateway.dev-loki.svc.cluster.local | Clients that uses the data                                    |
| promtail.clients[`{i}`].tenantName | string | loki                                           | Tenant name that matches the grafana `dataSources.tenantName` |

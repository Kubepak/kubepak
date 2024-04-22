# 'custom-coredns' Package

## Description

A package for CoreDNS, empowering customization specifically designed for Kubernetes clusters.

## Values

| Name                                   | Type   | Default | Description                     |
|----------------------------------------|--------|---------|---------------------------------|
| custom-coredns.configFiles[`{i}`].key  | string |         | CoreDNS configuration file key  |
| custom-coredns.configFiles[`{i}`].path | string |         | CoreDNS configuration file path |

### Notes

1. The `custom-coredns.configFiles[`{i}`].path` value specifying the CoreDNS configuration file path can be either
   relative to the Kubepak shell script or absolute.

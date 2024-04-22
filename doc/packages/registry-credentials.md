# 'registry-credentials' Package

## Description

A package for registry credentials, which maps them into Kubernetes to support pulling from Amazon’s EC2 Container
Registry (ECR) and Docker Private Registries (DPR).

## Values

| Name                                                          | Type   | Default                     | Description                                        |
|---------------------------------------------------------------|--------|-----------------------------|----------------------------------------------------|
| registry-credentials.namespaces                               | list   | []                          | Namespaces in which the credentials are replicated |
| registry-credentials.cronjobs.ecr.schedule                    | string | 0 */1 * * *                 | Schedule to update the ECR registry credentials    |
| registry-credentials.registries.dpr[`{i}`].server             | string | https://index.docker.io/v1/ | Docker server URL                                  |
| registry-credentials.registries.dpr[`{i}`].username           | string |                             | Docker username                                    |
| registry-credentials.registries.dpr[`{i}`].password           | string |                             | Docker password                                    |
| registry-credentials.registries.ecr[`{i}`].awsAccount         | string |                             | AWS account                                        |
| registry-credentials.registries.ecr[`{i}`].awsAccessKeyId     | string |                             | AWS access key ID                                  |
| registry-credentials.registries.ecr[`{i}`].awsSecretAccessKey | string |                             | AWS secret access key                              |
| registry-credentials.registries.ecr[`{i}`].awsRegion          | string |                             | AWS region                                         |

### Notes

1. For the registry credentials to be available to pods, their namespaces must be added to the following list:
   `registry-credentials.namespaces`.

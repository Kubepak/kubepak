# 'cert-manager-issuers' Package

## Description

A package for Cert-Manager issuers, Kubernetes resources that represent certificate authorities (CAs) that are able to
generate signed certificates by honoring certificate signing requests.

## Values

| Name                                                                                   | Type   | Default                                                | Description                                |
|----------------------------------------------------------------------------------------|--------|--------------------------------------------------------|--------------------------------------------|
| cert-manager-issuers.issuers.acme[`{i}`].name                                          | string |                                                        | ACME issuer name                           |
| cert-manager-issuers.issuers.acme[`{i}`].server                                        | string | https://acme-staging-v02.api.letsencrypt.org/directory | ACME server URL                            |
| cert-manager-issuers.issuers.acme[`{i}`].email                                         | string |                                                        | Email address to receive notifications     |
| cert-manager-issuers.issuers.acme[`{i}`].solvers.dns01[`{j}`].provider                 | string |                                                        | DNS01 provider: `rfc2136` or `route53`     |
| cert-manager-issuers.issuers.acme[`{i}`].solvers.dns01[`{j}`].rfc2136.nameserver       | string |                                                        | RFC2136 nameserver                         |
| cert-manager-issuers.issuers.acme[`{i}`].solvers.dns01[`{j}`].rfc2136.tsigKeyName      | string |                                                        | RFC2136 TSIG key name                      |
| cert-manager-issuers.issuers.acme[`{i}`].solvers.dns01[`{j}`].rfc2136.tsigKeyAlgorithm | string |                                                        | RFC2136 TSIG key algorithm                 |
| cert-manager-issuers.issuers.acme[`{i}`].solvers.dns01[`{j}`].route53.awsRegion        | string |                                                        | AWS region                                 |
| cert-manager-issuers.issuers.acme[`{i}`].solvers.dns01[`{j}`].route53.accessKeyId      | string |                                                        | AWS access key ID                          |
| cert-manager-issuers.issuers.acme[`{i}`].solvers.dns01[`{j}`].route53.secretAccessKey  | string |                                                        | AWS secret access key                      |
| cert-manager-issuers.issuers.acme[`{i}`].solvers.dns01[`{j}`].dnsZones                 | list   | []                                                     | DNS zones that can be solved by the solver |

# 'openapi-oathkeeper' Package

## Description

A package dedicated to generating Ory Oathkeeper access rules from OpenAPI specifications.

## Values

| Name                                     | Type   | Default                 | Description                                                     |
|------------------------------------------|--------|-------------------------|-----------------------------------------------------------------|
| openapi-oathkeeper.config.prefix         | string |                         | OpenAPI prefix identifier                                       |
| openapi-oathkeeper.config.serverUrls     | list   | []                      | List of public-facing server URLs this configuration applies to |
| openapi-oathkeeper.config.upstream       | object | {}                      | Backend service definition for Ory Oathkeeper to proxy to       |
| openapi-oathkeeper.config.authenticators | map    |                         | Map of Ory Oathkeeper authenticators to apply                   |
| openapi-oathkeeper.config.authorizer     | object |                         | Ory Oathkeeper authorizer configuration to apply                |
| openapi-oathkeeper.config.mutators       | list   |                         | List of Oathkeeper mutators to apply                            |
| openapi-oathkeeper.config.errors         | list   |                         | Custom error handlers for Ory Oathkeeper decisions              |
| openapi-oathkeeper.source.url            | string |                         | Git repository URL for the OpenAPI file(s)                      |
| openapi-oathkeeper.source.branch         | string |                         | Git branch/tag/commit for the OpenAPI file(s)                   |
| openapi-oathkeeper.source.basePath       | string | .                       | Base path in Git repo for the OpenAPI file(s)                   |
| openapi-oathkeeper.source.regexFilter    | string | .*\\.(yaml\|yml\|json)$ | Regex to find relevant OpenAPI file(s) in base path             |

# 'postgresql' Package

## Important Note

Intended for development or testing only.

## Description

A package for PostgreSQL, a powerful, open source object-relational database system that uses and extends the SQL
language combined with many features that safely store and scale the most complicated data workloads.

## Values

| Name                                       | Type   | Default  | Description                                                          |
|--------------------------------------------|--------|----------|----------------------------------------------------------------------|
| postgresql.image.registry                  | string |          | Image registry                                                       |
| postgresql.image.repository                | string |          | Image repository                                                     |
| postgresql.image.tag                       | string |          | Image tag                                                            |
| postgresql.auth.postgresPassword           | string | postgres | Password for the "postgres" admin user                               |
| postgresql.persistence.size                | string | 8Gi      | Persistence volume size                                              |
| postgresql.tls.enabled                     | bool   | false    | TLS enabled flag                                                     |
| postgresql.tls.cert_b64                    | string |          | TLS certificate, in base64 without line wrapping                     |
| postgresql.tls.key_b64                     | string |          | TLS certificate key, in base64 without line wrapping                 |
| postgresql.tls.ca_b64                      | string |          | TLS trusted certificate authorities, in base64 without line wrapping |
| postgresql.primary.extendedConfigmap       | string |          | ConfigMap name for extended PostgreSQL primary configuration         |
| postgresql.primary.pod.nodeSelector        | object | {}       | Primary node selection constraint                                    |
| postgresql.primary.pod.tolerations         | list   | []       | Primary pod tolerations                                              |
| postgresql.primary.pod.affinity            | object | {}       | Primary pod affinity                                                 |
| postgresql.primary.pod.container.resources | object | {}       | Primary resource requests and limits                                 |

### Notes

1. The default credentials for the administrator are as follows:

    * Username: postgres
    * Password: postgres

2. The `postgresql.tls.cert_b64`, `postgresql.tls.key_b64`, and `postgresql.tls.ca_b64` values must be encoded in base64
   without line wrapping.

   Here is an example:
   ```bash
   base64 -w0 <"${HOME}/.local/share/cert-store/ca.pem"
   ```

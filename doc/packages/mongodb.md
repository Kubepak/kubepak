# 'mongodb' Package

## Important Note

Intended for development or testing only.

## Description

A package for MongoDB, a document database with the scalability and flexibility that you want with the querying and
indexing that you need.

## Values

| Name                                    | Type   | Default | Description                                                 |
|-----------------------------------------|--------|---------|-------------------------------------------------------------|
| mongodb.image.registry                  | string |         | Image registry                                              |
| mongodb.image.repository                | string |         | Image repository                                            |
| mongodb.image.tag                       | string |         | Image tag                                                   |
| mongodb.auth.rootPassword               | string | root    | Root password                                               |
| mongodb.persistence.size                | string | 8Gi     | Persistence volume size                                     |
| mongodb.tls.enabled                     | bool   | false   | TLS enabled flag                                            |
| mongodb.tls.caCert_b64                  | string |         | CA certificate, in base64 without line wrapping             |
| mongodb.tls.caKey_b64                   | string |         | CA certificate private key, in base64 without line wrapping |
| mongodb.pod.nodeSelector                | object | {}      | Node selection constraint                                   |
| mongodb.pod.tolerations                 | list   | []      | Pod tolerations                                             |
| mongodb.pod.affinity                    | object | {}      | Pod affinity                                                |
| mongodb.pod.container.resources         | object | {}      | Resource requests and limits                                |
| mongodb.arbiter.pod.nodeSelector        | string | {}      | Arbiter node selection constraint                           |
| mongodb.arbiter.pod.tolerations         | list   | []      | Arbiter pod tolerations                                     |
| mongodb.arbiter.pod.affinity            | object | {}      | Arbiter pod affinity                                        |
| mongodb.arbiter.pod.container.resources | object | {}      | Arbiter resource requests and limits                        |

### Notes

1. The default credentials for the administrator are as follows:

    * Username: root
    * Password: root

2. The `mongodb.tls.caCert_b64` and `mongodb.tls.caKey_b64` values must be encoded in base64 without line wrapping.

   Here is an example:
   ```bash
   base64 -w0 <"${HOME}/.local/share/cert-store/ca.pem"
   ```

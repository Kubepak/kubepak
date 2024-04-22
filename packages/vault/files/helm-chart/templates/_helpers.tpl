{{- define "vault.ingress.host" -}}
{{- default (printf "%s.%s:%d" .Release.Name (include "common.host.defaultDomain" .) (include "common.ingressController.service.httpsPort" . | int)) (.Values.packages.vault.ingress.host) }}
{{- end }}

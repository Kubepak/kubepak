{{- define "generic-application.ingress.host" -}}
{{- default (printf "%s.%s:%d" .Release.Name (include "common.host.defaultDomain" .) (include "common.ingressController.service.httpsPort" . | int)) (index .Values "packages" "generic-application" "ingress" "host") }}
{{- end }}

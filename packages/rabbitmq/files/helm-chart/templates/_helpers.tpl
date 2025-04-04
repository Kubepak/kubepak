{{- define "rabbitmq.manager.ingress.host" -}}
{{- default (printf "%s.%s:%d" (printf "%s-manager" .Release.Name) (include "common.host.defaultDomain" .) (include "common.ingressController.service.httpsPort" . | int)) (.Values.packages.rabbitmq.manager.ingress.host) }}
{{- end }}

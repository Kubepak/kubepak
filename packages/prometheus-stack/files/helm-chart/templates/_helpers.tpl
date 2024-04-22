{{- define "prometheus-stack.grafana.ingress.host" -}}
{{- default (printf "%s.%s:%d" (printf "%s-grafana" .Release.Name) (include "common.host.defaultDomain" .) (include "common.ingressController.service.httpsPort" . | int)) (index .Values "packages" "prometheus-stack" "grafana" "ingress" "host") }}
{{- end }}

{{- define "prometheus-stack.grafana.web.externalUrl" -}}
{{- default (printf "https://%s" (include "prometheus-stack.grafana.ingress.host" .)) (index .Values "packages" "prometheus-stack" "grafana" "web" "externalUrl") }}
{{- end }}

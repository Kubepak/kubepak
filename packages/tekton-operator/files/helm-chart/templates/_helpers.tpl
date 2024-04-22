{{- define "tekton-dashboard.ingress.host" -}}
{{- default (printf "tekton-dashboard.%s:%d" (include "common.host.defaultDomain" .) (include "common.ingressController.service.httpsPort" . | int)) (index .Values "packages" "tekton-operator" "dashboard" "ingress" "host") }}
{{- end }}

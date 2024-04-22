{{- define "argo-cd.ingress.host" -}}
{{- default (printf "%s.%s:%d" "argo-cd" (include "common.host.defaultDomain" .) (include "common.ingressController.service.httpsPort" . | int)) (index .Values "packages" "argo-cd" "ingress" "host") }}
{{- end }}

{{- define "argo-workflows.ingress.host" -}}
{{- default (printf "%s.%s:%d" .Release.Name (include "common.host.defaultDomain" .) (include "common.ingressController.service.httpsPort" . | int)) (index .Values "packages" "argo-workflows" "ingress" "host") }}
{{- end }}

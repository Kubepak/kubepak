{{- define "common.ingressController" -}}
{{- if and (eq (include "common.context.contains" (merge (dict "value" "multiple-ingress-controllers") .)) "true") (.networkPlane) }}
  {{- index .Values "packages" (printf "ingress-%s" .networkPlane) "emissary-ingress" | toYaml }}
{{- else }}
  {{- index .Values "packages" "emissary-ingress" | toYaml }}
{{- end }}
{{- end }}

{{- define "common.ingressController.id" -}}
{{- $id := "default" }}
{{- $ingressController := include "common.ingressController" . | fromYaml }}
{{- if $ingressController }}
  {{- if $ingressController.id }}
    {{- $id = $ingressController.id }}
  {{- end }}
{{- end }}
{{- $id }}
{{- end }}

{{- define "common.ingressController.service.httpsPort" -}}
{{- $httpsPort := "8443" }}
{{- $ingressController := include "common.ingressController" . | fromYaml }}
{{- if $ingressController }}
  {{- if $ingressController.service }}
    {{- if $ingressController.service.httpsPort }}
      {{- $httpsPort = $ingressController.service.httpsPort }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $httpsPort }}
{{- end }}

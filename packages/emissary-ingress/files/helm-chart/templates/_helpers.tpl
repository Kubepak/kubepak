{{- define "emissary-ingress.id" -}}
{{- $id := "default" }}
{{- if index .Values "packages" "emissary-ingress" }}
    {{- if index .Values "packages" "emissary-ingress" "id" }}
        {{- $id = index .Values "packages" "emissary-ingress" "id" }}
    {{- end }}
{{- end }}
{{- $id }}
{{- end }}

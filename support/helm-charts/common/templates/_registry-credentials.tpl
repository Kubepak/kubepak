{{- define "common.registryCredentials.imagePullSecrets" -}}
imagePullSecrets:
{{- $hasNameField := default false .hasNameField }}
{{- if hasKey (index .Values "packages") "registry-credentials" }}
  {{- range $key, $value := index .Values "packages" "registry-credentials" "registries" }}
    {{- range $index, $_ := $value }}
  - {{ ternary "name: " "" $hasNameField }}registry-creds-{{ $key }}-{{ $index }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "common.host.defaultDomain" -}}
{{- printf "%s.%s.%s.local" .Values.environment .Values.project .Values.organization }}
{{- end }}

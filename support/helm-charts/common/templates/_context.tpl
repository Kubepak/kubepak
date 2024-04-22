{{- define "common.context.contains" -}}
{{- regexMatch (printf "^([a-zA-Z0-9_-]+,)*%s(,[a-zA-Z0-9_-]+)*$" .value) .Values.context }}
{{- end }}

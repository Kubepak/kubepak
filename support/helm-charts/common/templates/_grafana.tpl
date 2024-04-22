{{- define "common.grafana.dashboard.configmaps" -}}
{{- range $filePath, $_ := .Files.Glob .path }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/name: {{ $.Chart.Name }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
    app.kubernetes.io/part-of: {{ $.Values.organization }}.{{ $.Values.project }}
    app.kubernetes.io/managed-by: kubepak
    grafana_dashboard: grafana
  annotations:
    grafana_folder: {{ $.Release.Name }}
  name: grafana-dashboard-{{ $filePath | base | splitList "." | first }}
  namespace: {{ $.Release.Namespace }}
data:
  {{ $filePath | base }}: {{ $.Files.Get $filePath | toJson }}
...
{{- end }}
{{- end }}

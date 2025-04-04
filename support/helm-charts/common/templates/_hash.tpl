{{- define "hash.generateShortSha" -}}
{{- $input := .input }}
{{- $shaLength := default 8 .shaLength }}
{{- trunc $shaLength (sha1sum $input) }}
{{- end -}}

{{- define "hash.generateUniqueBasename" -}}
{{- $path := .path }}
{{- $shaLength := .shaLength | default 8 }}
{{- $basename := base $path }}
{{- $name := regexReplaceAll "\\..*$" $basename "" }}
{{- $suffix := regexReplaceAll "^[^.]*" $basename "" }}
{{- printf "%s-%s%s" $name (include "hash.generateShortSha" (dict "input" $path "shaLength" $shaLength)) $suffix }}
{{- end -}}

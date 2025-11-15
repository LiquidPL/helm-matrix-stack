{{- define "matrix-stack.well-known.labels" -}}
{{- with required "matrix-stack.well-known.labels missing context" .context -}}
{{ include "matrix-stack.common.labels" $.root }}
{{ include "matrix-stack.well-known.selector-labels" (dict "context" . "root" $.root) }}
app.kubernetes.io/component: well-known-delegation
app.kubernetes.io/version: {{ .image.tag }}
{{- end }}
{{- end }}

{{- define "matrix-stack.well-known.selector-labels" -}}
{{- with required "matrix-stack.well-known.selector-labels missing context" .context -}}
app.kubernetes.io/name: nginx
app.kubernetes.io/instance: {{ include "matrix-stack.fullname" $.root }}-well-known-delegation
{{- end }}
{{- end }}

{{- define "matrix-stack.matrix-authentication-service.labels" -}}
{{- with required "matrix-stack.matrix-authentication-service.labels missing context" .context -}}
{{ include "matrix-stack.common.labels" $.root }}
{{ include "matrix-stack.matrix-authentication-service.selector-labels" (dict "context" . "root" $.root) }}
app.kubernetes.io/component: matrix-authentication-service
app.kubernetes.io/version: {{ .image.tag }}
{{- end }}
{{- end }}

{{- define "matrix-stack.matrix-authentication-service.selector-labels" -}}
{{- with required "matrix-stack.matrix-authentication-service.selector-labels missing context" .context -}}
app.kubernetes.io/name: matrix-authentication-service
app.kubernetes.io/instance: {{ include "matrix-stack.fullname" $.root }}-matrix-authentication-service
{{- end }}
{{- end }}

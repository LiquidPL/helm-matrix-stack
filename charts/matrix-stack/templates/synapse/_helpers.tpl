{{- define "matrix-stack.synapse.labels" -}}
{{- with required "matrix-stack.synapse.labels missing context" .context -}}
{{ include "matrix-stack.common.labels" $.root }}
{{ include "matrix-stack.synapse.selector-labels" (dict "context" . "root" $.root) }}
app.kubernetes.io/component: matrix-server
app.kubernetes.io/version: {{ .image.tag }}
{{- end }}
{{- end }}

{{- define "matrix-stack.synapse.selector-labels" -}}
{{- with required "matrix-stack.synapse.selector-labels missing context" .context -}}
app.kubernetes.io/name: synapse
app.kubernetes.io/instance: {{ include "matrix-stack.fullname" $.root }}-synapse
{{- end }}
{{- end }}

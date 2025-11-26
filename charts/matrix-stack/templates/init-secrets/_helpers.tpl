{{- define "matrix-stack.init-secrets.labels" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.init-secrets.labels missing context" .context -}}
{{ include "matrix-stack.common.labels" $.root }}
{{ include "matrix-stack.init-secrets.selector-labels" (dict "context" . "root" $.root) }}
app.kubernetes.io/component: provisioning
app.kubernetes.io/version: {{ $root.Values.matrixTools.image.tag }}
{{- end }}
{{- end }}

{{- define "matrix-stack.init-secrets.selector-labels" -}}
{{- with required "matrix-stack.init-secrets.selector-labels missing context" .context -}}
app.kubernetes.io/name: matrix-tools
app.kubernetes.io/instance: {{ include "matrix-stack.fullname" $.root }}-init-secrets
{{- end }}
{{- end }}

{{- define "matrix-stack.init-secrets.generated-secrets" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.init-secrets.generated-secrets missing context" .context -}}
{{- include "matrix-stack.synapse.generated-secrets" (dict "context" $root.Values.synapse "root" $root) -}}
{{- include "matrix-stack.matrix-authentication-service.generated-secrets" (dict "context" $root.Values.matrixAuthenticationService "root" $root) -}}
{{- end }}
{{- end }}

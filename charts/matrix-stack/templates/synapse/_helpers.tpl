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

{{- define "matrix-stack.synapse.generated-secrets" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.synapse.generated-secrets missing context" .context -}}
{{- if not .signingKey }}
- secretName: {{ include "matrix-stack.fullname" $root }}-synapse-generated
  secretKey: SYNAPSE_SIGNING_KEY
  type: signingkey
{{- end }}
{{- if not .macaroonKey }}
- secretName: {{ include "matrix-stack.fullname" $root }}-synapse-generated
  secretKey: SYNAPSE_MACAROON_KEY
  type: rand32
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.synapse.provided-secrets" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.synapse.provided-secrets missing context" .context }}
{{- with .signingKey }}
{{ list . | toYaml }}
{{- end }}
{{- with .macaroonKey }}
{{ list . | toYaml }}
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.synapse.postgres-secrets" -}}
{{- with required "matrix-stack.synapse.postgres-secrets missing context" .context -}}
{{- $secrets := list -}}
{{- with .host -}}
{{- if hasKey . "secretName" -}}
{{- $secrets = append $secrets (set . "property" "host") -}}
{{- end }}
{{- end }}
{{- with .port -}}
{{- if hasKey . "secretName" -}}
{{- $secrets = append $secrets (set . "property" "port") -}}
{{- end }}
{{- end }}
{{- with .database -}}
{{- if hasKey . "secretName" -}}
{{- $secrets = append $secrets (set . "property" "database") -}}
{{- end }}
{{- end }}
{{- with .user -}}
{{- if hasKey . "secretName" -}}
{{- $secrets = append $secrets (set . "property" "user") -}}
{{- end }}
{{- end }}
{{- with .password -}}
{{- if hasKey . "secretName" -}}
{{- $secrets = append $secrets (set . "property" "password") -}}
{{- end }}
{{- end }}
{{ $secrets | uniq | toJson }}
{{- end }}
{{- end }}

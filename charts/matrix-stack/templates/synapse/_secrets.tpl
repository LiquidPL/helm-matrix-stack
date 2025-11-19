{{- define "matrix-stack.synapse.secret-keys.signing-key" -}}
SYNAPSE_SIGNING_KEY
{{- end -}}

{{- define "matrix-stack.synapse.secret-keys.macaroon-key" -}}
SYNAPSE_MACAROON_KEY
{{- end -}}

{{- define "matrix-stack.synapse.secret-keys.postgres-host" -}}
SYNAPSE_POSTGRES_HOST
{{- end -}}

{{- define "matrix-stack.synapse.secret-keys.postgres-port" -}}
SYNAPSE_POSTGRES_PORT
{{- end -}}

{{- define "matrix-stack.synapse.secret-keys.postgres-database" -}}
SYNAPSE_POSTGRES_DATABASE
{{- end -}}

{{- define "matrix-stack.synapse.secret-keys.postgres-user" -}}
SYNAPSE_POSTGRES_USER
{{- end -}}

{{- define "matrix-stack.synapse.secret-keys.postgres-password" -}}
SYNAPSE_POSTGRES_PASSWORD
{{- end -}}

{{- define "matrix-stack.synapse.generated-secrets" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.synapse.generated-secrets missing context" .context -}}
{{- if not .signingKey }}
- secretName: {{ include "matrix-stack.fullname" $root }}-synapse-generated
  secretKey: {{ include "matrix-stack.synapse.secret-keys.signing-key" . }}
  type: signingkey
{{- end }}
{{- if not .macaroonKey }}
- secretName: {{ include "matrix-stack.fullname" $root }}-synapse-generated
  secretKey: {{ include "matrix-stack.synapse.secret-keys.macaroon-key" . }}
  type: rand32
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.synapse.secrets" -}}
{{- $root := .root -}}
{{- if include "matrix-stack.synapse.generated-secrets" . }}
- secretName: {{ include "matrix-stack.fullname" $root }}-synapse-generated
{{- end }}
{{- with required "matrix-stack.synapse.secrets missing context" .context }}
{{- with .signingKey }}
- secretName: {{ .secretName }}
{{- end }}
{{- with .macaroonKey }}
- secretName: {{ .secretName }}
{{- end }}
{{- include "matrix-stack.synapse.postgres-secrets" (dict "context" .postgres "root" $) }}
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
{{ $secrets | toYaml }}
{{- end }}
{{- end }}

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

{{- define "matrix-stack.synapse.provided-secret-data" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.synapse.provided-secret-data missing context" .context -}}
{{- with (.signingKey).value }}
{{ include "matrix-stack.synapse.secret-keys.signing-key" . }}: {{ . | b64enc }}
{{- end }}
{{- with (.macaroonKey).value }}
{{ include "matrix-stack.synapse.secret-keys.macaroon-key" . }}: {{ . | b64enc }}
{{- end }}
{{- with .postgres }}
{{- with .host.value }}
{{ include "matrix-stack.synapse.secret-keys.postgres-host" . }}: {{ . | b64enc }}
{{- end }}
{{- with (.port).value }}
{{ include "matrix-stack.synapse.secret-keys.postgres-port" . }}: {{ . | b64enc }}
{{- end }}
{{- with .database.value }}
{{ include "matrix-stack.synapse.secret-keys.postgres-database" . }}: {{ . | b64enc }}
{{- end }}
{{- with .user.value }}
{{ include "matrix-stack.synapse.secret-keys.postgres-user" . }}: {{ . | b64enc }}
{{- end }}
{{- with .password.value }}
{{ include "matrix-stack.synapse.secret-keys.postgres-password" . }}: {{ . | b64enc }}
{{- end }}
{{- end }}
{{- with (.additionalConfig).value }}
additional.yaml: {{ . | b64enc }}
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.synapse.secrets" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.synapse.secrets missing context" .context }}
{{- if include "matrix-stack.synapse.generated-secrets" (dict "context" . "root" $root) }}
- secretName: {{ include "matrix-stack.fullname" $root }}-synapse-generated
{{- end }}
{{- if include "matrix-stack.synapse.provided-secret-data" (dict "context" . "root" $root) }}
- secretName: {{ include  "matrix-stack.fullname" $root}}-synapse
{{- end }}
{{- with (.signingKey).secretName }}
- secretName: {{ . }}
{{- end }}
{{- with (.macaroonKey).secretName }}
- secretName: {{ . }}
{{- end }}
{{- include "matrix-stack.synapse.postgres-secrets" (dict "context" .postgres "root" $root) }}
{{/* we don't need to handle the provided secret case as it's already handled above */}}
{{- with (.additionalConfig).secretName }}
- secretName: {{ . }}
{{- end }}
{{- with $root.Values.matrixAuthenticationService }}
{{- if (.synapseSecret).secretName }}
{{ list (pick .synapseSecret "secretName") | toYaml }}
{{- else if (.synapseSecret).value }}
- secretName: {{ include "matrix-stack.fullname" $root }}-matrix-authentication-service
{{- else }}
- secretName: {{ include "matrix-stack.fullname" $root }}-matrix-authentication-service-generated
{{- end }}
  mountSubPath: true
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.synapse.postgres-secrets" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.synapse.postgres-secrets missing context" .context -}}
{{- $secrets := list -}}
{{- $providedSecret := printf "%s-synapse" (include "matrix-stack.fullname" $root) -}}
{{- with .host }}
{{- $secrets = append $secrets (dict "property" "host" "secretName" (.secretName | default $providedSecret)) -}}
{{- end }}
{{- with .port }}
{{- $secrets = append $secrets (dict "property" "port" "secretName" (.secretName | default $providedSecret)) -}}
{{- end }}
{{- with .database }}
{{- $secrets = append $secrets (dict "property" "database" "secretName" (.secretName | default $providedSecret)) -}}
{{- end }}
{{- with .user }}
{{- $secrets = append $secrets (dict "property" "user" "secretName" (.secretName | default $providedSecret)) -}}
{{- end }}
{{- with .password }}
{{- $secrets = append $secrets (dict "property" "password" "secretName" (.secretName | default $providedSecret)) -}}
{{- end }}
{{- if $secrets }}
{{ $secrets | toYaml }}
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.synapse.postgres-secret" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.synapse.postgres-secret missing context" .context -}}
{{- if hasKey .value "secretName" }}
{{ list (dict "property" .valueName "secretName" .value.secretName) | toYaml }}
{{- else }}
{{ list (dict "property" .valueName "secretName" (printf "%s-synapse" (include "matrix-stack.fullname" $root))) | toYaml }}
{{- end }}
{{- end }}
{{- end }}

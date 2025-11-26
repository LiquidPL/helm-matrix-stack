{{- define "matrix-stack.matrix-authentication-service.secret-keys.synapse-secret" -}}
MAS_SYNAPSE_SECRET
{{- end -}}

{{- define "matrix-stack.matrix-authentication-service.secret-keys.encryption-secret" -}}
MAS_ENCRYPTION_SECRET
{{- end -}}

{{- define "matrix-stack.matrix-authentication-service.secret-keys.rsa-key" -}}
MAS_RSA_PRIVATE_KEY
{{- end -}}

{{- define "matrix-stack.matrix-authentication-service.secret-keys.ecdsa-prime256v1-key" -}}
MAS_ECDSA_PRIME256V1_PRIVATE_KEY
{{- end -}}

{{- define "matrix-stack.matrix-authentication-service.secret-keys.ecdsa-secp256k1-key" -}}
MAS_ECDSA_SECP256K1_PRIVATE_KEY
{{- end -}}

{{- define "matrix-stack.matrix-authentication-service.secret-keys.ecdsa-secp384r1-key" -}}
MAS_ECDSA_SECP384R1_PRIVATE_KEY
{{- end -}}

{{- define "matrix-stack.matrix-authentication-service.secret-keys.postgres-uri" -}}
MAS_POSTGRES_URI
{{- end -}}

{{- define "matrix-stack.matrix-authentication-service.secret-keys.postgres-host" -}}
MAS_POSTGRES_HOST
{{- end -}}

{{- define "matrix-stack.matrix-authentication-service.secret-keys.postgres-port" -}}
MAS_POSTGRES_PORT
{{- end -}}

{{- define "matrix-stack.matrix-authentication-service.secret-keys.postgres-database" -}}
MAS_POSTGRES_DATABASE
{{- end -}}

{{- define "matrix-stack.matrix-authentication-service.secret-keys.postgres-user" -}}
MAS_POSTGRES_USER
{{- end -}}

{{- define "matrix-stack.matrix-authentication-service.secret-keys.postgres-password" -}}
MAS_POSTGRES_PASSWORD
{{- end -}}

{{- define "matrix-stack.matrix-authentication-service.generated-secrets" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.matrix-authentication-service.generated-secrets missing context" .context -}}
{{- if not .synapseSecret }}
- secretName: {{ include "matrix-stack.fullname" $root }}-matrix-authentication-service-generated
  secretKey: {{ include "matrix-stack.matrix-authentication-service.secret-keys.synapse-secret" . }}
  type: rand32
{{- end }}
{{- if not .encryptionSecret }}
- secretName: {{ include "matrix-stack.fullname" $root }}-matrix-authentication-service-generated
  secretKey: {{ include "matrix-stack.matrix-authentication-service.secret-keys.encryption-secret" . }}
  type: hex32
{{- end }}
{{- if not (.privateKeys).rsa }}
- secretName: {{ include "matrix-stack.fullname" $root }}-matrix-authentication-service-generated
  secretKey: {{ include "matrix-stack.matrix-authentication-service.secret-keys.rsa-key" . }}
  type: rsa
{{- end }}
{{- if not (.privateKeys).ecdsaPrime256v1 }}
- secretName: {{ include "matrix-stack.fullname" $root }}-matrix-authentication-service-generated
  secretKey: {{ include "matrix-stack.matrix-authentication-service.secret-keys.ecdsa-prime256v1-key" . }}
  type: ecdsaprime256v1
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.matrix-authentication-service.provided-secret-data" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.matrix-authentication-service.provided-secret-data missing context" .context -}}
{{- with (.synapseSecret).value }}
{{ include "matrix-stack.matrix-authentication-service.secret-keys.synapse-secret" . }}: {{ . | b64enc }}
{{- end }}
{{- with (.encryptionSecret).value }}
{{ include "matrix-stack.matrix-authentication-service.secret-keys.encryption-secret" . }}: {{ . | b64enc }}
{{- end }}
{{- with ((.privateKeys).rsa).value }}
{{ include "matrix-stack.matrix-authentication-service.secret-keys.rsa-key" . }}: {{ . | b64enc }}
{{- end }}
{{- with ((.privateKeys).ecdsaPrime256v1).value }}
{{ include "matrix-stack.matrix-authentication-service.secret-keys.ecdsa-prime256v1-key" . }}: {{ . | b64enc }}
{{- end }}
{{- with .postgres }}
{{- with (.uri).value }}
{{ include "matrix-stack.matrix-authentication-service.secret-keys.postgres-uri" . }}: {{ . | b64enc }}
{{- end }}
{{- with (.host).value }}
{{ include "matrix-stack.matrix-authentication-service.secret-keys.postgres-host" . }}: {{ . | b64enc }}
{{- end }}
{{- with (.port).value }}
{{ include "matrix-stack.matrix-authentication-service.secret-keys.postgres-port" . }}: {{ . | toString | b64enc }}
{{- end }}
{{- with (.database).value }}
{{ include "matrix-stack.matrix-authentication-service.secret-keys.postgres-database" . }}: {{ . | b64enc }}
{{- end }}
{{- with (.user).value }}
{{ include "matrix-stack.matrix-authentication-service.secret-keys.postgres-user" . }}: {{ . | b64enc }}
{{- end }}
{{- with (.password).value }}
{{ include "matrix-stack.matrix-authentication-service.secret-keys.postgres-password" . }}: {{ . | b64enc }}
{{- end }}
{{- end }}
{{- with (.additionalConfig).value }}
additional.yaml: {{ . | b64enc }}
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.matrix-authentication-service.secrets" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.matrix-authentication-service.secrets missing context" .context }}
{{- if include "matrix-stack.matrix-authentication-service.generated-secrets" (dict "context" . "root" $root) }}
- secretName: {{ include "matrix-stack.fullname" $root }}-matrix-authentication-service-generated
{{- end }}
{{- if include "matrix-stack.matrix-authentication-service.provided-secret-data" (dict "context" . "root" $root) }}
- secretName: {{ include "matrix-stack.fullname" $root }}-matrix-authentication-service
{{- end }}
{{- with (.synapseSecret).secretName }}
- secretName: {{ . }}
{{- end }}
{{- with (.encryptionSecret).secretName }}
- secretName: {{ . }}
{{- end }}
{{- with ((.privateKeys).rsa).secretName }}
- secretName: {{ . }}
{{- end }}
{{- with ((.privateKeys).ecdsaPrime256v1).secretName }}
- secretName: {{ . }}
{{- end }}
{{- with ((.privateKeys).ecdsaSecp256k1).secretName }}
- secretName: {{ . }}
{{- end }}
{{- with ((.privateKeys).ecdsaSecp384r1).secretName }}
- secretName: {{ . }}
{{- end }}
{{- include "matrix-stack.matrix-authentication-service.postgres-secrets" (dict "context" .postgres "root" $root) }}
{{/* we don't need to handle the provided secret case as it's already handled above */}}
{{- with (.additionalConfig).secretName }}
- secretName: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.matrix-authentication-service.postgres-secrets" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.matrix-authentication-service.postgres-secrets missing context" .context -}}
{{- $secrets := list -}}
{{- $providedSecret := printf "%s-matrix-authentication-service" (include "matrix-stack.fullname" $root) -}}
{{- with .uri -}}
{{- $secrets = append $secrets (dict "property" "uri" "secretName" (.secretName | default $providedSecret)) -}}
{{- end }}
{{- with .host -}}
{{- $secrets = append $secrets (dict "property" "host" "secretName" (.secretName | default $providedSecret)) -}}
{{- end }}
{{- with .port -}}
{{- $secrets = append $secrets (dict "property" "port" "secretName" (.secretName | default $providedSecret)) -}}
{{- end }}
{{- with .database -}}
{{- $secrets = append $secrets (dict "property" "database" "secretName" (.secretName | default $providedSecret)) -}}
{{- end }}
{{- with .user -}}
{{- $secrets = append $secrets (dict "property" "user" "secretName" (.secretName | default $providedSecret)) -}}
{{- end }}
{{- with .password -}}
{{- $secrets = append $secrets (dict "property" "password" "secretName" (.secretName | default $providedSecret)) -}}
{{- end }}
{{- if $secrets }}
{{ $secrets | toYaml }}
{{- end }}
{{- end }}
{{- end }}

{{- $root := .root -}}
{{- with required "synapse/homeserver.yaml.tpl missing context" .context -}}
public_baseurl: https://{{ .host }}/
server_name: {{ $root.Values.serverName }}

listeners:
  - port: 8008
    tls: false
    type: http
    x_forwarded: true
    resources:
      - names: [client, federation]
        compress: false
{{- with .postgres }}
database:
  name: psycopg2
  args:
    host: __SYNAPSE_POSTGRES_HOST__
    port: {{ if not (hasKey . "port") }}5432{{ else }}__SYNAPSE_POSTGRES_PORT__{{ end }}
    database: __SYNAPSE_POSTGRES_DATABASE__
    user: __SYNAPSE_POSTGRES_USER__
    password: __SYNAPSE_POSTGRES_PASSWORD__
{{- end }}

log_config: /config/log_config.yaml
media_store_path: /media
max_upload_size: {{ .media.maxUploadSize }}

report_stats: false

signing_key_path: /secrets/{{
  include "matrix-stack.common.secret-path" (dict
    "root" $root
    "context" (dict
      "valuePath" "synapse.signingKey"
      "initSecretKey" "SYNAPSE_SIGNING_KEY"
    )
  )
}}
macaroon_secret_key_path: /secrets/{{
  include "matrix-stack.common.secret-path" (dict
    "root" $root
    "context" (dict
      "valuePath" "synapse.macaroonKey"
      "initSecretKey" "SYNAPSE_MACAROON_KEY"
    )
  )
}}

matrix_authentication_service:
  enabled: true
  endpoint: http://{{ include "matrix-stack.fullname" $root }}-matrix-authentication-service:8080
  secret_path: /secrets/{{
    include "matrix-stack.common.secret-path" (dict
      "root" $root
      "context" (dict
        "valuePath" "matrixAuthenticationService.synapseSecret"
        "initSecretKey" (include "matrix-stack.matrix-authentication-service.secret-keys.synapse-secret" .)
      )
    )
  }}
{{- end }}

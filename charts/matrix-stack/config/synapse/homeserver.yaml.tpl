{{- $root := .root -}}
{{- with required "synapse/homeserver.yaml.tpl missing context" .context -}}
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
    host: {{ ternary .host.value "__SYNAPSE_POSTGRES_HOST__" (hasKey .host "value") }}
    port: {{ if not (hasKey . "port") }}5432{{ else }}{{ ternary .port.value "__SYNAPSE_POSTGRES_PORT__" (hasKey .port "value") }}{{ end }}
    database: {{ ternary .database.value "__SYNAPSE_POSTGRES_DATABASE__" (hasKey .database "value") }}
    user: {{ ternary .user.value "__SYNAPSE_POSTGRES_USER__" (hasKey .user "value") }}
    password: {{ ternary .password.value "__SYNAPSE_POSTGRES_PASSWORD__" (hasKey .password "value") }}
{{- end }}

log_config: /config/log_config.yaml
media_store_path: /media
max_upload_size: {{ .media.maxUploadSize }}

report_stats: false

signing_key_path: /secrets/signing-key/{{ .signingKey.secretKey }}
macaroon_secret_key_path: /secrets/macaroon-key/{{ .macaroonKey.secretKey }}
{{- end }}

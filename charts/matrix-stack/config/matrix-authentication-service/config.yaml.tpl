{{- $root := .root -}}
{{- with required "config/matrix-authentication-service/config.yaml.tpl missing context" .context -}}
http:
  public_base: https://{{ .host }}/
  listeners:
    - name: main
      resources:
        - name: discovery
        - name: human
        - name: oauth
        - name: compat
        - name: graphql
        - name: assets
        - name: adminapi
      binds:
        - address: '[::]:8080'
    - name: internal
      resources:
        - name: health
      binds:
        - address: '[::]:8081'

{{- with .postgres }}
database:
{{- if .uri }}
  uri: ${MAS_POSTGRES_URI}
{{- else }}
  host: ${MAS_POSTGRES_HOST}
  port: {{ if not (hasKey . "port") }}5432{{ else }}${MAS_POSTGRES_PORT}{{ end }}
  database: ${MAS_POSTGRES_DATABASE}
  username: ${MAS_POSTGRES_USER}
  password: ${MAS_POSTGRES_PASSWORD}
{{- end }}
{{- end }}

matrix:
  kind: synapse_modern
  homeserver: {{ $root.Values.serverName }}
  endpoint: http://{{ include "matrix-stack.fullname" $root }}-synapse:8008
  secret_file: /secrets/{{
    include "matrix-stack.common.secret-path" (dict
      "root" $root
      "context" (dict
        "valuePath" "matrixAuthenticationService.synapseSecret"
        "initSecretKey" (include "matrix-stack.matrix-authentication-service.secret-keys.synapse-secret" .)
      )
    )
  }}

secrets:
  encryption_file: /secrets/{{
    include "matrix-stack.common.secret-path" (dict
      "root" $root
      "context" (dict
        "valuePath" "matrixAuthenticationService.encryptionSecret"
        "initSecretKey" (include "matrix-stack.matrix-authentication-service.secret-keys.encryption-secret" .)
      )
    )
  }}

  keys:
    - kid: rsa
      key_file: /secrets/{{
        include "matrix-stack.common.secret-path" (dict
          "root" $root
          "context" (dict
            "valuePath" "matrixAuthenticationService.privateKeys.rsa"
            "initSecretKey" (include "matrix-stack.matrix-authentication-service.secret-keys.rsa-key" .)
          )
        )
      }}
    - kid: prime256v1
      key_file: /secrets/{{
        include "matrix-stack.common.secret-path" (dict
          "root" $root
          "context" (dict
            "valuePath" "matrixAuthenticationService.privateKeys.ecdsaPrime256v1"
            "initSecretKey" (include "matrix-stack.matrix-authentication-service.secret-keys.ecdsa-prime256v1-key" .)
          )
        )
      }}
    {{ if (.privateKeys).ecdsaSecp384r1 }}
    - kid: secp384r1
      key_file: /secrets/{{
        include "matrix-stack.common.secret-path" (dict
          "root" $root
          "context" (dict
            "valuePath" "matrixAuthenticationService.privateKeys.ecdsaSecp384r1"
            "initSecretKey" (include "matrix-stack.matrix-authentication-service.secret-keys.ecdsa-secp384r1-key" .)
          )
        )
      }}
    {{- end }}
    {{- if (.privateKeys).ecdsaSecp256k1 }}
    - kid: secp256k1
      key_file: /secrets/{{
        include "matrix-stack.common.secret-path" (dict
          "root" $root
          "context" (dict
            "valuePath" "matrixAuthenticationService.privateKeys.ecdsaSecp256k1"
            "initSecretKey" (include "matrix-stack.matrix-authentication-service.secret-keys.ecdsa-secp256k1-key" .)
          )
        )
      }}
    {{- end }}
{{- end }}

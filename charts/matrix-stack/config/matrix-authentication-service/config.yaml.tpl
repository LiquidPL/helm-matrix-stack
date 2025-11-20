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
  uri: __MAS_POSTGRES_URI__
{{- else }}
  host: __MAS_POSTGRES_HOST__
  port: {{ if not (hasKey . "port") }}5432{{ else }}__MAS_POSTGRES_PORT__{{ end }}
  database: __MAS_POSTGRES_DATABASE__
  username: __MAS_POSTGRES_USER__
  password: __MAS_POSTGRES_PASSWORD__
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

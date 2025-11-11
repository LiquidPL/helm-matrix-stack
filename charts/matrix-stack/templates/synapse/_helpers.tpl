{{- define "matrix-stack.synapse.labels" -}}
{{- with required "missing matrix-stack.synapse.labels context" .context -}}
{{ include "matrix-stack.common.labels" $.root }}
{{ include "matrix-stack.synapse.selectorLabels" (dict "context" . "root" $.root) }}
app.kubernetes.io/component: matrix-server
app.kubernetes.io/version: {{ .image.tag }}
{{- end }}
{{- end }}

{{- define "matrix-stack.synapse.selectorLabels" -}}
{{- with required "missing matrix-stack.synapse.selectorLabels context" .context -}}
app.kubernetes.io/name: synapse
app.kubernetes.io/instance: {{ include "matrix-stack.fullname" $.root }}-synapse
{{- end }}
{{- end }}

{{- define "matrix-stack.synapse.image" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.synapse.image missing context" .context -}}
{{- if .digest }}
image: "{{ .registry }}/{{ .repository }}@{{ .digest }}"
imagePullPolicy: {{ coalesce .pullPolicy $.root.Values.image.pullPolicy "IfNotPresent" }}
{{- else }}
image: "{{ .registry }}/{{ .repository }}:{{ .tag }}"
imagePullPolicy: {{ coalesce .pullPolicy $.root.Values.image.pullPolicy "Always" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.synapse.postgresSecrets" -}}
{{- with required "matrix-stack.synapse.postgresSecrets missing context" .context -}}
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
{{ $secrets | uniq | toJson }}
{{- end }}
{{- end }}
{{- end }}

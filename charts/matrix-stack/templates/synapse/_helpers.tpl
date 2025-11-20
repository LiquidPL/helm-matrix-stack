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

{{- define "matrix-stack.synapse.mas-routes" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.synapse.mas-routes missing context" .context }}
{{- range $subpath := list "login" "logout" "refresh" }}
{{- range $version := list "api/v1" "r0" "v3" "unstable" }}
- /_matrix/client/{{ $version }}/{{ $subpath }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.synapse.mas-ingress-paths" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.synapse.mas-ingress-paths missing context" .context }}
{{- range include "matrix-stack.synapse.mas-routes" (dict "context" . "root" $root) | fromYamlArray }}
- path: {{ . }}
  pathType: Prefix
  backend:
    service:
      name: {{ include "matrix-stack.fullname" $root }}-matrix-authentication-service
      port:
        name: http
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.synapse.mas-httproute-paths" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.synapse.mas-httproute-paths missing context" .context }}
{{- range include "matrix-stack.synapse.mas-routes" (dict "context" . "root" $root) | fromYamlArray }}
- path:
    type: PathPrefix
    value: {{ . }}
{{- end }}
{{- end }}
{{- end }}

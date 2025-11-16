{{- define "matrix-stack.common.value-from-path" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.common.value-from-path missing context" .context -}}
{{- $current := mustMergeOverwrite (dict) (mustDeepCopy $root.Values) -}}
{{- range (mustRegexSplit "\\." . -1) -}}
{{- if $current -}}
{{- $current = dig . nil $current -}}
{{- end -}}
{{- end -}}
{{ $current | toJson }}
{{- end -}}
{{- end -}}

{{- define "matrix-stack.common.secret-path" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.common.secret-path missing context" .context -}}
{{- $valuePath := required "matrix-stack.common.secret-path missing valuePath" .valuePath -}}
{{- $initSecretKey := required "matrix-stack.common.secret-path missing initSecretKey" .initSecretKey -}}
{{- $value := (include "matrix-stack.common.value-from-path" (dict "root" $root "context" $valuePath) | fromJson) -}}
{{- if $value -}}
provided-{{ $value.secretName }}/{{ $value.secretKey }}
{{- else -}}
{{- if $root.Values.initSecrets.enabled -}}
generated/{{ $initSecretKey }}
{{- else -}}
{{- fail (printf "initSecrets.enabled is false but no secret for %s provided" $valuePath) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* context - name of component */}}
{{- define "matrix-stack.common.secret-volumes" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.common.secret-volumes missing context" .context -}}
{{- $component := required "matrix-stack.common.secret-volumes missing component" .component -}}
{{- if (include (printf "matrix-stack.%s.generated-secrets" $component) (dict "context" (get $root.Values $component) "root" $root)) }}
- name: generated
  secret:
    secretName: generated
    defaultMode: 0400
{{- end }}
{{- $usedSecrets := list -}}
{{- range (include (printf "matrix-stack.%s.provided-secrets" $component) (dict "context" (get $root.Values $component) "root" $root) | fromYamlArray) }}
{{- if not (has .secretName $usedSecrets) }}
- name: provided-{{ .secretName }}
  secret:
    secretName: {{ .secretName }}
    defaultMode: 0400
{{- $usedSecrets = append $usedSecrets .secretName -}}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "matrix-stack.common.secret-volumemounts" -}}
{{- $root := .root -}}
{{- with required "matrix-stack.common.secret-volumemounts missing context" .context -}}
{{- $component := required "matrix-stack.common.secret-volumemounts missing component" .component -}}
{{- if (include (printf "matrix-stack.%s.generated-secrets" $component) (dict "context" (get $root.Values $component) "root" $root)) }}
- name: generated
  mountPath: /secrets/generated
  readOnly: true
{{- end }}
{{- $usedSecrets := list -}}
{{- range (include (printf "matrix-stack.%s.provided-secrets" $component) (dict "context" (get $root.Values $component) "root" $root) | fromYamlArray) }}
{{- if not (has .secretName $usedSecrets) }}
- name: provided-{{ .secretName }}
  mountPath: /secrets/provided-{{ .secretName }}
  defaultMode: 0400
{{- $usedSecrets = append $usedSecrets .secretName -}}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

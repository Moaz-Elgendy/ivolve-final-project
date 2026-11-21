{{/* Reusable snippets. Call with: {{ include "ivolve.labels" (dict "name" "auth" "root" .) }} */}}
{{- define "ivolve.labels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/part-of: ivolve
{{- end }}

{{- define "ivolve.selector" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end }}

{{/* Full image reference. Repos are <name>-<environment> (e.g. frontend-dev), one registry for all envs.
     Call with: {{ include "ivolve.image" (dict "name" .Values.auth.image "root" .) }} */}}
{{- define "ivolve.image" -}}
{{ required "registry is required: set it as an Argo Application helm parameter" .root.Values.registry }}/{{ .name }}-{{ required "environment is required (values-<env>.yaml)" .root.Values.environment }}:{{ required "imageTag is required (values-<env>.yaml)" .root.Values.imageTag }}
{{- end }}

{{/* Container hardening for the app containers (mysql is excluded: its entrypoint starts as root) */}}
{{- define "ivolve.containerSecurity" -}}
runAsNonRoot: true
allowPrivilegeEscalation: false
capabilities:
  drop: [ALL]
seccompProfile:
  type: RuntimeDefault
{{- end }}

{{/* Vault Agent Injector annotations; $secrets is a dict of name -> (path, template) */}}
{{- define "ivolve.vaultAnnotations" -}}
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/role: {{ .root.Values.vault.role | quote }}
vault.hashicorp.com/agent-inject-secret-{{ .file }}: {{ .path | quote }}
vault.hashicorp.com/agent-inject-template-{{ .file }}: |
{{ .template | indent 2 }}
{{- end }}

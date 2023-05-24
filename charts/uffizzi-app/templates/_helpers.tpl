{{/* vim: set filetype=mustache: */}}

{{- define "web.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.web.image "global" .Values.global) }}
{{- end -}}

{{- define "web.renderImagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.web.image) "context" $) -}}
{{- end -}}

{{- define "sidekiq.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.sidekiq.image "global" .Values.global) }}
{{- end -}}

{{- define "sidekiq.renderImagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.sidekiq.image) "context" $) -}}
{{- end -}}

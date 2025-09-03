{{/*
Expand the name of the chart.
*/}}
{{- define "govway_fse_gtw.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "govway_fse_gtw.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "govway_fse_gtw.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "govway_fse_gtw.labels" -}}
helm.sh/chart: {{ include "govway_fse_gtw.chart" . }}
{{ include "govway_fse_gtw.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "govway_fse_gtw.selectorLabels" -}}
app.kubernetes.io/name: {{ include "govway_fse_gtw.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "govway_fse_gtw.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "govway_fse_gtw.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* 
  Validazione globale cloudProvider e regole specifiche per provider
*/}}
{{- define "govway_fse_gtw.validateCloudProvider" -}}

  {{- if not .Values.govway.entityName }}
    {{- fail "❌ La varibile govway.entityName è obbligatoria." }}
  {{- end }}

  {{- $cloudProvider := required "❌ .Values.cloudProvider è obbligatorio!" .Values.cloudProvider }}
  {{- $supportedProviders := list "aws" "azure" "gcp" }}
  {{- if not (has $cloudProvider $supportedProviders) }}
    {{- fail (printf "❌ Valore cloudProvider '%s' non supportato. Usa uno tra: %s" $cloudProvider (join ", " $supportedProviders)) }}
  {{- end }}

  {{- if eq $cloudProvider "aws" }}
    {{- $confighosts := .Values.ingress.config_host }}
    {{- if empty $confighosts }}
      {{- fail "❌ Per 'aws', 'ingress.config_host' deve essere definito e contenere almeno un host." }}
    {{- end }}
    {{- if not (kindIs "string" $confighosts) }}
      {{- fail (printf "❌ 'ingress.config_host' deve essere una stringa.") }}
    {{- end }}

    {{- $monitorhosts := .Values.ingress.monitor_host  }}
    {{- if or (not $monitorhosts) (eq (len $monitorhosts) 0) }}
      {{- fail "❌ Per 'aws', 'ingress.monitor_host' deve essere definito e contenere almeno un host." }}
    {{- end }}
    {{- if not (kindIs "string" $monitorhosts) }}
      {{- fail (printf "❌ 'ingress.monitor_host' deve essere una stringa.") }}
    {{- end }}



    {{- $iam := default "" .Values.secrets.iamrole }}
    {{- $sa  := default "" .Values.serviceAccountName }}
    {{- if and (empty $iam) (empty $sa) }}
      {{- fail "❌ Per 'aws', imposta almeno uno tra 'secrets.iamrole' o 'serviceAccountName'." }}
    {{- end }}

    {{- if and (not (empty $iam)) (not (empty $sa)) }}
      {{- fail "❌ Configurazione ambigua: imposta solo uno tra 'secrets.iamrole' e 'serviceAccountName'." }}
    {{- end }}

    {{- if not .Values.secrets.certificateArn }}
      {{- fail "❌ Per 'aws', 'secrets.certificateArn' è obbligatorio." }}
    {{- end }}
    
  {{- else if eq $cloudProvider "azure" }}
    {{- if not .Values.secrets.tenantId }}
      {{- fail "❌ Per 'azure', 'secrets.tenantId' è obbligatorio." }}
    {{- end }}
  {{- end }}
  
{{- end }}


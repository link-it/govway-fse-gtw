{{/*
Expand the name of the chart.
*/}}
{{- define "govway_fse_gtw.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 50 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
Su AWS il nome del job non può superare i 52 caratteri, quindi per sicurezza limitiamo a 50.
*/}}
{{- define "govway_fse_gtw.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 50 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 50 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 50 | trimSuffix "-" }}
{{- end }}
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

    {{- if not .Values.secrets.iamrole }}
      {{- fail "❌ Per 'aws', 'secrets.iamrole' è obbligatorio." }}
    {{- end }}
  {{- end }}

  {{- if eq $cloudProvider "azure" }}
    {{- if not .Values.secrets.tenantId }}
      {{- fail "❌ Per 'azure', 'secrets.tenantId' è obbligatorio." }}
    {{- end }}
  {{- end }}
{{- end }}


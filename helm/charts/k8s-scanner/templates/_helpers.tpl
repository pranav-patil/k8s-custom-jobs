{{/*
Expand the name of the chart.
*/}}
{{- define "k8s-scanner.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "k8s-scanner.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "k8s-scanner.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k8s-scanner.labels" -}}
helm.sh/chart: {{ include "k8s-scanner.chart" . }}
{{ include "k8s-scanner.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k8s-scanner.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-scanner.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "k8s-scanner.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "k8s-scanner.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
AdminController Common labels
*/}}
{{- define "adminController.labels" -}}
helm.sh/chart: {{ include "k8s-scanner.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "k8s-scanner.name" . }}
{{ include "adminController.selectorLabels" . }}
{{- range $k, $v := (default (dict) .Values.extraLabels) }}
{{ $k }}: {{ quote $v }}
{{- end }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Admin Controller service account
*/}}
{{- define "adminController.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "adminController.fullname" .) .Values.serviceAccount.adminController.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.adminController.name }}
{{- end }}
{{- end }}

{{/*
Admin Controller Selector labels
*/}}
{{- define "adminController.selectorLabels" -}}
app.kubernetes.io/name: {{ include "adminController.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: emprovise-adminController
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "adminController.fullname" -}}
{{- if .Values.adminControllerFullnameOverride -}}
{{- .Values.adminControllerFullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.adminControllerFullnameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" "adminController" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else if contains .Release.Name $name -}}
{{- printf "%s-%s" "adminController" $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" "adminController" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "k8s.job.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
TLS configuration - TLS min version
*/}}
{{- define "tlsConfig.minTLSVersion" -}}
{{- if .minTLSVersion }}
{{- .minTLSVersion }}
{{- else }}
{{- "VersionTLS12" }}
{{- end }}
{{- end }}

{{/*
TLS configuration - TLS cipher suites
*/}}
{{- define "tlsConfig.cipherSuites" -}}
{{- if .cipherSuites }}
{{- join "," .cipherSuites }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Kube Bench Job Selector labels
*/}}
{{- define "kubeBenchJob.selectorLabels" -}}
app.kubernetes.io/name: kube-bench-job
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: emprovise-kube-bench-job
{{- end }}

{{/*
Create an image source.
*/}}
{{- define "image.source" -}}
{{- if and (not .registry) (not .imageDefaults.registry) -}}
{{- if .digest -}}
{{- printf "%s@%s" .repository .digest | quote -}}
{{- else -}}
{{- printf "%s:%s" .repository .tag | quote -}}
{{- end -}}
{{- else -}}
{{- if .digest -}}
{{- printf "%s/%s@%s" (default .imageDefaults.registry .registry) .repository .digest | quote -}}
{{- else -}}
{{- printf "%s/%s:%s" (default .imageDefaults.registry .registry) .repository .tag | quote -}}
{{- end -}}
{{- end -}}
{{- end -}}


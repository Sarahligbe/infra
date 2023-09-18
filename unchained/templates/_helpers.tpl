{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "unchained.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "unchained.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "unchained.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
StatefulSet labels
*/}}
{{- define "unchained.statefulsetLabels" }}
appName: {{ .Release.Name }}
assetName: {{ .Values.name }}
tier: statefulset
{{- end }}

{{/*
API labels
*/}}
{{- define "unchained.apiLabels" }}
appName: {{ .Release.Name }}
assetName: {{ .Values.name }}
tier: api
coinstack: {{ .Values.name }}
{{- end }}

{{/*
Default Template for API Service. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "unchained.apiservice" }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .Chart.Name }}-api-svc
  namespace: {{ .Chart.Name }}
  labels:
    {{- include "unchained.apiLabels" . | nindent 4 }}
spec:
  type: ClusterIP
  ports:
    - port: 3000
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "unchained.apiLabels" . | nindent 4 }}
{{- end }}

{{/*
Default Template for API HorizontalPodAutoscaler. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "unchained.apihpa" }}
{{- if eq .Values.api.autoscaling 'true' }}
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: {{ .Chart.Name }}-hpa
  namespace: {{ .Chart.Name }}
spec:
  minReplicas: 2
  maxReplicas: 6
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ .Chart.Name }}-{{ .Values.api.tier }}
    metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 75
{{- end }}
{{- end }}

{{/*
Default Template for StatefulSet Service. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "unchained.statefulsetsvc" }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .Chart.Name }}-svc
  namespace: {{ .Chart.Name }}
  labels:
    {{- include "unchained.statefulsetLabels" . | nindent 4 }}
spec:
  type: ClusterIP
  ports:
    {{- range .Values.statefulset.containers }}
    - port: {{ .port.containerPort }}
      targetPort: {{ .port.name }}
      protocol: TCP
      name: {{ .port.name }}
    {{- end }}
  selector:
    {{- include "unchained.statefulsetLabels" . | nindent 4 }}
{{- end }}

{{/*
Default Template for tendermint script. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "unchained.tendermint" }}
{{ $.Files.Get "files/tendermint.sh" }}
{{- end }}

{{/*
Default Template for evm script. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "unchained.evm" }}
{{ $.Files.Get "files/evm.sh" }}
{{- end }}

{{/*
Default Template for indexer-readiness script. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "unchained.indexerReadiness" }}
{{ $.Files.Get "files/indexer-readiness.sh" }}
{{- end }}
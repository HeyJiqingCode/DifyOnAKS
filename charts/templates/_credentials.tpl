{{- define "dify.api.credentials" -}}
# A secret key that is used for securely signing the session cookie and encrypting sensitive information on the database. You can generate a strong key using `openssl rand -base64 42`.
SECRET_KEY: {{ .Values.api.secretKey | b64enc | quote }}

# The code execution API key for the sandbox service.
{{- if .Values.sandbox.enabled }}
CODE_EXECUTION_API_KEY: {{ .Values.sandbox.auth.apiKey | b64enc | quote }}
{{- end }}
{{ include "dify.db.credentials" . }}
{{ include "dify.redis.credentials" . }}
{{ include "dify.celery.credentials" . }}
{{ include "dify.storage.credentials" . -}}
{{ include "dify.vectordb.credentials" . }}
{{ include "dify.mail.credentials" . }}

# The plugin daemon credentials.
{{- if .Values.pluginDaemon.enabled }}
PLUGIN_DAEMON_KEY: {{ .Values.pluginDaemon.auth.serverKey | b64enc | quote }}
INNER_API_KEY_FOR_PLUGIN: {{ .Values.pluginDaemon.auth.difyApiKey | b64enc | quote }}
{{- end }}

{{- if and .Values.api.otel.enabled (not .Values.externalSecret.enabled) }}
# The OTLP API key for OpenTelemetry.
OTLP_API_KEY: {{ .Values.api.otel.apiKey | b64enc | quote }}
{{- end }}
{{- end }}

{{- define "dify.worker.credentials" -}}
# A secret key that is used for securely signing the session cookie and encrypting sensitive information on the database. You can generate a strong key using `openssl rand -base64 42`.
SECRET_KEY: {{ .Values.api.secretKey | b64enc | quote }}
{{ include "dify.db.credentials" . }}
{{ include "dify.redis.credentials" . }}
{{ include "dify.celery.credentials" . -}}
{{ include "dify.storage.credentials" . }}
{{ include "dify.vectordb.credentials" . }}
{{ include "dify.mail.credentials" . }}

# The plugin daemon credentials.
{{- if .Values.pluginDaemon.enabled }}
PLUGIN_DAEMON_KEY: {{ .Values.pluginDaemon.auth.serverKey | b64enc | quote }}
INNER_API_KEY_FOR_PLUGIN: {{ .Values.pluginDaemon.auth.difyApiKey | b64enc | quote }}
{{- end }}

{{- if and .Values.api.otel.enabled (not .Values.externalSecret.enabled) }}
# The OTLP API key for OpenTelemetry.
OTLP_API_KEY: {{ .Values.api.otel.apiKey | b64enc | quote }}
{{- end }}
{{- end }}

{{- define "dify.web.credentials" -}}
{{- end }}

{{- define "dify.db.credentials" -}}
{{- if .Values.externalPostgres.enabled }}
# The external Postgres configurations.
DB_USERNAME: {{ .Values.externalPostgres.username | b64enc | quote }}
DB_PASSWORD: {{ .Values.externalPostgres.password | b64enc | quote }}

{{- else if .Values.postgresql.enabled }}
# The internal Postgres configurations.
  {{ with .Values.postgresql.global.postgresql.auth }}
  {{- if empty .username }}
DB_USERNAME: {{ print "postgres" | b64enc | quote }}
DB_PASSWORD: {{ .postgresPassword | b64enc | quote }}
  {{- else }}
DB_USERNAME: {{ .username | b64enc | quote }}
DB_PASSWORD: {{ .password | b64enc | quote }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "dify.storage.credentials" -}}
{{- if and .Values.externalS3.enabled (not .Values.externalSecret.enabled)}}
# The S3 compatible storage configurations, only available when STORAGE_TYPE is `s3`.
S3_ACCESS_KEY: {{ .Values.externalS3.accessKey | b64enc | quote }}
S3_SECRET_KEY: {{ .Values.externalS3.secretKey | b64enc | quote }}

{{- else if .Values.externalAzureBlobStorage.enabled }}
# The Azure Blob storage configurations, only available when STORAGE_TYPE is `azure-blob`.
AZURE_BLOB_ACCOUNT_KEY: {{ .Values.externalAzureBlobStorage.key | b64enc | quote }}

{{- else if .Values.externalOSS.enabled }}
# The Alibaba Cloud OSS configurations, only available when STORAGE_TYPE is `oss`.
ALIYUN_OSS_ACCESS_KEY: {{ .Values.externalOSS.accessKey | b64enc | quote }}
ALIYUN_OSS_SECRET_KEY: {{ .Values.externalOSS.secretKey | b64enc | quote }}

{{- else if .Values.externalGCS.enabled }}
# The Google Cloud Storage configurations, only available when STORAGE_TYPE is `gcs`.
GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64: {{ .Values.externalGCS.serviceAccountJsonBase64 | b64enc | quote }}

{{- else if .Values.externalCOS.enabled }}
# The Tencent Cloud COS configurations, only available when STORAGE_TYPE is `cos`.
TENCENT_COS_SECRET_KEY: {{ .Values.externalCOS.secretKey| b64enc | quote }}

{{- else if .Values.externalOBS.enabled }}
# The Huawei Cloud OBS configurations, only available when STORAGE_TYPE is `obs`.
HUAWEI_OBS_ACCESS_KEY: {{ .Values.externalOBS.accessKey | b64enc | quote }}
HUAWEI_OBS_SECRET_KEY: {{ .Values.externalOBS.secretKey | b64enc | quote }}

{{- else if .Values.externalTOS.enabled }}
# The Volcengine TOS configurations, only available when STORAGE_TYPE is `tos`.
VOLCENGINE_TOS_SECRET_KEY: {{ .Values.externalTOS.secretKey | b64enc | quote }}
{{- else }}
{{- end }}
{{- end }}

{{- define "dify.redis.credentials" -}}
{{- if .Values.externalRedis.enabled }}
# The external Redis configurations.
  {{- with .Values.externalRedis }}
REDIS_USERNAME: {{ .username | b64enc | quote }}
REDIS_PASSWORD: {{ .password | b64enc | quote }}
  {{- end }}
{{- else if .Values.redis.enabled }}
{{- $redisHost := printf "%s-redis-master" .Release.Name -}}
  {{- with .Values.redis }}
REDIS_USERNAME: {{ print "" | b64enc | quote }}
REDIS_PASSWORD: {{ .auth.password | b64enc | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "dify.celery.credentials" -}}
{{- if .Values.externalRedis.enabled }}
# Use redis as the broker, and redis db 1 for celery broker.
  {{- with .Values.externalRedis }}
    {{- $scheme := "redis" }}
    {{- if .useSSL }}
      {{- $scheme = "rediss" }}
    {{- end }}
CELERY_BROKER_URL: {{ printf "%s://%s:%s@%s:%v/1" $scheme .username .password .host .port | b64enc | quote }}
  {{- end }}
{{- else if .Values.redis.enabled }}
{{- $redisHost := printf "%s-redis-master" .Release.Name -}}
  {{- with .Values.redis }}
CELERY_BROKER_URL: {{ printf "redis://:%s@%s:%v/1" .auth.password $redisHost .master.service.ports.redis | b64enc | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "dify.vectordb.credentials" -}}
{{- if .Values.externalWeaviate.enabled }}
# the weaviate credentials
WEAVIATE_API_KEY: {{ .Values.externalWeaviate.apiKey | b64enc | quote }}

{{- else if .Values.externalQdrant.enabled }}
# the qdrant credentials
QDRANT_API_KEY: {{ .Values.externalQdrant.apiKey | b64enc | quote }}

{{- else if .Values.externalMilvus.enabled}}
# the milvus credentials
MILVUS_TOKEN: {{ .Values.externalMilvus.token | b64enc | quote }}
MILVUS_USER: {{ .Values.externalMilvus.user | b64enc | quote }}
MILVUS_PASSWORD: {{ .Values.externalMilvus.password | b64enc | quote }}

{{- else if .Values.externalPgvector.enabled}}
# The pgvector credentials
PGVECTOR_USER: {{ .Values.externalPgvector.username | b64enc | quote }}
PGVECTOR_PASSWORD: {{ .Values.externalPgvector.password | b64enc | quote }}

{{- else if .Values.externalTencentVectorDB.enabled}}
# The Tencent Vector Database credentials
TENCENT_VECTOR_DB_USERNAME: {{ .Values.externalTencentVectorDB.username | b64enc | quote }}
TENCENT_VECTOR_DB_API_KEY: {{ .Values.externalTencentVectorDB.apiKey | b64enc | quote }}

{{- else if .Values.externalMyScaleDB.enabled}}
# The MyScale (MySQL compatible) credentials
MYSCALE_USER: {{ .Values.externalMyScaleDB.username | b64enc | quote }}
MYSCALE_PASSWORD: {{ .Values.externalMyScaleDB.password | b64enc | quote }}

{{- else if .Values.externalTableStore.enabled}}
# The TableStore (Aliyun) credentials
TABLESTORE_ACCESS_KEY_ID: {{ .Values.externalTableStore.accessKeyId | b64enc | quote }}
TABLESTORE_ACCESS_KEY_SECRET: {{ .Values.externalTableStore.accessKeySecret | b64enc | quote }}

{{- else if .Values.externalElasticsearch.enabled}}
# The Elasticsearch credentials
ELASTICSEARCH_USERNAME: {{ .Values.externalElasticsearch.username | b64enc | quote }}
ELASTICSEARCH_PASSWORD: {{ .Values.externalElasticsearch.password | b64enc | quote }}

{{- else if .Values.weaviate.enabled }}
# The Weaviate credentials.
  {{- if .Values.weaviate.authentication.apikey }}
WEAVIATE_API_KEY: {{ first .Values.weaviate.authentication.apikey.allowed_keys | b64enc | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "dify.mail.credentials" -}}
{{- if eq .Values.api.mail.type "resend" }}
# Mail credentials for Resend
RESEND_API_KEY: {{ .Values.api.mail.resend.apiKey | b64enc | quote }}

{{- else if eq .Values.api.mail.type "smtp" }}
# Mail credentials for SMTP
SMTP_USERNAME: {{ .Values.api.mail.smtp.username | b64enc | quote }}
SMTP_PASSWORD: {{ .Values.api.mail.smtp.password | b64enc | quote }}
{{- end }}
{{- end }}

{{- define "dify.sandbox.credentials" -}}
# The code execution API key for the sandbox service.
API_KEY: {{ .Values.sandbox.auth.apiKey | b64enc | quote }}
{{- end }}

{{- define "dify.pluginDaemon.credentials" -}}
{{ include "dify.db.credentials" . }}
{{ include "dify.redis.credentials" . }}
{{ include "dify.pluginDaemon.storage.credentials" . }}
# The plugin daemon credentials.
SERVER_KEY: {{ .Values.pluginDaemon.auth.serverKey | b64enc | quote }}
DIFY_INNER_API_KEY: {{ .Values.pluginDaemon.auth.difyApiKey | b64enc | quote }}
{{- end }}

{{- define "dify.pluginDaemon.storage.credentials" -}}
{{- if and .Values.externalS3.enabled .Values.externalS3.bucketName.pluginDaemon }}
# The S3 compatible storage credentials for plugin daemon.
AWS_ACCESS_KEY: {{ .Values.externalS3.accessKey | b64enc | quote }}
AWS_SECRET_KEY: {{ .Values.externalS3.secretKey | b64enc | quote }}

{{- else if and .Values.externalOSS.enabled .Values.externalOSS.bucketName.pluginDaemon }}
# The Alibaba Cloud OSS credentials for plugin daemon.
ALIYUN_OSS_ACCESS_KEY_SECRET: {{ .Values.externalOSS.secretKey | b64enc | quote }}

{{- else if and .Values.externalGCS.enabled .Values.externalGCS.bucketName.pluginDaemon }}
# The Google Cloud Storage credentials for plugin daemon.
GCS_CREDENTIALS: {{ .Values.externalGCS.serviceAccountJsonBase64 | b64enc | quote }}

{{- else if and .Values.externalCOS.enabled .Values.externalCOS.bucketName.pluginDaemon }}
# The Tencent Cloud COS credentials for plugin daemon.
TENCENT_COS_SECRET_KEY: {{ .Values.externalCOS.secretKey | b64enc | quote }}

{{- else if and .Values.externalOBS.enabled .Values.externalOBS.bucketName.pluginDaemon }}
# The Huawei Cloud OBS credentials for plugin daemon.
HUAWEI_OBS_SECRET_KEY: {{ .Values.externalOBS.secretKey | b64enc | quote }}

{{- else if and .Values.externalTOS.enabled .Values.externalTOS.bucketName.pluginDaemon }}
# The Volcengine TOS credentials for plugin daemon.
PLUGIN_VOLCENGINE_TOS_SECRET_KEY: {{ .Values.externalTOS.secretKey | b64enc | quote }}
{{- end }}
{{- end }}
API_SECRET_KEY=$(openssl rand -base64 42)
RESEND_API_KEY=$(openssl rand -base64 42)
CODE_EXECUTION_API_KEY=$(openssl rand -base64 42)

kubectl create namespace dify

kubectl create secret tls certs-dify --cert=/root/tls.crt --key=/root/tls.key 


helm template demo ./DifyOnAKS/charts/ \
--set nodeSelector.agentpool=dify \
--set image.api.tag=latest \
--set image.web.tag=latest \
--set image.sandbox.tag=latest \
--set api.secretKey=$API_SECRET_KEY \
--set api.mail.resend.apiKey=$RESEND_API_KEY \
--set sandbox.auth.apiKey=$CODE_EXECUTION_API_KEY \
--set ingress.className='azure-application-gateway' \
--set ingress.tls[0].hosts[0]='<domain_name>' \
--set ingress.tls[0].secretName=certs-dify \
--set ingress.hosts[0].host='<domain_name>' \
--set ingress.hosts[0].paths[0].path='/' \
--set ingress.hosts[0].paths[0].pathType=Prefix \
--set externalRedis.host='<redis_host>' \
--set externalRedis.password='<access_key>' \
--set externalPostgres.username=postgres \
--set externalPostgres.password='<pg_password>' \
--set externalPostgres.address='<pg_host>' \
--set externalPostgres.dbName=dify \
--set externalPgvector.username=postgres \
--set externalPgvector.password='<pg_password>' \
--set externalPgvector.address='<pg_host>' \
--set externalPgvector.dbName=dify \
--set externalAzureBlobStorage.enabled=true \
--set externalAzureBlobStorage.url='https://<storage_account_name>.blob.core.windows.net' \
--set externalAzureBlobStorage.account='<storage_account_name>' \
--set externalAzureBlobStorage.key='<access_key>' \
--set externalAzureBlobStorage.container=dify 

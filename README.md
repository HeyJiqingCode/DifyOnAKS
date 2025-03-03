
## Architecture
<img width="1074" alt="Xnip2025-03-03_21-32-36" src="https://github.com/user-attachments/assets/0a30a93e-f130-4171-b163-541e6c885cd3" />


## Step-by-Step

1) Create Application Gateway (backend pool without targets) ;
2) Create AKS cluster with ingress-appgw addons enabled ;
3) Create Azure Cache for Redis 
    - Enable access keys authentication and non-ssl ;
    - Disable public access and create private endpoint ;
4) Create Azure Database for PostgreSQL / Azure Cosmos DB for PostgreSQL
    - Install extension vector and uuid-ossp ;
    - Disable public access and create private endpoint ;
5) Create Azure Storage Account / Container and disable public access and create private endpoint 

6) Generate Keys
```
API_SECRET_KEY=$(openssl rand -base64 42)
RESEND_API_KEY=$(openssl rand -base64 42)
CODE_EXECUTION_API_KEY=$(openssl rand -base64 42)
INNER_API_KEY=$(openssl rand -base64 42)
```

7) Create Namespace&Secret
```
kubectl create namespace dify
kubectl create secret tls certs-dify --cert=/root/tls.crt --key=/root/tls.key 
```

8) Helm Install Dify
```
helm install demo ./DifyOnAKS/charts/ \
--set nodeSelector.agentpool=dify \
--set image.api.tag=latest \
--set image.web.tag=latest \
--set image.sandbox.tag=latest \
--set api.secretKey=$API_SECRET_KEY \
--set api.mail.resend.apiKey=$RESEND_API_KEY \
--set sandbox.auth.apiKey=$CODE_EXECUTION_API_KEY \
--set pluginDaemon.auth.apiKey=$DAEMON_API_KEY \
--set pluginDaemon.auth.innerApiKey=$INNER_API_KEY \
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
--set externalPgvector.dbName=dify
```

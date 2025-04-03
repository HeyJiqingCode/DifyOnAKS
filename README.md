## DifyOnAKS
Deploy [langgenius/dify](https://github.com/langgenius/dify) on AKS(Azure Kubernetes Services) with helm chart.

## Default Values
<table>
    <tr>
        <td style="font-weight:bold" colspan="2">Items</td>
        <td style="font-weight:bold">Default Values</td>
    </tr>
    <tr>
        <td rowspan="2">api</td>
        <td>enabled</td>
        <td>true</td>
    </tr>
    <tr>
        <td>persistence.persistentVolumeClaim.storageClass</td>
        <td>default</td>
    </tr>
    <tr>
        <td rowspan="2">worker</td>
        <td>enabled</td>
        <td>true</td>
    </tr>
    <tr>
        <td>persistence.persistentVolumeClaim.storageClass</td>
        <td>default</td>
    </tr>
    <tr>
        <td rowspan="2">proxy</td>
        <td>enabled</td>
        <td>true</td>
    </tr>
    <tr>
        <td>log.persistence.enabled</td>
        <td>false</td>
    </tr>
    <tr>
        <td>web</td>
        <td>enabled</td>
        <td>true</td>
    </tr>
    <tr>
        <td>sandbox</td>
        <td>enabled</td>
        <td>true</td>
    </tr>
    <tr>
        <td rowspan="2">pluginDaemon</td>
        <td>enabled</td>
        <td>true</td>
    </tr>
    <tr>
        <td>persistence.persistentVolumeClaim.storageClass</td>
        <td>default</td>
    </tr>
    <tr>
        <td>postgresql</td>
        <td>enabled</td>
        <td>false</td>
    </tr>
    <tr>
        <td>redis</td>
        <td>enabled</td>
        <td>false</td>
    </tr>
    <tr>
        <td>weaviate</td>
        <td>enabled</td>
        <td>false</td>
    </tr>
    <tr>
        <td>externalPostgres</td>
        <td>enabled</td>
        <td>true</td>
    </tr>
    <tr>
        <td>externalPgvector</td>
        <td>enabled</td>
        <td>true</td>
    </tr>
    <tr>
        <td>externalRedis</td>
        <td>enabled</td>
        <td>true</td>
    </tr>
</table>

## Architecture

1）Dify components running with docker-compose, and the azure services used to host them.
![image](https://github.com/user-attachments/assets/84a3edd0-6475-4c34-918a-79a72d605a68)


2）From the perspective of azure service, the deployment architecture of dify.
![image](https://github.com/user-attachments/assets/c5e28365-54f1-46f3-ad65-8f7c9bc1bf11)

## Step-by-Step

1) Create AKS cluster with app-routing addons enabled ;
2) Create Azure Cache for Redis 
    - Enable access keys authentication and non-ssl ;
    - Disable public access and create private endpoint ;
3) Create Azure Database for PostgreSQL / Azure Cosmos DB for PostgreSQL
    - Install extension vector and uuid-ossp ;
    - Disable public access and create private endpoint ;

4) Generate Keys
```
API_SECRET_KEY=$(openssl rand -base64 42)
RESEND_API_KEY=$(openssl rand -base64 42)
CODE_EXECUTION_API_KEY=$(openssl rand -base64 42)
DAEMON_SERVER_KEY=$(openssl rand -base64 42)
INNER_DIFY_KEY=$(openssl rand -base64 42)
```

5) Create Namespace&Secret
```
kubectl create namespace dify
```

6) Helm Install Dify
```
helm install <app_name> ./DifyOnAKS/charts/ \
--set image.api.tag=1.1.3 \
--set image.web.tag=1.1.3 \
--set image.sandbox.tag=0.2.11 \
--set image.pluginDaemon.tag=0.0.6-local \
--set api.secretKey=$API_SECRET_KEY \
--set api.mail.resend.apiKey=$RESEND_API_KEY \
--set sandbox.auth.apiKey=$CODE_EXECUTION_API_KEY \
--set pluginDaemon.auth.serverKey=$DAEMON_SERVER_KEY \
--set pluginDaemon.auth.difyApiKey=$INNER_DIFY_KEY \
--set externalRedis.host='<redis_host>' \
--set externalRedis.password='<access_key>' \
--set externalPostgres.username=postgres \
--set externalPostgres.password='<pg_password>' \
--set externalPostgres.address='<pg_host>' \
--set externalPostgres.database.api=dify \
--set externalPostgres.database.pluginDaemon=dify_plugin \
--set externalPgvector.username=postgres \
--set externalPgvector.password='<pg_password>' \
--set externalPgvector.address='<pg_host>' \
--set externalPgvector.dbName=dify
```

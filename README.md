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
<img width="1055" alt="image" src="https://github.com/user-attachments/assets/7ee26d97-59e4-4db8-9cc8-150e8ad87ae1" />


2）From the perspective of azure service, the deployment architecture of dify.
<img width="1072" alt="image" src="https://github.com/user-attachments/assets/2d23ba1c-278a-478c-80ef-1ef27bb32994" />


## Step-by-Step

1) Create AKS cluster with app-routing addon enabled ;
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
```

5) Generate Yaml
```
helm template demo ./DifyOnAKS/charts/ \
--set image.api.tag=0.15.5 \
--set image.web.tag=0.15.5 \
--set image.sandbox.tag=0.2.11 \
--set api.secretKey=$API_SECRET_KEY \
--set api.mail.resend.apiKey=$RESEND_API_KEY \
--set sandbox.auth.apiKey=$CODE_EXECUTION_API_KEY \
--set externalRedis.host='<redis_host>' \
--set externalRedis.password='<access_key>' \
--set externalPostgres.username=postgres \
--set externalPostgres.password='<pg_password>' \
--set externalPostgres.address='<pg_host>' \
--set externalPostgres.database.api=dify \
--set externalPgvector.username=postgres \
--set externalPgvector.password='<pg_password>' \
--set externalPgvector.address='<pg_host>' \
--set externalPgvector.dbName=dify > dify-0.15.5.yaml
```

6) Create Namespace & Deploy Dify
```
kubectl create namespace dify
kubectl create -f dify-0.15.5.yaml -n dify
```
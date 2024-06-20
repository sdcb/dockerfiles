param (
    [string]$imageName,
    [string]$aliyunRegistry,
    [string]$dockerNamespace,
    [string]$dockerUsername,
    [string]$runId
)

$date = Get-Date -Format "yyyyMMdd"

# Tag for Alibaba Cloud
docker tag $imageName $aliyunRegistry/$dockerNamespace/$imageName
docker tag $imageName $aliyunRegistry/$dockerNamespace/$imageName-$date
docker tag $imageName $aliyunRegistry/$dockerNamespace/$imageName-r-$runId

# Tag for Docker Hub
docker tag $imageName $dockerUsername/$imageName
docker tag $imageName $dockerUsername/$imageName-$date
docker tag $imageName $dockerUsername/$imageName-r-$runId

# Push to Alibaba Cloud
docker push $aliyunRegistry/$dockerNamespace/$imageName
docker push $aliyunRegistry/$dockerNamespace/$imageName-$date
docker push $aliyunRegistry/$dockerNamespace/$imageName-r-$runId

# Push to Docker Hub
docker push $dockerUsername/$imageName
docker push $dockerUsername/$imageName-$date
docker push $dockerUsername/$imageName-r-$runId
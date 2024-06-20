function Login-DockerRegistries {
    param(
        [string]$aliyunUsername,
        [string]$aliyunPassword,
        [string]$aliyunRegistry,
        [string]$dockerUsername,
        [string]$dockerPassword
    )

    # Login to Alibaba Cloud Container Registry
    echo $aliyunPassword | docker login -u $aliyunUsername $aliyunRegistry --password-stdin

    # Login to Docker Hub
    echo $dockerPassword | docker login -u $dockerUsername --password-stdin
}

function TagAndPushDockerImages {
    param(
        [string]$imageName,
        [string]$aliyunRegistry,
        [string]$aliyunNamespace,
        [string]$dockerUsername,
        [int]$runId
    )

    $date = Get-Date -Format "yyyyMMdd"

    # Tagging for Alibaba Cloud
    docker tag $imageName:latest $aliyunRegistry/$aliyunNamespace/$imageName:latest
    docker tag $imageName:latest $aliyunRegistry/$aliyunNamespace/$imageName:$date
    docker tag $imageName:latest $aliyunRegistry/$aliyunNamespace/$imageName-r-$runId

    # Tagging for Docker Hub
    docker tag $imageName:latest $dockerUsername/$imageName:latest
    docker tag $imageName:latest $dockerUsername/$imageName:$date
    docker tag $imageName:latest $dockerUsername/$imageName-r-$runId

    # Pushing to Alibaba Cloud
    docker push $aliyunRegistry/$aliyunNamespace/$imageName:latest
    docker push $aliyunRegistry/$aliyunNamespace/$imageName:$date
    docker push $aliyunRegistry/$aliyunNamespace/$imageName-r-$runId

    # Pushing to Docker Hub
    docker push $dockerUsername/$imageName:latest
    docker push $dockerUsername/$imageName:$date
    docker push $dockerUsername/$imageName-r-$runId
}
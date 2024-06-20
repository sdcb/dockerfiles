function Login-DockerRegistries {
    param(
        [string]$aliyunUsername,
        [string]$aliyunPassword,
        [string]$aliyunRegistry,
        [string]$dockerUsername,
        [string]$dockerPassword
    )

    # Login to Alibaba Cloud Container Registry
    Write-Output $aliyunPassword | docker login -u $aliyunUsername $aliyunRegistry --password-stdin

    # Login to Docker Hub
    Write-Output $dockerPassword | docker login -u $dockerUsername --password-stdin
}

function TagAndPushDockerImages {
    param(
        [string]$imageName,
        [string]$aliyunRegistry,
        [string]$aliyunNamespace,
        [string]$dockerUsername,
        [int]$runId
    )

    Write-Output "Registry: $aliyunRegistry, Namespace: $aliyunNamespace, Docker Username: $dockerUsername"

    $date = Get-Date -Format "yyyyMMdd"

    # Tagging for Alibaba Cloud
    docker tag $imageName "${aliyunRegistry}/${aliyunNamespace}/${imageName}"
    docker tag $imageName "${aliyunRegistry}/${aliyunNamespace}/${imageName}:$date"
    docker tag $imageName "${aliyunRegistry}/${aliyunNamespace}/${imageName}:r-$runId"

    # Tagging for Docker Hub
    docker tag $imageName "${dockerUsername}/${imageName}"
    docker tag $imageName "${dockerUsername}/${imageName}:$date"
    docker tag $imageName "${dockerUsername}/${imageName}:r-$runId"

    # Script block for pushing to Alibaba Cloud
    $aliyunPush = {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        docker push "${aliyunRegistry}/${aliyunNamespace}/${imageName}"
        docker push "${aliyunRegistry}/${aliyunNamespace}/${imageName}:$date"
        docker push "${aliyunRegistry}/${aliyunNamespace}/${imageName}:r-$runId"
        Write-Output "Time taken to push to Alibaba Cloud: $($sw.Elapsed.TotalSeconds) seconds"
    }

    # Script block for pushing to Docker Hub
    $dockerHubPush = {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        docker push "${dockerUsername}/${imageName}"
        docker push "${dockerUsername}/${imageName}:$date"
        docker push "${dockerUsername}/${imageName}:r-$runId"
        Write-Output "Time taken to push to Docker Hub: $($sw.Elapsed.TotalSeconds) seconds"
    }

    # Start jobs for Alibaba Cloud and Docker Hub
    Write-Output "Pushing to Alibaba Cloud..."
    $jobAliyun = Start-Job -ScriptBlock $aliyunPush
    $jobDockerHub = Start-Job -ScriptBlock $dockerHubPush

    # Wait for all jobs to complete
    Write-Output "Pushing to Docker Hub..."
    Wait-Job $jobAliyun, $jobDockerHub

    # Output results and clean up jobs
    Receive-Job $jobAliyun
    Receive-Job $jobDockerHub
    Remove-Job $jobAliyun
    Remove-Job $jobDockerHub
}
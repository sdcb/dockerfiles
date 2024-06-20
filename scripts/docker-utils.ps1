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
        [string]$githubRepository,
        [string]$aliyunRegistry,
        [string]$aliyunNamespace,
        [string]$dockerUsername,
        [int]$runId
    )

    $date = Get-Date -Format "yyyyMMdd"

    # Tagging for Alibaba Cloud
    docker tag $imageName "${aliyunRegistry}/${aliyunNamespace}/${imageName}"
    docker tag $imageName "${aliyunRegistry}/${aliyunNamespace}/${imageName}:$date"
    docker tag $imageName "${aliyunRegistry}/${aliyunNamespace}/${imageName}:r-$runId"

    # Tagging for Docker Hub
    docker tag $imageName "${dockerUsername}/${imageName}"
    docker tag $imageName "${dockerUsername}/${imageName}:$date"
    docker tag $imageName "${dockerUsername}/${imageName}:r-$runId"

    # Script block for pushing to ghcr.io
    $githubPush = {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        docker push "ghcr.io/${using:githubRepository}/${using:imageName}:r-${using:runId}"
        docker push "ghcr.io/${using:githubRepository}/${using:imageName}:${using:date}"
        docker push "ghcr.io/${using:githubRepository}/${using:imageName}"
        $sw.Stop()
        Write-Output "Time taken to push to GitHub Container Registry: $($sw.Elapsed.TotalSeconds) seconds"
    }

    # Script block for pushing to Alibaba Cloud
    $aliyunPush = {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        docker push "${using:aliyunRegistry}/${using:aliyunNamespace}/${using:imageName}:r-${using:runId}"
        docker push "${using:aliyunRegistry}/${using:aliyunNamespace}/${using:imageName}:${using:date}"
        docker push "${using:aliyunRegistry}/${using:aliyunNamespace}/${using:imageName}"
        $sw.Stop()
        Write-Output "Time taken to push to Alibaba Cloud: $($sw.Elapsed.TotalSeconds) seconds"
    }

    # Script block for pushing to Docker Hub
    $dockerHubPush = {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        docker push "${using:dockerUsername}/${using:imageName}:r-${using:runId}"
        docker push "${using:dockerUsername}/${using:imageName}:${using:date}"
        docker push "${using:dockerUsername}/${using:imageName}"
        $sw.Stop()
        Write-Output "Time taken to push to Docker Hub: $($sw.Elapsed.TotalSeconds) seconds"
    }

    $selectedPushes = @($githubPush, $dockerHubPush) # removed $aliyunPush because too slow
    Write-Output "Pushing to Registries..."

    # Parallel execution of push operations
    $jobs = @()
    foreach ($push in $selectedPushes) {
        $jobs += Start-Job -ScriptBlock $push
    }

    # Wait for all jobs to complete and stream their output
    $jobs | ForEach-Object {
        # Continuously check job status and fetch output
        while ($_.State -eq 'Running') {
            # Receive available output without removing it from the job
            $_ | Receive-Job -Keep
            Start-Sleep -Seconds 1
        }
    
        # Receive any remaining output once the job is completed
        $_ | Receive-Job
        Remove-Job $_
    }

    Write-Output "All pushes completed."
}
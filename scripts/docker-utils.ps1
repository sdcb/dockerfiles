function Login-DockerRegistries {
    param(
        [string]$dockerUsername,
        [string]$dockerToken,
        [string]$githubOwner,
        [string]$githubToken
    )

    # Login to GitHub Container Registry
    Write-Output $githubToken | docker login ghcr.io -u $githubOwner --password-stdin

    # Login to Docker Hub
    Write-Output $dockerToken | docker login -u $dockerUsername --password-stdin
}

function TagAndPushDockerImages {
    param(
        [string]$imageName,
        [string]$githubRepository,
        [string]$dockerUsername,
        [int]$runId
    )

    $date = Get-Date -Format "yyyyMMdd"

    # Tagging for GitHub Container Registry
    docker tag $imageName "ghcr.io/${githubRepository}/${imageName}:r-$runId"
    docker tag $imageName "ghcr.io/${githubRepository}/${imageName}:$date"
    docker tag $imageName "ghcr.io/${githubRepository}/${imageName}"

    # Tagging for Docker Hub
    docker tag $imageName "${dockerUsername}/${imageName}:r-$runId"
    docker tag $imageName "${dockerUsername}/${imageName}:$date"
    docker tag $imageName "${dockerUsername}/${imageName}"

    # pushing to Docker Hub
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    docker push "${dockerUsername}/${imageName}:r-${runId}"
    docker push "${dockerUsername}/${imageName}:${date}"
    docker push "${dockerUsername}/${imageName}"
    $sw.Stop()
    Write-Output "Time taken to push to Docker Hub: $($sw.Elapsed.TotalSeconds) seconds"

    # pushing to ghcr.io
    Write-Host "Pushing to GitHub Container Registry..."
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    docker push "ghcr.io/${githubRepository}/${imageName}:r-${runId}"
    docker push "ghcr.io/${githubRepository}/${imageName}:${date}"
    docker push "ghcr.io/${githubRepository}/${imageName}"
    $sw.Stop()
    Write-Output "Time taken to push to GitHub Container Registry: $($sw.Elapsed.TotalSeconds) seconds"

    Write-Output "All pushes completed."
}
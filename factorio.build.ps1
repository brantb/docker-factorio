param(
    [Parameter(Mandatory)]
    [string]$Version,

    [Parameter()]
    [string]$Image = "iqsandbox.azurecr.io/factorio"
)
$tag = "$($Image):$($Version)"
[uri]$downloadUri = "https://www.factorio.com/get-download/$Version/headless/linux64"
$destination = Join-Path $BuildRoot "factorio_headless_x64_$Version.tar.xz"

# Synopsis: Downloads the headless build
task Download -If (-not (Test-Path $destination)) {
    Invoke-WebRequest -Uri $downloadUri -OutFile $destination -ErrorAction Stop
} 

# Synopsis: Build container image
task Build Download, {
    exec { docker build --build-arg factorio_version=$Version -t $tag $BuildRoot }
}

# Synopsis: Launch the server to ensure it works
task Test Build, {
    exec { docker run --rm -it $tag }
}

# Synopsis: Pushes container image
task Push Build, {
    exec { docker push $tag }
}

# Synopsis: Poll until the specified headless build shows up on factorio.com
task WaitForBuild {
    $tries = 1
    while (-not (Test-Path $Destination)) {
        try {
            Write-Host "Attempt #$tries"
            Invoke-WebRequest -Uri $downloadUri -OutFile $destination -ErrorAction SilentlyContinue
        } catch { 
            # .. 'em all
            $tries++
            Start-Sleep -Seconds 60
        }
    }
}
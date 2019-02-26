param(
    [Parameter(Mandatory)]
    [string]$Version
)
$tag = "iqsandbox.azurecr.io/factorio:$Version"
[uri]$downloadUri = "https://www.factorio.com/get-download/$Version/headless/linux64"
$destination = Join-Path $BuildRoot "factorio_headless_x64_$Version.tar.xz"

task Download -If (-not (Test-Path $destination)) {
    Invoke-WebRequest -Uri $downloadUri -OutFile $destination -ErrorAction Stop
} 

task Build Download, {
    exec {docker build --build-arg factorio_version=$Version -t $tag .}
}

task Test Build, {
    exec { docker run --rm -it $tag }
}

task Push Build, {
    exec { docker push $tag }
}
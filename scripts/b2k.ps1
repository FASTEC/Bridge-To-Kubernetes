# B2K.ps1 - PowerShell script to replicate the functionality of b2k.sh for Windows
if (-not $UUID) {
    $UUID = [guid]::NewGuid().ToString().ToLower()
}

$SVC = $env:SVC
if (-not $SVC) {
    $SVC = Read-Host -Prompt 'Service'
}

$ROUTING = "$SVC-$UUID"

$NS = $env:NS
if (-not $NS) {
    $NS = Read-Host -Prompt 'Namespace'
}

$PORT = $env:PORT
if (-not $PORT) {
    $PORT = Read-Host -Prompt 'Local Port(s) (space separated for multiple)'
}

$LOCAL_PORTS = @()
foreach ($i in $PORT.Split(" ")) {
    $LOCAL_PORTS += "--local-port", $i
}

Write-Output "Connecting service $SVC in namespace $NS to ports $PORT with routing $ROUTING"

dsc.exe connect `
    --service $SVC `
    --routing $ROUTING `
    --namespace $NS `
    $LOCAL_PORTS `
    --use-kubernetes-service-environment-variables

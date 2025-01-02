param(
    [Parameter(Mandatory=$true)]
    [string]$Version
)

# Define installation directory
$installDir = "$env:LOCALAPPDATA\Bridge-To-Kubernetes"
$zipUrl = "https://github.com/go1com/Bridge-To-Kubernetes/releases/download/${Version}/win-x64.zip"
$zipFile = Join-Path $env:TEMP "bridge-to-k8s.zip"

# Create installation directory if it doesn't exist
if (!(Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force
}

try {
    # Download the zip file
    Write-Host "Downloading Bridge-To-Kubernetes from $zipUrl..."
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile

    # Clean previous installation
    Write-Host "Cleaning previous installation in $installDir..."
    Get-ChildItem -Path $installDir -Recurse | Remove-Item -Force -Recurse

    # Extract the zip file
    Write-Host "Extracting files to $installDir..."
    Expand-Archive -Path $zipFile -DestinationPath $installDir -Force

    # Download b2k.ps1
    $b2kUrl = "https://raw.githubusercontent.com/go1com/Bridge-To-Kubernetes/main/scripts/b2k.ps1"
    $b2kPath = Join-Path $installDir "b2k.ps1"
    Write-Host "Downloading b2k.ps1..."
    Invoke-WebRequest -Uri $b2kUrl -OutFile $b2kPath

    # Create b2k.cmd wrapper for easier execution
    $b2kCmd = Join-Path $installDir "b2k.cmd"
    @"
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0b2k.ps1" %*
"@ | Out-File -FilePath $b2kCmd -Encoding ASCII

    # Add to PATH if not already present
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$installDir*") {
        Write-Host "Adding to User PATH..."
        [Environment]::SetEnvironmentVariable(
            "Path",
            "$userPath;$installDir",
            "User"
        )
        $env:Path = "$env:Path;$installDir"
    }

    Write-Host "Installation completed successfully!"
    Write-Host "Please restart your terminal to use 'dsc.exe' or 'b2k'"
}
catch {
    Write-Error "Installation failed: $_"
    exit 1
}
finally {
    # Cleanup
    if (Test-Path $zipFile) {
        Remove-Item $zipFile -Force
    }
}
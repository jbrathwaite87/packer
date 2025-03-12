# Set strict error handling
$ErrorActionPreference = "Stop"

# Function to download and install Appx packages
Function Install-AppxPackage {
    param ([string]$url, [string]$fileName)

    $tempPath = "C:\Windows\Temp\$fileName"

    Write-Host "📥 Downloading $fileName to $tempPath..."
    Invoke-WebRequest -Uri $url -OutFile $tempPath -UseBasicParsing
    
    # Verify download succeeded
    if (!(Test-Path $tempPath)) {
        Write-Host "❌ Failed to download $fileName. Exiting!"
        exit 1
    }
}

# Ensure WinGet is installed
Write-Output "🛠 Checking if WinGet is installed..."
$winGetPath = (Get-Command winget -ErrorAction SilentlyContinue).Source

if (-not $winGetPath) {
    Write-Host "🚨 WinGet not found! Installing dependencies..."
    
    # Install WinGet
    $releases_url = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri $releases_url
    $latestRelease = $releases.assets | Where-Object { $_.browser_download_url -match 'msixbundle' } | Select-Object -First 1
    Install-AppxPackage -url $latestRelease.browser_download_url -fileName "WinGet.msixbundle"

    # Wait for WinGet to be available
    $attempts = 0
    do {
        Start-Sleep -Seconds 5
        $winGetPath = (Get-Command winget -ErrorAction SilentlyContinue).Source
        $attempts++
    } while (-not $winGetPath -and $attempts -lt 10)

    if (-not $winGetPath) {
        Write-Host "❌ WinGet installation failed!"
        exit 1
    }
} else {
    Write-Host "✅ WinGet is already installed."
}

# Ensure WinGet is available in PATH
$env:Path += ";C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe"

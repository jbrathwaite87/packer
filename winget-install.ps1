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
} # ✅ Closing function brace added here

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

# Ensure WinGet is available in PATH (Fixing missing string terminator issue)
$env:Path += ";\"C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\""

# Remove Unwanted Applications
Write-Output "Removing Unwanted Apps..."
$unwantedApps = @("*3DPrint*", "Microsoft.MixedReality.Portal")
Foreach ($app in $unwantedApps) {
    Write-Host "🗑️ Uninstalling: $app"
    Get-AppxPackage -allusers $app | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# Ensure WSL is installed before running install
Write-Output "🐧 Checking WSL..."
$wslInstalled = wsl --status 2>$null
if (!$wslInstalled) {
    Write-Host "🔧 Installing WSL..."
    wsl --install
} else {
    Write-Host "✅ WSL is already installed."
}

# Install MATLAB and required toolboxes
Write-Output "📥 Downloading MATLAB Package Manager (MPM)..."
$mpmPath = "C:\Windows\Temp\mpm.exe"
Invoke-WebRequest -Uri "https://www.mathworks.com/mpm/win64/mpm" -OutFile $mpmPath -UseBasicParsing

if (!(Test-Path $mpmPath)) {
    Write-Host "❌ Failed to download MATLAB Package Manager. Exiting!"
    exit 1
}

Write-Output "⚙️ Installing MATLAB and toolboxes..."
Start-Process -FilePath $mpmPath -ArgumentList "install --release=R2024B --products=MATLAB Global_Optimization_Toolbox Optimization_Toolbox Parallel_Computing_Toolbox Symbolic_Math_Toolbox" -NoNewWindow -Wait

Write-Output "🎉 MATLAB installation completed!"

Write-Output "🎉 All installations and configurations are complete!"

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

    Write-Host "📦 Installing $fileName..."
    Add-AppxPackage -Path $tempPath
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

# Ensure settings directory exists before writing settings
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState"
if (!(Test-Path $settingsPath)) {
    Write-Host "📂 Creating missing settings directory..."
    New-Item -ItemType Directory -Path $settingsPath -Force
}

# Configure WinGet settings
Write-Output "⚙️ Configuring WinGet..."
$settingsFile = "$settingsPath\settings.json"
$settingsJson = @"
{
    "experimentalFeatures": {
        "experimentalMSStore": true
    }
}
"@
$settingsJson | Out-File $settingsFile -Encoding utf8 -Force

# Install applications using WinGet
Write-Output "🚀 Installing Applications..."
$apps = @(
    @{name = "Microsoft.AzureCLI" }, 
    @{name = "Microsoft.PowerShell" }, 
    @{name = "Microsoft.VisualStudioCode" }, 
    @{name = "Microsoft.WindowsTerminal"; source = "msstore" }, 
    @{name = "AgileBits.1Password" }, 
    @{name = "AgileBits.1Password.CLI" }, 
    @{name = "Git.Git" }, 
    @{name = "Docker.DockerDesktop" },
    @{name = "ScootersSoftware.BeyondCompare.4" },
    @{name = "Microsoft.DotNet.SDK.6"  },
    @{name = "GitHub.cli" },
    @{name = "Canonical.Ubuntu.2204" },
    @{name = "GitHub.GitHubDesktop" },
    @{name = "Python.Python.3.10" },
    @{name = "Node.js" },
    @{name = "Microsoft.VisualStudio.2022.Professional" }
)

Foreach ($app in $apps) {
    try {
        # Check if the app is already installed
        $listApp = winget list --exact -q $app.name --accept-source-agreements 2>$null
        if ($null -eq $listApp -or -not $listApp -or ![String]::Join("", $listApp).Contains($app.name)) {
            Write-Host "📦 Installing: $($app.name)"
            if ($app.source -ne $null) {
                winget install --exact --silent $app.name --source $app.source --accept-package-agreements --accept-source-agreements
            } else {
                winget install --exact --silent $app.name --accept-package-agreements --accept-source-agreements
            }
        } else {
            Write-Host "✅ Skipping install of $($app.name) (already installed)"
        }
    } catch {
        Write-Host "❌ Error installing $($app.name): $_"
    }
}

# Remove Unwanted Applications
Write-Output "🧹 Removing Unwanted Apps..."
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

Write-Output "🎉 All installations and configurations are complete!"

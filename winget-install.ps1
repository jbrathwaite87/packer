# Set strict error handling
$ErrorActionPreference = "Stop"

# Remove Unwanted Applications
Write-Output "Removing Unwanted Apps..."
$unwantedApps = @("*3DPrint*", "Microsoft.MixedReality.Portal")
Foreach ($app in $unwantedApps) {
    Write-Host "Uninstalling: $app"
    Get-AppxPackage -allusers $app | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# Install MATLAB and required toolboxes
Write-Output "Downloading MATLAB Package Manager (MPM)..."
$mpmPath = "C:\Windows\Temp\mpm.exe"
Invoke-WebRequest -Uri "https://www.mathworks.com/mpm/win64/mpm" -OutFile $mpmPath -UseBasicParsing

if (!(Test-Path $mpmPath)) {
    Write-Host "Failed to download MATLAB Package Manager. Exiting!"
    exit 1
}

Write-Output "Installing MATLAB and toolboxes..."
Start-Process -FilePath $mpmPath -ArgumentList "install --release=R2024B --products=MATLAB Global_Optimization_Toolbox Optimization_Toolbox Parallel_Computing_Toolbox Symbolic_Math_Toolbox" -NoNewWindow -Wait

Write-Output "MATLAB installation completed!"

# Install Putty
Write-Output "Downloading Putty..."
Invoke-WebRequest -Uri "https://the.earth.li/~sgtatham/putty/0.74/w64/putty-64bit-0.74-installer.msi" -OutFile "C:\Windows\Temp\putty-installer.msi"

Write-Output "Installing Putty..."
$putty = Start-Process msiexec.exe -ArgumentList "/i","C:\Windows\Temp\putty-installer.msi","/passive" -NoNewWindow -Wait -PassThru
if ($putty.ExitCode -ne 0) {
    Write-Error "Error installing Putty"
    exit 1
}

# Install Visual Studio Code
Write-Output "Downloading Visual Studio Code..."
$vscodeUrl = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"
$destination = "C:\Windows\Temp\VSCodeSetup.exe"

Invoke-WebRequest -Uri $vscodeUrl -OutFile $destination

Write-Output "Installing Visual Studio Code..."
$vscode = Start-Process -FilePath $destination -ArgumentList "/SILENT","/NORESTART","/MERGETASKS=!runcode" -NoNewWindow -Wait -PassThru
if ($vscode.ExitCode -ne 0) {
    Write-Error "Error installing VSCode"
    exit 1
}

# Install VS Code Extensions
$vscode_extensions = @("ms-vscode-remote.remote-ssh")
foreach ($vse in $vscode_extensions) {
    Write-Host "Installing VSCode extension $vse"
    $vscodeext = Start-Process "C:\Program Files\Microsoft VS Code\bin\code.cmd" -ArgumentList "--install-extension",$vse,"--force" -NoNewWindow -Wait -PassThru
    if ($vscodeext.ExitCode -ne 0) {
        Write-Error "Error installing VSCode extension"
        exit 1
    }
}

# Enable Developer Mode
Function Enable-DevMode {
    Write-Host "Enabling Developer Mode..."
    $RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not (Test-Path -Path $RegistryKeyPath)) {
        New-Item -Path $RegistryKeyPath -ItemType Directory -Force
    }
    New-ItemProperty -Path $RegistryKeyPath -Name AllowDevelopmentWithoutDevLicense -PropertyType DWORD -Value 1 -Force

    # Enable Windows Subsystem for Linux
    Write-Host "Enabling Windows Subsystem for Linux..."
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux
}

# Install Chocolatey & Developer Tools
Function Install-DevTools {
    Write-Host "Installing Chocolatey..."
    Invoke-WebRequest https://community.chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

    Write-Host "Installing Developer Tools via Chocolatey..."
    choco install powershell-packagemanagement -y
    choco install git.install -y
    choco install beyondcompare -y
    choco install nodejs.install -y
    choco install nuget.commandline -y
    choco install visualstudio2022professional -y

    Write-Host "Developer tools installation completed."
}

# Call the functions to enable developer mode and install developer tools
Enable-DevMode
Install-DevTools

Write-Output "All installations and configurations are complete!"

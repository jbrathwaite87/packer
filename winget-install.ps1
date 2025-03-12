# Set strict error handling
$ErrorActionPreference = "Stop"

# Remove Unwanted Applications
Write-Output "Removing Unwanted Apps..."
$unwantedApps = @("*3DPrint*", "Microsoft.MixedReality.Portal")
Foreach ($app in $unwantedApps) {
    Write-Host "Uninstalling: $app"
    Get-AppxPackage -allusers $app | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# Ensure WSL is installed before running install
# Ensure WSL is installed before running install
Write-Output "Checking WSL..."
try {
    $wslStatus = wsl --status 2>$null
    Write-Output "WSL is already installed."
} catch {
    Write-Output "WSL is not installed. Installing now..."
    wsl --install

    # Wait for installation to complete
    Start-Sleep -Seconds 10

    # Verify Installation
    try {
        $wslStatus = wsl --status 2>$null
        Write-Output "WSL installation completed successfully."
    } catch {
        Write-Output "WSL installation failed. Exiting!"
        exit 1
    }
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
Write-Output "All installations and configurations are complete!"

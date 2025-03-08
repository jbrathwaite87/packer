@echo off
echo Installing ScooterSoftware Beyond Compare 4...
winget install --id=ScooterSoftware.BeyondCompare4 -e
if %ERRORLEVEL% NEQ 0 echo Error installing Beyond Compare 4

echo Installing Git...
winget install --id=Git.Git -e
if %ERRORLEVEL% NEQ 0 echo Error installing Git

echo Installing GitHub CLI...
winget install --id=GitHub.cli -e
if %ERRORLEVEL% NEQ 0 echo Error installing GitHub CLI

echo Installing Microsoft Git Credential Manager Core...
winget install --id=Microsoft.GitCredentialManagerCore -e
if %ERRORLEVEL% NEQ 0 echo Error installing Git Credential Manager Core

echo Installing Microsoft PowerShell...
winget install --id=Microsoft.PowerShell -e
if %ERRORLEVEL% NEQ 0 echo Error installing Microsoft PowerShell

echo Installing Windows Terminal...
winget install --id=Microsoft.WindowsTerminal -e
if %ERRORLEVEL% NEQ 0 echo Error installing Windows Terminal

echo Installing Kitware CMake...
winget install --id=Kitware.CMake -e
if %ERRORLEVEL% NEQ 0 echo Error installing Kitware CMake

echo Installing Visual Studio 2022 Professional...
winget install --id=Microsoft.VisualStudio.2022.Professional -e
if %ERRORLEVEL% NEQ 0 echo Error installing Visual Studio 2022 Professional

echo Installing Visual Studio Code...
winget install --id=Microsoft.VisualStudioCode -e
if %ERRORLEVEL% NEQ 0 echo Error installing Visual Studio Code

echo Installing 1Password...
winget install --id=AgileBits.1Password -e
if %ERRORLEVEL% NEQ 0 echo Error installing 1Password

echo Installing 1Password CLI...
winget install --id=AgileBits.1Password.CLI -e
if %ERRORLEVEL% NEQ 0 echo Error installing 1Password CLI

echo Installing Ubuntu 22.04...
winget install --id=Canonical.Ubuntu.2204 -e
if %ERRORLEVEL% NEQ 0 echo Error installing Ubuntu 22.04

echo All installations attempted.

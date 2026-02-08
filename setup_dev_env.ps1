# Setup Script for Ashish's Windows Dev Environment
# This script automates the setup process based on planing.txt

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot

function Update-SessionEnvironment {
    try {
        $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        $env:Path = $machinePath + ";" + $userPath
        Write-Host "Environment variables updated." -ForegroundColor Gray
    }
    catch {
        Write-Warning "Could not update environment variables: $_"
    }
}

function Show-Prompt {
    param(
        [string]$StepName,
        [string]$Description
    )
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Step: $StepName" -ForegroundColor Yellow
    Write-Host "Action: $Description" -ForegroundColor White
    
    $choice = Read-Host "Do you want to proceed with this step? (Y/N)"
    if ($choice -eq 'y' -or $choice -eq 'Y') {
        return $true
    }
    Write-Host "Skipping $StepName..." -ForegroundColor Gray
    return $false
}

Write-Host "Starting setup..." -ForegroundColor Cyan

# Initial Readiness Check
Write-Host "`nIMPORTANT PRE-REQUISITES:" -ForegroundColor Yellow
Write-Host "1. Ensure you have a web browser installed and open."
Write-Host "2. Ensure you are logged into your GitHub account in that browser."
Write-Host "This will be required for GitHub CLI authentication later."
Write-Host ""
$ready = Read-Host "Are you ready to proceed? (Y/N)"
if ($ready -ne 'Y' -and $ready -ne 'y') {
    Write-Warning "Setup aborted by user."
    Exit
}

# Check for administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Write-Warning "This script requires Administrator privileges. Please run as Administrator."
    Exit
}

# Global variables for user identity
$global:userName = $null
$global:userEmail = $null

# 1. Execute installScript.ps1
if (Show-Prompt "1. Install Software" "Run InstallScript.ps1 to install packages via Winget/UniGetUI") {
    Write-Host "`n[Step 1] Running InstallScript.ps1..." -ForegroundColor Green
    $installScriptPath = "$scriptDir\InstallScript.ps1"
    if (Test-Path $installScriptPath) {
        try {
            & $installScriptPath
            Update-SessionEnvironment
        }
        catch {
            Write-Error "Failed to execute InstallScript.ps1: $_"
        }
    }
    else {
        Write-Warning "InstallScript.ps1 not found at $installScriptPath"
    }
}

# NEW: Git Configuration
if (Show-Prompt "1a. Configure Git Identity" "Set global Git user.name and user.email") {
    Write-Host "`n[Step 1a] Configuring Git Identity..." -ForegroundColor Green
    
    $global:userName = Read-Host "Enter your Name for Git (e.g. John Doe)"
    $global:userEmail = Read-Host "Enter your Email for Git (e.g. you@example.com)"
    
    if (-not [string]::IsNullOrWhiteSpace($global:userName) -and -not [string]::IsNullOrWhiteSpace($global:userEmail)) {
        git config --global user.name "$global:userName"
        git config --global user.email "$global:userEmail"
        Write-Host "Git identity set."
    }
    else {
        Write-Warning "Name or Email was empty. Skipping Git configuration."
    }
}





# NEW: GitHub CLI Setup
if (Show-Prompt "1b. Setup GitHub CLI" "Install GitHub CLI and authenticate") {
    Write-Host "`n[Step 1b] Setting up GitHub CLI..." -ForegroundColor Green
    
    # Check if gh is installed, if not try to install it
    if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
        Write-Host "GitHub CLI not found. Attempting to install..."
        winget install --id "GitHub.cli" -e --source winget --accept-source-agreements --accept-package-agreements --silent
        Update-SessionEnvironment
    }
    
    if (Get-Command "gh" -ErrorAction SilentlyContinue) {
        Write-Host "Starting GitHub authentication..."
        Write-Host "Follow the instructions in the browser window that opens." -ForegroundColor Yellow
        gh auth login
    }
    else {
        Write-Warning "GitHub CLI (gh) could not be found or installed."
    }
}

# 2. Install JetBrainsMono Nerd Font
if (Show-Prompt "2. Install Fonts" "Install JetBrainsMono Nerd Font") {
    Write-Host "`n[Step 2] Installing JetBrainsMono Nerd Font..." -ForegroundColor Green
    try {
        $fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        $tempDir = $env:TEMP
        $fontZipPath = Join-Path $tempDir "JetBrainsMono.zip"
        $fontExtractPath = Join-Path $tempDir "JetBrainsMono_Extract"
        
        Write-Host "Downloading font..."
        Invoke-WebRequest -Uri $fontZipUrl -OutFile $fontZipPath
        
        Write-Host "Extracting font..."
        if (Test-Path $fontExtractPath) { Remove-Item $fontExtractPath -Recurse -Force }
        Expand-Archive -Path $fontZipPath -DestinationPath $fontExtractPath -Force
        
        $destFonts = "$env:WINDIR\Fonts"
        $fontFiles = Get-ChildItem -Path $fontExtractPath -Filter "*.ttf" -Recurse
        
        foreach ($font in $fontFiles) {
            Write-Host "Installing $($font.Name)..."
            Copy-Item -Path $font.FullName -Destination $destFonts -Force
            # Register in registry ensures it's available immediately/after reboot without manual install action
            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $font.Name -Value $font.Name -PropertyType String -Force | Out-Null
        }
        Write-Host "Fonts installed successfully."
    }
    catch {
        Write-Error "Error installing fonts: $_"
    }
}



# 3. Install VSCodium Extensions
Write-Host "`n[Step 3] Installing VSCodium extensions..." -ForegroundColor Green
$extensionsFile = "$scriptDir\text-editor\vscodium-extensions.txt"
if (Test-Path $extensionsFile) {
    # Check if codium is available, try to find it explicitly if not in path yet
    if (-not (Get-Command "codium" -ErrorAction SilentlyContinue)) {
        Update-SessionEnvironment
    }
    
    if (Get-Command "codium" -ErrorAction SilentlyContinue) {
        Get-Content $extensionsFile | ForEach-Object {
            $ext = $_.Trim()
            if (-not [string]::IsNullOrWhiteSpace($ext)) {
                Write-Host "Installing extension: $ext"
                cmd /c "codium --install-extension $ext"
            }
        }
    }
    else {
        Write-Warning "codium command not found. Ensure VSCodium is installed and added to PATH."
    }
}
else {
    Write-Warning "Extensions file not found at $extensionsFile"
}

# 4. Configure VSCodium Settings
if (Show-Prompt "4. VSCodium Settings" "Copy settings.json to VSCodium user directory") {
    Write-Host "`n[Step 4] Configuring VSCodium settings..." -ForegroundColor Green
    $vscodeSettingsSrc = "$scriptDir\text-editor\settings.json"
    $vscodeSettingsDestDir = "$env:APPDATA\VSCodium\User"
    $vscodeSettingsDest = "$vscodeSettingsDestDir\settings.json"

    if (Test-Path $vscodeSettingsSrc) {
        if (-not (Test-Path $vscodeSettingsDestDir)) {
            New-Item -ItemType Directory -Path $vscodeSettingsDestDir -Force | Out-Null
        }
        
        Copy-Item -Path $vscodeSettingsSrc -Destination $vscodeSettingsDest -Force
        Write-Host "VSCodium settings copied to $vscodeSettingsDest"
    }
    else {
        Write-Warning "VSCodium settings source not found at $vscodeSettingsSrc"
    }
}

# NEW: Antigravity Setup
if (Show-Prompt "4a. Antigravity Setup" "Install Extensions and Copy Settings for Antigravity Editor") {
    Write-Host "`n[Step 4a] Configuring Antigravity Editor..." -ForegroundColor Green
    
    # 4a.1 Extensions
    $agExtensionsFile = "$scriptDir\antigravity-bak\antigravity-extensions.txt"
    if (Test-Path $agExtensionsFile) {
        # Check for Antigravity binary
        # Assuming binary name, if unknown we might skip or try 'code' if it's VS Code based
        # Based on user context, it seems to be a VS Code fork. 
        # But 'Google.Antigravity' via winget suggests it might have its own binary.
        # I will try to detect it or assume it's "antigravity" or on PATH.
        # If not found, warn.
        
        # User said "add google's anitgravity ... under the codium config".
        # I will attempt to use 'antigravity' command.
        
        if (-not (Get-Command "antigravity" -ErrorAction SilentlyContinue)) {
            Update-SessionEnvironment
        }
        
        if (Get-Command "antigravity" -ErrorAction SilentlyContinue) {
            Get-Content $agExtensionsFile | ForEach-Object {
                $ext = $_.Trim()
                if (-not [string]::IsNullOrWhiteSpace($ext)) {
                    Write-Host "Installing Antigravity extension: $ext"
                    cmd /c "antigravity --install-extension $ext"
                }
            }
        }
        else {
            Write-Warning "Antigravity command not found. Cannot install extensions automatically."
        }
    }
    else {
        Write-Warning "Antigravity extensions file not found at $agExtensionsFile"
    }
    
    # 4a.2 Settings
    $agSettingsSrc = "$scriptDir\antigravity-bak\settings.json"
    $agSettingsDestDir = "$env:APPDATA\Antigravity\User"
    $agSettingsDest = "$agSettingsDestDir\settings.json"
    
    if (Test-Path $agSettingsSrc) {
        if (-not (Test-Path $agSettingsDestDir)) {
            New-Item -ItemType Directory -Path $agSettingsDestDir -Force | Out-Null
        }
        
        Copy-Item -Path $agSettingsSrc -Destination $agSettingsDest -Force
        Write-Host "Antigravity settings copied to $agSettingsDest"
    }
    else {
        Write-Warning "Antigravity settings source not found at $agSettingsSrc"
    }
}

# 5 & 6. Configure Windows Terminal (Profile & Settings)
# ... (Continuing with existing code) ... 
# I will break here and just target the SSH section separately to avoid huge replacement block unless I can do it easily.
# Actually I need to match the context perfectly. 
# Step 4 ends at line 114. Step 5 starts at 116.
# I will implement Step 4a and THEN separately updates SSH.


# 5 & 6. Configure Windows Terminal (Profile & Settings)
if (Show-Prompt "5 & 6. Windows Terminal" "Configure Windows Terminal settings") {
    Write-Host "`n[Step 5 & 6] Configuring Windows Terminal..." -ForegroundColor Green
    $terminalSettingsSrc = "$scriptDir\terminal\settings.json"
    $terminalSettingsDest = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

    if (Test-Path $terminalSettingsSrc) {
        if (Test-Path $terminalSettingsDest) {
            Copy-Item -Path $terminalSettingsSrc -Destination $terminalSettingsDest -Force
            Write-Host "Windows Terminal settings replaced."
        }
        else {
            Write-Warning "Windows Terminal settings file not found at default location: $terminalSettingsDest. Is Windows Terminal installed?"
        }
    }
    else {
        Write-Warning "Terminal settings source not found at $terminalSettingsSrc"
    }
}

# 7. Configure PowerShell Profile
if (Show-Prompt "7. PowerShell Profile" "Add Starship init to PowerShell profile") {
    Write-Host "`n[Step 7] Configuring PowerShell Profile..." -ForegroundColor Green
    # Ensure profile directory exists
    if (-not (Test-Path (Split-Path $PROFILE))) {
        New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force | Out-Null
    }

    if (-not (Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -Type File -Force | Out-Null
    }

    $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    # Added space after & for safer execution
    $starshipInit = "Invoke-Expression (& starship init powershell)"
    if ($null -eq $profileContent -or $profileContent -notlike "*$starshipInit*") {
        Add-Content -Path $PROFILE -Value "`n$starshipInit"
        Write-Host "Added Starship init to PowerShell profile."
    }
    else {
        Write-Host "Starship init already present in PowerShell profile."
    }
}

# 8. Configure Starship
if (Show-Prompt "8. Starship" "Configure Starship preset") {
    Write-Host "`n[Step 8] Configuring Starship..." -ForegroundColor Green
    $starshipConfigDir = "$env:USERPROFILE\.config"
    if (-not (Test-Path $starshipConfigDir)) {
        New-Item -ItemType Directory -Path $starshipConfigDir -Force | Out-Null
    }

    if (-not (Get-Command "starship" -ErrorAction SilentlyContinue)) {
        Update-SessionEnvironment
    }

    if (Get-Command "starship" -ErrorAction SilentlyContinue) {
        $starshipTomlPath = "$starshipConfigDir\starship.toml"
        # The command provided uses forward slashes in path, ensuring compatibility
        $starshipTomlPathCmd = $starshipTomlPath -replace "\\", "/"
        Write-Host "Setting Starship preset..."
        Invoke-Expression "starship preset gruvbox-rainbow -o $starshipTomlPathCmd"
    }
    else {
        Write-Warning "Starship command not found. Ensure it is installed."
    }
}

# 9. Copy Neovim Configuration
if (Show-Prompt "9. Neovim Config" "Copy Neovim configuration") {
    Write-Host "`n[Step 9] Copying Neovim configuration..." -ForegroundColor Green
    $nvimSrc = "$scriptDir\nvim"
    $nvimDest = "$env:LOCALAPPDATA\nvim"

    if (Test-Path $nvimSrc) {
        if (Test-Path $nvimDest) {
            Write-Host "Removing existing Neovim config..."
            Remove-Item -Path $nvimDest -Recurse -Force
        }
        Copy-Item -Path $nvimSrc -Destination "$env:LOCALAPPDATA" -Recurse -Force
        Write-Host "Neovim configuration copied to $nvimDest"
    }
    else {
        Write-Warning "Neovim source directory not found at $nvimSrc"
    }
}






# 11. Final Instructions
Write-Host "`n[Step 11] Setup actions complete." -ForegroundColor Cyan
Write-Host "IMPORTANT: Please restart your computer now to ensure all changes (fonts, path updates) take effect." -ForegroundColor Yellow
Write-Host "After restart, run the following command in PowerShell to run Chris Titus Tech's Utility:" -ForegroundColor Yellow
Write-Host "irm https://christitus.com/win | iex" -ForegroundColor White

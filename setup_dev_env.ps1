# Setup Script for Ashish's Windows Dev Environment
# This script automates the setup process based on planing.txt

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot

function Update-Environment {
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
    if ($choice -eq 'Y' -or $choice -eq 'y') {
        return $true
    }
    Write-Host "Skipping $StepName..." -ForegroundColor Gray
    return $false
}

Write-Host "Starting setup..." -ForegroundColor Cyan

# Check for administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Write-Warning "This script requires Administrator privileges. Please run as Administrator."
    Exit
}

# 1. Execute installScript.ps1
if (Show-Prompt "1. Install Software" "Run InstallScript.ps1 to install packages via Winget/UniGetUI") {
    Write-Host "`n[Step 1] Running InstallScript.ps1..." -ForegroundColor Green
    $installScriptPath = "$scriptDir\InstallScript.ps1"
    if (Test-Path $installScriptPath) {
        try {
            & $installScriptPath
            Update-Environment
        }
        catch {
            Write-Error "Failed to execute InstallScript.ps1: $_"
        }
    }
    else {
        Write-Warning "InstallScript.ps1 not found at $installScriptPath"
    }
}

# 2. Install JetBrainsMono Nerd Font
if (Show-Prompt "2. Install Fonts" "Download and install JetBrainsMono Nerd Font") {
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
if (Show-Prompt "3. VSCodium Extensions" "Install extensions listed in text-editor/vscodium-extensions.txt") {
    Write-Host "`n[Step 3] Installing VSCodium extensions..." -ForegroundColor Green
    $extensionsFile = "$scriptDir\text-editor\vscodium-extensions.txt"
    if (Test-Path $extensionsFile) {
        # Check if codium is available, try to find it explicitly if not in path yet
        if (-not (Get-Command "codium" -ErrorAction SilentlyContinue)) {
            Update-Environment
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

# 5 & 6. Configure Windows Terminal (Profile & Settings)
if (Show-Prompt "5 & 6. Windows Terminal" "Configure Windows Terminal settings") {
    Write-Host "`n[Step 5 & 6] Configuring Windows Terminal..." -ForegroundColor Green
    $terminalSettingsSrc = "$scriptDir\terminal\settings.json"
    # Common path for Windows Terminal settings (packaged version)
    $terminalSettingsDest = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

    if (Test-Path $terminalSettingsSrc) {
        if (Test-Path $terminalSettingsDest) {
            Write-Host "Windows Terminal settings already exist. Skipping to preserve current config." -ForegroundColor Gray
            Write-Host "To force update, delete $terminalSettingsDest and re-run." -ForegroundColor Gray
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
if (Show-Prompt "8. Starship Config" "Set Starship preset to gruvbox-rainbow") {
    Write-Host "`n[Step 8] Configuring Starship..." -ForegroundColor Green
    $starshipConfigDir = "$env:USERPROFILE\.config"
    if (-not (Test-Path $starshipConfigDir)) {
        New-Item -ItemType Directory -Path $starshipConfigDir -Force | Out-Null
    }

    if (-not (Get-Command "starship" -ErrorAction SilentlyContinue)) {
        Update-Environment
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
if (Show-Prompt "9. Neovim Config" "Copy Neovim configuration to local appdata") {
    Write-Host "`n[Step 9] Copying Neovim configuration..." -ForegroundColor Green
    $nvimSrc = "$scriptDir\nvim"
    $nvimDest = "$env:LOCALAPPDATA\nvim"

    if (Test-Path $nvimSrc) {
        if (Test-Path $nvimDest) {
            Write-Host "Neovim configuration already exists at $nvimDest. Skipping." -ForegroundColor Gray
            Write-Host "To force update, delete $nvimDest and re-run." -ForegroundColor Gray
        }
        else {
            Copy-Item -Path $nvimSrc -Destination "$env:LOCALAPPDATA" -Recurse -Force
            Write-Host "Neovim configuration copied to $nvimDest"
        }
    }
    else {
        Write-Warning "Neovim source directory not found at $nvimSrc"
    }
}

# 10. Generate SSH Key
if (Show-Prompt "10. SSH Key" "Generate SSH key and add to agent") {
    Write-Host "`n[Step 10] Generating SSH Key..." -ForegroundColor Green
    $sshDir = "$env:USERPROFILE\.ssh"
    $sshKeyPath = "$sshDir\id_ed25519"
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    }

    if (-not (Test-Path $sshKeyPath)) {
        Write-Host "Generating new ED25519 key..."
        # -N "" for no passphrase, -f to specify file
        ssh-keygen -t ed25519 -C "ashishyadav4978@gmail.com" -f $sshKeyPath -N ""
    }
    else {
        Write-Host "SSH Key already exists at $sshKeyPath"
    }

    # Start ssh-agent
    Write-Host "Configuring ssh-agent..."
    try {
        $agentService = Get-Service -Name ssh-agent
        if ($agentService.Status -ne 'Running') {
            Set-Service -Name ssh-agent -StartupType Manual
            Start-Service -Name ssh-agent
        }
        
        # Add key to agent
        if (Test-Path $sshKeyPath) {
            ssh-add $sshKeyPath
        }
    }
    catch {
        Write-Error "Failed to configure ssh-agent: $_"
    }
}

# 11. Final Instructions
Write-Host "`n[Step 11] Setup actions complete." -ForegroundColor Cyan
Write-Host "IMPORTANT: Please restart your computer now to ensure all changes (fonts, path updates) take effect." -ForegroundColor Yellow
Write-Host "After restart, run the following command in PowerShell to run Chris Titus Tech's Utility:" -ForegroundColor Yellow
Write-Host "irm https://christitus.com/win | iex" -ForegroundColor White

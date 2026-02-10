<#
.SYNOPSIS
    Automated Windows Development Setup Script
    Based on planing.md requirements.

.DESCRIPTION
    This script provides a TUI to select and execute setup steps.
    Step 1 (InstallScript) runs in the current context (expected Non-Admin).
    Steps 2-10 run in an Admin context (auto-elevates if needed).

.PARAMETER ExecuteAdminSteps
    Internal parameter used when the script accepts self-elevation.
#>

param (
    [string[]]$ExecuteAdminSteps = @()
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot

# -------------------------------------------------------------------------
# Helper Functions
# -------------------------------------------------------------------------

function Show-Menu {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "   Automated Windows Dev Setup           " -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "1.  Run InstallScript (Non-Admin)"
    Write-Host "2a. Setup Git Config (Name/Email)"
    Write-Host "2b. Install Tools & Login (GH CLI, FZF)"
    Write-Host "2c. Clone Repositories (Interactive FZF)"
    Write-Host "3.  Install Nerd Fonts"
    Write-Host "4.  Install VSCodium Extensions"
    Write-Host "5.  Configure VSCodium Settings"
    Write-Host "6.  Install Antigravity Extensions"
    Write-Host "7.  Configure Antigravity Settings"
    Write-Host "8.  Configure Windows Terminal (Starship, Settings)"
    Write-Host "9.  Copy Neovim Config"
    Write-Host "10. System Backup Restore (import-settings.ps1)"
    Write-Host "-----------------------------------------"
    Write-Host "A.  Execute All (Recommended)"
    Write-Host "Q.  Quit"
    Write-Host "=========================================" -ForegroundColor Cyan
}

function Test-Admin {
    $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Run-Step1 {
    Write-Host "`n[Step 1] Running InstallScript.ps1..." -ForegroundColor Green
    
    # Requirement: Enforce Non-Admin
    if (Test-Admin) {
        Write-Error "[Step 1] This step MUST be run in a non-admin terminal. Please restart the script without admin privileges or open a new non-admin terminal."
        return
    }

    $installScript = Join-Path $ScriptDir "InstallScript.ps1"
    if (Test-Path $installScript) {
        try {
            & $installScript
            Write-Host "[Step 1] Completed." -ForegroundColor Green
        }
        catch {
            Write-Host "[Step 1] Failed: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "InstallScript.ps1 not found at $installScript" -ForegroundColor Red
    }
}

function Run-AdminSteps {
    param([string[]]$StepsToRun)
    
    # This function contains the logic for Steps 2-10
    # It must be run as Administrator
    
    if (-not (Test-Admin)) {
        Write-Host "Requesting Admin privileges for remaining steps..." -ForegroundColor Yellow
        $exe = "powershell"
        if (Get-Command "pwsh" -ErrorAction SilentlyContinue) { 
            $exe = "pwsh" 
            Write-Host "Using PowerShell 7 (pwsh) for elevation." -ForegroundColor Cyan
        }
        $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -ExecuteAdminSteps $($StepsToRun -join ',')"
        Start-Process $exe -Verb RunAs -ArgumentList $argList -Wait
        return
    }

    Write-Host "`nStarting Admin Tasks..." -ForegroundColor Cyan

    # Step 2a: Git Config
    if ($StepsToRun -contains "2a" -or $StepsToRun -contains "A") {
        try {
            Write-Host "`n[Step 2a] Setting up Git Config..." -ForegroundColor Green
            
            $gitName = Read-Host "Enter Git Name (Default: ashish)"
            if ([string]::IsNullOrWhiteSpace($gitName)) { $gitName = "ashish" }
            
            $gitEmail = Read-Host "Enter Git Email (Default: ashish@email.com)"
            if ([string]::IsNullOrWhiteSpace($gitEmail)) { $gitEmail = "ashish@email.com" }
            
            git config --global user.name "$gitName"
            git config --global user.email "$gitEmail"
            Write-Host "Git config updated."
        }
        catch {
            Write-Host "[Step 2a] Failed: $_" -ForegroundColor Red
        }
    }

    # Step 2b: Tools & Login
    if ($StepsToRun -contains "2b" -or $StepsToRun -contains "A") {
        try {
            Write-Host "`n[Step 2b] Installing Tools & Logging in..." -ForegroundColor Green
            
            # GitHub CLI
            if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
                Write-Host "Installing GitHub CLI..."
                winget install GitHub.cli --accept-source-agreements --accept-package-agreements
            }
            
            # FZF (Dependency for 2c)
            if (-not (Get-Command "fzf" -ErrorAction SilentlyContinue)) {
                Write-Host "Installing FZF..."
                winget install junegunn.fzf --accept-source-agreements --accept-package-agreements
            }

            # Auth Login
            Write-Host "Checking GitHub Login status..."
            try {
                $status = gh auth status 2>&1
                if ($status -match "Logged in to github.com") {
                    Write-Host "Already logged in."
                }
                else {
                    throw "Not logged in"
                }
            }
            catch {
                Write-Host "Please login to GitHub in the browser if requested..."
                gh auth login -w -p ssh
            }
        }
        catch {
            Write-Host "[Step 2b] Failed: $_" -ForegroundColor Red
        }
    }

    # Step 2c: Clone Repos
    if ($StepsToRun -contains "2c" -or $StepsToRun -contains "A") {
        try {
            Write-Host "`n[Step 2c] Cloning Repositories..." -ForegroundColor Green
            
            if (-not (Get-Command "fzf" -ErrorAction SilentlyContinue)) {
                Write-Warning "FZF not found. Please run Step 2b first."
            }
            else {
                # Fetch Username
                $me = gh api user --jq .login
                Write-Host "Fetching repos for user: $me"

                # Fetch repos and pipe to fzf
                $repoList = gh repo list $me --limit 200 --json nameWithOwner --jq '.[].nameWithOwner'
                
                if ($repoList) {
                    Write-Host "Select repositories to clone." -ForegroundColor Cyan
                    Write-Host "Use TAB to multi-select, ENTER to confirm." -ForegroundColor Yellow
                    $selected = $repoList | fzf -m
                    
                    if ($selected) {
                        $targetBase = "$HOME\Documents\github-repo"
                        if (-not (Test-Path $targetBase)) { New-Item -ItemType Directory -Path $targetBase -Force | Out-Null }
                        
                        foreach ($repo in $selected) {
                            $target = Join-Path $targetBase ($repo -split "/")[-1]
                            if (-not (Test-Path $target)) {
                                Write-Host "Cloning $repo..."
                                git clone "https://github.com/$repo.git" $target
                            }
                            else {
                                Write-Host "$repo already exists at $target."
                            }
                        }
                    }
                    else {
                        Write-Host "No repositories selected." -ForegroundColor Yellow
                    }
                }
                else {
                    Write-Warning "No repositories found for user $me."
                }
            }
        }
        catch {
            Write-Host "[Step 2c] Failed: $_" -ForegroundColor Red
        }
    }

    # Step 3: Fonts (Admin required for Register-Font usually, or just copy)
    if ($StepsToRun -contains "3" -or $StepsToRun -contains "A") {
        try {
            Write-Host "`n[Step 3] Installing Fonts..." -ForegroundColor Green
            $availableFonts = @("JetBrainsMono", "CascadiaCode", "FiraCode", "Meslo")
            $selectedFonts = @()

            if ($StepsToRun -contains "A") {
                Write-Host "Auto-selecting recommended fonts for 'Execute All' (JetBrainsMono, Meslo)..."
                $selectedFonts = @("JetBrainsMono", "Meslo")
            }
            else {
                # Interactive Selection
                Write-Host "Select Fonts to Install (comma separated numbers):"
                for ($i = 0; $i -lt $availableFonts.Count; $i++) {
                    Write-Host "$($i+1). $($availableFonts[$i])"
                }
                $selection = Read-Host "Selection (Enter for All)"
                
                if ([string]::IsNullOrWhiteSpace($selection)) {
                    $selectedFonts = $availableFonts
                }
                else {
                    $indices = $selection -split "," | ForEach-Object { $_.Trim() }
                    foreach ($idx in $indices) {
                        if ($idx -match '^\d+$' -and [int]$idx -ge 1 -and [int]$idx -le $availableFonts.Count) {
                            $selectedFonts += $availableFonts[[int]$idx - 1]
                        }
                    }
                }
            }
            
            if ($selectedFonts.Count -eq 0) {
                Write-Host "No fonts selected. Skipping." -ForegroundColor Yellow
            }
            else {
                Write-Host "Installing: $($selectedFonts -join ', ')"
                $fonts = $selectedFonts
            }
            
            $fontUrls = @{
                "JetBrainsMono" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
                "CascadiaCode"  = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
                "FiraCode"      = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
                "Meslo"         = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
            }

            $tempDir = $env:TEMP
            
            # Download and Install Loop
            foreach ($fontName in $fonts) {
                $url = $fontUrls[$fontName]
                $zipPath = Join-Path $tempDir "$fontName.zip"
                $extractPath = Join-Path $tempDir "$fontName" # _Extract
                
                try {
                    Invoke-WebRequest -Uri $url -OutFile $zipPath
                    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
                    
                    $fontFiles = Get-ChildItem -Path $extractPath -Include "*.ttf", "*.otf" -Recurse
                    # $shell = New-Object -ComObject Shell.Application
                    # $fontsFolder = $shell.Namespace(0x14) # Unused
    
                    foreach ($file in $fontFiles) {
                        if (-not (Test-Path "C:\Windows\Fonts\$($file.Name)")) {
                            Write-Host "Installing $($file.Name)..."
                            Copy-Item $file.FullName -Destination "C:\Windows\Fonts" -Force
                            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $file.Name -Value $file.Name -PropertyType String -Force | Out-Null
                        }
                    }
                    Write-Host "$fontName installed."
                }
                catch {
                    Write-Host "Failed to install ${fontName}: $_" -ForegroundColor Red
                }
            }
        }
        catch {
            Write-Host "[Step 3] Failed: $_" -ForegroundColor Red
        }
    }

    # Step 4: VSCodium Ext
    if ($StepsToRun -contains "4" -or $StepsToRun -contains "A") {
        try {
            Write-Host "`n[Step 4] Installing VSCodium Extensions..." -ForegroundColor Green
            $extFile = Join-Path $ScriptDir "codium-bak\vscodium-extensions.txt"
            if (Test-Path $extFile) {
                $extensions = Get-Content $extFile
                foreach ($ext in $extensions) {
                    if (-not [string]::IsNullOrWhiteSpace($ext)) {
                        Write-Host "Installing $ext..."
                        cmd /c "codium --install-extension $ext"
                    }
                }
            }
        }
        catch {
            Write-Host "[Step 4] Failed: $_" -ForegroundColor Red
        }
    }

    # Step 5: VSCodium Settings
    if ($StepsToRun -contains "5" -or $StepsToRun -contains "A") {
        try {
            Write-Host "`n[Step 5] Configuring VSCodium Settings..." -ForegroundColor Green
            $src = Join-Path $ScriptDir "codium-bak\settings.json"
            $destDir = "$env:APPDATA\VSCodium\User"
            if (-not (Test-Path $destDir)) { New-Item -Path $destDir -ItemType Directory -Force | Out-Null }
            if (Test-Path $src) {
                Copy-Item $src "$destDir\settings.json" -Force
                Write-Host "Settings copied."
            }
        }
        catch {
            Write-Host "[Step 5] Failed: $_" -ForegroundColor Red
        }
    }

    # Step 6: Antigravity Ext
    if ($StepsToRun -contains "6" -or $StepsToRun -contains "A") {
        try {
            Write-Host "`n[Step 6] Installing Antigravity Extensions..." -ForegroundColor Green
            $extFile = Join-Path $ScriptDir "antigravity-bak\antigravity-extensions.txt"
            if (Test-Path $extFile) {
                $extensions = Get-Content $extFile
                foreach ($ext in $extensions) {
                    if (-not [string]::IsNullOrWhiteSpace($ext)) {
                        Write-Host "Installing $ext..."
                        try {
                            cmd /c "antigravity --install-extension $ext"
                        }
                        catch {
                            Write-Host "Failed to run antigravity command. Is it in PATH?" -ForegroundColor Red
                        }
                    }
                }
            }
        }
        catch {
            Write-Host "[Step 6] Failed: $_" -ForegroundColor Red
        }
    }

    # Step 7: Antigravity Settings
    if ($StepsToRun -contains "7" -or $StepsToRun -contains "A") {
        try {
            Write-Host "`n[Step 7] Configuring Antigravity Settings..." -ForegroundColor Green
            $src = Join-Path $ScriptDir "antigravity-bak\settings.json"
            $destDir = "$env:APPDATA\antigravity\User" 
            if (-not (Test-Path $destDir)) { New-Item -Path $destDir -ItemType Directory -Force | Out-Null }
            if (Test-Path $src) {
                Copy-Item $src "$destDir\settings.json" -Force
                Write-Host "Settings copied."
            }
        }
        catch {
            Write-Host "[Step 7] Failed: $_" -ForegroundColor Red
        }
    }

    # Step 8: Windows Terminal
    if ($StepsToRun -contains "8" -or $StepsToRun -contains "A") {
        try {
            Write-Host "`n[Step 8] Configuring AAK Windows Terminal..." -ForegroundColor Green
            
            # Install Starship if not present
            if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
                winget install Starship.Starship --accept-source-agreements --accept-package-agreements
            }
            
            # Refresh Path for current session (Winget install location)
            $wingetLinks = "$env:LOCALAPPDATA\Microsoft\WinGet\Links"
            if ($env:Path -notlike "*$wingetLinks*" -and (Test-Path $wingetLinks)) {
                $env:Path += ";$wingetLinks"
                Write-Host "Added Winget links to current session PATH."
            }
    
            # Profile Update Logic
            $profilesToUpdate = @()
            if ($PROFILE) { $profilesToUpdate += $PROFILE }
            if (Get-Command "pwsh" -ErrorAction SilentlyContinue) {
                try {
                    $ps7Path = pwsh -NoProfile -Command "Write-Host -NoNewline `$PROFILE"
                    if (-not [string]::IsNullOrWhiteSpace($ps7Path) -and $profilesToUpdate -notcontains $ps7Path) {
                        $profilesToUpdate += $ps7Path
                        Write-Host "Detected PowerShell 7 Profile: $ps7Path" -ForegroundColor Cyan
                    }
                }
                catch {
                    Write-Warning "Failed to query pwsh for profile path."
                }
            }
            $docs = [Environment]::GetFolderPath("MyDocuments")
            $potentialPaths = @(
                "$docs\PowerShell\Microsoft.PowerShell_profile.ps1",
                "$docs\PowerShell\profile.ps1",
                "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
            )
            foreach ($path in $potentialPaths) {
                if ($profilesToUpdate -notcontains $path) {
                    if ($path -match "Microsoft.PowerShell_profile.ps1") {
                        $profilesToUpdate += $path
                    }
                }
            }
            $profilesToUpdate = $profilesToUpdate | Select-Object -Unique
    
            foreach ($p in $profilesToUpdate) {
                try {
                    $dir = Split-Path $p -Parent
                    if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
                    if (-not (Test-Path $p)) { New-Item -Path $p -ItemType File -Force | Out-Null; Write-Host "Created profile file: $p" }
    
                    $profileContent = Get-Content $p -Raw -ErrorAction SilentlyContinue
                    $starshipInit = "Invoke-Expression (& starship init powershell)"
                    if ([string]::IsNullOrWhiteSpace($profileContent) -or $profileContent -notlike "*$starshipInit*") {
                        Add-Content -Path $p -Value "`r`n$starshipInit" -Encoding UTF8
                        Write-Host "Success: Added Starship init to $p" -ForegroundColor Green
                    }
                    else {
                        Write-Host "Skip: Starship already configured in $p" -ForegroundColor Gray
                    }
                }
                catch {
                    Write-Host "Failed to update profile $p : $_" -ForegroundColor Red
                }
            }
    
            # Preset
            try {
                $configDir = "$HOME\.config"
                if (-not (Test-Path $configDir)) {
                    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
                    Write-Host "Created .config directory."
                }
                Invoke-Expression "starship preset gruvbox-rainbow -o '$HOME\.config\starship.toml'"
                Write-Host "Starship preset applied."
            }
            catch {
                Write-Warning "Could not apply Starship preset in this session. Restart terminal to see changes."
            }
            
            # Settings JSON
            $termSettingsSrc = Join-Path $ScriptDir "terminal\settings.json"
            $pkgDir = Get-ChildItem "$env:LOCALAPPDATA\Packages" -Filter "Microsoft.WindowsTerminal_*" | Select-Object -First 1
            if ($pkgDir) {
                $termSettingsDest = "$($pkgDir.FullName)\LocalState\settings.json"
                if (Test-Path $termSettingsDest) {
                    Copy-Item $termSettingsSrc $termSettingsDest -Force
                    Write-Host "Terminal Settings updated."
                }
            }
        }
        catch {
            Write-Host "[Step 8] Failed: $_" -ForegroundColor Red
        }
    }

    # Step 9: Neovim
    if ($StepsToRun -contains "9" -or $StepsToRun -contains "A") {
        try {
            Write-Host "`n[Step 9] Copying Neovim Config..." -ForegroundColor Green
            $nvimSrc = Join-Path $ScriptDir "nvim"
            $nvimDest = "$env:LOCALAPPDATA\nvim"
            if (Test-Path $nvimSrc) {
                Copy-Item -Path $nvimSrc -Destination $nvimDest -Recurse -Force
                Write-Host "Neovim config copied."
            }
        }
        catch {
            Write-Host "[Step 9] Failed: $_" -ForegroundColor Red
        }
    }

    # Step 10: Backup Import
    if ($StepsToRun -contains "10" -or $StepsToRun -contains "A") {
        try {
            Write-Host "`n[Step 10] Running System Backup Restore..." -ForegroundColor Green
            $importScript = Join-Path $ScriptDir "import-settings.ps1"
            if (Test-Path $importScript) {
                & $importScript
            }
        }
        catch {
            Write-Host "[Step 10] Failed: $_" -ForegroundColor Red
        }
    }
    
    Write-Host "`nAdmin Steps Completed. Press Enter to exit."
    Read-Host
}

# -------------------------------------------------------------------------
# Main Execution Logic
# -------------------------------------------------------------------------

# If script is called with ExecuteAdminSteps argument, jump straight to Admin Tasks
if ($ExecuteAdminSteps.Count -gt 0) {
    if (-not (Test-Admin)) {
        Write-Error "This secondary process must be run as Administrator."
        exit 1
    }
    Run-AdminSteps -StepsToRun $ExecuteAdminSteps
    exit
}

# Normal Entry Point (Interactive TUI)
while ($true) {
    Show-Menu
    $choice = Read-Host "Select an option"
    
    if ($choice -eq 'Q') { break }
    
    $runStep1 = $false
    $adminSteps = @()
    
    if ($choice -eq 'A') {
        $runStep1 = $true
        # Include specific sub-steps of 2 in A
        $adminSteps = @("2a", "2b", "2c", "3", "4", "5", "6", "7", "8", "9", "10", "A") 
    }
    elseif ($choice -match '^\d+[abc]?$') {
        # Match digits possibly followed by a/b/c
        if ($choice -eq '1') {
            $runStep1 = $true
        }
        else {
            $adminSteps += $choice
        }
    }
    else {
        Write-Host "Invalid Selection." -ForegroundColor Red
        Start-Sleep -Seconds 1
        continue
    }
    
    # Requirement: "Step 1 ... execute it on a no admin terminal"
    if ($runStep1) {
        if (Test-Admin) {
            Write-Warning "Current session is Administrator. Step 1 requires Non-Admin."
            Write-Warning "Please restart script without Admin privileges for Step 1."
            # We skip running it to enforce safety, as requested to "force" it.
            # But the user might want a choice? Plan said Enforce.
            Start-Sleep -Seconds 2
        }
        else {
            Run-Step1
        }
    }
    
    # Run remaining steps if any
    if ($adminSteps.Count -gt 0) {
        Run-AdminSteps -StepsToRun $adminSteps
    }
    
    Write-Host "`nOperation Completed. Press Enter to return to menu..."
    Read-Host
}

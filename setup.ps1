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
    Write-Host "2.  Setup Git & GitHub (Config, CLI, Clones)"
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
    $installScript = Join-Path $ScriptDir "InstallScript.ps1"
    if (Test-Path $installScript) {
        # Execute in existing window or new window? user asked for standard execution.
        # Requirement: "execute it on a no admin terminal"
        # We assume the current session is No Admin.
        try {
            & $installScript
            Write-Host "[Step 1] Completed." -ForegroundColor Green
        } catch {
            Write-Host "[Step 1] Failed: $_" -ForegroundColor Red
        }
    } else {
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

    # Step 2: Git/GitHub
    if ($StepsToRun -contains "2" -or $StepsToRun -contains "A") {
        Write-Host "`n[Step 2] Setting up Git/GitHub..." -ForegroundColor Green
        
        # Git Config
        $gitName = Read-Host "Enter Git Name (Default: ashish)"
        if ([string]::IsNullOrWhiteSpace($gitName)) { $gitName = "ashish" }
        
        $gitEmail = Read-Host "Enter Git Email (Default: ashish@email.com)"
        if ([string]::IsNullOrWhiteSpace($gitEmail)) { $gitEmail = "ashish@email.com" }
        
        git config --global user.name "$gitName"
        git config --global user.email "$gitEmail"
        Write-Host "Git config updated."

        # GitHub CLI
        if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
            Write-Host "Installing GitHub CLI..."
            winget install GitHub.cli --accept-source-agreements --accept-package-agreements
        }
        
        # Auth Login
        Write-Host "Please login to GitHub in the browser if requested..."
        gh auth login -w -p ssh
        
        # Clone Repos logic
        Write-Host "Fetching Repositories..."
        try {
            $repos = gh repo list --limit 100 --json name,sshUrl | ConvertFrom-Json
            # Filter logic could go here, for now simpler interactive or text file
            $repoFile = Join-Path $ScriptDir "repos.txt"
            $selectedRepos = @()
            
            if (Test-Path $repoFile) {
                $fileContent = Get-Content $repoFile
                # Assume simple list of names or URLs
                # Ideally matching names to what 'gh' returned or just cloning URLs
                # Requirement says "Lets me select specific repos OR read from a repos.txt file"
                # We'll prioritize the file if exists, else interactive is complex in console, skipping interactive repo picker for simplicity unless requested
                foreach ($line in $fileContent) {
                    $match = $repos | Where-Object { $_.name -eq $line -or $_.sshUrl -eq $line }
                    if ($match) { $selectedRepos += $match }
                }
            } else {
                 # Fallback: Clone all? Or skip?
                 # Requirement: "Lets me select... OR read from repos.txt"
                 # I will implement reading from repos.txt essentially.
                 Write-Host "repos.txt not found. Skipping auto-cloning." -ForegroundColor Yellow
            }
            
            $projectDir = "$HOME\Projects"
            if (-not (Test-Path $projectDir)) { New-Item -ItemType Directory -Path $projectDir | Out-Null }
            
            foreach ($repo in $selectedRepos) {
                $target = Join-Path $projectDir $repo.name
                if (-not (Test-Path $target)) {
                    Write-Host "Cloning $($repo.name)..."
                    git clone $repo.sshUrl $target
                } else {
                    Write-Host "$($repo.name) already exists."
                }
            }
        } catch {
            Write-Host "Error during Repo operations: $_" -ForegroundColor Red
        }
    }

    # Step 3: Fonts (Admin required for Register-Font usually, or just copy)
    if ($StepsToRun -contains "3" -or $StepsToRun -contains "A") {
        Write-Host "`n[Step 3] Installing Fonts..." -ForegroundColor Green
        $availableFonts = @("JetBrainsMono", "CascadiaCode", "FiraCode", "Meslo")
        $selectedFonts = @()

        if ($StepsToRun -contains "A") {
            # Automated / "Execute All" preference from plan: 
            # "select jetbrainsMono Nerd font and default font for AAK" (Meslo is often default for tough prompts, or just JetBrains)
            Write-Host "Auto-selecting recommended fonts for 'Execute All' (JetBrainsMono, Meslo)..."
            $selectedFonts = @("JetBrainsMono", "Meslo")
        } else {
            # Interactive Selection
            Write-Host "Select Fonts to Install (comma separated numbers):"
            for ($i = 0; $i -lt $availableFonts.Count; $i++) {
                Write-Host "$($i+1). $($availableFonts[$i])"
            }
            $selection = Read-Host "Selection (Enter for All)"
            
            if ([string]::IsNullOrWhiteSpace($selection)) {
                $selectedFonts = $availableFonts
            } else {
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
        } else {
            Write-Host "Installing: $($selectedFonts -join ', ')"
            $fonts = $selectedFonts
        }
        
        # Simpler approach: Install via scoop or winget if possible, but requirement gave URL example.
        # Installing fonts via script is tricky without external tools or shell com objects.
        # We will follow the provided snippet style.
        
        $fontUrls = @{
            "JetBrainsMono" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
            "CascadiaCode" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
            "FiraCode" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
            "Meslo" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
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
                $shell = New-Object -ComObject Shell.Application
                $fontsFolder = $shell.Namespace(0x14) # Special folder Fonts

                foreach ($file in $fontFiles) {
                     # Check if installed - rudimentary check by name
                     if (-not (Test-Path "C:\Windows\Fonts\$($file.Name)")) {
                         Write-Host "Installing $($file.Name)..."
                         # Installing via copy is often restricted.
                         # Reliable method: Copy to Fonts dir + Registry entry.
                         Copy-Item $file.FullName -Destination "C:\Windows\Fonts" -Force
                         
                         # Add registry key
                         New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $file.Name -Value $file.Name -PropertyType String -Force | Out-Null
                     }
                }
                Write-Host "$fontName installed."
            } catch {
                Write-Host "Failed to install ${fontName}: $_" -ForegroundColor Red
            }
        }
    }

    # Step 4: VSCodium Ext
    if ($StepsToRun -contains "4" -or $StepsToRun -contains "A") {
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

    # Step 5: VSCodium Settings
    if ($StepsToRun -contains "5" -or $StepsToRun -contains "A") {
        Write-Host "`n[Step 5] Configuring VSCodium Settings..." -ForegroundColor Green
        $src = Join-Path $ScriptDir "codium-bak\settings.json"
        $destDir = "$env:APPDATA\VSCodium\User"
        if (-not (Test-Path $destDir)) { New-Item -Path $destDir -ItemType Directory -Force | Out-Null }
        if (Test-Path $src) {
            Copy-Item $src "$destDir\settings.json" -Force
            Write-Host "Settings copied."
        }
    }

    # Step 6: Antigravity Ext
    if ($StepsToRun -contains "6" -or $StepsToRun -contains "A") {
        Write-Host "`n[Step 6] Installing Antigravity Extensions..." -ForegroundColor Green
        $extFile = Join-Path $ScriptDir "antigravity-bak\antigravity-extensions.txt"
        if (Test-Path $extFile) {
            $extensions = Get-Content $extFile
            foreach ($ext in $extensions) {
                if (-not [string]::IsNullOrWhiteSpace($ext)) {
                    Write-Host "Installing $ext..."
                    try {
                        cmd /c "antigravity --install-extension $ext"
                    } catch {
                        Write-Host "Failed to run antigravity command. Is it in PATH?" -ForegroundColor Red
                    }
                }
            }
        }
    }

    # Step 7: Antigravity Settings
    if ($StepsToRun -contains "7" -or $StepsToRun -contains "A") {
        Write-Host "`n[Step 7] Configuring Antigravity Settings..." -ForegroundColor Green
        $src = Join-Path $ScriptDir "antigravity-bak\settings.json"
        $destDir = "$env:APPDATA\antigravity\User" # Guessing path structure similar to Code
        if (-not (Test-Path $destDir)) { New-Item -Path $destDir -ItemType Directory -Force | Out-Null }
        if (Test-Path $src) {
            Copy-Item $src "$destDir\settings.json" -Force
            Write-Host "Settings copied."
        }
    }

    # Step 8: Windows Terminal
    if ($StepsToRun -contains "8" -or $StepsToRun -contains "A") {
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

        # Profile Update Logic (Robust PS7 Targeting)
        $profilesToUpdate = @()
        
        # 1. Current Profile (Context script is running in)
        if ($PROFILE) { $profilesToUpdate += $PROFILE }
        
        # 2. PowerShell 7 Profile (Query pwsh directly if available)
        if (Get-Command "pwsh" -ErrorAction SilentlyContinue) {
            try {
                $ps7Path = pwsh -NoProfile -Command "Write-Host -NoNewline `$PROFILE"
                if (-not [string]::IsNullOrWhiteSpace($ps7Path) -and $profilesToUpdate -notcontains $ps7Path) {
                    $profilesToUpdate += $ps7Path
                    Write-Host "Detected PowerShell 7 Profile: $ps7Path" -ForegroundColor Cyan
                }
            } catch {
                Write-Warning "Failed to query pwsh for profile path."
            }
        }
        
        # 3. Fallback / Standard Paths (if pwsh query failed or not present)
        $docs = [Environment]::GetFolderPath("MyDocuments")
        $potentialPaths = @(
            "$docs\PowerShell\Microsoft.PowerShell_profile.ps1",
            "$docs\PowerShell\profile.ps1",
            "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
        )
        
        foreach ($path in $potentialPaths) {
            if ($profilesToUpdate -notcontains $path) {
                # Only add if it looks like a valid structure or user specifically asked for PS7 defaults
                # We'll add Microsoft.PowerShell_profile.ps1 as it is the standard for PS7 core.
                if ($path -match "Microsoft.PowerShell_profile.ps1") {
                    $profilesToUpdate += $path
                }
            }
        }

        # Remove duplicates
        $profilesToUpdate = $profilesToUpdate | Select-Object -Unique

        foreach ($p in $profilesToUpdate) {
            try {
                $dir = Split-Path $p -Parent
                if (-not (Test-Path $dir)) {
                    New-Item -Path $dir -ItemType Directory -Force | Out-Null
                }
                
                # Check/Create File
                if (-not (Test-Path $p)) {
                    New-Item -Path $p -ItemType File -Force | Out-Null
                    Write-Host "Created profile file: $p"
                }

                $profileContent = Get-Content $p -Raw -ErrorAction SilentlyContinue
                # Ensure spacing is consistent with user request: (& starship ...)
                $starshipInit = "Invoke-Expression (& starship init powershell)"
                
                if ([string]::IsNullOrWhiteSpace($profileContent) -or $profileContent -notlike "*$starshipInit*") {
                    # Add newline before to be safe
                    Add-Content -Path $p -Value "`r`n$starshipInit" -Encoding UTF8
                    Write-Host "Success: Added Starship init to $p" -ForegroundColor Green
                } else {
                    Write-Host "Skip: Starship already configured in $p" -ForegroundColor Gray
                }
            } catch {
                Write-Host "Failed to update profile $p : $_" -ForegroundColor Red
            }
        }

        # Preset
        try {
            Invoke-Expression "starship preset gruvbox-rainbow -o '$HOME\.config\starship.toml'"
            Write-Host "Starship preset applied."
        } catch {
            Write-Warning "Could not apply Starship preset in this session (command not found?). Restart terminal to see changes."
        }
        
        # Settings JSON
        $termSettingsSrc = Join-Path $ScriptDir "terminal\settings.json"
        
        # Finding Windows Terminal Settings path is tricky as it's a store app.
        # Usually in $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_...\LocalState\settings.json
        $pkgDir = Get-ChildItem "$env:LOCALAPPDATA\Packages" -Filter "Microsoft.WindowsTerminal_*" | Select-Object -First 1
        if ($pkgDir) {
            $termSettingsDest = "$($pkgDir.FullName)\LocalState\settings.json"
            if (Test-Path $termSettingsDest) {
                # Require merging or overwrite? Plan says "copy the setting ... to windows terminal settings.json and add the following configuration to it"
                # If we overwrite, we might lose local state. Assuming overwrite for "setup".
                Copy-Item $termSettingsSrc $termSettingsDest -Force
                Write-Host "Terminal Settings updated."
            }
        }
    }

    # Step 9: Neovim
    if ($StepsToRun -contains "9" -or $StepsToRun -contains "A") {
        Write-Host "`n[Step 9] Copying Neovim Config..." -ForegroundColor Green
        $nvimSrc = Join-Path $ScriptDir "nvim"
        $nvimDest = "$env:LOCALAPPDATA\nvim"
        if (Test-Path $nvimSrc) {
            Copy-Item -Path $nvimSrc -Destination $nvimDest -Recurse -Force
            Write-Host "Neovim config copied."
        }
    }

    # Step 10: Backup Import
    if ($StepsToRun -contains "10" -or $StepsToRun -contains "A") {
        Write-Host "`n[Step 10] Running System Backup Restore..." -ForegroundColor Green
        $importScript = Join-Path $ScriptDir "import-settings.ps1"
        if (Test-Path $importScript) {
            & $importScript
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
        $adminSteps = @("2","3","4","5","6","7","8","9","10", "A") 
    } elseif ($choice -match '^\d+$') {
        if ($choice -eq '1') {
            $runStep1 = $true
        } else {
            $adminSteps += $choice
        }
    } else {
        Write-Host "Invalid Selection." -ForegroundColor Red
        Start-Sleep -Seconds 1
        continue
    }
    
    # Requirement: "Step 1 ... execute it on a no admin terminal"
    if ($runStep1) {
        if (Test-Admin) {
            Write-Warning "Running Step 1 as Administrator (Not Recommended but continuing)."
        }
        Run-Step1
    }
    
    # Run remaining steps if any
    if ($adminSteps.Count -gt 0) {
        Run-AdminSteps -StepsToRun $adminSteps
    }
    
    Write-Host "`nOperation Completed. Press Enter to return to menu..."
    Read-Host
}

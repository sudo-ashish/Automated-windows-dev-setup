<#
.SYNOPSIS
    Import-Settings
.DESCRIPTION
    Restores Windows User Settings from the 'system-backup' folder.
.PARAMETER Theme
    Import Theme/Personalization registry keys.
.PARAMETER Explorer
    Import Explorer/Search registry keys.
.PARAMETER Mouse
    Import Mouse/Touchpad registry keys.
.PARAMETER Profile
    Import PowerShell Profile.
.PARAMETER All
    Import everything.
#>
param(
    [switch]$Theme,
    [switch]$Explorer,
    [switch]$Mouse,
    [switch]$Profile,
    [switch]$All
)

# If no specific switch is provided, default to All
if (-not ($Theme -or $Explorer -or $Mouse -or $Profile)) {
    $All = $true
}

$backupDir = Join-Path $PSScriptRoot "system-backup"

if (!(Test-Path $backupDir)) {
    Write-Host "Backup folder not found." -ForegroundColor Red
    exit
}

Write-Host "Restoring settings from $backupDir"

# ------------------------------
# Import Registry Files
# ------------------------------
function Import-Reg {
    param($Name)
    $path = "$backupDir\$Name"
    if (Test-Path $path) {
        Write-Host "Importing $Name..."
        reg import $path
    }
}

if ($All -or $Theme) {
    Import-Reg "themes.reg"
}

if ($All -or $Explorer) {
    Import-Reg "explorer.reg"
    Import-Reg "search.reg"
}

if ($All -or $Mouse) {
    Import-Reg "touchpad.reg"
    Import-Reg "mouse.reg"
}

# ------------------------------
# Restore PowerShell Profile
# ------------------------------
# Restore PowerShell Profile
# ------------------------------
if ($All -or $Profile) {
    $src = "$backupDir\powershell-profile.ps1"
    if (Test-Path $src) {
        Write-Host "Restoring PowerShell Profile..."
        
        # Determine target path
        $docs = [System.Environment]::GetFolderPath('MyDocuments')
        $targetDir = Join-Path $docs "PowerShell"
        $targetFile = Join-Path $targetDir "Microsoft.PowerShell_profile.ps1"

        # Ensure directory exists
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        # Copy to Standard Location
        Write-Host "Restoring to: $targetFile"
        Copy-Item $src $targetFile -Force

        # Also copy to $PROFILE if it's defined and different, just in case
        if ($PROFILE -and ($PROFILE -ne $targetFile)) {
             # Only if parent dir exists or we create it? 
             # Let's stick to standard path as primary. 
             # If $PROFILE is valid file path, try it too.
             try {
                $profDir = Split-Path $PROFILE -Parent
                if (Test-Path $profDir) {
                    Write-Host "Also restoring to: $PROFILE"
                    Copy-Item $src $PROFILE -Force
                }
             } catch {}
        }
    }
    else {
        Write-Host "Backup profile not found at $src" -ForegroundColor Yellow
    }
}

# ------------------------------
# Restart Explorer (Only if needed)
# ------------------------------
if ($All -or $Explorer -or $Theme) {
    Write-Host "Restarting Explorer to apply changes..."
    Stop-Process -Name explorer -Force
}

Write-Host "Import complete."

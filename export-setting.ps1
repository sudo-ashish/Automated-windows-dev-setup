<#
.SYNOPSIS
    Export-Settings
.DESCRIPTION
    Exports Windows User Settings (Theme, Explorer, Mouse) and PowerShell Profile to a 'system-backup' folder.
#>

$backupDir = Join-Path $PSScriptRoot "system-backup"

if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory $backupDir | Out-Null
}

Write-Host "Saving settings to $backupDir"

# ------------------------------
# Theme / Personalization
# ------------------------------
reg export `
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes" `
    "$backupDir\themes.reg" /y

# ------------------------------
# Explorer Settings
# ------------------------------
reg export `
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" `
    "$backupDir\explorer.reg" /y

# ------------------------------
# Touchpad (Precision)
# ------------------------------
reg export `
    "HKCU\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" `
    "$backupDir\touchpad.reg" /y

# ------------------------------
# Taskbar / Search
# ------------------------------
reg export `
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" `
    "$backupDir\search.reg" /y

# ------------------------------
# Mouse Settings
# ------------------------------
reg export `
    "HKCU\Control Panel\Mouse" `
    "$backupDir\mouse.reg" /y

# ------------------------------
# PowerShell Profile
# ------------------------------
if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$backupDir\powershell-profile.ps1" -Force
}

Write-Host "Export complete."

# ==============================
# Import Windows User Settings
# ==============================

$backupDir = "$HOME\Documents\Automated-windows-dev-setup\system-backup"

if (!(Test-Path $backupDir)) {
    Write-Host "Backup folder not found." -ForegroundColor Red
    exit
}

Write-Host "Restoring settings from $backupDir"

# ------------------------------
# Import Registry Files
# ------------------------------
Get-ChildItem "$backupDir\*.reg" | ForEach-Object {

    Write-Host "Importing $($_.Name)..."
    reg import $_.FullName
}

# ------------------------------
# Restore PowerShell Profile
# ------------------------------
if (Test-Path "$backupDir\powershell-profile.ps1") {

    Copy-Item `
     "$backupDir\powershell-profile.ps1" `
     $PROFILE `
     -Force
}

# ------------------------------
# Restart Explorer
# ------------------------------
Stop-Process -Name explorer -Force

Write-Host "Import complete. Log out recommended."

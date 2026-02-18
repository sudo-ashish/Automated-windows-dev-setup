<#
.SYNOPSIS
    Export-Settings
.DESCRIPTION
    Exports Windows User Settings (Theme, Explorer, Mouse) and PowerShell Profile to a 'system-backup' folder.
.PARAMETER Theme
    Export Theme/Personalization registry keys.
.PARAMETER Explorer
    Export Explorer/Search registry keys.
.PARAMETER Mouse
    Export Mouse/Touchpad registry keys.
.PARAMETER Profile
    Export PowerShell Profile.
.PARAMETER All
    Export everything.
#>
param(
    [switch]$Theme,
    [switch]$Explorer,
    [switch]$Mouse,
    [switch]$Profile,
    [switch]$All
)

# If no specific switch is provided, default to All (or handle as error, but All is safer for backward compat if called without args)
if (-not ($Theme -or $Explorer -or $Mouse -or $Profile)) {
    $All = $true
}

$backupDir = Join-Path $PSScriptRoot "system-backup"

if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory $backupDir | Out-Null
}

Write-Host "Saving settings to $backupDir"

# ------------------------------
# Theme / Personalization
# ------------------------------
if ($All -or $Theme) {
    Write-Host "Exporting Themes..."
    reg export `
        "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes" `
        "$backupDir\themes.reg" /y
}

# ------------------------------
# Explorer Settings
# ------------------------------
if ($All -or $Explorer) {
    Write-Host "Exporting Explorer/Search..."
    reg export `
        "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" `
        "$backupDir\explorer.reg" /y

    reg export `
        "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" `
        "$backupDir\search.reg" /y
}

# ------------------------------
# Mouse / Touchpad
# ------------------------------
if ($All -or $Mouse) {
    Write-Host "Exporting Mouse/Touchpad..."
    reg export `
        "HKCU\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" `
        "$backupDir\touchpad.reg" /y

    reg export `
        "HKCU\Control Panel\Mouse" `
        "$backupDir\mouse.reg" /y
}

# ------------------------------
# PowerShell Profile
# ------------------------------
if ($All -or $Profile) {
    $found = $false
    
    # Define standard paths to check (Manual check because $PROFILE depends on host)
    $docs = [System.Environment]::GetFolderPath('MyDocuments')
    $potentialPaths = @(
        # PowerShell 7+
        (Join-Path $docs "PowerShell\Microsoft.PowerShell_profile.ps1"),
        (Join-Path $docs "PowerShell\profile.ps1"),
        # Windows PowerShell (5.1)
        (Join-Path $docs "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"),
        (Join-Path $docs "WindowsPowerShell\profile.ps1")
    )

    # Also check $PROFILE variable locations if they exist
    if ($PROFILE.CurrentUserCurrentHost) { $potentialPaths += $PROFILE.CurrentUserCurrentHost }
    if ($PROFILE.CurrentUserAllHosts) { $potentialPaths += $PROFILE.CurrentUserAllHosts }
    if ($PROFILE -is [string]) { $potentialPaths += $PROFILE }

    # Remove duplicates and check
    $potentialPaths | Select-Object -Unique | ForEach-Object {
        if (-not $found -and (Test-Path $_)) {
            Write-Host "Exporting Profile found at: $_"
            Copy-Item $_ "$backupDir\powershell-profile.ps1" -Force
            $found = $true
        }
    }
    
    if (-not $found) {
        Write-Host "Warning: No PowerShell profile found." -ForegroundColor Yellow
        Write-Host "Checked locations:" -ForegroundColor DarkGray
        $potentialPaths | Select-Object -Unique | ForEach-Object { Write-Host " - $_" -ForegroundColor DarkGray }
    }
}

Write-Host "Export complete."

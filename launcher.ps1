<#
.SYNOPSIS
    winHelp Launcher - Central orchestrator for the modernized Windows setup utility.
.DESCRIPTION
    v2.0 Orchestrator. Supports both CLI and high-performance GUI.
#>
param(
    [switch]$Install,
    [switch]$Git,
    [switch]$GitHub,
    [switch]$Backup,
    [switch]$Restore,
    [switch]$Debloat,
    [switch]$Update,
    [switch]$All,
    [switch]$GUI
)

# 1. Initialize Global State
$Global:AppRoot = $PSScriptRoot
. (Join-Path $Global:AppRoot "core/Logger.ps1")
. (Join-Path $Global:AppRoot "core/ConfigManager.ps1")

Write-Log "winHelp Launcher starting..." -Level INFO

# 2. Load Configuration
Load-Config

# 3. Handle Execution Mode
if (-not ($Install -or $Git -or $GitHub -or $Backup -or $Restore -or $Debloat -or $Update -or $All -or $GUI)) {
    Write-Log "No parameters provided. Defaulting to GUI mode." -Level INFO
    $GUI = $true
}

# 4. Modules Preparation
$ModulesToRun = @()
if ($All) {
    $ModulesToRun = @("Installers", "git/Git", "git/GitHub", "Backups", "Debloater", "Updates")
}
else {
    if ($Install) { $ModulesToRun += "Installers" }
    if ($Git) { $ModulesToRun += "git/Git" }
    if ($GitHub) { $ModulesToRun += "git/GitHub" }
    if ($Backup -or $Restore) { $ModulesToRun += "Backups" }
    if ($Debloat) { $ModulesToRun += "Debloater" }
    if ($Update) { $ModulesToRun += "Updates" }
}

# 5. CLI Execution Path
if ($ModulesToRun.Count -gt 0) {
    foreach ($ModuleName in $ModulesToRun) {
        $ModulePath = Join-Path $Global:AppRoot "modules/$ModuleName.ps1"
        if (Test-Path $ModulePath) {
            Write-Log "Running Module: $ModuleName" -Level INFO
            try {
                . $ModulePath
                # Dispatcher for module-specific entry points if needed
                switch ($ModuleName) {
                    "Installers" { Invoke-AppInstall }
                    "git/Git" { Set-GitConfig; Install-Tools }
                    "git/GitHub" { Invoke-GitHubFetch } # Just a pulse check for CLI
                    "Backups" { if ($Restore) { Invoke-Restore -All } else { Invoke-Backup -All } }
                    "Debloater" { Invoke-Debloat }
                    "Updates" { Invoke-Update }
                }
            }
            catch {
                Write-Log "Failed to execute $ModuleName: $($_.Exception.Message)" -Level ERROR
            }
        }
        else {
            Write-Log "Module not found: $ModulePath" -Level WARN
        }
    }
}

# 6. GUI Execution Path
if ($GUI) {
    Write-Log "Initializing GUI v2 Interface..." -Level INFO
    # Source all modules for UI availability
    Get-ChildItem -Path (Join-Path $Global:AppRoot "modules") -Filter "*.ps1" -Recurse | ForEach-Object { . $_.FullName }
    . (Join-Path $Global:AppRoot "ui/UIManager.ps1")
    Invoke-GUI
}

Write-Log "winHelp execution finished." -Level INFO

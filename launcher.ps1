<#
.SYNOPSIS
    winHelp Launcher - Central orchestrator for modular Windows setup.
.DESCRIPTION
    Supports both CLI and GUI modes. Loads config and runs requested modules.
.PARAMETER Software
    Run software installation module.
.PARAMETER Backup
    Run backup/restore module.
.PARAMETER Setup
    Run system setup module (Git, Fonts, etc).
.PARAMETER Debloat
    Run Windows debloating module.
.PARAMETER All
    Run all enabled modules from config.
.PARAMETER GUI
    Launch the graphical interface (default if no args provided).
#>
param(
    [switch]$Software,
    [switch]$Backup,
    [switch]$Restore,
    [switch]$Setup,
    [switch]$Debloat,
    [switch]$GitHub,
    [switch]$Update,
    [switch]$All,
    [switch]$GUI
)

# 1. Initialize Paths & Core Utilities
$AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $AppRoot "src/core/Logger.ps1")
. (Join-Path $AppRoot "src/core/Config.ps1")

Write-Log "winHelp Launcher starting..." -Level INFO

# 2. Load Configuration
Load-Config

# 3. Determine Execution Mode
if (-not ($Software -or $Backup -or $Restore -or $Setup -or $Debloat -or $GitHub -or $Update -or $All -or $GUI)) {
    Write-Log "No parameters provided. Defaulting to GUI mode." -Level INFO
    $GUI = $true
}

# 4. Modules to Run
$ModulesToRun = @()

if ($All) {
    Write-Log "Running all enabled modules from config..." -Level INFO
    if (Test-FeatureEnabled "software_install") { $ModulesToRun += "Installers" }
    if (Test-FeatureEnabled "backup_restore") { $ModulesToRun += "Backups" }
    if (Test-FeatureEnabled "system_setup") { $ModulesToRun += "Setup" }
    if (Test-FeatureEnabled "debloat") { $ModulesToRun += "Debloater" }
    if (Test-FeatureEnabled "github_repos") { $ModulesToRun += "GitHub" }
    if (Test-FeatureEnabled "updates") { $ModulesToRun += "Updates" }
}
else {
    if ($Software) { $ModulesToRun += "Installers" }
    if ($Backup -or $Restore) { $ModulesToRun += "Backups" }
    if ($Setup) { $ModulesToRun += "Setup" }
    if ($Debloat) { $ModulesToRun += "Debloater" }
    if ($GitHub) { $ModulesToRun += "GitHub" }
    if ($Update) { $ModulesToRun += "Updates" }
}

# 5. Execute Modules (Headless/CLI path)
if ($ModulesToRun.Count -gt 0) {
    foreach ($ModuleName in $ModulesToRun) {
        $ModulePath = Join-Path $AppRoot "src/modules/$ModuleName.ps1"
        if (Test-Path $ModulePath) {
            Write-Log "Loading module: $ModuleName" -Level INFO
            try {
                . $ModulePath
                
                # Execute the primary function of the module
                switch ($ModuleName) {
                    "Installers" { Invoke-AppInstall }
                    "Backups" { 
                        if ($Restore) { Invoke-Restore -All }
                        else { Invoke-Backup -All }
                    }
                    "Setup" { Invoke-Setup }
                    "Debloater" { Invoke-Debloat }
                    "GitHub" { Invoke-GitHubRepos }
                    "Updates" { Invoke-Update }
                }
            }
            catch {
                Write-Log "Failed to execute module $($ModuleName): $($_.Exception.Message)" -Level ERROR
            }
        }
        else {
            Write-Log "Module script not found: $ModulePath" -Level WARN
        }
    }
}

# 6. Launch GUI (WPF path)
if ($GUI) {
    Write-Log "Launching GUI (Phase 4 Implementation)..." -Level INFO
    # TODO: Implement Phase 4 GUI logic
}

Write-Log "winHelp execution finished." -Level INFO

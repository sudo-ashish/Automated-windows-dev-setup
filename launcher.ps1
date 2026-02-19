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
    [switch]$Setup,
    [switch]$Debloat,
    [switch]$All,
    [switch]$GUI
)

# 1. Initialize Paths & Core Utilities
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $PSScriptRoot "src/core/Logger.ps1")
. (Join-Path $PSScriptRoot "src/core/Config.ps1")

Write-Log "winHelp Launcher starting..." -Level INFO

# 2. Load Configuration
Load-Config

# 3. Determine Execution Mode
if (-not ($Software -or $Backup -or $Setup -or $Debloat -or $All -or $GUI)) {
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
}
else {
    if ($Software) { $ModulesToRun += "Installers" }
    if ($Backup) { $ModulesToRun += "Backups" }
    if ($Setup) { $ModulesToRun += "Setup" }
    if ($Debloat) { $ModulesToRun += "Debloater" }
}

# 5. Execute Modules (Headless/CLI path)
if ($ModulesToRun.Count -gt 0) {
    foreach ($ModuleName in $ModulesToRun) {
        $ModulePath = Join-Path $PSScriptRoot "src/modules/$ModuleName.ps1"
        if (Test-Path $ModulePath) {
            Write-Log "Executing module: $ModuleName" -Level INFO
            . $ModulePath
        }
        else {
            # For Phase 1, create placeholders if missing
            Write-Log "Module script not found: $ModulePath. Creating placeholder..." -Level WARN
            "Write-Log 'Placeholder for $ModuleName' -Level INFO" | Out-File $ModulePath
            . $ModulePath
        }
    }
}

# 6. Launch GUI (WPF path)
if ($GUI) {
    Write-Log "Launching GUI (Phase 4 Implementation)..." -Level INFO
    # TODO: Implement Phase 4 GUI logic
}

Write-Log "winHelp execution finished." -Level INFO

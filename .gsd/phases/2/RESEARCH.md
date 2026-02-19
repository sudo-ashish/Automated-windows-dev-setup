# RESEARCH.md — Phase 2: Feature Porting

## Current State Analysis (setup.ps1)

### 1. Software Installation
- Logic: Lines 593-699 in `setup.ps1`.
- Mechanism: Generates a temporary batch/ps1 script and launches it via `explorer.exe` to de-elevate.
- Data: Uses `$AppDefinitions` array.
- Porting Strategy:
    - Move `$AppDefinitions` to `src/modules/Installers.ps1`.
    - Create a `Invoke-SoftwareInstall` function.
    - Use `Write-Log` for progress.

### 2. Backup/Restore
- Logic: Handled by external scripts `export-setting.ps1` and `import-settings.ps1`.
- Porting Strategy:
    - Move these scripts into `src/modules/Backups.ps1` as functions.
    - Standardize parameters and logging.
    - Ensure they respect the `backup_dir` setting in `config.json`.

### 3. System Setup
- Logic: Lines 720-948 in `setup.ps1`.
- Covers: Git, GH CLI, FZF, Fonts, Terminal, VSCodium, Antigravity, Neovim.
- Porting Strategy:
    - Create `src/modules/Setup.ps1`.
    - Break into granular functions (e.g., `Set-GitConfig`, `Sync-EditorSettings`).
    - Use `src/ui/wt-defaults.json` and assets moved in Phase 1.

## Porting Challenges
- **Interactivity**: Some scripts launch external windows (like `gh auth login`). The launcher must handle this gracefully.
- **Elevation**: Some tasks (Font install, Registry edits) require Admin. `launcher.ps1` should ideally check for elevation at start.
- **WPF Dependencies**: Ensure the modules are completely decoupled from the `$gui` object. They should return data or log progress, which the UI (in Phase 4) can then consume.

## Refactor Pattern
Each module script will follow this pattern:
```powershell
function Invoke-ModuleName {
    param($Options)
    Write-Log "Starting ModuleName..."
    # Implementation
}
```
This allows the `launcher.ps1` to simply dot-source the file and call the primary function.

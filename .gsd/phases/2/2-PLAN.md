---
phase: 2
plan: 2
wave: 1
---

# Plan 2.2: Backup & Restore Module

## Objective
Consolidate the existing backup and restore scripts into a single modular unit that integrates with the new orchestration layer.

## Context
- .gsd/SPEC.md
- export-setting.ps1
- import-settings.ps1
- setup.ps1 (Lines 1046-1097)

## Tasks

<task type="auto">
  <name>Refactor Backup Logic into Module</name>
  <files>src/modules/Backups.ps1</files>
  <action>
    - Combine logic from `export-setting.ps1` and `import-settings.ps1` into `src/modules/Backups.ps1`.
    - Implement `Invoke-Backup` and `Invoke-Restore` functions.
    - Support switches: `-Theme`, `-Explorer`, `-Mouse`, `-Profile`.
    - Use `config.json`'s `backup_dir` setting.
    - Replace `Write-Host` with `Write-Log`.
  </action>
  <verify>powershell -Command ". src/core/Logger.ps1; . src/core/Config.ps1; . src/modules/Backups.ps1; Invoke-Backup -Theme"</verify>
  <done>`Backups.ps1` correctly handles export/import as functional units.</done>
</task>

<task type="auto">
  <name>Integrate Backups with Launcher</name>
  <files>launcher.ps1</files>
  <action>
    - Update `launcher.ps1` to call `Invoke-Backup` or `Invoke-Restore` (if a restore flag is added, or default to backup) when `-Backup` is switched.
    - Ensure it respects `config.json` toggles for specific areas (Theme, Explorer, etc.).
  </action>
  <verify>powershell -File launcher.ps1 -Backup</verify>
  <done>`launcher.ps1` triggers the modular backup logic.</done>
</task>

## Success Criteria
- [ ] Backup/Restore logic is unified in `src/modules/Backups.ps1`.
- [ ] Registry exports and imports function correctly with structured logging.
- [ ] Original standalone scripts are now redundant (can be archived later).

---
phase: 2
plan: 1
wave: 1
---

# Plan 2.1: Software Installer Module

## Objective
Extract the software definition and installation logic from the monolithic script into a clean, standalone module.

## Context
- .gsd/SPEC.md
- .gsd/phases/2/RESEARCH.md
- setup.ps1 (Lines 28-54, 593-699)

## Tasks

<task type="auto">
  <name>Create Installers.ps1 Module</name>
  <files>src/modules/Installers.ps1</files>
  <action>
    - Move `$AppDefinitions` from `setup.ps1` to `src/modules/Installers.ps1`.
    - Implement `Invoke-AppInstall` function that:
        - Accepts a list of App IDs or "All" from config.
        - Uses WinGet to install apps.
        - Uses `Write-Log` for progress/error reporting.
  </action>
  <verify>powershell -Command ". src/core/Logger.ps1; . src/modules/Installers.ps1; Get-Variable AppDefinitions"</verify>
  <done>`Installers.ps1` contains the app definitions and an installation function.</done>
</task>

<task type="auto">
  <name>Integrate Installers with Launcher</name>
  <files>launcher.ps1</files>
  <action>
    - Update `launcher.ps1` to call `Invoke-AppInstall` when the `-Software` flag is used.
    - Ensure it passes the correct arguments based on `config.json` or CLI overrides.
  </action>
  <verify>powershell -File launcher.ps1 -Software (with a small app, or just verify function call via logging)</verify>
  <done>`launcher.ps1` successfully triggers the modular installer logic.</done>
</task>

## Success Criteria
- [ ] Software IDs and installation logic are moved out of `setup.ps1`.
- [ ] `launcher.ps1 -Software` functional without GUI.

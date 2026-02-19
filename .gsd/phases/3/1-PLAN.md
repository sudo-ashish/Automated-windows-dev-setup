---
phase: 3
plan: 1
wave: 1
---

# Plan 3.1: Debloater Module

## Objective
Implement the new Debloater module to streamline Windows by removing telemetry, preinstalled apps, and unwanted features.

## Context
- .gsd/SPEC.md (REQ-07)
- .gsd/phases/3/RESEARCH.md
- config.json (debloat section)

## Tasks

<task type="auto">
  <name>Implement Debloater.ps1</name>
  <files>src/modules/Debloater.ps1</files>
  <action>
    - Create `Invoke-Debloat` function.
    - Implement logic for:
        - `Disable-Telemetry`: Disables DiagTrack service and sets registry keys.
        - `Remove-Bloatware`: Uninstalls common preinstalled AppxPackages (configurable list).
        - `Disable-BingSearch`: Sets registry key to disable Bing in start menu.
    - Respect toggles in `config.json`.
    - Use `Write-Log` for every action.
  </action>
  <verify>powershell -Command ". src/core/Logger.ps1; . src/core/Config.ps1; . src/modules/Debloater.ps1; Invoke-Debloat"</verify>
  <done>`Debloater.ps1` correctly implements the requested system optimizations.</done>
</task>

<task type="auto">
  <name>Integrate Debloater with Launcher</name>
  <files>launcher.ps1</files>
  <action>
    - Update the `switch` block in `launcher.ps1` to call `Invoke-Debloat` when `-Debloat` is used.
    - Ensure it is included in the `-All` execution path if enabled in config.
  </action>
  <verify>powershell -File launcher.ps1 -Debloat</verify>
  <done>`launcher.ps1` triggers the debloating logic.</done>
</task>

## Success Criteria
- [ ] Telemetry, Bing, and Bloatware removal logic is implemented.
- [ ] Logic respects `config.json` toggles.
- [ ] All actions are logged to the central log file.

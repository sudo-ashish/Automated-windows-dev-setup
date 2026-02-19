---
phase: 3
plan: 3
wave: 1
---

# Plan 3.3: Update Module & Core Refinement

## Objective
Implement a module to handle system updates and refine the orchestrator's error handling.

## Context
- .gsd/SPEC.md (REQ-05)
- launcher.ps1

## Tasks

<task type="auto">
  <name>Implement Updates.ps1</name>
  <files>src/modules/Updates.ps1</files>
  <action>
    - Create `Invoke-Update` function.
    - Implement logic for:
        - `winget upgrade --all`
        - (Optional) Windows Update check via `PSWindowsUpdate` module if available.
    - Log results of the update process.
  </action>
  <verify>powershell -Command ". src/core/Logger.ps1; . src/modules/Updates.ps1; Invoke-Update"</verify>
  <done>`Updates.ps1` handles automated system updates.</done>
</task>

<task type="auto">
  <name>Refine Launcher Orchestration</name>
  <files>launcher.ps1</files>
  <action>
    - Add `-Update` switch to `launcher.ps1`.
    - Improve error handling in the module loading loop (try/catch around dot-sourcing).
    - Ensure `launcher.ps1` returns meaningful exit codes based on module success.
  </action>
  <verify>powershell -File launcher.ps1 -Update</verify>
  <done>Launcher is more robust and supports the Update module.</done>
</task>

## Success Criteria
- [ ] System updates can be triggered via `launcher.ps1 -Update`.
- [ ] Launcher handles module failures without crashing.
- [ ] Headless execution is fully functional for all Phase 1-3 features.

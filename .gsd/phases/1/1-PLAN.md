---
phase: 1
plan: 1
wave: 1
---

# Plan 1.1: Structure & Logging

## Objective
Establish the new modular directory structure and implement the structured logging system that will be reused by all modules.

## Context
- .gsd/SPEC.md
- .gsd/phases/1/RESEARCH.md
- Existing `setup.ps1` (for reference)

## Tasks

<task type="auto">
  <name>Setup Directory Structure</name>
  <files>
    - src/core/
    - src/modules/
    - src/ui/
    - logs/
  </files>
  <action>
    - Create the following directories: `src/core`, `src/modules`, `src/ui`, `logs`.
    - Move `wt-defaults.json` to `src/ui/`.
    - Move `nvim/` folder to `src/modules/configs/nvim/`.
  </action>
  <verify>Test-Path "src/core", "src/modules", "src/ui", "logs"</verify>
  <done>All baseline directories created and existing assets moved.</done>
</task>

<task type="auto">
  <name>Implement Core Logger</name>
  <files>src/core/Logger.ps1</files>
  <action>
    - Implement a `Write-Log` function in `src/core/Logger.ps1`.
    - Features:
        - Scopes: INFO, WARN, ERROR, DEBUG.
        - Color-coded console output.
        - Persistent file logging to `logs/winHelp_YYYY-MM-DD.log`.
        - Format: `[timestamp] [LEVEL] Message`.
  </action>
  <verify>powershell -Command ". src/core/Logger.ps1; Write-Log 'Test Info' -Level INFO; Test-Path logs/winHelp_*.log"</verify>
  <done>`Write-Log` is functional for both console and file output.</done>
</task>

## Success Criteria
- [ ] New project skeleton is established.
- [ ] Centralized logging is available for all future modules.

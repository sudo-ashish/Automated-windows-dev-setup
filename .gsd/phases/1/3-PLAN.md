---
phase: 1
plan: 3
wave: 1
---

# Plan 1.3: Launcher Orchestration

## Objective
Implement the main Entry point (`launcher.ps1`) that orchestrates the core utilities and modules using CLI arguments or defaults.

## Context
- .gsd/SPEC.md
- .gsd/phases/1/RESEARCH.md
- src/core/Logger.ps1
- src/core/Config.ps1

## Tasks

<task type="auto">
  <name>Implement launcher.ps1 with CLI parsing</name>
  <files>launcher.ps1</files>
  <action>
    - Create `launcher.ps1` as the new project entry point.
    - Implement parameter block for CLI flags: `-Software`, `-Backup`, `-Setup`, `-Debloat`, `-All`, `-GUI`.
    - Logic should load `src/core/Logger.ps1` and `src/core/Config.ps1` immediately.
  </action>
  <verify>powershell -File launcher.ps1 -Help</verify>
  <done>`launcher.ps1` parses arguments and initializes core utilities.</done>
</task>

<task type="auto">
  <name>Implement Dynamic Module Sourcing</name>
  <files>launcher.ps1</files>
  <action>
    - Add logic to `launcher.ps1` to loop through requested flags (or config) and source the relevant scripts from `src/modules/`.
    - For Phase 1, these modules can be empty placeholder scripts that just log "Module [Name] Loaded".
  </action>
  <verify>powershell -File launcher.ps1 -All</verify>
  <done>Launcher can dynamically source and run logic from the `modules` directory.</done>
</task>

## Success Criteria
- [ ] Central orchestrator is functional.
- [ ] Support for both Headless (CLI) and GUI-ready paths.
- [ ] End-to-end logging from launcher start to finish.

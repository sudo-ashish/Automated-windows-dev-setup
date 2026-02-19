---
phase: 3
plan: 2
wave: 1
---

# Plan 3.2: GitHub Repository Module

## Objective
Port the GitHub repository fetching and cloning logic from `setup.ps1` into a modular utility.

## Context
- setup.ps1 (Lines 950-1041)
- .gsd/phases/3/RESEARCH.md

## Tasks

<task type="auto">
  <name>Create GitHub.ps1 Module</name>
  <files>src/modules/GitHub.ps1</files>
  <action>
    - Extract logic from `setup.ps1` into `src/modules/GitHub.ps1`.
    - Implement `Invoke-GitHubFetch`: Returns repo list (for UI use later).
    - Implement `Invoke-GitHubClone`: Clones repos to a target path.
    - Path should default to `~/Documents/github-repo` or a config setting.
    - Add `-Fetch` and `-Clone` logic.
  </action>
  <verify>powershell -Command ". src/core/Logger.ps1; . src/modules/GitHub.ps1; Invoke-GitHubFetch"</verify>
  <done>`GitHub.ps1` correctly handles repository discovery and cloning.</done>
</task>

<task type="auto">
  <name>Integrate GitHub with Launcher</name>
  <files>launcher.ps1</files>
  <action>
    - Add a `-GitHub` switch to `launcher.ps1`.
    - Update the execution logic to call `Invoke-GitHubClone` when the switch is used.
    - (Optional) Allow specifying repo names via CLI or config.
  </action>
  <verify>powershell -File launcher.ps1 -GitHub</verify>
  <done>Launcher provides a headless path for cloning repositories.</done>
</task>

## Success Criteria
- [ ] GitHub logic is moved out of the UI/Monolith.
- [ ] Cloning works headlessly via the launcher.
- [ ] Logic gracefully handles missing `gh` CLI or authentication.

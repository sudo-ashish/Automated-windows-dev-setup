---
phase: 2
plan: 3
wave: 1
---

# Plan 2.3: System Setup Module

## Objective
Port the various system configuration tasks (Git, Fonts, Terminal, Editors) into a cohesive modular script.

## Context
- .gsd/SPEC.md
- setup.ps1 (Lines 720-948)
- src/ui/wt-defaults.json
- src/modules/configs/nvim/

## Tasks

<task type="auto">
  <name>Implement Setup.ps1 Module</name>
  <files>src/modules/Setup.ps1</files>
  <action>
    - Port logic for:
        - `Set-GitConfig` (using config.json values)
        - `Install-Tools` (GH CLI, FZF)
        - `Install-NerdFont` (Downloads and installs font)
        - `Set-TerminalDefaults` (Merges JSON)
        - `Sync-EditorSettings` (VSCodium, Antigravity, Neovim)
    - Use assets from `src/ui/` and `src/modules/configs/`.
    - Centralize all "Setup" logic in functions within this file.
  </action>
  <verify>powershell -Command ". src/core/Logger.ps1; . src/core/Config.ps1; . src/modules/Setup.ps1; Set-GitConfig"</verify>
  <done>`Setup.ps1` contains all modular configuration functions.</done>
</task>

<task type="auto">
  <name>Integrate Setup with Launcher</name>
  <files>launcher.ps1</files>
  <action>
    - Update `launcher.ps1` to call the sub-functions of `Setup.ps1` when `-Setup` flag is used.
    - Logic should check `config.json` to decide which sub-tasks to run (e.g., `git_config`, `fonts`, `terminal`).
  </action>
  <verify>powershell -File launcher.ps1 -Setup</verify>
  <done>`launcher.ps1` orchestrates the complex setup tasks via the new module.</done>
</task>

## Success Criteria
- [ ] Git, Fonts, Terminal, and Editor logic is modularized.
- [ ] Assets are correctly referenced in their new locations.
- [ ] `launcher.ps1 -Setup` performs all enabled configurations.

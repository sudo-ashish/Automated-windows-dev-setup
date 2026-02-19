---
phase: 4
plan: 2
wave: 1
---

# Plan 4.2: UI Event Handlers & Expansion

## Objective
Wire up the buttons to the modular backend functions and add UI controls for new features (Debloat, Updates).

## Context
- setup.ps1 (Lines 508-1107)
- .gsd/phases/4/RESEARCH.md

## Tasks

<task type="auto">
  <name>Wire Up Module Handlers</name>
  <files>src/ui/UIManager.ps1</files>
  <action>
    - Port event handlers from `setup.ps1` for:
        - `InstallAppsBtn` -> `Invoke-AppInstall`
        - `RunSetupBtn` -> calls `Setup.ps1` functions
        - `FetchReposBtn` / `CloneReposBtn` -> `GitHub.ps1`
        - `ExportBtn` / `ImportBtn` -> `Backups.ps1`
    - Ensure all handlers use the modular functions instead of inline logic.
  </action>
  <verify>Launch UI and click Fetch Repos (ensure it works without the monolithic setup.ps1).</verify>
  <done>UI is fully integrated with the new modular backend.</done>
</task>

<task type="auto">
  <name>Expand UI for Debloater</name>
  <files>src/ui/Main.xaml, src/ui/UIManager.ps1</files>
  <action>
    - Add a new TabItem for "System Debloat" in `Main.xaml`.
    - Add checkboxes for Telemetry, Bing Search, and Bloatware removal.
    - Add a "Run Debloater" button.
    - Wire handler to `Invoke-Debloat`.
  </action>
  <verify>Launch UI, check Debloat tab, verify button triggers module.</verify>
  <done>New Debloater feature is exposed in the GUI.</done>
</task>

<task type="auto">
  <name>Finalize Launcher GUI Path</name>
  <files>launcher.ps1</files>
  <action>
    - Update `launcher.ps1` to call `Invoke-GUI` when the `-GUI` flag is used (or by default).
    - Ensure all required modules are sourced before launching the UI.
  </action>
  <verify>Run `launcher.ps1` without arguments and verify full GUI functionality.</verify>
  <done>Launcher is the single entry point for both CLI and GUI.</done>
</task>

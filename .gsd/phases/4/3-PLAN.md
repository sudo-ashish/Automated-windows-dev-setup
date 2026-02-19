---
phase: 4
plan: 3
wave: 1
---

# Plan 4.3: Cleanup, Documentation & Polish

## Objective
Remove redundant files, update documentation, and perform final verification.

## Tasks

<task type="auto">
  <name>Cleanup Redundant Files</name>
  <action>
    - Rename `setup.ps1` to `setup_legacy.ps1.bak` or remove it.
    - Remove `export-setting.ps1` and `import-settings.ps1` as they are now in `Backups.ps1`.
  </action>
  <verify>Ensure `launcher.ps1` still works after removals.</verify>
  <done>Codebase is clean and modular.</done>
</task>

<task type="auto">
  <name>Update Documentation</name>
  <files>README.md</files>
  <action>
    - Update `README.md` to reflect the new architecture:
        - How to use `launcher.ps1`.
        - CLI arguments.
        - Configuration via `config.json`.
        - New Debloater feature.
  </action>
  <verify>Read through README.md.</verify>
  <done>Documentation is up to date.</done>
</task>

<task type="auto">
  <name>Final Empirical Verification</name>
  <action>
    - Run the tool in various modes (CLI -All, CLI -Software, GUI).
    - Capture logs for evidence.
  </action>
  <verify>All features functional across both interfaces.</verify>
  <done>Project successfully refactored and expanded.</done>
</task>

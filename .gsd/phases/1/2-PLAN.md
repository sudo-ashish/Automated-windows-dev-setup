---
phase: 1
plan: 2
wave: 1
---

# Plan 1.2: Configuration System

## Objective
Implement the JSON-based configuration system to enable feature toggling and settings management across the modular system.

## Context
- .gsd/SPEC.md
- .gsd/phases/1/RESEARCH.md
- .gsd/phases/1/1-PLAN.md

## Tasks

<task type="auto">
  <name>Create config.json baseline</name>
  <files>config.json</files>
  <action>
    - Create a baseline `config.json` with toggles for current features (Software, Backup, Setup) and the new Debloat feature.
    - Include global settings like `log_level` and `theme`.
  </action>
  <verify>Get-Content config.json | ConvertFrom-Json</verify>
  <done>`config.json` exists with valid structure.</done>
</task>

<task type="auto">
  <name>Implement Config Loader Utility</name>
  <files>src/core/Config.ps1</files>
  <action>
    - Implement a utility to load and parse `config.json` into a global `$GlobalConfig` object.
    - Add a helper to check if a feature is enabled (e.g., `Test-FeatureEnabled "debloat"`).
  </action>
  <verify>powershell -Command ". src/core/Config.ps1; Load-Config; Test-FeatureEnabled 'software_install'"</verify>
  <done>Configuration logic is separated and accessible globally.</done>
</task>

## Success Criteria
- [ ] Centralized configuration system is functional.
- [ ] Features can be toggled via `config.json`.

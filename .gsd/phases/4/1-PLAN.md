---
phase: 4
plan: 1
wave: 1
---

# Plan 4.1: WPF Infrastructure & XAML Port

## Objective
Establish the WPF infrastructure, extract the XAML, and implement the core UI manager.

## Context
- setup.ps1 (Lines 60-478)
- .gsd/phases/4/RESEARCH.md

## Tasks

<task type="auto">
  <name>Extract XAML to File</name>
  <files>src/ui/Main.xaml</files>
  <action>
    - Extract the XAML string from `setup.ps1` and save it to `src/ui/Main.xaml`.
    - Clean up the XAML to be a standalone file (remove the heredoc markers).
  </action>
  <verify>Test-Path "src/ui/Main.xaml"</verify>
  <done>`Main.xaml` contains the UI layout.</done>
</task>

<task type="auto">
  <name>Implement UIManager.ps1</name>
  <files>src/ui/UIManager.ps1</files>
  <action>
    - Create `src/ui/UIManager.ps1`.
    - Implement `Invoke-GUI` function.
    - Logic should:
        - Load XAML from file.
        - Locate all controls (GitNameBox, LogBox, etc).
        - Hook up basic window events (Closing, ThemeToggle).
        - Provide a bridge for logging to `LogBox`.
  </action>
  <verify>powershell -Command ". src/core/Logger.ps1; . src/ui/UIManager.ps1; Invoke-GUI (Check if window opens)"</verify>
  <done>GUI window can be launched headlessly from the manager.</done>
</task>

<task type="auto">
  <name>Bridge Logger to UI</name>
  <files>src/core/Logger.ps1</files>
  <action>
    - Update `Write-Log` in `src/core/Logger.ps1` to detect if a global UI log control exists and write to it.
  </action>
  <verify>Invoke a log while UI is open and verify it appears in the UI box.</verify>
  <done>Central logger now supports UI output.</done>
</task>

# SPEC.md — Project Specification

> **Status**: `FINALIZED`

## Vision
Refactor `winHelp` from a monolithic script into a modular, maintainable, and extensible Windows development utility that supports both a rich WPF GUI and headless CLI automation.

## Goals
1.  **Modularity**: Decouple features (installers, debloating, backups, etc.) into independent scripts that can run standalone.
2.  **Orchestration**: Implement a central `launcher.ps1` that manages configuration loading, module importing, and execution flow.
3.  **Config-Driven**: Use a `config.json` file to control feature toggles and settings, separating logic from configuration.
4.  **Flexible Interface**: Provide a central WPF UI for ease of use while maintaining full headless/CLI support for automation.
5.  **Robust Observability**: Implement structured, timestamped logging to a `/logs` folder with consistent error handling across all modules.

## Non-Goals (Out of Scope)
- Creating a cross-platform (Linux/macOS) version.
- Building a custom package manager (will continue to use Winget/MS Store).
- Developing a cloud-based settings sync service.

## Users
- **Developers**: Setting up fresh Windows installations with specific tools and configurations.
- **Power Users**: Automating Windows optimization, debloating, and backup routines.
- **System Administrators**: Deploying standardized environments via headless CLI automation.

## Constraints
- **Language**: Must be written in PowerShell (5.1 or 7+ compatibility preferred).
- **UI Framework**: Must use WPF/XAML for the graphical interface.
- **Dependencies**: Minimize external binary dependencies, relying on built-in tools like Winget when possible.

## Success Criteria
- [ ] Monolithic `setup.ps1` is successfully decomposed into logical modules.
- [ ] `launcher.ps1` can execute any module via CLI arguments without launching the GUI.
- [ ] `config.json` correctly toggles features and module execution.
- [ ] Structured logs are generated in the `/logs` directory for every execution session.
- [ ] All existing functionality (software install, backup, git config) is preserved in the new structure.
- [ ] New "Debloat" module is functional and configurable.

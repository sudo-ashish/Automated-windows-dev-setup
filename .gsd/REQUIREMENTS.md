# REQUIREMENTS.md

## Functional Requirements
| ID | Requirement | Source | Status |
|----|-------------|--------|--------|
| REQ-01 | Create modular script structure for: Installers, Debloating, Backups, Configs, Updates, and UI. | Goal 1 | Pending |
| REQ-02 | Implement `launcher.ps1` to orchestrate module execution based on CLI args and config. | Goal 2 | Pending |
| REQ-03 | Build `config.json` system for feature toggling and settings management. | Goal 3 | Pending |
| REQ-04 | Provide WPF GUI that interacts with modules via the orchestration layer. | Goal 4 | Pending |
| REQ-05 | Support headless execution for all modules via `launcher.ps1`. | Goal 4 | Pending |
| REQ-06 | Implement structured logging (timestamped files in `/logs`). | Goal 5 | Pending |
| REQ-07 | Implement debloating module (Apps, OneDrive, Windows Features). | Goal 1 | Pending |
| REQ-08 | Port existing "Software Tab" logic to new module. | Goal 1 | Pending |
| REQ-09 | Port existing "Backup/Restore" logic to new module. | Goal 1 | Pending |
| REQ-10 | Port existing "Setup" (Git/Fonts/Editors) logic to new module. | Goal 1 | Pending |

## Non-Functional Requirements
| ID | Requirement | Source | Status |
|----|-------------|--------|--------|
| REQ-11 | Consistent error handling across all module scripts. | Goal 5 | Pending |
| REQ-12 | Maintain PowerShell 5.1 compatibility for core features. | Constraint | Pending |
| REQ-13 | Ensure clean and readable console output. | Goal 5 | Pending |
| REQ-14 | No logic should be hardcoded in `launcher.ps1` that belongs in a module. | Goal 1 | Pending |

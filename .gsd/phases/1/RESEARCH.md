# RESEARCH.md — Phase 1: Foundation

## Architectural Decisions

### 1. Directory Structure
```
winHelp/
├── launcher.ps1        # Orchestrator & CLI Entry point
├── config.json         # User configuration
├── logs/               # Structured log files
├── src/
│   ├── core/           # Shared logic (Logger, Config Loader)
│   │   ├── Logger.ps1
│   │   └── Config.ps1
│   ├── modules/        # Feature-specific scripts
│   │   ├── Installers.ps1
│   │   ├── Debloater.ps1
│   │   ├── Backups.ps1
│   │   └── ...
│   └── ui/             # WPF Assets & UI Logic
│       └── Main.xaml
```

### 2. Orchestration Strategy
The `launcher.ps1` will:
1.  Initialize properties and paths.
2.  Import `src/core/Logger.ps1` and `src/core/Config.ps1`.
3.  Load `config.json`.
4.  Parse CLI arguments.
5.  Dynamically dot-source or import modules based on config/arguments.
6.  Execute the requested action (CLI vs GUI).

### 3. Structured Logging
A `Write-Log` helper function in `src/core/Logger.ps1` will:
- Support severity levels (`INFO`, `WARN`, `ERROR`, `DEBUG`).
- Output to console with color-coding.
- Append to a daily log file in `logs/` (e.g., `winHelp_2026-02-19.log`).
- Format: `[YYYY-MM-DD HH:mm:ss] [LEVEL] Message`

### 4. Configuration System
`config.json` will follow this structure:
```json
{
  "features": {
    "software_install": true,
    "debloat": false,
    "backup": true
  },
  "settings": {
    "log_level": "INFO",
    "theme": "Dark"
  },
  "modules": {
    "debloat": {
      "remove_onedrive": true,
      "remove_preinstalled_apps": true
    }
  }
}
```

## Task Decomposition (Phase 1)
1.  **Project Shell**: Create the new directory structure and move current assets to relevant folders.
2.  **Core Components**: Implement `Logger.ps1` and `Config.ps1`.
3.  **The Orchestrator**: Implement `launcher.ps1` with CLI argument support and dynamic loading logic.

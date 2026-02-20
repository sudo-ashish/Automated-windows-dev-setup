# 🚀 winHelp - Automated Windows Development Setup

A modern, modular orchestrator to turn a fresh Windows installation into a powerful development environment. 

---

## 🛠 Getting Started

### 1. Run the Launcher
The central entry point is now `launcher.ps1`. It supports both a modern GUI and a powerful CLI.

**Run the GUI:**
Right-click `launcher.ps1` and select **Run with PowerShell**.

**Run via CLI:**
Open PowerShell in the project directory and run:
```powershell
.\launcher.ps1 -All
```

### 2. Available Flags (CLI)
- `-Software`: Run software installation module.
- `-Backup`: Export system settings (registry + profile).
- `-Restore`: Restore system settings.
- `-Setup`: Run system configuration (Git, Fonts, Terminal, etc).
- `-Debloat`: Run Windows debloating optimizations.
- `-GitHub`: Clone repositories defined in config.
- `-Update`: Run system and package updates via Winget.
- `-All`: Run all enabled modules.

---

## ⚙️ Configuration
Customize your setup by editing `config.json`. You can define:
- **Default Apps**: Specific Winget IDs to install.
- **Git Info**: Your user name and email.
- **Debloat Settings**: Toggle telemetry and bloatware removal.
- **Backup Path**: Where to save your system snapshots.

---

## 📂 Project Structure
- `launcher.ps1`: The central orchestrator.
- `config.json`: Master configuration file.
- `assets/`: Static dependencies, terminal defaults, and external IDE extensions backups.
- `core/`: Internal engine (Logger, Config loader).
- `modules/`: Independent task modules (Installers, Backups, Setup, Debloater, etc).
- `ui/`: WPF GUI definition and manager.
- `build/logs/`: Timestamped execution logs.

---

## 💡 Troubleshooting
**Execution Policy**: If blocked, run:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

**Admin Rights**: Most system tasks (Fonts, Debloating) require Administrator privileges. Run PowerShell as Administrator for best results.

---

*Refactored for Modular winHelp v2.0*

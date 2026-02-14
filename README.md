# Automated Windows Development Setup

A comprehensive, automated tool to set up a modern Windows development environment. This project features a **dark-themed WPF GUI** that handles tool installation, GitHub repository cloning, and configurations for Terminal, VSCodium, and Neovim.

## Features

- **Modern GUI**: Tabbed interface built with WPF/XAML, featuring a custom dark theme and thin scrollbars.
- **One-Click Setup**: Automates the installation of:
    - **Core Tools**: Git, Node.js, VSCodium, Python 3.14, etc.
    - **CLI Utilities**: GitHub CLI (gh), FZF, Bat, Eza.
    - **Fonts**: Nerd Fonts (JetBrainsMono, CascadiaCode, etc.).
- **Github Integration**:
    - Authenticate and fetch repositories dynamically.
    - **Interactive List**: Select multiple repositories to clone in bulk.
    - Display repository visibility (Public/Private).
- **Dotfile Management**:
    - **Backup/Restore**: specific functions to export Registry keys (Theme, Mouse, Explorer) and PowerShell profiles.
    - **Configuration**: Deploys Starship for Windows Terminal and custom Neovim configs.

## Prerequisites

1.  **PowerShell 5.1 or 7+**.
2.  **Execution Policy**:
    ```powershell
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
    ```

## Installation & Usage

1.  **Clone or Download** this repository.
2.  **Run the Script**:
    ```powershell
    .\setup.ps1
    ```
3.  **The GUI**:
    -   **Setup Tab**:
        -   **Step 1**: Basic InstallScript (Chrome, Node, VSCode, etc.).
        -   **Step 2a**: Setup Git Config (Name/Email) & Install Tools (GH CLI, FZF).
        -   **Step 2b**: GitHub Auth Login (Interactive) - *Run this to authenticate with GitHub and setup SSH.*
        -   **Step 3**: Install Nerd Fonts (JetBrainsMono, CascadiaCode, etc.).
        -   **Steps 4-7**: VSCodium & Antigravity Setup (Extensions & Settings).
        -   **Step 8**: Configure PowerShell 7 (Profile & Starship 'gruvbox-rainbow' preset).
        -   **Step 9**: Neovim Config (Copies `nvim` folder to LocalAppData).
        -   **Execute**: Check the boxes for the steps you want and click **Execute Selected Setup**.
    -   **GitHub Repos Tab**:
        -   Click **Fetch Repositories** (Ensures you are authenticated).
        -   Check the repositories you want to clone.
        -   Click **Clone Selected** (Defaults to `~/Documents/github-repo`).
    -   **Backup/Restore Tab**:
        -   **Export**: Saves Registry keys (Theme, Mouse, Explorer) and PowerShell profiles to `system-backup/`.
        -   **Import**: Restores settings from `system-backup/`.

## Requirements

- Windows 10/11
- Administrator privileges (requested automatically when needed for font installation or system changes).

## Project Structure

- `setup.ps1`: Main application script (WPF + Logic).
- `InstallScript.ps1`: Bulk package installer (WinGet).
- `export-setting.ps1` / `import-settings.ps1`: Backup logic.
- `nvim/`: Neovim configuration files.
- `terminal/`: Windows Terminal settings.

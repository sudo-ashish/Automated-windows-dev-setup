# Windows Development Environment Setup

Automated setup scripts to configure a consistent Windows development environment.

## Overview

This repository contains scripts and configuration files to quickly bootstrap a Windows machine for development. The main orchestration script is `setup_dev_env.ps1`.

## Features

-   **Automated Software Installation**: Uses Winget (via `InstallScript.ps1`) to install core tools like VSCodium, Git, Python, Node.js, and more.
-   **Font Setup**: Downloads and installs JetBrainsMono Nerd Font.
-   **VSCodium Configuration**: Installs extensions and syncs `settings.json`.
-   **Windows Terminal**: Configures terminal profile and settings.
-   **Shell Customization**: Sets up PowerShell with Starship prompt (`gruvbox-rainbow` preset).
-   **Neovim**: Deploys a pre-configured Neovim setup.
-   **SSH**: Generates an ED25519 SSH key and configures the ssh-agent.

## Prerequisites

-   Windows 10 or 11.
-   PowerShell (run as **Administrator**).
-   Internet connection.

## Usage

1.  Open PowerShell as Administrator.
2.  Navigate to this directory:
    ```powershell
    cd path\to\backup-scripts
    ```
3.  Run the setup script:
    ```powershell
    .\setup_dev_env.ps1
    ```
4.  Follow the interactive prompts. You can choose to proceed with or skip each step:
    -   Type `Y` and press Enter to run a step.
    -   Press Enter (or type `N`) to skip a step.

## Post-Installation

1.  **Restart your computer** to ensure all changes (especially fonts and path updates) take effect.
2.  After restarting, run the Chris Titus Tech Windows Utility (as suggested by the script):
    ```powershell
    irm https://christitus.com/win | iex
    ```

## Directory Structure

-   `setup_dev_env.ps1`: The main interactive setup script.
-   `InstallScript.ps1`: Helper script for bulk software installation via Winget.
-   `text-editor/`:
    -   `settings.json`: VSCodium user settings.
    -   `vscodium-extensions.txt`: List of VSCodium extensions to install.
-   `terminal/`:
    -   `settings.json`: Windows Terminal configuration.
-   `nvim/`: Neovim configuration files.

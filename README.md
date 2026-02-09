# Windows Development Environment Setup

Automated setup scripts to configure a consistent Windows development environment.

## Overview

This repository contains scripts and configuration files to quickly bootstrap a Windows machine for development. The main orchestration script is `setup_dev_env.ps1`.

## Features

-   **Automated Software Installation**: Uses Winget (via `InstallScript.ps1`) to install core tools.
-   **Git & GitHub**: Configures identity, installs GitHub CLI, and authenticates.
-   **Repo Cloning**: Interactive menu or file-based (`repos.txt`) cloning of GitHub repositories to `~/Projects`.
-   **Font Setup**: Downloads and installs JetBrainsMono Nerd Font.
-   **Editor Configuration**: 
    -   **VSCodium**: Installs extensions and syncs settings.
    -   **Antigravity**: Installs extensions and syncs settings.
    -   **Neovim**: Deploys a pre-configured Neovim setup.
-   **Shell Customization**:
    -   **Windows Terminal**: Configures terminal profile and settings.
    -   **Starship**: Sets up PowerShell with Starship prompt (`gruvbox-rainbow` preset).
-   **SSH**: Generates an ED25519 SSH key and configures the ssh-agent.

## Prerequisites

-   Windows 10 or 11.
-   PowerShell (run as **Administrator**).
-   Internet connection.
-   (Optional) `repos.txt`: A file with one repository URL per line for automated cloning.

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
4.  Follow the interactive prompts:
    -   **Step 1c (Repo Cloning)**: If `repos.txt` exists, it clones those repos. Otherwise, it presents a numbered menu of your GitHub repositories to choose from.
    -   **Other Steps**: Type `Y` to proceed or `N` to skip.

## Post-Installation

1.  **Restart your computer** to ensure all changes (especially fonts and path updates) take effect.

## Directory Structure

-   `setup_dev_env.ps1`: The main interactive setup script.
-   `InstallScript.ps1`: Bulk software installation via Winget.
-   `repos.txt`: (Optional) List of repositories to clone.
-   `text-editor/`: VSCodium settings and extensions list.
-   `antigravity-bak/`: Antigravity editor settings and extensions list.
-   `terminal/`: Windows Terminal configuration.
-   `nvim/`: Neovim configuration files.

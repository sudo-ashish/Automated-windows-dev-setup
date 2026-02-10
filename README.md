# Automated Windows Development Setup

This project automates the setup of a Windows development environment, installing tools like Git, GitHub CLI, VSCodium, Nerd Fonts, and configuring Windows Terminal with Starship.

## Features

- **Interactive TUI**: Choose specific setup steps or run a full automated setup.
- **Dependency Management**: Handles installation order correctly (e.g., installs Git before cloning repos).
- **Admin Handling**: Automatically requests Administrator privileges only when needed.
- **PowerShell 7 Support**: Configures profiles for both Windows PowerShell and PowerShell 7.
- **Font Installation**: Installs popular Nerd Fonts (JetBrainsMono, CascadiaCode, etc.).
- **Dotfile Management**: Syncs settings for VSCodium, Windows Terminal, and Neovim.

## Prerequisites

Before running the script, you must configure PowerShell to allow script execution.

1.  Open PowerShell as **Administrator** or **User** (depending on your preference, but User is fine as the script executes step 1 with user priviledge and elevates for others).
2.  Run the following command to allow local scripts:
    ```powershell
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
    ```

## How to Run

1.  Navigate to the project directory:
    ```powershell
    cd path\to\Automated-windows-dev-setup
    ```
2.  **Unblock the script** (important for files downloaded from the internet):
    ```powershell
    Unblock-File .\setup.ps1
    ```
3.  Execute the setup script:
    ```powershell
    .\setup.ps1
    ```

## Usage

Once started, you will see a menu:

-   **1-10**: Select individual steps to run specific tasks.
    -   **2a**: Setup Git Config (Name/Email)
    -   **2b**: Install Tools (GitHub CLI, FZF) & Login
    -   **2c**: Clone Repositories (Interactive FZF selection - Use TAB to multi-select)
    -   You can select multiple steps by entering comma-separated numbers (e.g., `2b,2c,8`).
-   **A**: Execute All (Recommended for fresh installs). automating the entire process.
-   **Q**: Quit.

## New Features

- **GitHub Integration**: Step 2 is now split for better control.
  - **Dynamic User**: Fetches your GitHub username automatically.
  - **FZF Support**: Uses `fzf` for interactive repository selection.
- **Bug Fixes**: Improved handling of `.config` directory creation and admin privileges for Step 1.

## Project Structure

-   `setup.ps1`: The main entry point script.
-   `import-settings.ps1`: Helper script to restore system settings/registry keys.
-   `codium-bak/`: Contains VSCodium extensions list and settings.json.
-   `antigravity-bak/`: Contains Antigravity extensions list and settings.json.
-   `terminal/`: Contains Windows Terminal settings.json.
-   `nvim/`: Neovim configuration directory.

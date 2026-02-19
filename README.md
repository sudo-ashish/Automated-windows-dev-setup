# 🚀 Automated Windows Development Setup

A simple, all-in-one tool to turn a fresh Windows installation into a powerful development environment. No more manual downloads or confusing configurations—just check the boxes and click Go!

---

## 🛠 Getting Started

### 1. Download the Project
Download this folder to your computer and unzip it if needed.

### 2. Run the Setup Tool
1. Right-click the file named `setup.ps1`.
2. Select **Run with PowerShell**.
3. If a window pops up asking about "Execution Policy," just press **Y** or **A** and hit Enter.

---

## 📱 How to Use the App

The app is divided into four easy-to-use tabs:

### 1. 📦 Software Tab
Choose from a curated list of popular developer tools like Chrome, VS Code, Discord, Python, and more. 
- **How to use:** Check the apps you want, then click **Install Selected**. A new window will open to handle the installation safely.

### 2. ⚙️ Setup Tab
This tab handles the "boring" configuration parts.
- **Git Config:** Type in your name and email so your code edits are attributed to you.
- **Tools (2a/2b):** Install helper tools like FZF and log into your GitHub account.
- **Fonts (3):** Automatically download and install high-quality coding fonts (Nerd Fonts).
- **Editors (4-9):** Installs pre-configured settings for VSCodium, Antigravity, and Neovim so they look and feel great immediately.

### 3. 🐙 GitHub Repos Tab
Easily bring your existing projects onto your new computer.
- **How to use:** After logging in (Step 2b in the Setup tab), click **Fetch Repositories**. Select the ones you want to clone and click **Clone Selected**. They will be saved to `Documents/github-repo`.

### 4. 💾 Backup/Restore Tab
Save your Windows "vibe"—including your theme, mouse settings, and custom taskbar configurations.
- **Export:** Saves your current Windows settings to the `system-backup` folder.
- **Import:** Restores settings from a previous backup. *Note: This will restart Explorer to apply changes.*

---

## 💡 Troubleshooting

**"The script says 'Execution Policy' prevents it from running."**
Open PowerShell as Administrator and paste the following command, then hit Enter:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

**"Do I need to be an Administrator?"**
Yes, it is recommended to run the script as an Administrator (Right-click PowerShell -> Run as Administrator) so it can install fonts and system settings properly.

---

## 📂 Project Structure

- `setup.ps1`: The main app window and logic.
- `export-setting.ps1` / `import-settings.ps1`: The engine behind the Backup/Restore tab.
- `nvim/`: Pre-made settings for the Neovim editor.
- `wt-defaults.json`: Modern settings for the Windows Terminal.
- `system-backup/`: Where your Windows settings are saved.

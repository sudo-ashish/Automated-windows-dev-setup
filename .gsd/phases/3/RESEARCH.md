# RESEARCH.md — Phase 3: Expansion

## Objectives
1. Implement the **Debloater** module (new feature).
2. Implement an **Update** module for system/winget updates.
3. Port the **GitHub Repository** logic from `setup.ps1`.

## 1. Debloater Logic (REQ-07)
Standard PowerShell debloating tasks:
- **Telemetry Removal**: Disable services like `DiagTrack` (Connected User Experiences and Telemetry).
- **Preinstalled Apps**: Use `Get-AppxPackage` and `Remove-AppxPackage` for common bloatware (Maps, People, etc.).
- **Bing Search**: Registry edit: `HKCU:\Software\Policies\Microsoft\Windows\Explorer\DisableSearchBoxSuggestions`.
- **Telemetry Registry**: Set `AllowTelemetry` to 0 in `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection`.

## 2. GitHub API (Ported)
- Current logic uses `gh` CLI.
- Tasks:
    - `Invoke-GitHubFetch`: Returns a list of repositories for the authenticated user.
    - `Invoke-GitHubClone`: Clones selected repositories to a target directory.
- Integration: The launcher should be able to run these headlessly (e.g., clone all repos or specific ones from config).

## 3. Updates (REQ-05)
- Logic: Check for winget updates.
- Command: `winget upgrade --all --include-unknown`.
- This can be a simple module that runs common update tasks.

## Refactor Pattern
Continue using the established module pattern:
```powershell
function Invoke-Debloat {
    param($Options)
    # Registry edits & Appx removal
}

function Invoke-GitHubRepos {
    param([string]$Action, [string[]]$RepoNames)
    # Fetch or Clone logic
}
```

## Challenges
- **External Dependencies**: GitHub module requires `gh` CLI.
- **Safety**: Debloating can be destructive. Ensure it's toggleable and logs everything clearly.
- **Interactivity**: `gh auth login` is interactive; fetching repos is not (if logged in).

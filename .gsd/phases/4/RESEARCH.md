# RESEARCH.md — Phase 4: UI Integration

## UI Strategy

### 1. Standalone XAML
The XAML will be moved from `setup.ps1` into `src/ui/Main.xaml`. This allows for cleaner separation and potentially easier editing (though we are editing via text).

### 2. UI Entry Point
A new module `src/ui/UIManager.ps1` will handle:
- Loading the XAML.
- Locating controls.
- Binding event handlers.
- Bridging the `Log` messages to the UI `LogBox`.

### 3. Integration with Modules
The UI will call functions from the ported modules:
- **Software**: Calls `Invoke-AppInstall -AppIds $selected`.
- **Setup**: Calls sub-functions from `src/modules/Setup.ps1` based on checkboxes.
- **GitHub**: Handles fetching via `Invoke-GitHubFetch` and updating the `RepoListView`.
- **Backups**: Calls `Invoke-Backup` or `Invoke-Restore`.

### 4. Shared Logging Bridge
The `Log` helper function in the original script needs to be reconciled with `src/core/Logger.ps1`.
- Proposed: `src/core/Logger.ps1` will have an optional callback or a global variable `$Global:UILogBox` that it writes to if present.

### 5. New Features in UI
- Add a "Debloat" tab or section to the UI to expose the new Debloater module functionality.
- Add an "Updates" button or status indicator.

## Component Breakdown
- `src/ui/Main.xaml`: Visual layout.
- `src/ui/WPFUtils.ps1`: Helpers for brush creation, control finding, etc.
- `src/ui/UIManager.ps1`: Main UI logic and event wiring.

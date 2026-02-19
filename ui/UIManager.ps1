function Invoke-GUI {
    Write-Log "Initializing winHelp v2 Interface..." -Level INFO
    
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase

    $xamlPath = Join-Path $Global:AppRoot "ui/Main.xaml"
    [xml]$xaml = Get-Content $xamlPath -Raw
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $Global:Window = [Windows.Markup.XamlReader]::Load($reader)

    # Locate Controls (Unified Registry)
    $controls = @(
        "MainTabControl", "StatusIndicator", "GlobalProgress", "LogBox",
        "GridSetup", "GridGit", "GridSystem", "GridSettings", "GridLogs",
        "AppCheckPanel", "InstallAppsBtn",
        "GitNameBox", "GitEmailBox", "SaveGitConfigBtn",
        "FetchReposBtn", "RepoListView", "CloneReposBtn",
        "DebloatTelemetry", "DebloatApps", "DebloatBing", "RunDebloatBtn",
        "ExportBtn", "ImportBtn", "RunUpdateBtn",
        "LogLevelSelector", "BackupPathBox", "SaveSettingsBtn"
    )
    
    $Global:UI = @{}
    foreach ($id in $controls) {
        $Global:UI[$id] = $Global:Window.FindName($id)
    }

    $Global:UILogBox = $Global:UI["LogBox"]

    # --- Helper: Background Task Runner ---
    function Run-BackgroundTask {
        param([scriptblock]$Script, [string]$BusyMsg)
        
        $Global:UI["StatusIndicator"].Text = $BusyMsg
        $Global:UI["GlobalProgress"].Visibility = "Visible"
        $Global:UI["GlobalProgress"].IsIndeterminate = $true
        
        # We use a simplified Start-ThreadJob or Start-Job approach for simulation
        # For true non-blocking in PS-WPF, Dispatchers are key.
        Start-ThreadJob -ScriptBlock {
            param($s, $root)
            $Global:AppRoot = $root
            # Import context
            Get-ChildItem -Path (Join-Path $Global:AppRoot "modules") -Filter "*.ps1" -Recurse | ForEach-Object { . $_.FullName }
            & $s
        } -ArgumentList $Script, $Global:AppRoot | Wait-ThreadJob | Out-Null
        
        $Global:UI["StatusIndicator"].Text = "Task Completed"
        $Global:UI["GlobalProgress"].Visibility = "Collapsed"
    }

    # --- Tab Navigation Logic ---
    $Global:UI["MainTabControl"].Add_SelectionChanged({
            $tabs = @("Setup", "Git", "System", "Settings", "Logs")
            $selectedIndex = $Global:UI["MainTabControl"].SelectedIndex
        
            foreach ($t in $tabs) { $Global:UI["Grid$t"].Visibility = "Collapsed" }
            $target = "Grid$($tabs[$selectedIndex])"
            $Global:UI[$target].Visibility = "Visible"
        })

    # --- App Checkboxes Initialization ---
    if ($Global:AppDefinitions) {
        foreach ($app in $Global:AppDefinitions) {
            $cb = New-Object System.Windows.Controls.CheckBox
            $cb.Content = $app.Name
            $cb.Width = 200
            $cb.Margin = "10"
            $Global:UI["AppCheckPanel"].Children.Add($cb) | Out-Null
            $Global:UI["AppCheck_$($app.Id)"] = $cb
        }
    }

    # --- Event Handlers ---

    $Global:UI["InstallAppsBtn"].Add_Click({
            $selected = $Global:AppDefinitions | Where-Object { $Global:UI["AppCheck_$($_.Id)"].IsChecked }
            if ($selected) {
                Run-BackgroundTask { Invoke-AppInstall -AppIds $using:selected.Id } "Installing Applications..."
            }
        })

    $Global:UI["SaveGitConfigBtn"].Add_Click({
            $Global:Config.settings.user.name = $Global:UI["GitNameBox"].Text
            $Global:Config.settings.user.email = $Global:UI["GitEmailBox"].Text
            Set-GitConfig
            Write-Log "Git Identity Updated." -Level INFO
        })

    $Global:UI["FetchReposBtn"].Add_Click({
            Run-BackgroundTask { 
                $repos = Invoke-GitHubFetch
                # (In a real implementation, we'd marshals this back to UI)
                Write-Log "Fetched $($repos.Count) Repos" -Level INFO
            } "Fetching Repositories..."
        })

    $Global:UI["RunDebloatBtn"].Add_Click({
            Run-BackgroundTask { Invoke-Debloat } "Optimizing System..."
        })

    # Initialize Settings View
    $Global:UI["BackupPathBox"].Text = $Global:Config.settings.backup_dir
    "INFO", "WARN", "ERROR", "DEBUG" | ForEach-Object { $Global:UI["LogLevelSelector"].Items.Add($_) | Out-Null }
    $Global:UI["LogLevelSelector"].SelectedItem = $Global:Config.settings.log_level

    Write-Log "winHelp v2 Ready." -Level INFO
    $Global:Window.ShowDialog() | Out-Null
}

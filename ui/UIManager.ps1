function Invoke-GUI {
    Write-Log "Initializing WPF Interface..." -Level INFO
    
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase

    if (-not $Global:AppRoot) { $Global:AppRoot = Resolve-Path (Join-Path $PSScriptRoot "../..") }
    $xamlPath = Join-Path $Global:AppRoot "ui/Main.xaml"
    if (-not (Test-Path $xamlPath)) {
        Write-Log "XAML file not found: $xamlPath" -Level ERROR
        return
    }

    try {
        [xml]$xaml = Get-Content $xamlPath -Raw
        $reader = (New-Object System.Xml.XmlNodeReader $xaml)
        $Global:Window = [Windows.Markup.XamlReader]::Load($reader)

        # Locate Controls
        $controls = @(
            "GitNameBox", "GitEmailBox", "FontSelector", 
            "Step2a", "Step2b", "Step3", "Step4", "Step5", "Step6", "Step7", "Step8", "Step9",
            "RunSetupBtn", 
            "FetchReposBtn", "RepoListView", "CloneReposBtn",
            "ExportBtn", "ImportBtn", "BackupTheme", "BackupExplorer", "BackupMouse", "BackupProfile",
            "LogBox", "ThemeToggle", "RestartBtn", "ClearAllBtn", "TitleBar", "CloseBtn",
            "AppCheckPanel", "SelectAllAppsBtn", "DeselectAllAppsBtn", "InstallAppsBtn",
            "SelectAllStepsBtn", "DeselectAllStepsBtn",
            "DebloatTelemetry", "DebloatApps", "DebloatBing", "RunDebloatBtn"
        )
        
        $Global:UIElements = @{}
        foreach ($id in $controls) {
            Write-Log "Finding control: $id" -Level DEBUG
            $Global:UIElements[$id] = $Global:Window.FindName($id)
        }

        # Set Global LogBox for Logger.ps1
        $Global:UILogBox = $Global:UIElements["LogBox"]

        # Dynamically create app checkboxes
        if ($Global:AppDefinitions) {
            foreach ($app in $Global:AppDefinitions) {
                $cb = New-Object System.Windows.Controls.CheckBox
                $cb.Content = $app.Name
                $cb.Width = 220
                $cb.Margin = [System.Windows.Thickness]::new(5)
                $Global:UIElements["AppCheckPanel"].Children.Add($cb) | Out-Null
                $Global:UIElements["AppCheck_$($app.Id)"] = $cb
            }
        }

        # --- Event Handlers ---

        # Title / Header
        $Global:UIElements["TitleBar"].Add_MouseLeftButtonDown({
                if ($_.ClickCount -eq 2) {
                    if ($Global:Window.WindowState -eq "Maximized") {
                        $Global:Window.WindowState = "Normal"
                    }
                    else {
                        $Global:Window.WindowState = "Maximized"
                    }
                }
                else {
                    $Global:Window.DragMove()
                }
            })
        $Global:UIElements["CloseBtn"].Add_Click({
                Write-Log "Closing GUI..." -Level INFO
                $Global:Window.Close()
            })

        $Global:UIElements["ClearAllBtn"].Add_Click({
                Write-Log "Clearing all UI checkboxes..." -Level INFO
                foreach ($key in $Global:UIElements.Keys) {
                    $ctrl = $Global:UIElements[$key]
                    if ($null -eq $ctrl) { continue }
                    if ($ctrl.GetType().Name -eq "CheckBox") {
                        $ctrl.IsChecked = $false
                    }
                }
            })

        # Tab: Software
        $Global:UIElements["SelectAllAppsBtn"].Add_Click({ 
                foreach ($app in $Global:AppDefinitions) { $Global:UIElements["AppCheck_$($app.Id)"].IsChecked = $true } 
            })
        $Global:UIElements["DeselectAllAppsBtn"].Add_Click({ 
                foreach ($app in $Global:AppDefinitions) { $Global:UIElements["AppCheck_$($app.Id)"].IsChecked = $false } 
            })
        $Global:UIElements["InstallAppsBtn"].Add_Click({
                $selected = $Global:AppDefinitions | Where-Object { $Global:UIElements["AppCheck_$($_.Id)"].IsChecked }
                if ($selected.Count -gt 0) {
                    Invoke-AppInstall -AppIds $selected.Id
                }
                else {
                    Write-Log "No apps selected for installation." -Level WARN
                }
            })

        # Tab: Setup
        $Global:UIElements["SelectAllStepsBtn"].Add_Click({
                "Step2a", "Step2b", "Step3", "Step4", "Step5", "Step6", "Step7", "Step8", "Step9" | ForEach-Object { $Global:UIElements[$_].IsChecked = $true }
            })
        $Global:UIElements["DeselectAllStepsBtn"].Add_Click({
                "Step2a", "Step2b", "Step3", "Step4", "Step5", "Step6", "Step7", "Step8", "Step9" | ForEach-Object { $Global:UIElements[$_].IsChecked = $false }
            })
        $Global:UIElements["RunSetupBtn"].Add_Click({
                Write-Log "Running selected setup tasks..." -Level INFO
            
                # Sync config with UI values
                $Global:Config.settings.user.name = $Global:UIElements["GitNameBox"].Text
                $Global:Config.settings.user.email = $Global:UIElements["GitEmailBox"].Text
            
                if ($Global:UIElements["Step2a"].IsChecked) { Set-GitConfig; Install-Tools }
                if ($Global:UIElements["Step2b"].IsChecked) { Start-Process "gh" -ArgumentList "auth login" -Wait }
                if ($Global:UIElements["Step3"].IsChecked) { Install-NerdFont } # Note: Need to pass Selector value if possible
                if ($Global:UIElements["Step4"].IsChecked -or $Global:UIElements["Step5"].IsChecked -or $Global:UIElements["Step6"].IsChecked -or $Global:UIElements["Step7"].IsChecked -or $Global:UIElements["Step9"].IsChecked) {
                    Sync-EditorSettings
                }
                if ($Global:UIElements["Step8"].IsChecked) { Set-TerminalDefaults }
            
                Write-Log "Setup tasks finished." -Level INFO
            })

        # Tab: GitHub
        $Global:UIElements["FetchReposBtn"].Add_Click({
                $repos = Invoke-GitHubFetch
                if ($repos) {
                    $RepoCollection = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
                    foreach ($r in $repos) {
                        $item = New-Object PSObject
                        $name = if ($r.nameWithOwner) { $r.nameWithOwner } else { $r.name }
                        $url = if ($r.url) { $r.url } else { $r.sshUrl }
                        $item | Add-Member -NotePropertyName Name -NotePropertyValue $name
                        $item | Add-Member -NotePropertyName Display -NotePropertyValue "$name ($($r.visibility))"
                        $item | Add-Member -NotePropertyName Url -NotePropertyValue $url
                        $item | Add-Member -NotePropertyName IsSelected -NotePropertyValue $false
                        $RepoCollection.Add($item)
                    }
                    $Global:UIElements["RepoListView"].ItemsSource = $RepoCollection
                }
            })
        $Global:UIElements["CloneReposBtn"].Add_Click({
                $selected = $Global:UIElements["RepoListView"].ItemsSource | Where-Object { $_.IsSelected }
                if ($selected) {
                    Invoke-GitHubClone -RepoNames $selected.Name
                }
                else {
                    Write-Log "No repositories selected." -Level WARN
                }
            })

        # Tab: Backup
        $Global:UIElements["ExportBtn"].Add_Click({
                Invoke-Backup -Theme:$Global:UIElements["BackupTheme"].IsChecked `
                    -Explorer:$Global:UIElements["BackupExplorer"].IsChecked `
                    -Mouse:$Global:UIElements["BackupMouse"].IsChecked `
                    -PSProfile:$Global:UIElements["BackupProfile"].IsChecked
            })
        $Global:UIElements["ImportBtn"].Add_Click({
                Invoke-Restore -Theme:$Global:UIElements["BackupTheme"].IsChecked `
                    -Explorer:$Global:UIElements["BackupExplorer"].IsChecked `
                    -Mouse:$Global:UIElements["BackupMouse"].IsChecked `
                    -PSProfile:$Global:UIElements["BackupProfile"].IsChecked
            })

        # Tab: Debloat
        $Global:UIElements["RunDebloatBtn"].Add_Click({
                # Temporary override config for UI call
                $origTelemetry = $Global:Config.modules.debloat.telemetry_disable
                $origApps = $Global:Config.modules.debloat.bloatware_removal
                $origBing = $Global:Config.modules.debloat.bing_search_disable
                
                $Global:Config.modules.debloat.telemetry_disable = $Global:UIElements["DebloatTelemetry"].IsChecked
                $Global:Config.modules.debloat.bloatware_removal = $Global:UIElements["DebloatApps"].IsChecked
                $Global:Config.modules.debloat.bing_search_disable = $Global:UIElements["DebloatBing"].IsChecked
            
                Invoke-Debloat
            
                $Global:Config.modules.debloat.telemetry_disable = $origTelemetry
                $Global:Config.modules.debloat.bloatware_removal = $origApps
                $Global:Config.modules.debloat.bing_search_disable = $origBing
            })

        # Global
        $Global:UIElements["ThemeToggle"].Add_Click({
                $isDark = $Global:UIElements["ThemeToggle"].IsChecked
                $res = $Global:Window.Resources
                $Convert = [System.Windows.Media.BrushConverter]::new()
                $NewBrush = { param($hex) return $Convert.ConvertFromString($hex) }

                if ($isDark) {
                    $res["WindowBackground"] = & $NewBrush "#1E1E1E"
                    $res["ControlBackground"] = & $NewBrush "#252526"
                    $res["ControlBorder"] = & $NewBrush "#3E3E3E"
                    $res["TextPrimary"] = & $NewBrush "#F1F1F1"
                    $res["TextSecondary"] = & $NewBrush "#BBBBBB"
                    $res["ScrollThumb"] = & $NewBrush "#555555"
                }
                else {
                    $res["WindowBackground"] = & $NewBrush "#FAFAFA"
                    $res["ControlBackground"] = & $NewBrush "#FFFFFF"
                    $res["ControlBorder"] = & $NewBrush "#DDDDDD"
                    $res["TextPrimary"] = & $NewBrush "#333333"
                    $res["TextSecondary"] = & $NewBrush "#666666"
                    $res["ScrollThumb"] = & $NewBrush "#CCCCCC"
                }
            })

        $Global:UIElements["RestartBtn"].Add_Click({
                Write-Log "Restarting via GUI..." -Level INFO
                Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$($PSCommandPath)`""
                $Global:Window.Close()
            })

        Write-Log "GUI Ready. Welcome to Automated Setup." -Level INFO
        $Global:Window.ShowDialog() | Out-Null

    }
    catch {
        Write-Log "Failed to load GUI: $($_.Exception.Message)" -Level ERROR
        Write-Log "Stack: $($_.ScriptStackTrace)" -Level DEBUG
    }
}

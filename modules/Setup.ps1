function Set-GitConfig {
    $name = if ($Global:Config.settings.user.name) { $Global:Config.settings.user.name } else { "User Name" }
    $email = if ($Global:Config.settings.user.email) { $Global:Config.settings.user.email } else { "user@email.com" }
    
    Write-Log "Setting Git Config: $name / $email" -Level INFO
    git config --global user.name "$name"
    git config --global user.email "$email"
}

function Install-Tools {
    Write-Log "Installing GH CLI and FZF..." -Level INFO
    if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) { 
        Start-Process winget -ArgumentList "install GitHub.cli -e --silent --accept-source-agreements --accept-package-agreements" -Wait -NoNewWindow
        Write-Log "Installed GH CLI" -Level INFO
    }
    if (-not (Get-Command "fzf" -ErrorAction SilentlyContinue)) { 
        Start-Process winget -ArgumentList "install junegunn.fzf -e --silent --accept-source-agreements --accept-package-agreements" -Wait -NoNewWindow
        Write-Log "Installed FZF" -Level INFO
    }
}

function Install-NerdFont {
    $fontName = "JetBrainsMono" # Default or from config
    Write-Log "Installing Font: $fontName" -Level INFO
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$fontName.zip"
    $zipPath = Join-Path $env:TEMP "$fontName.zip"
    $extractPath = Join-Path $env:TEMP "$fontName"
    
    try {
        Write-Log "Downloading $url..." -Level DEBUG
        Invoke-WebRequest -Uri $url -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
        $files = Get-ChildItem -Path $extractPath -Include "*.ttf", "*.otf" -Recurse
        foreach ($f in $files) {
            if (-not (Test-Path "C:\Windows\Fonts\$($f.Name)")) {
                Write-Log "Copying $($f.Name)..." -Level DEBUG
                Copy-Item $f.FullName -Destination "C:\Windows\Fonts" -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $f.Name -Value $f.Name -PropertyType String -Force | Out-Null
            }
        }
        Write-Log "Font Installation Complete." -Level INFO
    }
    catch {
        Write-Log "Font Install Failed: $($_.Exception.Message)" -Level ERROR
    }
}

function Install-IdeExtensions {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ActiveIde
    )

    Write-Log "Installing extensions for IDE: $ActiveIde" -Level INFO
    $extensions = $Global:Config.modules.ide.extensions.$ActiveIde

    if (-not $extensions -or $extensions.Count -eq 0) {
        Write-Log "No extensions defined or enabled for $ActiveIde." -Level INFO
        return
    }

    $binMap = @{
        "vscodium" = "codium"
        "antigravity" = "antigravity"
        "vscode" = "code"
    }

    $bin = if ($binMap.ContainsKey($ActiveIde.ToLower())) { $binMap[$ActiveIde.ToLower()] } else { $ActiveIde }

    if (-not (Get-Command $bin -ErrorAction SilentlyContinue)) {
        Write-Log "Target IDE binary '$bin' not found in PATH. Skipping extensions." -Level WARN
        return
    }

    foreach ($ext in $extensions) {
        Write-Log "Installing $ActiveIde extension: $ext" -Level DEBUG
        Start-Process $bin -ArgumentList "--install-extension `"$ext`" --force" -Wait -NoNewWindow
    }
    Write-Log "Extension installation for $ActiveIde complete." -Level INFO
}

function Set-TerminalDefaults {
    Write-Log "Merging Terminal Defaults..." -Level INFO
    try {
        $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        $defaultsPath = Join-Path $AppRoot "assets/wt-defaults.json"

        if (Test-Path $settingsPath) {
            if (Test-Path $defaultsPath) {
                $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
                $newDefaults = Get-Content $defaultsPath -Raw | ConvertFrom-Json

                if (-not $settings.PSObject.Properties["profiles"]) { $settings | Add-Member -NotePropertyName profiles -NotePropertyValue (@{}) }
                if (-not $settings.profiles.PSObject.Properties["defaults"]) { $settings.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue (@{}) }

                foreach ($prop in $newDefaults.PSObject.Properties) {
                    if ($settings.profiles.defaults.PSObject.Properties[$prop.Name]) {
                        $settings.profiles.defaults.$($prop.Name) = $prop.Value
                    }
                    else {
                        $settings.profiles.defaults | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
                    }
                }

                $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath
                Write-Log "Terminal defaults merged successfully." -Level INFO
            }
            else {
                Write-Log "wt-defaults.json not found at $defaultsPath" -Level WARN
            }
        }
        else {
            Write-Log "Windows Terminal settings.json not found." -Level WARN
        }
    }
    catch {
        Write-Log "Failed to merge terminal settings: $($_.Exception.Message)" -Level ERROR
    }
}

function Sync-EditorSettings {
    Write-Log "Syncing Editor Settings..." -Level INFO
    
    # Neovim
    $nvSrc = Join-Path $AppRoot "assets/deps/nvim"
    if (Test-Path $nvSrc) {
        Write-Log "Copying Neovim config..." -Level INFO
        Copy-Item -Path $nvSrc -Destination "$env:LOCALAPPDATA\nvim" -Recurse -Force
    }

    # VSCodium
    $codiumSrc = Join-Path $AppRoot "assets/deps/codium/settings.json"
    if (Test-Path $codiumSrc) {
        $dest = "$env:APPDATA\VSCodium\User\settings.json"
        $destDir = Split-Path $dest
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        Copy-Item $codiumSrc $dest -Force
        Write-Log "VSCodium settings applied." -Level INFO
    }

    # Antigravity
    $antiSrc = Join-Path $AppRoot "assets/deps/antigravity/settings.json"
    if (Test-Path $antiSrc) {
        $dest = "$env:APPDATA\Antigravity\User\settings.json"
        $destDir = Split-Path $dest
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        Copy-Item $antiSrc $dest -Force
        Write-Log "Antigravity settings applied." -Level INFO
    }
}

function Invoke-Setup {
    param($Flags)

    Write-Log "Starting System Setup..." -Level INFO

    if ($Global:Config.settings.setup.git_config) { Set-GitConfig }
    if ($Global:Config.settings.setup.install_tools) { Install-Tools }
    if ($Global:Config.settings.setup.fonts) { Install-NerdFont }
    if ($Global:Config.settings.setup.terminal_defaults) { Set-TerminalDefaults }
    if ($Global:Config.settings.setup.editor_configs) { Sync-EditorSettings }

    Write-Log "System Setup completed." -Level INFO
}

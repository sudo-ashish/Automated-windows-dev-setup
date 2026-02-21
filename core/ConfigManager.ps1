$Global:Config = $null
$Global:ConfigPath = (Join-Path $PSScriptRoot "../config.json")

function Load-Config {
    param(
        [string]$Path = $Global:ConfigPath
    )

    if (Test-Path $Path) {
        try {
            $json = Get-Content $Path -Raw
            $Global:Config = $json | ConvertFrom-Json
            Write-Log "Configuration loaded from $Path" -Level INFO
        }
        catch {
            Write-Log "Failed to parse config.json: $($_.Exception.Message)" -Level ERROR
            exit 1
        }
    }
    else {
        Write-Log "config.json not found at $Path" -Level ERROR
        exit 1
    }

    # Ensure required IDE extensions structure exists safely
    $configChanged = $false
    
    if (-not $Global:Config.PSObject.Properties['modules']) {
        $Global:Config | Add-Member -NotePropertyName modules -NotePropertyValue @{}
        $configChanged = $true
    }
    
    if (-not $Global:Config.modules.PSObject.Properties['ide']) {
        $Global:Config.modules | Add-Member -NotePropertyName ide -NotePropertyValue @{}
        $configChanged = $true
    }
    
    if (-not $Global:Config.modules.ide.PSObject.Properties['extensions']) {
        $Global:Config.modules.ide | Add-Member -NotePropertyName extensions -NotePropertyValue @{}
        $configChanged = $true
    }

    # Migration from legacy text files if the extension config is empty
    $AppRoot = Resolve-Path (Join-Path $PSScriptRoot "../")
    
    # Check vscodium text file
    if (-not $Global:Config.modules.ide.extensions.PSObject.Properties['vscodium']) {
        $LegacyCod = Join-Path $AppRoot "assets/deps/codium/vscodium-extensions.txt"
        $codList = @()
        if (Test-Path $LegacyCod) {
            $codList = Get-Content $LegacyCod | Where-Object { $_ -match "\S" }
            Write-Log "Migrated vscodium extensions from legacy file." -Level INFO
        }
        $Global:Config.modules.ide.extensions | Add-Member -NotePropertyName 'vscodium' -NotePropertyValue $codList
        $configChanged = $true
    }

    # Check antigravity text file
    if (-not $Global:Config.modules.ide.extensions.PSObject.Properties['antigravity']) {
        $LegacyAnti = Join-Path $AppRoot "assets/deps/antigravity/antigravity-extensions.txt"
        $antiList = @()
        if (Test-Path $LegacyAnti) {
            $antiList = Get-Content $LegacyAnti | Where-Object { $_ -match "\S" }
            Write-Log "Migrated antigravity extensions from legacy file." -Level INFO
        }
        $Global:Config.modules.ide.extensions | Add-Member -NotePropertyName 'antigravity' -NotePropertyValue $antiList
        $configChanged = $true
    }

    if ($configChanged) {
        Save-Config -Path $Path
        Write-Log "Config structure updated/migrated successfully." -Level INFO
    }
}

function Save-Config {
    param(
        [string]$Path = $Global:ConfigPath
    )

    if ($null -ne $Global:Config) {
        try {
            $Global:Config | ConvertTo-Json -Depth 10 | Out-File -FilePath $Path -Encoding UTF8
            Write-Log "Configuration saved to $Path" -Level DEBUG
        }
        catch {
            Write-Log "Failed to save configuration: $($_.Exception.Message)" -Level ERROR
        }
    }
}

function Test-FeatureEnabled {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FeatureName
    )

    if ($null -eq $Global:Config) {
        Load-Config
    }

    if ($Global:Config.features.PSObject.Properties[$FeatureName]) {
        return $Global:Config.features.$FeatureName
    }

    return $false
}

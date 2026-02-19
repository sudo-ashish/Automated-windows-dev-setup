$Global:Config = $null

function Load-Config {
    param(
        [string]$ConfigPath = (Join-Path $PSScriptRoot "../../config.json")
    )

    if (Test-Path $ConfigPath) {
        try {
            $json = Get-Content $ConfigPath -Raw
            $Global:Config = $json | ConvertFrom-Json
            Write-Log "Configuration loaded from $ConfigPath" -Level INFO
        }
        catch {
            Write-Log "Failed to parse config.json: $($_.Exception.Message)" -Level ERROR
            exit 1
        }
    }
    else {
        Write-Log "config.json not found at $ConfigPath" -Level ERROR
        exit 1
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

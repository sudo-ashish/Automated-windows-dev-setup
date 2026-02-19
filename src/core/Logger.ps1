function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] [$Level] $Message"

    # Console output with color
    $color = switch ($Level) {
        "INFO" { "Cyan" }
        "WARN" { "Yellow" }
        "ERROR" { "Red" }
        "DEBUG" { "Gray" }
        Default { "White" }
    }
    Write-Host $logLine -ForegroundColor $color

    # File output
    $logDir = Join-Path $PSScriptRoot "../../logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $logFile = Join-Path $logDir ("winHelp_" + (Get-Date -Format "yyyy-MM-dd") + ".log")
    Add-Content -Path $logFile -Value $logLine
}


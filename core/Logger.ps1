function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] [$Level] $Message"

    # Console output
    $color = "Gray"
    switch ($Level) {
        "WARN" { $color = "Yellow" }
        "ERROR" { $color = "Red" }
        "DEBUG" { $color = "DarkGray" }
        "INFO" { $color = "Cyan" }
    }
    Write-Host $logLine -ForegroundColor $color

    # UI output if available
    if ($Global:UILogBox) {
        $Global:UILogBox.Dispatcher.Invoke({
                $Global:UILogBox.AppendText("$logLine`r`n")
                $Global:UILogBox.ScrollToEnd()
            })
    }

    # File output
    $logDir = Join-Path $Global:AppRoot "build/logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $logFile = Join-Path $logDir ("winHelp_" + (Get-Date -Format "yyyy-MM-dd") + ".log")
    try {
        Add-Content -Path $logFile -Value $logLine -ErrorAction SilentlyContinue
    }
    catch {
        # Fallback if file is locked
    }
}

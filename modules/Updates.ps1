function Invoke-Update {
    Write-Log "Checking for system and package updates..." -Level INFO

    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        Write-Log "Running Winget upgrade..." -Level INFO
        # We run upgrade --all. 
        # Note: In a headless script, we use --accept-source-agreements and --accept-package-agreements
        $process = Start-Process winget -ArgumentList "upgrade", "--all", "--accept-source-agreements", "--accept-package-agreements", "--silent" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Log "Winget updates completed successfully." -Level INFO
        }
        elseif ($process.ExitCode -eq -1978335189) {
            Write-Log "No updates found." -Level INFO
        }
        else {
            Write-Log "Winget upgrade finished with exit code: $($process.ExitCode)" -Level WARN
        }
    }
    else {
        Write-Log "Winget not found. Skipping package updates." -Level WARN
    }

    Write-Log "Update process finished." -Level INFO
}

<#
.SYNOPSIS
    winHelp Bootstrap - Remote installer and initialization script.
.DESCRIPTION
    Ensures environment readiness, fetches the latest winHelp release/repo,
    and hands off execution to the main launcher.
#>

$TargetDir = Join-Path $env:USERPROFILE "Downloads/winHelp"
$RepoUrl = "https://github.com/sudo-ashish/winHelp" # Placeholder URL

function Write-BootstrapLog {
    param($Msg, $Color = "Cyan")
    Write-Host "[Bootstrap] $Msg" -ForegroundColor $Color
}

Write-BootstrapLog "Starting winHelp Bootstrap..." 

# 1. Administrator Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-BootstrapLog "Please run PowerShell as Administrator to use winHelp." "Red"
    exit
}

# 2. Ensure Target Directory
if (-not (Test-Path $TargetDir)) {
    Write-BootstrapLog "Creating target directory: $TargetDir"
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

Set-Location $TargetDir

# 3. Source Integrity / Download
if (Test-Path ".git") {
    Write-BootstrapLog "Existing repository found. Pulling latest changes..."
    git pull origin main
}
else {
    Write-BootstrapLog "Downloading latest version..."
    # If git is available, clone. Otherwise download ZIP.
    if (Get-Command "git" -ErrorAction SilentlyContinue) {
        git clone $RepoUrl .
    }
    else {
        Write-BootstrapLog "Git not found, downloading ZIP..."
        $zipFile = Join-Path $env:TEMP "winHelp.zip"
        Invoke-WebRequest -Uri "$RepoUrl/archive/refs/heads/main.zip" -OutFile $zipFile
        Expand-Archive -Path $zipFile -DestinationPath "." -Force
        # Move files from subfolder if expanded with one
        $subFolder = Get-ChildItem -Directory | Where-Object { $_.Name -like "winHelp-*" }
        if ($subFolder) {
            Get-ChildItem -Path $subFolder.FullName | Move-Item -Destination "." -Force
            Remove-Item $subFolder.FullName -Recurse -Force
        }
    }
}

# 4. Initialize Config
if (-not (Test-Path "config.json")) {
    Write-BootstrapLog "Initializing default config.json..."
    # In a real scenario, we'd copy a template. Here we assume one exists or create a basic one.
    $defaultConfig = @{
        settings = @{
            log_level  = "INFO"
            theme      = "Dark"
            backup_dir = "build/snapshots"
            user       = @{ name = ""; email = "" }
            setup      = @{
                git_config        = $true
                install_tools     = $true
                fonts             = $true
                terminal_defaults = $true
                editor_configs    = $true
            }
        }
        modules  = @{
            debloat = @{
                telemetry_disable   = $true
                bloatware_removal   = $true
                bing_search_disable = $true
            }
        }
    }
    $defaultConfig | ConvertTo-Json -Depth 10 | Out-File "config.json" -Encoding UTF8
}

# 5. Hand-off to Launcher
Write-BootstrapLog "Environment ready. Launching winHelp..." "Green"
powershell -ExecutionPolicy Bypass -File "launcher.ps1"

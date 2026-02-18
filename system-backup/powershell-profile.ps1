# ================================
# Settings
# ================================

$AutoInstall = $true   # set false if you want no installs
$AskBeforeInstall = $false


# ================================
# Helper Functions
# ================================

function Confirm-Install($name) {
    if (-not $AskBeforeInstall) { return $true }

    $ans = Read-Host "$name missing. Install? (y/n)"
    return $ans -eq 'y'
}


function Install-Binary {
    param(
        [string]$Name,
        [string]$WingetId
    )

    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        return
    }

    if (-not $AutoInstall) {
        Write-Warning "$Name not found"
        return
    }

    if (-not (Confirm-Install $Name)) {
        return
    }

    Write-Host "Installing $Name..." -ForegroundColor Cyan

    try {
        winget install --id $WingetId `
            --silent `
            --accept-source-agreements `
            --accept-package-agreements

        # Refresh PATH
        $env:Path =
            [Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
            [Environment]::GetEnvironmentVariable("Path","User")
    }
    catch {
        Write-Warning "Failed to install $Name"
    }
}


function Install-PSModule {
    param(
        [string]$Name
    )

    if (Get-Module -ListAvailable -Name $Name) {
        return
    }

    if (-not $AutoInstall) {
        Write-Warning "Module $Name missing"
        return
    }

    if (-not (Confirm-Install $Name)) {
        return
    }

    Write-Host "Installing $Name..." -ForegroundColor Cyan

    try {
        if ((Get-PSRepository PSGallery).InstallationPolicy -ne 'Trusted') {
            Set-PSRepository PSGallery -InstallationPolicy Trusted
        }

        Install-Module $Name `
            -Scope CurrentUser `
            -Force `
            -AllowClobber
    }
    catch {
        Write-Warning "Failed to install $Name"
    }
}


# ================================
# Dependency Lists
# ================================

$binaries = @(
    @{ Name="oh-my-posh"; Id="JanDeDobbeleer.OhMyPosh" },
    @{ Name="zoxide";     Id="ajeetdsouza.zoxide" }
)

$modules = @(
    "Terminal-Icons",
    "PSReadLine"
)


# ================================
# Install Dependencies (Loop)
# ================================

foreach ($bin in $binaries) {
    Install-Binary $bin.Name $bin.Id
}

foreach ($mod in $modules) {
    Install-PSModule $mod
}


# ================================
# Initialization
# ================================

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh `
        --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json' |
        Invoke-Expression
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { zoxide init powershell | Out-String })
}


# ================================
# Imports
# ================================

foreach ($mod in $modules) {
    Import-Module $mod -ErrorAction SilentlyContinue
}


# ================================
# PSReadLine Config
# ================================

if (Get-Module PSReadLine) {

    Set-PSReadLineOption `
        -PredictionSource History `
        -PredictionViewStyle ListView `
        -HistoryNoDuplicates `
        -MaximumHistoryCount 10000

    Set-PSReadLineKeyHandler UpArrow   HistorySearchBackward
    Set-PSReadLineKeyHandler DownArrow HistorySearchForward
}

function Update-PowerShell {
    # If function "Update-PowerShell_Override" is defined in profile.ps1 file
    # then call it instead.
    if (Get-Command -Name "Update-PowerShell_Override" -ErrorAction SilentlyContinue) {
        Update-PowerShell_Override
    } else {
        try {
            Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
            $updateNeeded = $false
            $currentVersion = $PSVersionTable.PSVersion.ToString()
            $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
            $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
            $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
            if ($currentVersion -lt $latestVersion) {
                $updateNeeded = $true
            }

            if ($updateNeeded) {
                Write-Host "Updating PowerShell..." -ForegroundColor Yellow
                Start-Process powershell.exe -ArgumentList "-NoProfile -Command winget upgrade Microsoft.PowerShell --accept-source-agreements --accept-package-agreements" -Wait -NoNewWindow
                Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
            } else {
                Write-Host "Your PowerShell is up to date." -ForegroundColor Green
            }
        } catch {
            Write-Error "Failed to update PowerShell. Error: $_"
        }
    }
}

# ================================
# Utility Functions
# ================================

function touch($file) {
    New-Item -ItemType File -Path $file -Force | Out-Null
}

function ff($name) {
    Get-ChildItem -Recurse `
        -Filter "*$name*" `
        -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName
}

function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name) {
    Get-Process $name
}

# Quick Access to Editing the Profile
function Edit-Profile {
    vim $PROFILE.CurrentUserAllHosts
}

function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

# Quick Access to System Information
function sysinfo { Get-ComputerInfo }

Set-Alias -Name ep -Value Edit-Profile

# Navigation Shortcuts
function docs {
    $docs = if(([Environment]::GetFolderPath("MyDocuments"))) {([Environment]::GetFolderPath("MyDocuments"))} else {$HOME + "\Documents"}
    Set-Location -Path $docs
}

function dtop {
    $dtop = if ([Environment]::GetFolderPath("Desktop")) {[Environment]::GetFolderPath("Desktop")} else {$HOME + "\Documents"}
    Set-Location -Path $dtop
}

# Directory Management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }

# Simplified Process Management
function k9 { Stop-Process -Name $args[0] }

# Enhanced Listing
function la { Get-ChildItem | Format-Table -AutoSize }
function ll { Get-ChildItem -Force | Format-Table -AutoSize }


# Git Shortcuts
function gs { git status }

function ga { git add . }

function gc { param($m) git commit -m "$m" }

function gpush { git push }

function gpull { git pull }

function g { __zoxide_z github }

function gcl { git clone "$args" }

function gcom {
    git add .
    git commit -m "$args"
}

function lazyg {
    git add .
    git commit -m "$args"
    git push
}



# Help Function
function Show-Help {
    $helpText = @"
$($PSStyle.Foreground.Cyan)PowerShell Profile Help$($PSStyle.Reset)
$($PSStyle.Foreground.Yellow)=======================$($PSStyle.Reset)
$($PSStyle.Foreground.Green)Edit-Profile$($PSStyle.Reset) - Opens the current user's profile for editing using the configured editor.
$($PSStyle.Foreground.Green)Update-PowerShell$($PSStyle.Reset) - Checks for the latest PowerShell release and updates if a new version is available.

$($PSStyle.Foreground.Cyan)Git Shortcuts$($PSStyle.Reset)
$($PSStyle.Foreground.Yellow)=======================$($PSStyle.Reset)
$($PSStyle.Foreground.Green)ga$($PSStyle.Reset) - Shortcut for 'git add .'.
$($PSStyle.Foreground.Green)gc$($PSStyle.Reset) <message> - Shortcut for 'git commit -m'.
$($PSStyle.Foreground.Green)gcl$($PSStyle.Reset) <repo> - Shortcut for 'git clone'.
$($PSStyle.Foreground.Green)gcom$($PSStyle.Reset) <message> - Adds all changes and commits with the specified message.
$($PSStyle.Foreground.Green)gp$($PSStyle.Reset) - Shortcut for 'git push'.
$($PSStyle.Foreground.Green)gpull$($PSStyle.Reset) - Shortcut for 'git pull'.
$($PSStyle.Foreground.Green)gpush$($PSStyle.Reset) - Shortcut for 'git push'.
$($PSStyle.Foreground.Green)gs$($PSStyle.Reset) - Shortcut for 'git status'.
$($PSStyle.Foreground.Green)lazyg$($PSStyle.Reset) <message> - Adds all changes, commits with the specified message, and pushes to the remote repository.

$($PSStyle.Foreground.Cyan)Shortcuts$($PSStyle.Reset)
$($PSStyle.Foreground.Yellow)=======================$($PSStyle.Reset)
$($PSStyle.Foreground.Green)docs$($PSStyle.Reset) - Changes the current directory to the user's Documents folder.
$($PSStyle.Foreground.Green)dtop$($PSStyle.Reset) - Changes the current directory to the user's Desktop folder.
$($PSStyle.Foreground.Green)ep$($PSStyle.Reset) - Opens the profile for editing.
$($PSStyle.Foreground.Green)ff$($PSStyle.Reset) <name> - Finds files recursively with the specified name.
$($PSStyle.Foreground.Green)k9$($PSStyle.Reset) <name> - Kills a process by name.
$($PSStyle.Foreground.Green)la$($PSStyle.Reset) - Lists all files in the current directory with detailed formatting.
$($PSStyle.Foreground.Green)ll$($PSStyle.Reset) - Lists all files, including hidden, in the current directory with detailed formatting.
$($PSStyle.Foreground.Green)mkcd$($PSStyle.Reset) <dir> - Creates and changes to a new directory.
$($PSStyle.Foreground.Green)pgrep$($PSStyle.Reset) <name> - Lists processes by name.
$($PSStyle.Foreground.Green)pkill$($PSStyle.Reset) <name> - Kills processes by name.
$($PSStyle.Foreground.Green)sysinfo$($PSStyle.Reset) - Displays detailed system information.
$($PSStyle.Foreground.Green)touch$($PSStyle.Reset) <file> - Creates a new empty file.
$($PSStyle.Foreground.Green)unzip$($PSStyle.Reset) <file> - Extracts a zip file to the current directory.
$($PSStyle.Foreground.Yellow)=======================$($PSStyle.Reset)

Use '$($PSStyle.Foreground.Magenta)Show-Help$($PSStyle.Reset)' to display this help message.
"@
    Write-Host $helpText
}


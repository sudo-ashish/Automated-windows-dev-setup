# ==============================================================================
# 1. SETTINGS & DEPENDENCY LISTS
# ==============================================================================
$AutoInstall = $true   # set false if you want no installs
$AskBeforeInstall = $false

$binaries = @(
    @{ Name="oh-my-posh"; Id="JanDeDobbeleer.OhMyPosh" },
    @{ Name="zoxide";     Id="ajeetdsouza.zoxide" }
)

$modules = @(
    "Terminal-Icons",
    "PSReadLine"
)

# ==============================================================================
# 2. INFRASTRUCTURE & INSTALLATION FUNCTIONS
# ==============================================================================
function Confirm-Install($name) {
    if (-not $AskBeforeInstall) { return $true }
    $ans = Read-Host "$name missing. Install? (y/n)"
    return $ans -eq 'y'
}

function Install-Binary {
    param([string]$Name, [string]$WingetId)
    if (Get-Command $Name -ErrorAction SilentlyContinue) { return }
    if (-not $AutoInstall) { Write-Warning "$Name not found"; return }
    if (-not (Confirm-Install $Name)) { return }

    Write-Host "Installing $Name..." -ForegroundColor Cyan
    try {
        winget install --id $WingetId --silent --accept-source-agreements --accept-package-agreements
        # Refresh PATH
        $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
    }
    catch { Write-Warning "Failed to install $Name" }
}

function Install-PSModule {
    param([string]$Name)
    if (Get-Module -ListAvailable -Name $Name) { return }
    if (-not $AutoInstall) { Write-Warning "Module $Name missing"; return }
    if (-not (Confirm-Install $Name)) { return }

    Write-Host "Installing $Name..." -ForegroundColor Cyan
    try {
        if ((Get-PSRepository PSGallery).InstallationPolicy -ne 'Trusted') {
            Set-PSRepository PSGallery -InstallationPolicy Trusted
        }
        Install-Module $Name -Scope CurrentUser -Force -AllowClobber
    }
    catch { Write-Warning "Failed to install $Name" }
}

# Run Installation Loops
foreach ($bin in $binaries) { Install-Binary $bin.Name $bin.Id }
foreach ($mod in $modules) { Install-PSModule $mod }

# ==============================================================================
# 3. ENVIRONMENT & INITIALIZATION
# ==============================================================================

# Imports
foreach ($mod in $modules) { Import-Module $mod -ErrorAction SilentlyContinue }

# Oh-My-Posh
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json' | Invoke-Expression
}

# Zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { zoxide init powershell | Out-String })
}

# PSReadLine Config
if (Get-Module PSReadLine) {
    Set-PSReadLineOption `
        -PredictionSource History `
        -PredictionViewStyle ListView `
        -HistoryNoDuplicates `
        -MaximumHistoryCount 10000

    Set-PSReadLineKeyHandler UpArrow   HistorySearchBackward
    Set-PSReadLineKeyHandler DownArrow HistorySearchForward
}

# ==============================================================================
# 4. CORE UTILITIES & SYSTEM
# ==============================================================================
function Update-PowerShell {
    if (Get-Command -Name "Update-PowerShell_Override" -ErrorAction SilentlyContinue) {
        Update-PowerShell_Override
    } else {
        try {
            Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
            $currentVersion = $PSVersionTable.PSVersion.ToString()
            $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
            $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
            $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
            if ($currentVersion -lt $latestVersion) {
                Write-Host "Updating PowerShell..." -ForegroundColor Yellow
                Start-Process powershell.exe -ArgumentList "-NoProfile -Command winget upgrade Microsoft.PowerShell --accept-source-agreements --accept-package-agreements" -Wait -NoNewWindow
                Write-Host "PowerShell has been updated. Please restart your shell." -ForegroundColor Magenta
            } else {
                Write-Host "Your PowerShell is up to date." -ForegroundColor Green
            }
        } catch { Write-Error "Failed to update PowerShell. Error: $_" }
    }
}

function sysinfo { Get-ComputerInfo }

function Edit-Profile { vim $PROFILE.CurrentUserAllHosts }
Set-Alias -Name ep -Value Edit-Profile

# ==============================================================================
# 5. FILE & PROCESS MANAGEMENT
# ==============================================================================
function touch($file) { New-Item -ItemType File -Path $file -Force | Out-Null }

function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }

function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function ff($name) {
    Get-ChildItem -Recurse -Filter "*$name*" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
}

function la { Get-ChildItem | Format-Table -AutoSize }
function ll { Get-ChildItem -Force | Format-Table -AutoSize }

# Navigation
function docs {
    $docs = if(([Environment]::GetFolderPath("MyDocuments"))) {([Environment]::GetFolderPath("MyDocuments"))} else {$HOME + "\Documents"}
    Set-Location -Path $docs
}

function dtop {
    $dtop = if ([Environment]::GetFolderPath("Desktop")) {[Environment]::GetFolderPath("Desktop")} else {$HOME + "\Desktop"}
    Set-Location -Path $dtop
}

# Process Management
function pkill {
    param([Parameter(Mandatory=$true)]$name)
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep {
    param([Parameter(Mandatory=$true)]$name)
    Get-Process $name
}

function k9 { 
    param([Parameter(Mandatory=$true)]$name)
    Stop-Process -Name $name 
}

# ==============================================================================
# 6. GIT SHORTCUTS
# ==============================================================================
function gs { git status }
function ga { git add . }
function gc { param($m) git commit -m "$m" }
function gpush { git push }
function gpull { git pull }
function g { __zoxide_z github }
function gcl { git clone "$args" }
function gcom { git add .; git commit -m "$args" }
function lazyg { git add .; git commit -m "$args"; git push }

# ==============================================================================
# 7. HELP SYSTEM
# ==============================================================================
function Show-Help {
    $helpText = @"
$($PSStyle.Foreground.Cyan)PowerShell Profile Help$($PSStyle.Reset)
$($PSStyle.Foreground.Yellow)=======================$($PSStyle.Reset)
$($PSStyle.Foreground.Green)Edit-Profile$($PSStyle.Reset) - Opens the current user's profile for editing.
$($PSStyle.Foreground.Green)Update-PowerShell$($PSStyle.Reset) - Checks for latest release and updates via Winget.

$($PSStyle.Foreground.Cyan)Git Shortcuts$($PSStyle.Reset)
$($PSStyle.Foreground.Yellow)=======================$($PSStyle.Reset)
$($PSStyle.Foreground.Green)ga$($PSStyle.Reset) - Shortcut for 'git add .'.
$($PSStyle.Foreground.Green)gc$($PSStyle.Reset) <message> - Shortcut for 'git commit -m'.
$($PSStyle.Foreground.Green)gcl$($PSStyle.Reset) <repo> - Shortcut for 'git clone'.
$($PSStyle.Foreground.Green)gcom$($PSStyle.Reset) <message> - Adds all changes and commits.
$($PSStyle.Foreground.Green)gpush$($PSStyle.Reset) - Shortcut for 'git push'.
$($PSStyle.Foreground.Green)gpull$($PSStyle.Reset) - Shortcut for 'git pull'.
$($PSStyle.Foreground.Green)gs$($PSStyle.Reset) - Shortcut for 'git status'.
$($PSStyle.Foreground.Green)lazyg$($PSStyle.Reset) <message> - Add, Commit, and Push in one go.

$($PSStyle.Foreground.Cyan)Shortcuts$($PSStyle.Reset)
$($PSStyle.Foreground.Yellow)=======================$($PSStyle.Reset)
$($PSStyle.Foreground.Green)docs$($PSStyle.Reset) - Jump to Documents.
$($PSStyle.Foreground.Green)dtop$($PSStyle.Reset) - Jump to Desktop.
$($PSStyle.Foreground.Green)ep$($PSStyle.Reset) - Alias for Edit-Profile.
$($PSStyle.Foreground.Green)ff$($PSStyle.Reset) <name> - Finds files recursively.
$($PSStyle.Foreground.Green)k9/pkill$($PSStyle.Reset) - Kill processes.
$($PSStyle.Foreground.Green)la/ll$($PSStyle.Reset) - Enhanced directory listing.
$($PSStyle.Foreground.Green)mkcd$($PSStyle.Reset) <dir> - Create and enter directory.
$($PSStyle.Foreground.Green)sysinfo$($PSStyle.Reset) - System details.
$($PSStyle.Foreground.Green)touch$($PSStyle.Reset) <file> - Create empty file.
$($PSStyle.Foreground.Green)unzip$($PSStyle.Reset) <file> - Extract zip in place.
$($PSStyle.Foreground.Yellow)=======================$($PSStyle.Reset)
"@
    Write-Host $helpText
}

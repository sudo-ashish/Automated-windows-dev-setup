<#
.SYNOPSIS
    Automated Windows Development Setup Script (Dark Theme Tabbed GUI)

.DESCRIPTION
    A comprehensive WPF application for setting up a Windows dev environment.
    Features:
    - Dark/Light Theme Toggle (Icon Based).
    - 4:3 Aspect Ratio.
    - Tabs: Setup, GitHub, Backup/Restore.
    - Integrated Console Logging.
    - Custom Thin Scrollbars.
#>

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot

# Ensure WPF (PresentationFramework) is loaded
try { Add-Type -AssemblyName PresentationFramework } catch { Write-Warning "WPF not supported."; exit }

# -------------------------------------------------------------------------
# XAML - GUI Definition
# -------------------------------------------------------------------------
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Automated Windows Dev Setup" Height="600" Width="800" ResizeMode="CanResize" WindowStartupLocation="CenterScreen"
        Background="{DynamicResource WindowBackground}" Foreground="{DynamicResource TextPrimary}" FontFamily="Segoe UI">
    <Window.Resources>
        <!-- Initial Colors (Dark Theme Default) -->
        <SolidColorBrush x:Key="WindowBackground" Color="#1E1E1E"/>
        <SolidColorBrush x:Key="ControlBackground" Color="#252526"/>
        <SolidColorBrush x:Key="ControlBorder" Color="#3E3E3E"/>
        <SolidColorBrush x:Key="AccentColor" Color="#007ACC"/>
        <SolidColorBrush x:Key="TextPrimary" Color="#F1F1F1"/>
        <SolidColorBrush x:Key="TextSecondary" Color="#BBBBBB"/>
        <SolidColorBrush x:Key="ScrollThumb" Color="#555555"/>

        <!-- Icons -->
        <!-- Moon (for switching to Dark) -->
        <PathGeometry x:Key="MoonIcon" Figures="M19.03 15.28C19.35 15.28 19.66 15.3 19.96 15.35L20.67 15.48L20.2 14.9C19.26 13.67 18.77 12.16 18.77 10.61C18.77 6.13 22.41 2.5 26.89 2.5C27 2.5 27.13 2.5 27.24 2.5L28.18 2.57L27.5 1.9C26.3 0.68 24.68 0 22.95 0C18.73 0 15.3 3.43 15.3 7.64C15.3 8.36 15.4 9.07 15.6 9.77C12.45 10.53 10.1 13.36 10.1 16.71C10.1 20.61 13.28 23.78 17.18 23.78C17.81 23.78 18.43 23.7 19.03 15.28Z"/>
        <!-- Sun (for switching to Light) -->
        <PathGeometry x:Key="SunIcon" Figures="M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zm0-5C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z M12 0L12 3M12 21L12 24M3.5 3.5L5.6 5.6M18.4 18.4L20.5 20.5M0 12L3 12M21 12L24 12M3.5 20.5L5.6 18.4M18.4 5.6L20.5 3.5"/>

        <!-- Theme Toggle Style -->
        <Style x:Key="ThemeToggleStyle" TargetType="ToggleButton">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="5"/>
            <Setter Property="Margin" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ToggleButton">
                        <Border Background="{TemplateBinding Background}" CornerRadius="15" Padding="{TemplateBinding Padding}">
                            <!-- Path Data will be set via DataBinding -->
                            <Path Name="IconPath" Fill="{DynamicResource TextPrimary}" Stretch="Uniform" Width="20" Height="20"/>
                        </Border>
                         <ControlTemplate.Triggers>
                            <!-- IsChecked=True (Dark Mode Active) -> Show Sun (to switch to Light) -->
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="IconPath" Property="Data" Value="M6.76 4.84l-1.8-1.79-1.41 1.41 1.79 1.79 1.42 1.41zM4 10.5H1v2h3v-2zm9-9.95h-2V3.5h2V.55zm7.45 3.91l-1.41-1.41-1.79 1.79 1.41 1.41 1.79-1.79zm-3.21 13.7l1.79 1.8 1.41-1.41-1.8-1.79-1.4 1.4zM20 10.5v2h3v-2h-3zm-8-5c-3.31 0-6 2.69-6 6s2.69 6 6 6 6-2.69 6-6-2.69-6-6-6zm-1 16.95h2V19.5h-2v2.95zm-7.45-3.91l1.41 1.41 1.79-1.8-1.41-1.41-1.79 1.8z"/>
                                <Setter TargetName="IconPath" Property="Fill" Value="Yellow"/> <!-- Optional: Make sun yellow -->
                            </Trigger>
                            <!-- IsChecked=False (Light Mode Active) -> Show Moon (to switch to Dark) -->
                            <Trigger Property="IsChecked" Value="False">
                                <Setter TargetName="IconPath" Property="Data" Value="M9.37,5.51C9.19,6.15,9.1,6.82,9.1,7.5c0,4.08,3.32,7.4,7.4,7.4c0.68,0,1.35-0.09,1.99-0.27C17.45,17.16,14.93,19,12,19 c-3.86,0-7-3.14-7-7C5,9.07,6.84,6.55,9.37,5.51z M12,3c-4.97,0-9,4.03-9,9s4.03,9,9,9s9-4.03,9-9c0-0.46-0.04-0.92-0.1-1.36 c-0.98,1.37-2.58,2.26-4.4,2.26c-2.98,0-5.4-2.42-5.4-5.4c0-1.81,0.89-3.42,2.26-4.4C12.92,3.04,12.46,3,12,3L12,3z"/>
                                <Setter TargetName="IconPath" Property="Fill" Value="#444"/> <!-- Dark moon -->
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#33888888"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Custom ScrollBar Style (Thin) -->
        <Style x:Key="ScrollBarThumb" TargetType="{x:Type Thumb}">
            <Setter Property="OverridesDefaultStyle" Value="true"/>
            <Setter Property="IsTabStop" Value="false"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="{x:Type Thumb}">
                        <Border CornerRadius="4" Background="{DynamicResource ScrollThumb}" BorderBrush="Transparent" BorderThickness="0" Width="8"/>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="{x:Type ScrollBar}">
            <Setter Property="Stylus.IsFlicksEnabled" Value="false"/>
            <Setter Property="Width" Value="10"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="{x:Type ScrollBar}">
                        <Grid x:Name="GridRoot" Width="10" Background="Transparent">
                            <Track x:Name="PART_Track" IsDirectionReversed="true" Focusable="false">
                                <Track.Thumb>
                                    <Thumb Style="{StaticResource ScrollBarThumb}"/>
                                </Track.Thumb>
                            </Track>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Styles -->
        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
        </Style>
        <Style TargetType="Label">
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
        </Style>
        
        <!-- Modern Button Style -->
        <Style TargetType="Button">
            <Setter Property="Background" Value="{DynamicResource ControlBackground}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource ControlBorder}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="15,8"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="Border" Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                CornerRadius="4">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#444444"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="{DynamicResource AccentColor}"/>
                                <Setter TargetName="Border" Property="BorderBrush" Value="{DynamicResource AccentColor}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Primary Button Style -->
        <Style x:Key="PrimaryButton" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
            <Setter Property="Background" Value="{DynamicResource AccentColor}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource AccentColor}"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#0062A3"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="FontSize" Value="14"/>
        </Style>

        <Style TargetType="TextBox">
            <Setter Property="Background" Value="{DynamicResource WindowBackground}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource ControlBorder}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="5"/>
            <Setter Property="CaretBrush" Value="{DynamicResource TextPrimary}"/>
        </Style>

        <Style TargetType="ComboBox">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="5"/>
            <Setter Property="FontSize" Value="14"/>
        </Style>

        <Style TargetType="TabControl">
            <Setter Property="Background" Value="{DynamicResource WindowBackground}"/>
            <Setter Property="BorderThickness" Value="0"/>
        </Style>
        
        <Style TargetType="TabItem">
            <Setter Property="Background" Value="{DynamicResource ControlBackground}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Padding" Value="15,10"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border Name="Border" Background="{TemplateBinding Background}" BorderBrush="{DynamicResource ControlBorder}" BorderThickness="1,1,1,0" CornerRadius="4,4,0,0" Margin="2,0,2,0">
                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Center" ContentSource="Header" Margin="10,2"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="{DynamicResource WindowBackground}"/>
                                <Setter TargetName="Border" Property="BorderThickness" Value="1,1,1,0"/>
                                <Setter Property="Foreground" Value="{DynamicResource AccentColor}"/>
                                <Setter Property="FontWeight" Value="Bold"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="False">
                                <Setter TargetName="Border" Property="Background" Value="{DynamicResource ControlBackground}"/>
                                <Setter Property="Foreground" Value="{DynamicResource TextSecondary}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- ListView Styles -->
        <Style TargetType="ListView">
            <Setter Property="Background" Value="{DynamicResource ControlBackground}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource ControlBorder}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
        </Style>
        <Style TargetType="ListViewItem">
             <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ListViewItem">
                        <Border Name="Bd" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Background="{TemplateBinding Background}" Padding="{TemplateBinding Padding}" SnapsToDevicePixels="true">
                            <GridViewRowPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}" VerticalAlignment="{TemplateBinding VerticalContentAlignment}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="true">
                                <Setter TargetName="Bd" Property="Background" Value="{DynamicResource ControlBorder}"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="true">
                                <Setter TargetName="Bd" Property="Background" Value="{DynamicResource AccentColor}"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/> <!-- Header/Toggle Area -->
            <RowDefinition Height="*"/> <!-- Tabs -->
            <RowDefinition Height="150"/> <!-- Log Console -->
        </Grid.RowDefinitions>

        <!-- Header / Toggle -->
        <Grid Grid.Row="0" Margin="0,0,10,0" Panel.ZIndex="1000">
             <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,5,10,0">
                <Button Name="RestartBtn" Content="Reload Script" FontSize="10" Padding="5,2" Margin="0,0,10,0" Height="25" Background="Transparent" Foreground="{DynamicResource TextSecondary}" BorderThickness="1"/>
                <ToggleButton Name="ThemeToggle" Style="{StaticResource ThemeToggleStyle}" IsChecked="True" ToolTip="Toggle Theme"/> 
            </StackPanel>
        </Grid>

        <TabControl Grid.Row="1" Margin="0,-35,0,0" Panel.ZIndex="1">
            <!-- TAB 1: SETUP -->
            <TabItem Header="Setup">
                 <ScrollViewer VerticalScrollBarVisibility="Auto" Padding="0,0,5,0">
                    <Grid Margin="15">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        
                        <!-- Left Column: Forms -->
                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                            <Border Background="{DynamicResource ControlBackground}" CornerRadius="4" Padding="10" Margin="0,0,0,15">
                                <StackPanel>
                                    <Label Content="Git Configuration" FontSize="15" Margin="0,0,0,5" Foreground="{DynamicResource AccentColor}"/>
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="60"/>
                                            <ColumnDefinition Width="*"/>
                                        </Grid.ColumnDefinitions>
                                        <Grid.RowDefinitions>
                                            <RowDefinition Height="Auto"/>
                                            <RowDefinition Height="Auto"/>
                                        </Grid.RowDefinitions>
                                        
                                        <Label Grid.Row="0" Grid.Column="0" Content="Name:" VerticalAlignment="Center" Foreground="{DynamicResource TextSecondary}"/>
                                        <TextBox Grid.Row="0" Grid.Column="1" Name="GitNameBox" Text="Ashish" Margin="0,0,0,10"/>
                                        
                                        <Label Grid.Row="1" Grid.Column="0" Content="Email:" VerticalAlignment="Center" Foreground="{DynamicResource TextSecondary}"/>
                                        <TextBox Grid.Row="1" Grid.Column="1" Name="GitEmailBox" Text="ashish@email.com"/>
                                    </Grid>
                                </StackPanel>
                            </Border>

                            <Border Background="{DynamicResource ControlBackground}" CornerRadius="4" Padding="10" Margin="0,0,0,15">
                                <StackPanel>
                                    <Label Content="Font Selection (Nerd Fonts)" FontSize="15" Margin="0,0,0,5" Foreground="{DynamicResource AccentColor}"/>
                                    <ComboBox Name="FontSelector" SelectedIndex="0">
                                        <ComboBoxItem Content="JetBrainsMono"/>
                                        <ComboBoxItem Content="CascadiaCode"/>
                                        <ComboBoxItem Content="FiraCode"/>
                                        <ComboBoxItem Content="Meslo"/>
                                    </ComboBox>
                                </StackPanel>
                            </Border>

                            <Border Background="{DynamicResource ControlBackground}" CornerRadius="4" Padding="10">
                                <StackPanel>
                                    <Label Content="Core Installations" FontSize="15" Margin="0,0,0,5" Foreground="{DynamicResource AccentColor}"/>
                                    <CheckBox Name="Step1" Content="1. Basic InstallScript (Non-Admin)"/>
                                    <TextBlock Text="     (Chrome, VSCode, Node, etc.)" Foreground="{DynamicResource TextSecondary}" FontSize="12" Margin="5,-3,0,10"/>
                                </StackPanel>
                            </Border>
                        </StackPanel>

                        <!-- Right Column: Components -->
                        <Border Grid.Column="1" Background="{DynamicResource ControlBackground}" CornerRadius="4" Padding="10">
                            <StackPanel>
                                <Label Content="Environment Config" FontSize="15" Margin="0,0,0,10" Foreground="{DynamicResource AccentColor}"/>
                                <StackPanel>
                                    <CheckBox Name="Step2a" Content="2a. Git Config &amp; Tools (GH CLI, FZF)"/>
                                    <CheckBox Name="Step2b" Content="2b. GitHub Auth Login"/>
                                    <CheckBox Name="Step3" Content="3. Install Selected Nerd Font"/>
                                    <CheckBox Name="Step4" Content="4. VSCodium Extensions"/>
                                    <CheckBox Name="Step5" Content="5. VSCodium Settings"/>
                                    <CheckBox Name="Step6" Content="6. Antigravity Extensions"/>
                                    <CheckBox Name="Step7" Content="7. Antigravity Settings"/>
                                    <CheckBox Name="Step9" Content="8. Neovim Config"/>
                                </StackPanel>
                                
                                <Separator Background="{DynamicResource ControlBorder}" Margin="0,15"/>
                                <Button Name="RunSetupBtn" Style="{StaticResource PrimaryButton}" Content="Execute Selected Setup" HorizontalAlignment="Stretch"/>
                            </StackPanel>
                        </Border>
                    </Grid>
                </ScrollViewer>
            </TabItem>

            <!-- TAB 2: GITHUB REPOS -->
            <TabItem Header="GitHub Repos">
                <Grid Margin="15">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    
                    <Border Grid.Row="0" Background="{DynamicResource ControlBackground}" CornerRadius="4" Padding="10" Margin="0,0,0,10">
                        <StackPanel Orientation="Horizontal">
                            <Button Name="FetchReposBtn" Content="Fetch Repositories" Width="150" Margin="0,0,15,0"/>
                            <TextBlock Text="Use 'gh auth login' first. Fetching may take a moment." VerticalAlignment="Center" Foreground="{DynamicResource TextSecondary}"/>
                        </StackPanel>
                    </Border>

                    <ListView Grid.Row="1" Name="RepoListView" Margin="0,0,0,10">
                        <ListView.View>
                            <GridView>
                                <GridViewColumn Header="Select" Width="60">
                                    <GridViewColumn.CellTemplate>
                                        <DataTemplate>
                                            <CheckBox IsChecked="{Binding IsSelected}" HorizontalAlignment="Center" Margin="5,0"/>
                                        </DataTemplate>
                                    </GridViewColumn.CellTemplate>
                                </GridViewColumn>
                                <GridViewColumn Header="Repository Name" Width="400" DisplayMemberBinding="{Binding Display}"/>
                                <GridViewColumn Header="URL" Width="250" DisplayMemberBinding="{Binding Url}"/>
                            </GridView>
                        </ListView.View>
                    </ListView>

                    <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right">
                        <Label Content="Target: ~/Documents/github-repo" VerticalAlignment="Center" Foreground="{DynamicResource TextSecondary}" Margin="0,0,10,0"/>
                        <Button Name="CloneReposBtn" Style="{StaticResource PrimaryButton}" Content="Clone Selected" Width="150"/>
                    </StackPanel>
                </Grid>
            </TabItem>

            <!-- TAB 3: BACKUP -->
            <TabItem Header="Backup/Restore">
                <Grid Margin="15">
                    <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                        <Border Background="{DynamicResource ControlBackground}" CornerRadius="8" Padding="30">
                            <StackPanel>
                                <Label Content="System Settings Backup" FontSize="24" HorizontalAlignment="Center" Margin="0,0,0,20" Foreground="{DynamicResource AccentColor}"/>
                                
                                <StackPanel Orientation="Vertical" Margin="0,0,0,20" HorizontalAlignment="Center">
                                    <CheckBox Name="BackupTheme" Content="Theme &amp; Personalization" IsChecked="True"/>
                                    <CheckBox Name="BackupExplorer" Content="Explorer &amp; Search" IsChecked="True"/>
                                    <CheckBox Name="BackupMouse" Content="Mouse &amp; Touchpad" IsChecked="True"/>
                                    <CheckBox Name="BackupProfile" Content="PowerShell Profile" IsChecked="True"/>
                                </StackPanel>

                                <Button Name="ExportBtn" Content="Export Selected (Backup)" Width="280" Height="40" Margin="0,0,0,10"/>
                                <TextBlock Text="Saves selected settings to local folder." HorizontalAlignment="Center" Foreground="{DynamicResource TextSecondary}" Margin="0,0,0,30"/>
                                
                                <Button Name="ImportBtn" Content="Import Selected (Restore)" Width="280" Height="40" Background="#A03030" BorderBrush="#A03030"/>
                                <TextBlock Text="Restores selected settings from local folder." HorizontalAlignment="Center" Foreground="{DynamicResource TextSecondary}" Margin="0,5,0,0"/>
                            </StackPanel>
                        </Border>
                    </StackPanel>
                </Grid>
            </TabItem>
        </TabControl>

        <!-- Log Console Area -->
        <Border Grid.Row="2" BorderBrush="{DynamicResource AccentColor}" BorderThickness="0,1,0,0" Background="Black">
            <TextBox Name="LogBox" IsReadOnly="True" Background="#0F0F0F" Foreground="#00FF00" FontFamily="Consolas" FontSize="13" 
                     VerticalScrollBarVisibility="Auto" TextWrapping="Wrap" BorderThickness="0" Padding="8"/>
        </Border>
    </Grid>
</Window>
"@

# -------------------------------------------------------------------------
# Helper Functions
# -------------------------------------------------------------------------

function Log {
    param([string]$Message, [string]$Color = "White")
    # Log to the GUI TextBox
    $gui["LogBox"].AppendText("[$((Get-Date).ToString('HH:mm:ss'))] $Message`r`n")
    $gui["LogBox"].ScrollToEnd()
    # Log to the actual host console
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message"
}

function Test-Admin {
    $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-Step1 {
    Log "Running Step 1 (InstallScript)..."
    $installScript = Join-Path $ScriptDir "InstallScript.ps1"
    
    if (Test-Path $installScript) {
        if (Test-Admin) {
            Log "Running as Admin. Launching Step 1 de-elevated (via Explorer)..."
            $tempBatch = Join-Path $env:TEMP ("InstallStep1_" + [Guid]::NewGuid() + ".bat")
            $cmd = "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"$installScript`"`r`npause"
            Set-Content -Path $tempBatch -Value $cmd
            Start-Process "explorer.exe" -ArgumentList "`"$tempBatch`""
            Log "Step 1 process launched in new window."
        }
        else {
            try {
                & $installScript
                Log "Step 1 Completed."
            }
            catch { Log "Step 1 Failed: $_" }
        }
    }
    else { Log "Error: InstallScript.ps1 not found." }
}

function New-Brush {
    param([string]$Hex)
    return [System.Windows.Media.BrushConverter]::new().ConvertFromString($Hex)
}

# -------------------------------------------------------------------------
# Main Logic & Event Handlers
# -------------------------------------------------------------------------

try {
    # Load XAML
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $Window = [Windows.Markup.XamlReader]::Load($reader)

    # Locate Controls
    $controls = @("GitNameBox", "GitEmailBox", "FontSelector", 
        "Step1", "Step2a", "Step2b", "Step3", "Step4", "Step5", "Step6", "Step7", "Step9",
        "RunSetupBtn", 
        "FetchReposBtn", "RepoListView", "CloneReposBtn",
        "ExportBtn", "ImportBtn", "BackupTheme", "BackupExplorer", "BackupMouse", "BackupProfile",
        "LogBox", "ThemeToggle", "RestartBtn")
    
    $gui = @{}
    foreach ($id in $controls) {
        $gui[$id] = $Window.FindName($id)
    }

    # Theme Switching Logic
    $gui["ThemeToggle"].Add_Click({
            $isDark = $gui["ThemeToggle"].IsChecked
            $res = $Window.Resources
        
            # Inline helper for brush creation
            $Convert = [System.Windows.Media.BrushConverter]::new()
            $NewBrush = { param($hex) return $Convert.ConvertFromString($hex) }

            if ($isDark) {
                # Dark Mode
                $res["WindowBackground"] = & $NewBrush "#1E1E1E"
                $res["ControlBackground"] = & $NewBrush "#252526"
                $res["ControlBorder"] = & $NewBrush "#3E3E3E"
                $res["TextPrimary"] = & $NewBrush "#F1F1F1"
                $res["TextSecondary"] = & $NewBrush "#BBBBBB"
                $res["ScrollThumb"] = & $NewBrush "#555555"
            }
            else {
                # Light Mode
                $res["WindowBackground"] = & $NewBrush "#FAFAFA"
                $res["ControlBackground"] = & $NewBrush "#FFFFFF"
                $res["ControlBorder"] = & $NewBrush "#DDDDDD"
                $res["TextPrimary"] = & $NewBrush "#333333"
                $res["TextSecondary"] = & $NewBrush "#666666"
                $res["ScrollThumb"] = & $NewBrush "#CCCCCC"
            }
        })

    # Restart Logic
    $gui["RestartBtn"].Add_Click({
            Log "Restarting script..."
            Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
            $Window.Close()
        })

    # ------------------
    # TAB 1: SETUP
    # ------------------
    $gui["RunSetupBtn"].Add_Click({
            if (-not (Test-Admin)) {
                Log "WARNING: Not running as Administrator. Admin tools (Fonts, Links) may fail."
            }
            [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action] {}, [System.Windows.Threading.DispatcherPriority]::Render)
        
            # Step 1
            if ($gui["Step1"].IsChecked) { Invoke-Step1 }

            # Step 2a: Git Config & Tools
            if ($gui["Step2a"].IsChecked) {
                # 1. Git Config
                $name = $gui["GitNameBox"].Text
                $email = $gui["GitEmailBox"].Text
                Log "Setting Git Config: $name / $email"
                git config --global user.name "$name"
                git config --global user.email "$email"

                # 2. Install Tools
                Log "Installing GH CLI and FZF..."
                if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) { 
                    winget install GitHub.cli -e --silent --accept-source-agreements --accept-package-agreements; 
                    Log "Installed GH CLI" 
                }
                if (-not (Get-Command "fzf" -ErrorAction SilentlyContinue)) { 
                    winget install junegunn.fzf -e --silent --accept-source-agreements --accept-package-agreements; 
                    Log "Installed FZF" 
                }
            
                # 3. Refresh Environment
                Log "Refreshing Environment Variables..."
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            }

            # Step 2b: GitHub Auth
            if ($gui["Step2b"].IsChecked) {
                if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
                    Log "Error: GH CLI not found. Please run Step 2a first."
                }
                else {
                    Log "Launching GitHub Authentication..."
                    # Check status first to inform user, but run login anyway as requested for manual config/re-auth
                    $isLoggedIn = $false
                    try {
                        $statusCheck = gh auth status 2>&1
                        if ($statusCheck | Select-String "Logged in to") { $isLoggedIn = $true }
                    } catch {
                        # Ignore error if simply not logged in
                    }

                    if ($isLoggedIn) {
                        Log "Note: You are already logged in, but launching login for re-authentication/SSH key setup."
                    }
                    
                    Start-Process "gh" -ArgumentList "auth login" -Wait
                    
                    # Verify after user closes the window
                    $authSuccess = $false
                    try {
                        $null = gh auth status 2>&1
                        if ($LASTEXITCODE -eq 0) { $authSuccess = $true }
                    } catch {
                         # If it threw, it likely failed or is not logged in
                         $authSuccess = $false
                    }

                    if ($authSuccess) { 
                        Log "GitHub: Authentication verified." 
                    }
                    else { 
                        Log "GitHub: Authentication not completed or failed." 
                    }
                }
            }

            # Step 3: Fonts
            if ($gui["Step3"].IsChecked) {
                $fontName = $gui["FontSelector"].Text
                Log "Installing Font: $fontName"
                $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$fontName.zip"
                $zipPath = Join-Path $env:TEMP "$fontName.zip"
                $extractPath = Join-Path $env:TEMP "$fontName"
                try {
                    Invoke-WebRequest -Uri $url -OutFile $zipPath
                    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
                    $files = Get-ChildItem -Path $extractPath -Include "*.ttf", "*.otf" -Recurse
                    foreach ($f in $files) {
                        if (-not (Test-Path "C:\Windows\Fonts\$($f.Name)")) {
                            Log "Copying $($f.Name)..."
                            Copy-Item $f.FullName -Destination "C:\Windows\Fonts" -Force
                            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $f.Name -Value $f.Name -PropertyType String -Force | Out-Null
                        }
                    }
                    Log "Font Installation Complete."
                }
                catch { Log "Font Install Failed: $_" }
            }


        
            # Step 8 Copy
            if ($gui["Step9"].IsChecked) {
                Log "Copying Neovim config..."
                Copy-Item -Path (Join-Path $ScriptDir "nvim") -Destination "$env:LOCALAPPDATA\nvim" -Recurse -Force
                Log "Neovim config copied."
            }
        
            # Step 4: VSCodium Extensions
            if ($gui["Step4"].IsChecked) {
                Log "Installing VSCodium Extensions..."
                $extFile = Join-Path $ScriptDir "codium-bak\vscodium-extensions.txt"
                if (Test-Path $extFile) {
                    Get-Content $extFile | ForEach-Object {
                        $ext = $_.Trim()
                        if (-not [string]::IsNullOrWhiteSpace($ext)) {
                            Log "Inst: $ext"
                            try { 
                                Start-Process "codium" -ArgumentList "--install-extension $ext --force" -NoNewWindow -Wait 
                            }
                            catch { Log "Failed to install $ext" }
                        }
                    }
                }
                else { Log "Extension list not found: $extFile" }
            }

            # Step 5: VSCodium Settings
            if ($gui["Step5"].IsChecked) {
                Log "Configuring VSCodium Settings..."
                $src = Join-Path $ScriptDir "codium-bak\settings.json"
                $destDir = "$env:APPDATA\VSCodium\User"
                if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                Copy-Item $src "$destDir\settings.json" -Force
                Log "VSCodium settings applied."
            }

            # Step 6: Antigravity Extensions
            if ($gui["Step6"].IsChecked) {
                Log "Installing Antigravity Extensions..."
                $extFile = Join-Path $ScriptDir "antigravity-bak\antigravity-extensions.txt"
                if (Test-Path $extFile) {
                    Get-Content $extFile | ForEach-Object {
                        $ext = $_.Trim()
                        if (-not [string]::IsNullOrWhiteSpace($ext)) {
                            Log "Inst: $ext"
                            # Assuming 'antigravity' is the command line tool. Adjust if 'cursor' or other.
                            try { 
                                Start-Process "antigravity" -ArgumentList "--install-extension $ext --force" -NoNewWindow -Wait 
                            }
                            catch { Log "Failed to install $ext (Check if 'antigravity' command exists)" }
                        }
                    }
                }
                else { Log "Extension list not found." }
            }

            # Step 7: Antigravity Settings
            if ($gui["Step7"].IsChecked) {
                Log "Configuring Antigravity Settings..."
                $src = Join-Path $ScriptDir "antigravity-bak\settings.json"
                # Assuming standard Cursor/VSCode-fork path structure. 
                # If Google.Antigravity is the ID, AppData might be 'Antigravity' or 'Google\Antigravity'.
                # Defaulting to 'Antigravity' based on folder name.
                $destDir = "$env:APPDATA\Antigravity\User" 
                if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                Copy-Item $src "$destDir\settings.json" -Force
                Log "Antigravity settings applied."
            }

            Log "Setup Batch Completed."
            [System.Windows.MessageBox]::Show("Setup actions completed. Check log for details.", "Done")
        })

    # ------------------
    # TAB 2: GITHUB
    # ------------------
    $RepoCollection = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
    $gui["RepoListView"].ItemsSource = $RepoCollection

    $gui["FetchReposBtn"].Add_Click({
            Log "Fetching repositories..."
            $RepoCollection.Clear()
        
            # Force refresh of window to show we are working (single thread limitation)
            [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action] {}, [System.Windows.Threading.DispatcherPriority]::Render)
        
            try {
                if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) { 
                    throw "GitHub CLI (gh) is not installed. Please install it first." 
                }

                # 1. Check Auth
                $authCheck = $false
                try {
                    $null = gh auth status 2>&1 | Out-Null
                    if ($LASTEXITCODE -eq 0) { $authCheck = $true }
                } catch {
                    $authCheck = $false
                }

 		if (-not $authCheck) { 
    			throw "Not logged in to GitHub. Please run 'gh auth login' in a terminal window." 
		}

                # 2. Get Current User Name
                $me = gh api user --jq .login 2>&1
                if ($LASTEXITCODE -ne 0) { 
                    throw "Failed to retrieve GitHub user information: $me" 
                }
                Log "Authenticated as: $me"

                # 3. Fetch Repositories
                # fetching name, nameWithOwner, url, sshUrl, and visibility
                $json = gh repo list $me --limit 100 --json "name,nameWithOwner,url,sshUrl,visibility" 2>&1
            
                if ($LASTEXITCODE -ne 0) { 
                    throw "Error fetching repositories: $json" 
                }

                $repos = $json | ConvertFrom-Json
            
                foreach ($r in $repos) {
                    $item = New-Object PSObject
                    
                    # Display Format: Name (Visibility)
                    $displayName = if ($r.nameWithOwner) { $r.nameWithOwner } else { $r.name }
                    $displayWithVis = "$displayName ($($r.visibility))"

                    # Select Clone URL (Prefer HTTPS unless configured otherwise, using URL from API)
                    $cloneUrl = if ($r.url) { $r.url } else { $r.sshUrl }

                    $item | Add-Member -MemberType NoteProperty -Name "Name" -Value $displayName
                    $item | Add-Member -MemberType NoteProperty -Name "Display" -Value $displayWithVis
                    $item | Add-Member -MemberType NoteProperty -Name "Url" -Value $cloneUrl
                    $item | Add-Member -MemberType NoteProperty -Name "IsSelected" -Value $false
                    $RepoCollection.Add($item)
                }
                Log "Successfully retrieved $($repos.Count) repositories."
            }
            catch {
                Log "ERROR: $_"
                [System.Windows.MessageBox]::Show("Error fetching repositories:`n$_", "GitHub Error", "OK", "Error")
            }
        })

    $gui["CloneReposBtn"].Add_Click({
            $targetBase = "$HOME\Documents\github-repo"
            if (-not (Test-Path $targetBase)) { New-Item -ItemType Directory -Path $targetBase -Force | Out-Null }
        
            foreach ($item in $RepoCollection) {
                if ($item.IsSelected) {
                    $target = Join-Path $targetBase ($item.Name -split "/")[-1]
                    if (-not (Test-Path $target)) {
                        Log "Cloning $($item.Name)..."
                        # Using Start-Process to avoid GUI freeze on large clones
                        Start-Process git -ArgumentList "clone", $item.Url, $target -NoNewWindow -Wait
                    }
                    else {
                        Log "Skipped $($item.Name) (Exists)."
                    }
                }
            }
            Log "Clone operation finished."
        })

    # ------------------
    # TAB 3: BACKUP
    # ------------------
    $gui["ExportBtn"].Add_Click({
            Log "Running Export Script..."
            $script = Join-Path $ScriptDir "export-setting.ps1"
            
            if (Test-Path $script) { 
                $params = @{}
                if ($gui["BackupTheme"].IsChecked) { $params["Theme"] = $true }
                if ($gui["BackupExplorer"].IsChecked) { $params["Explorer"] = $true }
                if ($gui["BackupMouse"].IsChecked) { $params["Mouse"] = $true }
                if ($gui["BackupProfile"].IsChecked) { $params["Profile"] = $true }

                if ($params.Count -eq 0) {
                     Log "No items selected for export."
                     return
                }

                # Construct command string for logging
                $logStr = $params.Keys | ForEach-Object { "-$_" }
                Log "Exporting: $($logStr -join ' ')"
                
                & $script @params | Out-String | ForEach-Object { Log $_ }
                Log "Export finished."
            }
            else { Log "Script not found." }
        })

    $gui["ImportBtn"].Add_Click({
            $params = @{}
            if ($gui["BackupTheme"].IsChecked) { $params["Theme"] = $true }
            if ($gui["BackupExplorer"].IsChecked) { $params["Explorer"] = $true }
            if ($gui["BackupMouse"].IsChecked) { $params["Mouse"] = $true }
            if ($gui["BackupProfile"].IsChecked) { $params["Profile"] = $true }

            if ($params.Count -eq 0) {
                 Log "No items selected for import."
                 return
            }

            $logStr = $params.Keys | ForEach-Object { "-$_" }
            $msg = "Are you sure you want to overwrite logic for:`n" + ($logStr -join "`n")
            $res = [System.Windows.MessageBox]::Show($msg, "Confirm Import", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
            
            if ($res -eq "Yes") {
                Log "Running Import Script..."
                $script = Join-Path $ScriptDir "import-settings.ps1"
                if (Test-Path $script) {
                    & $script @params | Out-String | ForEach-Object { Log $_ }
                    Log "Import finished."
                }
                else { Log "Script not found." }
            }
        })

    # Launch
    Log "Welcome to Automated Setup. Select a tab to begin."
    $Window.ShowDialog() | Out-Null
}
catch {
    Write-Host "CRITICAL ERROR: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
}

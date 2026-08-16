$version = "v2.12"
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# Import module(s)
Import-Module "$psScriptRoot\Functions\AtomModule.psm1" -Function Invoke-Runspace, Set-WindowStyle -Variable *
Import-Module "$psScriptRoot\Functions\AtomWpfModule.psm1"

$settingsXaml = @"
<StackPanel MaxWidth="300" Margin="5">
    <!-- NAV PANEL -->
    <StackPanel Orientation="Horizontal">
        <Button Name="navButton" Width="25" Height="25" Background="{DynamicResource backgroundHighlight}" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
        <TextBlock Text="Settings" FontSize="20" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
    </StackPanel>

    <!-- GENERAL PANEL -->
    <TextBlock Text="General" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <StackPanel>
            <StackPanel Name="togglePanel"/>
            <Button Name="defaultSwitchButton" Width="130" Background="{DynamicResource accentBrush}" HorizontalAlignment="Right" Style="{StaticResource RoundedButton}" Margin="5">
                <StackPanel Orientation="Horizontal">
                    <ContentControl Name="restoreImage" Width="16" Height="16" Margin="5"/>
                    <TextBlock Text="Restore Defaults" FontSize="11" Foreground="{DynamicResource accentText}" VerticalAlignment="Center"/>
                </StackPanel>
            </Button>
        </StackPanel>
    </Border>

    <!-- APPEARANCE PANEL -->
    <TextBlock Text="Appearance" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <StackPanel>
            <Button Name="themeSelectorButton" Background="Transparent" Style="{StaticResource RoundedButton}" HorizontalAlignment="Stretch" HorizontalContentAlignment="Stretch" ToolTip="Show theme options">
                <Grid Margin="5,2.5">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Text="Theme:" Foreground="{DynamicResource surfaceText}" FontSize="12" VerticalAlignment="Center"/>
                    <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Center">
                        <TextBlock Name="themeSelectorText" Foreground="{DynamicResource surfaceText}" FontSize="12" VerticalAlignment="Center" Margin="0,0,8,0"/>
                        <Border Name="themePrimarySwatch" Width="12" Height="12" Margin="1" VerticalAlignment="Center" CornerRadius="4,0,0,4"/>
                        <Border Name="themeBackgroundSwatch" Width="12" Height="12" Margin="1" VerticalAlignment="Center"/>
                        <Border Name="themeSurfaceSwatch" Width="12" Height="12" Margin="1" VerticalAlignment="Center"/>
                        <Border Name="themeAccentSwatch" Width="12" Height="12" Margin="1" VerticalAlignment="Center" CornerRadius="0,4,4,0"/>
                    </StackPanel>
                    <ContentControl Name="themeSelectorIndicator" Grid.Column="2" Width="16" Height="16" VerticalAlignment="Center" Margin="8,0,0,0"/>
                </Grid>
            </Button>
            <WrapPanel Name="themePanel" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,5,0,0" Visibility="Collapsed"/>
        </StackPanel>
    </Border>

    <!-- UPDATE PANEL -->
    <TextBlock Text="Updates" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <StackPanel>
            <Grid>
                <TextBlock Text="ATOM Version:" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                <TextBlock Name="versionText" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
            </Grid>
            <Grid>
                <TextBlock Text="Hash:" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                <TextBlock Name="versionHash" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
            </Grid>
            <Grid>
                <TextBlock Text="Last checked:" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                <TextBlock Name="updateText" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
            </Grid>
            <WrapPanel Orientation="Horizontal" HorizontalAlignment="Center">
                <Button Name="checkUpdateButton" Width="130" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" HorizontalAlignment="Center" Style="{StaticResource RoundedButton}" Margin="5" ToolTip="Check GitHub for ATOM updates">
                    <StackPanel Orientation="Horizontal">
                        <ContentControl Name="checkUpdatesImage" Width="16" Height="16" Margin="5"/>
                        <TextBlock Text="Check for Updates" FontSize="11" VerticalAlignment="Center" Margin="0,5,5,5"/>
                    </StackPanel>
                </Button>
                <Button Name="updateButton" Width="130" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" HorizontalAlignment="Center" Style="{StaticResource RoundedButton}" IsEnabled="False" Opacity="0.2" Margin="5" ToolTip="Updating ATOM will not remove custom plugins">
                    <StackPanel Orientation="Horizontal">
                        <ContentControl Name="updateImage" Width="16" Height="16" Margin="5"/>
                        <TextBlock Text="Update ATOM" FontSize="11" VerticalAlignment="Center" Margin="0,5,5,5"/>
                    </StackPanel>
                </Button>
            </WrapPanel>
        </StackPanel>
    </Border>

    <!-- ATOM PANEL -->
    <TextBlock Text="ATOM" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="1"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <Button Name="pathButton" Grid.Row="0" Grid.Column="0" Height="25" Width="25" VerticalAlignment="Center" Style="{StaticResource RoundHoverButtonStyle}" Margin="2" ToolTip="Open ATOM folder"/>
            <TextBlock Name="pathTextBox" Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="2" Text="$atomPath" Foreground="{DynamicResource surfaceText}" TextTrimming="CharacterEllipsis" VerticalAlignment="Center" Margin="5,2" ToolTip="$atomPath"/>

            <Border Grid.Row="1" Grid.ColumnSpan="3" Height="1" Background="{DynamicResource surfaceText}" Opacity="0.12" Margin="5,0"/>

            <ContentControl Name="githubImage" Grid.Row="2" Grid.Column="0" Width="18" Height="18" VerticalAlignment="Center" Margin="5"/>
            <TextBlock Name="githubTextBox" Grid.Row="2" Grid.Column="1" Foreground="{DynamicResource surfaceText}" TextTrimming="CharacterEllipsis" VerticalAlignment="Center" Margin="5,2"/>
            <StackPanel Grid.Row="2" Grid.Column="2" Orientation="Horizontal">
                <Button Name="githubLinkButton" Height="25" Width="25" VerticalAlignment="Center" Style="{StaticResource RoundHoverButtonStyle}" Margin="2" ToolTip="Copy repository URL"/>
                <Button Name="githubLaunchButton" Height="25" Width="25" VerticalAlignment="Center" Style="{StaticResource RoundHoverButtonStyle}" Margin="2" ToolTip="Open repository"/>
            </StackPanel>
        </Grid>
    </Border>
</StackPanel>
"@

$mainXaml = @"
<Window x:Name="mainWindow"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title = "ATOM $version"
    Background = "Transparent"
    AllowsTransparency="True"
    WindowStyle="None"
    Width="469" SizeToContent="Height"
    MinWidth="255" MinHeight="600"
    MaxWidth="923" MaxHeight="800"
    Top="0" Left="0"
    UseLayoutRounding="True"
    RenderOptions.BitmapScalingMode="HighQuality">

    <Window.Resources>
        $resourceDictionary
    </Window.Resources>

    <WindowChrome.WindowChrome>
        <WindowChrome CaptionHeight="0" CornerRadius="{DynamicResource cornerStrength}"/>
    </WindowChrome.WindowChrome>

    <Border BorderBrush="Transparent" BorderThickness="0" Background="{DynamicResource backgroundBrush}" CornerRadius="{DynamicResource cornerStrength}">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="48"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <Grid Grid.Row="0">
                <Border Background="{DynamicResource primaryBrush}" CornerRadius="{DynamicResource cornerStrength1}"/>
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <Viewbox Grid.Column="0" Width="105" Height="30" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="15,5">
                        <Canvas Width="1905" Height="358">
                            <Path Data="{StaticResource AtomLogoGeometry}" Fill="{DynamicResource primaryText}"/>
                        </Canvas>
                    </Viewbox>

                    <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center" Margin="5,0,8,0">
                        <Button Name="settingsButton" Width="28" Height="28" Style="{StaticResource RoundHoverButtonStyle}" Margin="2" ToolTip="Settings"/>
                        <Button Name="minimizeButton" Width="28" Height="28" Style="{StaticResource RoundHoverButtonStyle}" Margin="2" ToolTip="Minimize"/>
                        <Button Name="closeButton" Width="28" Height="28" Style="{StaticResource RoundHoverButtonStyle}" Margin="2" ToolTip="Close"/>
                    </StackPanel>
                </Grid>
            </Grid>

            <Grid Grid.Row="1">
                <ScrollViewer Name="scrollViewer" VerticalScrollBarVisibility="Visible" Style="{StaticResource CustomScrollViewerStyle}">
                    <StackPanel>
                        <Border Height="{Binding ActualHeight, ElementName=searchBar}" Margin="0,15,0,5"/>
                        <WrapPanel Name="pluginWrapPanel" Orientation="Horizontal" HorizontalAlignment="Center" Margin="10,0,0,10"/>
                    </StackPanel>
                </ScrollViewer>

                <Border Name="searchBar" Panel.ZIndex="10" Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" VerticalAlignment="Top" Margin="10,10,28,5" Padding="5">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>

                        <Grid Grid.Row="0">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <Button Name="backspaceButton" Grid.Column="0" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                            <ContentControl Name="searchImage" Grid.Column="1" Opacity="0.38" Width="16" Height="16" Margin="0"/>
                            <TextBlock Name="searchTextBlock" Grid.Column="2" Text="Search" Foreground="{DynamicResource surfaceText}" TextAlignment="Left" VerticalAlignment="Center" Opacity="0.69" Margin="5"/>
                            <TextBox Name="searchTextBox" Grid.Column="2" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" TextAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                            <Button Name="refreshButton" Grid.Column="3" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Reload plugins"/>
                            <Button Name="visibilityButton" Grid.Column="4" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                            <Button Name="sortButton" Grid.Column="5" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                        </Grid>

                        <Grid Grid.Row="1" Height="2" Margin="5,2">
                            <Border Height="1" Background="{DynamicResource surfaceText}" Opacity="0.44"/>
                            <ProgressBar Name="statusBarProgress" Height="2" Minimum="0" Maximum="100" Value="0" Background="Transparent" Foreground="{DynamicResource surfaceText}" IsHitTestVisible="False"/>
                        </Grid>

                        <Grid Name="statusContentGrid" Grid.Row="2">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="25"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <TextBlock Name="statusBarStatus" Grid.Row="0" Grid.Column="0" MinWidth="200" Foreground="{DynamicResource surfaceText}" FontSize="10" HorizontalAlignment="Left" VerticalAlignment="Center" TextTrimming="CharacterEllipsis" Margin="5"/>
                            <StackPanel Name="statusActions" Grid.Row="0" Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Right">
                                <Button Name="programUpdateButton" Content="Update" Height="21" MinWidth="55" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" HorizontalAlignment="Right" VerticalAlignment="Center" Style="{StaticResource RoundedButton}" Margin="2" Padding="8,0" Visibility="Collapsed" ToolTip="Update downloaded programs"/>
                                <Button Name="downloadSelectedButton" Content="Download Selected" Height="21" MinWidth="115" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" HorizontalAlignment="Right" VerticalAlignment="Center" Style="{StaticResource RoundedButton}" Margin="2" Padding="8,0" Visibility="Collapsed" IsEnabled="False"/>
                                <Button Name="downloadModeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="4,2.5" ToolTip="Download programs for offline use"/>
                            </StackPanel>
                        </Grid>
                    </Grid>
                </Border>
            </Grid>

            <ScrollViewer Name="scrollViewerSettings" Grid.Row="1" VerticalScrollBarVisibility="Visible" Style="{StaticResource CustomScrollViewerStyle}" Visibility="Collapsed">
                $settingsXaml
            </ScrollViewer>


        </Grid>
    </Border>
</Window>
"@

# Load XAML
$window = [Windows.Markup.XamlReader]::Parse($mainXaml)

# Assign variables to elements in XAML
$refreshButton          = $window.FindName('refreshButton')
$settingsButton         = $window.FindName('settingsButton')
$minimizeButton         = $window.FindName('minimizeButton')
$closeButton            = $window.FindName('closeButton')
$scrollViewer           = $window.FindName('scrollViewer')
$scrollViewerSettings   = $window.FindName('scrollViewerSettings')
$pluginWrapPanel        = $window.FindName('pluginWrapPanel')
$statusBarProgress      = $window.FindName('statusBarProgress')
$statusBarStatus        = $window.FindName('statusBarStatus')
$statusContentGrid      = $window.FindName('statusContentGrid')
$statusActions          = $window.FindName('statusActions')
$visibilityButton       = $window.FindName('visibilityButton')
$downloadModeButton     = $window.FindName('downloadModeButton')
$downloadSelectedButton = $window.FindName('downloadSelectedButton')
$programUpdateButton    = $window.FindName('programUpdateButton')

$script:downloadMode = $false
$script:downloadTransferState = $null
$window.Tag = @{
    UpdatingDownloadSelection = $false
    DownloadRefreshPending = $false
    DownloadCompletionStatus = $null
    UpdateQueue = $null
    CompactStatusLayout = $null
}

# Keep a readable minimum for status text, moving the action group only when needed.
function Update-StatusContentLayout {
    if ($statusContentGrid.ActualWidth -le 0) { return }

    $statusMargin = $statusBarStatus.Margin.Left + $statusBarStatus.Margin.Right
    $requiredWidth = $statusBarStatus.MinWidth + $statusMargin + $statusActions.DesiredSize.Width
    $compact = $statusContentGrid.ActualWidth -lt $requiredWidth
    if ($null -ne $window.Tag.CompactStatusLayout -and $window.Tag.CompactStatusLayout -eq $compact) { return }

    $window.Tag.CompactStatusLayout = $compact
    $actionRow = if ($compact) { 1 } else { 0 }
    $actionColumn = if ($compact) { 0 } else { 1 }
    $columnSpan = if ($compact) { 2 } else { 1 }

    [System.Windows.Controls.Grid]::SetRow($statusActions, $actionRow)
    [System.Windows.Controls.Grid]::SetColumn($statusActions, $actionColumn)
    [System.Windows.Controls.Grid]::SetColumnSpan($statusActions, $columnSpan)
    [System.Windows.Controls.Grid]::SetColumnSpan($statusBarStatus, $columnSpan)
}

$statusContentGrid.Add_SizeChanged({ Update-StatusContentLayout })
$statusActions.Add_SizeChanged({ Update-StatusContentLayout })

# Load quips
. $configPath\Quippy.ps1

# Automatically launch MountOS when ATOM is running in Windows PE.
$inPe = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
if ($inPe) { Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$pluginsPath\MountOS.ps1`"" -Wait }
# Set icon sources
$primaryIconResources = @{
    'settingsButton' = 'SettingsIcon'
    'minimizeButton' = 'MinimizeIcon'
    'closeButton' = 'CloseIcon'
}

$backgroundIconResources = @{
    'navButton' = 'ArrowBackIcon'
}

$surfaceIconResources = @{
    'backspaceButton' = 'BackspaceIcon'
    'searchImage' = 'SearchIcon'
    'refreshButton' = 'RefreshIcon'
    'themeSelectorIndicator' = 'ArrowDropDownIcon'
    'visibilityButton' = $(if ($atomSettings.ShowHiddenPlugins.Value) { 'VisibilityIcon' } else { 'VisibilityOffIcon' })
    'downloadModeButton' = 'DownloadIcon'
    'sortButton' = $(if ($atomSettings.SortPlugins.Value -eq 'Alphabetical') { 'TextDescendingIcon' } else { 'CategoryIcon' })
    'pathButton' = 'FolderOpenIcon'
    'githubImage' = 'GitHubIcon'
    'githubLinkButton' = 'LinkIcon'
    'githubLaunchButton' = 'OpenInBrowserIcon'
}

$accentIconResources = @{
    'checkUpdatesImage' = 'DownloadIcon'
    'updateImage' = 'UpdateIcon'
    'restoreImage' = 'ResetWrenchIcon'
}

Set-VectorIcon -ForegroundResource primaryText -ResourceMappings $primaryIconResources
Set-VectorIcon -ForegroundResource backgroundText -ResourceMappings $backgroundIconResources
Set-VectorIcon -ForegroundResource surfaceText -ResourceMappings $surfaceIconResources
Set-VectorIcon -ForegroundResource accentText -ResourceMappings $accentIconResources

# Launch ATOM on reboot
$runOncePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
if ($atomSettings.LaunchOnRestart.Value) {
    $registryValue = "cmd /c `"start /b powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$psCommandPath`"`""
    New-ItemProperty -Path $runOncePath -Name "ATOM" -Value $registryValue -Force | Out-Null
}

Invoke-Runspace -ScriptBlock {
    # Output BitLocker key to text file in log path
    if ($atomSettings.SaveEncryptionsKey.Value -and !$inPE) {
        # Name encryption key file based on current time & date
        $onlineOS = (Get-WmiObject -Class Win32_OperatingSystem).SystemDrive
        $currentDateTime = Get-Date -Format "MMddyy_HHmmss"
        $logFile = Join-Path $logsPath "EncryptionKey-$currentDateTime.txt"

        # Output encryption key to txt file if drive is encrypted
        $encryptionKey = (manage-bde -protectors -get $onlineOS | Select-String -Pattern '\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}').Matches.Value
        if ($encryptionKey) { $encryptionKey | Out-File -Append $logFile }

        # Remove old encryption keys, keep last 5 most recent
        Get-ChildItem $logsPath\EncryptionKey-*.txt | Sort-Object CreationTime -Descending | Select-Object -Skip 5 | Remove-Item -Force
    }
}

# Return all plugin list items that have download checkboxes
function Get-DownloadItems {
    foreach ($categoryGrid in $pluginWrapPanel.Children) {
        foreach ($item in $categoryGrid.Children[1].Child.Items) {
            if ($item.Control -is [System.Windows.Controls.CheckBox]) { $item }
        }
    }
}

# Keep category checkboxes and the download action bar synchronized with checked plugins
function Update-DownloadSelectionState {
    if (!$script:downloadMode -or $window.Tag.UpdatingDownloadSelection) { return }

    $selectedCount = 0
    $window.Tag.UpdatingDownloadSelection = $true

    try {
        foreach ($categoryGrid in $pluginWrapPanel.Children) {
            $categoryCheckBox = $categoryGrid.Tag
            if ($categoryCheckBox -isnot [System.Windows.Controls.CheckBox]) { continue }

            $availableItems = @($categoryGrid.Children[1].Child.Items | Where-Object { $_.IsEnabled })
            $selectedItems = @($availableItems | Where-Object { $_.Control.IsChecked })
            $selectedCount += $selectedItems.Count

            $categoryCheckBox.IsEnabled = $availableItems.Count -gt 0
            $categoryCheckBox.Opacity = if ($categoryCheckBox.IsEnabled) { 1.0 } else { 0.44 }
            $categoryCheckBox.IsChecked = $availableItems.Count -gt 0 -and $selectedItems.Count -eq $availableItems.Count
        }
    } finally {
        $window.Tag.UpdatingDownloadSelection = $false
    }

    $statusBarStatus.Text = if ($selectedCount -eq 1) { '1 program selected' } else { "$selectedCount programs selected" }
    $downloadSelectedButton.IsEnabled = $selectedCount -gt 0
}


# Keep the hidden-plugin button synchronized with the persisted setting
function Update-VisibilityButton {
    $isVisible = $atomSettings.ShowHiddenPlugins.Value
    $visibilityButton.ToolTip = if ($isVisible) { 'Hide hidden plugins' } else { 'Show hidden plugins' }
    $icon = if ($isVisible) { 'VisibilityIcon' } else { 'VisibilityOffIcon' }
    Set-VectorIcon -ForegroundResource surfaceText -ResourceMappings @{ 'visibilityButton' = $icon }
}

# Persist a managed plugin override without disturbing other user configuration
function Set-PluginOverride {
    param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$Name,
        [Parameter(Mandatory)][Object]$Value,
        [Parameter(Mandatory)][String]$RegionName,
        [Parameter(Mandatory)][String]$VariableName
    )


    $overridePath = Join-Path $configPath 'PluginsUser.ps1'
    $content = if (Test-Path -LiteralPath $overridePath -PathType Leaf) { [IO.File]::ReadAllText($overridePath) } else { '' }
    $regionPattern = "(?ms)^#region $([regex]::Escape($RegionName))\r?\n.*?^#endregion[^\S\r\n]*(?:\r?\n)?"
    $regionMatch = [regex]::Match($content, $regionPattern)
    $overrides = [ordered]@{}

    if ($regionMatch.Success) {
        $entryPattern = "(?m)^\s*'((?:''|[^'])*)'\s*=\s*'((?:''|[^'])*)'\s*$"
        foreach ($entry in [regex]::Matches($regionMatch.Value, $entryPattern)) {
            $entryName = $entry.Groups[1].Value.Replace("''", "'")
            $entryValue = $entry.Groups[2].Value.Replace("''", "'")
            $overrides[$entryName] = $entryValue
        }
    }

    $overrides[$Name] = [String]$Value
    $blockLines = @(
        "#region $RegionName"
        "`$$VariableName = [ordered]@{"
        $overrides.GetEnumerator() | Sort-Object Key | ForEach-Object {
            $escapedName = $_.Key.Replace("'", "''")
            $escapedValue = $_.Value.Replace("'", "''")
            "    '$escapedName' = '$escapedValue'"
        }
        '}'
        '#endregion'
    )
    $block = $blockLines -join [Environment]::NewLine

    $newContent =
        if ($regionMatch.Success) {
            [regex]::Replace($content, $regionPattern, [Text.RegularExpressions.MatchEvaluator]{ param($match) "$block$([Environment]::NewLine)" }, 1)
        } elseif ([String]::IsNullOrWhiteSpace($content)) {
            "$block$([Environment]::NewLine)"
        } else {
            "$($content.TrimEnd())$([Environment]::NewLine)$([Environment]::NewLine)$block$([Environment]::NewLine)"
        }

    $tempPath = "$overridePath.tmp"
    [IO.File]::WriteAllText($tempPath, $newContent, [Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $tempPath -Destination $overridePath -Force
}

# Persist a plugin category override without moving its launcher file
function Set-PluginCategory {
    param (
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$Category
    )

    Set-PluginOverride -Name $Name -Value $Category -RegionName 'ATOM Category Overrides' -VariableName 'pluginCategories'
    Update-PluginList -Reload
    $statusBarStatus.Text = "Moved $Name to $Category"
}

# Persist whether a plugin is hidden
function Set-PluginVisibility {
    param (
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][Boolean]$Hidden
    )

    Set-PluginOverride -Name $Name -Value $Hidden -RegionName 'ATOM Visibility Overrides' -VariableName 'pluginVisibility'
    Update-PluginList -Reload
    $statusBarStatus.Text = if ($Hidden) { "Hid $Name" } else { "Unhid $Name" }
}

# Show configuration, file, executable, and download details for a plugin
function Show-PluginProperties {
    param ([Parameter(Mandatory)]$Plugin)

    $pluginFile = Get-Item -LiteralPath $Plugin.FullName
    $programInfo = $Plugin.ProgramInfo
    $programPath = if ($programInfo.DestinationPath -and $programInfo.RelativePath) { Join-Path $programInfo.DestinationPath $programInfo.RelativePath }
    $programFile = if ($programPath -and (Test-Path -LiteralPath $programPath -PathType Leaf)) { Get-Item -LiteralPath $programPath }
    $versionInfo = if ($programFile) { $programFile.VersionInfo }

    $sections = [ordered]@{
        Plugin = [ordered]@{
            Name                 = $Plugin.Name
            Aliases              = (@($Plugin.Config.Aliases) -join ', ')
            Tags                 = (@($Plugin.Config.Tags) -join ', ')
            Tooltip              = $Plugin.Config.ToolTip
            Category             = $Plugin.Category
            'File type'          = $pluginFile.Extension.TrimStart('.').ToUpperInvariant()
            'File location'      = $pluginFile.FullName
            'File size'          = "$([Math]::Round($pluginFile.Length / 1KB, 2)) KB"
            'Last modified'      = $pluginFile.LastWriteTime
            Hidden               = $Plugin.Config.Hidden
            'Silent launch'      = $Plugin.Config.Silent
            'Works in Windows'   = $Plugin.Config.WorksInOs
            'Works in Windows PE'= $Plugin.Config.WorksInPe
        }
    }

    if ($programInfo) {
        $sections.Program = [ordered]@{
            Downloaded         = [Boolean]$programFile
            Executable         = $programPath
            'Detected version' = $(if ($versionInfo.ProductVersion) { $versionInfo.ProductVersion } else { $versionInfo.FileVersion })
            'Product name'     = $versionInfo.ProductName
            'Product version'  = $versionInfo.ProductVersion
            'File version'     = $versionInfo.FileVersion
            Company            = $versionInfo.CompanyName
            Description        = $versionInfo.FileDescription
            'Executable size'  = $(if ($programFile) { "$([Math]::Round($programFile.Length / 1MB, 2)) MB" })
            'Last modified'    = $(if ($programFile) { $programFile.LastWriteTime })
        }

        $downloadConfiguration = [ordered]@{}
        foreach ($entry in $programInfo.GetEnumerator() | Sort-Object Key) {
            $label = if ($entry.Key -eq 'ScriptBlock') { 'Custom download logic' } else { $entry.Key }
            $downloadConfiguration[$label] = if ($entry.Key -eq 'ScriptBlock') { [Boolean]$entry.Value } else { $entry.Value }
        }
        $sections['Download configuration'] = $downloadConfiguration
    }

    $manifestPath = Join-Path $programsPath 'downloads.json'
    if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
        try {
            $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
            $recordProperty = $manifest.Programs.PSObject.Properties[$Plugin.Name]
            if ($recordProperty) {
                $downloadRecord = [ordered]@{}
                foreach ($property in $recordProperty.Value.PSObject.Properties) {
                    $downloadRecord[$property.Name] = $property.Value
                }
                $sections['Download record'] = $downloadRecord
            }
        } catch {}
    }

    $detailsText = foreach ($section in $sections.GetEnumerator()) {
        $section.Key.ToUpperInvariant()
        foreach ($entry in $section.Value.GetEnumerator()) {
            $value = $entry.Value
            if ($value -is [Boolean]) { $value = if ($value) { 'Yes' } else { 'No' } }
            elseif ($value -is [DateTime]) { $value = $value.ToString('g') }
            elseif ($null -eq $value -or [String]::IsNullOrWhiteSpace([String]$value)) { $value = 'Not specified' }
            "$($entry.Key): $value"
        }
        ''
    }

    $dialogXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Width="700" Height="600" MinWidth="450" MinHeight="300" WindowStartupLocation="CenterOwner" ShowInTaskbar="False">
    <TextBox Name="details" IsReadOnly="True" AcceptsReturn="True" TextWrapping="NoWrap" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" FontFamily="Consolas" FontSize="12" Margin="10" Padding="10"/>
</Window>
"@
    $dialog = [Windows.Markup.XamlReader]::Parse($dialogXaml)
    $dialog.Title = "$($Plugin.Name) Properties"
    $dialog.Owner = $window
    $dialog.Background = $window.FindResource('backgroundBrush')

    $details = $dialog.FindName('details')
    $details.Text = ($detailsText -join [Environment]::NewLine).TrimEnd()
    $details.Background = $window.FindResource('surfaceBrush')
    $details.Foreground = $window.FindResource('surfaceText')
    $details.BorderBrush = $window.FindResource('accentBrush')
    [void]$dialog.ShowDialog()
}

# Function to load plugins in listboxes
function Update-PluginList {
    param (
        [ValidateSet('Category', 'Alphabetical')]
        [String]$SortMode = $(
            if ($script:atomSettings.SortPlugins.Value -eq 'Alphabetical') { 'Alphabetical' }
            else { 'Category' }
        ),
        [Switch]$Reload
    )

    Update-VisibilityButton

    $selectedPrograms =
        if ($script:downloadMode) {
            @(Get-DownloadItems | Where-Object { $_.IsEnabled -and $_.Control.IsChecked } | ForEach-Object { $_.Control.Tag })
        } else {
            @()
        }

    $pluginWrapPanel.Children.Clear()
    $downloadSelectedButton.Visibility = if ($script:downloadMode) { 'Visible' } else { 'Collapsed' }
    $programUpdateButton.Visibility = if ($script:downloadMode) { 'Visible' } else { 'Collapsed' }

    # Reload plugin configuration and file discovery only when explicitly invalidated.
    if ($Reload) { . $atomPath\Config\Plugins.ps1 }
    if ($Reload -or !$script:pluginFiles) {
        $script:pluginFiles = @(Get-ChildItem -LiteralPath $pluginsPath -File | Where-Object Extension -in '.ps1', '.bat', '.cmd', '.exe', '.lnk')
    }

    $plugins = $script:pluginFiles | ForEach-Object {
        $name = $_.BaseName
        $pluginConfig = $programs[$name]
        $category = if ($pluginConfig.Category) { [String]$pluginConfig.Category } elseif ($_.Directory.FullName -ne $pluginsPath) { $_.Directory.Name } else { 'Uncategorized' }
        $pluginPath = $_.FullName
        $programInfo = $programs[$name].ProgramInfo

        # Omit context-specific plugins unless their condition explicitly succeeds.
        if ($pluginConfig.ShowIf -is [ScriptBlock]) {
            try {
                $visibilityResult = @(& $pluginConfig.ShowIf)
                if (
                    $visibilityResult.Count -ne 1 -or
                    $visibilityResult[0] -isnot [Boolean] -or
                    !$visibilityResult[0]
                ) {
                    return
                }
            } catch {
                Write-Warning "Unable to evaluate ShowIf for '$name': $($_.Exception.Message)"
                return
            }
        }

        if ($script:downloadMode) {
            # Download mode only applies to plugins backed by a downloadable program.
            if (!$programInfo -or (!$atomSettings.ShowHiddenPlugins.Value -and $pluginConfig.Hidden)) { return }
        } elseif ($pluginConfig) {
            if (
                (!$inPE -and $pluginConfig.WorksInOs -eq $false) -or
                ($inPE -and $pluginConfig.WorksInPe -eq $false) -or
                (!$atomSettings.ShowHiddenPlugins.Value -and $pluginConfig.Hidden)
            ) {
                return
            }
        }

        [PSCustomObject]@{
            Name         = $name
            FullName     = $pluginPath
            Config       = $pluginConfig
            ProgramInfo  = $programInfo
            Category     = $category
            GroupCategory =
                if ($SortMode -eq 'Alphabetical') { 'All Plugins' }
                else { $category }
			LaunchParams = switch ($_.Extension) {
				'.bat' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$pluginPath`"" } }
				'.cmd' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$pluginPath`"" } }
				'.exe' { @{ FilePath = $pluginPath } }
				'.lnk' { @{ FilePath = $pluginPath } }
				'.ps1' { @{ FilePath = 'powershell'; ArgumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$pluginPath`"" } }
			}
        }
    } | Sort-Object GroupCategory, Name

    # Group plugins for UI
    $pluginGroups = $plugins | Group-Object GroupCategory

    $categorySelectionChanged = {
        if ($window.Tag.UpdatingDownloadSelection) { return }

        $window.Tag.UpdatingDownloadSelection = $true
        try {
            $isChecked = [Boolean]$this.IsChecked
            $this.Tag.Items | Where-Object { $_.IsEnabled } | ForEach-Object { $_.Control.IsChecked = $isChecked }
        } finally {
            $window.Tag.UpdatingDownloadSelection = $false
        }
        Update-DownloadSelectionState
    }
    foreach ($group in $pluginGroups) {
        # Create listbox for each plugin category
        $categoryLabel = New-Object System.Windows.Controls.TextBlock
        $categoryLabel.Text = $group.Name
        $categoryLabel.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'backgroundText')
        $categoryLabel.FontSize = 14
        $categoryLabel.Margin = '0,10,0,0'
        $categoryLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Bottom

        $pluginList = New-Object System.Windows.Controls.ListBox
        $pluginList.Background = 'Transparent'
        $pluginList.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
        $pluginList.BorderThickness = 0
        $pluginList.Margin = 5
        $pluginList.Padding = 0
        $pluginList.Width = 200
        $pluginList.SetValue([System.Windows.Controls.ScrollViewer]::HorizontalScrollBarVisibilityProperty, [System.Windows.Controls.ScrollBarVisibility]::Disabled)

        $categoryHeader = $categoryLabel
        $categoryCheckBox = $null

        if ($script:downloadMode) {
            $categoryCheckBox = New-Object System.Windows.Controls.CheckBox
            $categoryCheckBox.Tag = $pluginList
            $categoryCheckBox.ToolTip = "Select all available programs in $($group.Name)"
            $categoryCheckBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Bottom
            $categoryCheckBox.Margin = '0,10,5,0'
            $categoryCheckBox.LayoutTransform = [System.Windows.Media.ScaleTransform]::new(0.8, 0.8)

            $categoryCheckBox.Add_Checked($categorySelectionChanged)
            $categoryCheckBox.Add_Unchecked($categorySelectionChanged)

            $categoryHeader = New-Object System.Windows.Controls.StackPanel
            $categoryHeader.Orientation = [System.Windows.Controls.Orientation]::Horizontal
            $categoryHeader.Children.Add($categoryCheckBox) | Out-Null
            $categoryHeader.Children.Add($categoryLabel) | Out-Null
        }

        $categoryBorder = New-Object System.Windows.Controls.Border
        $categoryBorder.Style = $window.FindResource('CustomBorder')
        $categoryBorder.Margin = '0,5,0,0'
        $categoryBorder.SetValue([System.Windows.Controls.Grid]::RowProperty, 1)
        $categoryBorder.Child = $pluginList

        # Configure listbox into plugin wrappanel
        $categoryGrid = New-Object System.Windows.Controls.Grid
        $categoryGrid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
        $categoryGrid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
        $categoryGrid.Margin = '0,0,10,0'
        $categoryGrid.Tag = $categoryCheckBox

        if (!$script:downloadMode -and $SortMode -eq 'Category') {
            $categoryGrid.AllowDrop = $true
            $categoryGrid.DataContext = $group.Name

            $categoryGrid.Add_DragOver({
                param($sender, $eventArgs)

                $sourceCategory =
                    if ($eventArgs.Data.GetDataPresent('ATOM.PluginCategory')) { [String]$eventArgs.Data.GetData('ATOM.PluginCategory') }
                    else { $null }

                $eventArgs.Effects =
                    if ($sourceCategory -and $sourceCategory -ne $sender.DataContext) { [Windows.DragDropEffects]::Move }
                    else { [Windows.DragDropEffects]::None }
                $eventArgs.Handled = $true
            })

            $categoryGrid.Add_Drop({
                param($sender, $eventArgs)

                if ($eventArgs.Data.GetDataPresent('ATOM.PluginName')) {
                    try {
                        Set-PluginCategory -Name ([String]$eventArgs.Data.GetData('ATOM.PluginName')) -Category ([String]$sender.DataContext)
                    } catch {
                        $statusBarStatus.Text = "Unable to move plugin: $($_.Exception.Message)"
                    }
                }
                $eventArgs.Handled = $true
            })
        }

        $categoryGrid.Children.Add($categoryHeader) | Out-Null
        $categoryGrid.Children.Add($categoryBorder) | Out-Null
        $categoryGrid.RowDefinitions[0].Height = [System.Windows.GridLength]::new(30)
        $pluginWrapPanel.Children.Add($categoryGrid) | Out-Null

        foreach ($plugin in $group.Group) {
            $name = $plugin.Name
            $iconPath = "$resourcesPath\Icons\Program Icons\$name.png"

            if (!(Test-Path $iconPath)) {
                $initial = $name.Substring(0,1)
                $iconPath =
                    if ($initial -match '^[A-Z]') { "$resourcesPath\Icons\Default\$initial.png" }
                    else { "$resourcesPath\Icons\Default\#.png" }
            }

            $listBoxItemParams = @{
                Text = $name
                ImageSource = $iconPath
                ToolTip =
                    if ($atomSettings.ShowToolTips.Value -and $plugin.Config.ToolTip) { $plugin.Config.ToolTip }
                    else { $null }
            }

            if ($script:downloadMode) {
                $listBoxItemParams.ControlType = 'CheckBox'
                $listBoxItemParams.Tag = $name
            }

            $listBoxItem = New-ListBoxControlItem @listBoxItemParams
            $listBoxItem.Text.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
            $searchMetadata = @($plugin.Config.Aliases)
            if ($atomSettings.SearchPluginTags.Value) { $searchMetadata += @($plugin.Config.Tags) }
            $listBoxItem.DataContext = "$name $($searchMetadata -join ' ')"
            $listBoxItem.Tag = $plugin
            if ($plugin.Config.Hidden) { $listBoxItem.Opacity = 0.60 }

            $contextMenu = New-Object System.Windows.Controls.ContextMenu
            $contextMenu.Style = $window.FindResource('CustomContextMenu')
            $contextMenu.Background = $window.FindResource('accentBrush')
            $contextMenu.Add_Opened({
                $this.Background = $window.FindResource('accentBrush')
                foreach ($menuItem in $this.Items) {
                    $menuItem.Foreground = $window.FindResource('accentText')
                }
            }.GetNewClosure())

            $propertiesMenuItem = New-Object System.Windows.Controls.MenuItem
            $propertiesMenuItem.Header = 'Properties'
            $propertiesMenuItem.Tag = $plugin
            $propertiesMenuItem.Foreground = $window.FindResource('accentText')
            $propertiesMenuItem.Add_Click({ Show-PluginProperties -Plugin $this.Tag })
            $contextMenu.Items.Add($propertiesMenuItem) | Out-Null

            $visibilityMenuItem = New-Object System.Windows.Controls.MenuItem
            $visibilityMenuItem.Header = if ($plugin.Config.Hidden) { 'Unhide' } else { 'Hide' }
            $visibilityMenuItem.Tag = @{
                Name = $plugin.Name
                Hidden = !$plugin.Config.Hidden
            }
            $visibilityMenuItem.Foreground = $window.FindResource('accentText')
            $visibilityMenuItem.Add_Click({
                Set-PluginVisibility -Name $this.Tag.Name -Hidden $this.Tag.Hidden
            })
            $contextMenu.Items.Add($visibilityMenuItem) | Out-Null

            $listBoxItem.ContextMenu = $contextMenu
            [System.Windows.Controls.ContextMenuService]::SetShowOnDisabled($listBoxItem, $true)

            if ($script:downloadMode) {
                # Match the checkbox template's 20px artwork to the launch row's 16px icon height.
                $listBoxItem.Control.LayoutTransform = [System.Windows.Media.ScaleTransform]::new(0.8, 0.8)
                $programPath = Join-Path $plugin.ProgramInfo.DestinationPath $plugin.ProgramInfo.RelativePath

                if (Test-Path $programPath) {
                    $listBoxItem.IsEnabled = $false
                    $listBoxItem.Opacity = 0.38
                    $listBoxItem.ToolTip = 'Already downloaded for offline use'
                } else {
                    $listBoxItem.Control.IsChecked = $selectedPrograms -contains $name
                    $listBoxItem.Control.Add_Checked({ Update-DownloadSelectionState })
                    $listBoxItem.Control.Add_Unchecked({ Update-DownloadSelectionState })
                }

                $pluginList.Items.Add($listBoxItem) | Out-Null
                continue
            }

            $listBoxItem.Add_PreviewMouseLeftButtonDown({
                param($sender, $eventArgs)
                $window.Tag.PluginDragSource = $sender
                $window.Tag.PluginDragStart = $eventArgs.GetPosition($window)
            })

            $listBoxItem.Add_PreviewMouseMove({
                param($sender, $eventArgs)

                if ($eventArgs.LeftButton -ne [Windows.Input.MouseButtonState]::Pressed -or $window.Tag.PluginDragSource -ne $sender) { return }

                $dragPoint = $eventArgs.GetPosition($window)
                if (
                    [Math]::Abs($dragPoint.X - $window.Tag.PluginDragStart.X) -lt [Windows.SystemParameters]::MinimumHorizontalDragDistance -and
                    [Math]::Abs($dragPoint.Y - $window.Tag.PluginDragStart.Y) -lt [Windows.SystemParameters]::MinimumVerticalDragDistance
                ) {
                    return
                }

                $dragData = New-Object Windows.DataObject
                $dragData.SetData('ATOM.PluginName', $sender.Tag.Name)
                $dragData.SetData('ATOM.PluginCategory', $sender.Tag.Category)
                $window.Tag.PluginDragSource = $null
                $eventArgs.Handled = $true
                [void][Windows.DragDrop]::DoDragDrop($sender, $dragData, [Windows.DragDropEffects]::Move)
            })

            # Run plugin with the configured click count
            $clickEvent =
                if ($atomSettings.PluginClicks.Value -eq 2) { 'Add_MouseDoubleClick' }
                else { 'Add_MouseClick' }

            $listBoxItem.$clickEvent({
				$plugin = $this.Tag
				$name = $plugin.Name
				$launchParams = $plugin.LaunchParams

                $launchParams.WindowStyle =
                    if ($programs.$name.Silent -and !$atomSettings.EnableDebugMode.Value) { 'Hidden' }
                    else { 'Normal' }

                Start-Process @launchParams

				$statusBarStatus.Text = "Running $name"
            })

            # Open the plugin actions with right-click
            $listBoxItem.Add_MouseRightButtonUp({
                $this.ContextMenu.IsOpen = $true
            }.GetNewClosure())

            $pluginList.Items.Add($listBoxItem) | Out-Null
        }
    }

    if ($script:downloadMode) { Update-DownloadSelectionState }
}
Update-PluginList

# Rebuild download controls on the main UI runspace after a background download finishes.
$downloadRefreshTimer = New-Object System.Windows.Threading.DispatcherTimer
$downloadRefreshTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$downloadRefreshTimer.Add_Tick({
    $this.Stop()
    if (!$window.Tag.DownloadRefreshPending) { return }

    try {
        Update-PluginList
        $statusBarStatus.Text = $window.Tag.DownloadCompletionStatus
    } catch {
        $statusBarStatus.Text = 'Downloads finished, but the plugin list could not be refreshed'
    } finally {
        $window.Tag.DownloadRefreshPending = $false
    }
})

# Render file-transfer progress on the main UI thread.
$downloadProgressTimer = New-Object System.Windows.Threading.DispatcherTimer
$downloadProgressTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$downloadProgressTimer.Add_Tick({
    $state = $script:downloadTransferState
    if (!$state -or !$state.Program) { return }

    $sizeText =
        if ($null -ne $state.TotalBytes) { "$([math]::Ceiling($state.TotalBytes / 1MB))MB" }
        elseif ($state.Status -eq 'Connecting') { 'Calculating...' }
        else { 'Unknown size' }

    $statusBarStatus.Text = "Downloading $($state.Program) [$sizeText]"
    $statusBarProgress.Value =
        if ($null -ne $state.PercentComplete) { [math]::Min(100, [math]::Max(0, $state.PercentComplete)) }
        else { 0 }
})

# Search bar controls
$searchBar       = $window.FindName('searchBar')
$searchTextBlock = $window.FindName('searchTextBlock')
$searchTextBox   = $window.FindName('searchTextBox')

function Clear-SearchTextBox {
    $searchTextBox.Clear()
    $searchTextBox.Focus()
    $backspaceButton.Focus()
}

$backspaceButton = $window.FindName('backspaceButton')
$backspaceButton.Tooltip = "Clear search box"
$backspaceButton.Add_Click({
    Clear-SearchTextBox
})

$searchTextBox.Add_GotFocus({
    if ($searchTextBlock.Visibility -eq "Visible") { $searchTextBlock.Visibility = "Collapsed" }
})

$searchTextBox.Add_LostFocus({
    if ($searchTextBox.Text -eq "") { $searchTextBlock.Visibility = "Visible" }
})

$searchTimer = [System.Windows.Threading.DispatcherTimer]::new()
$searchTimer.Interval = [TimeSpan]::FromMilliseconds(125)
$searchTimer.Add_Tick({
    $this.Stop()
    $searchText = $searchTextBox.Text

    foreach ($categoryGrid in $pluginWrapPanel.Children) {
        $listBox = $categoryGrid.Children.Child
        $anyVisibleItems = $false

        foreach ($item in $listBox.Items) {
            $isVisible = ([String]$item.DataContext).IndexOf($searchText, [StringComparison]::OrdinalIgnoreCase) -ge 0
            $item.Visibility = if ($isVisible) { 'Visible' } else { 'Collapsed' }
            if ($isVisible) { $anyVisibleItems = $true }
        }

        $categoryGrid.Visibility = if ($anyVisibleItems) { 'Visible' } else { 'Collapsed' }
    }
})

$searchTextBox.Add_TextChanged({
    $searchTimer.Stop()
    $searchTimer.Start()
})

# Plugin sort button
$sortButton = $window.FindName('sortButton')

$sortButton.ToolTip =
    if ($atomSettings.SortPlugins.Value -eq 'Alphabetical') { "Sort by category" }
    else { "Sort alphabetically" }

$sortButton.Add_Click({
    if ($atomSettings.SortPlugins.Value -eq 'Alphabetical') {
        $sortButton.ToolTip = "Sort alphabetically"
        Set-VectorIcon -ForegroundResource surfaceText -ResourceMappings @{ 'sortButton' = 'CategoryIcon' }
        $script:atomSettings.SortPlugins.Value = 'Category'
        Save-AtomSettings
        Update-PluginList -SortMode Category
    } else {
        $sortButton.ToolTip = "Sort by category"
        Set-VectorIcon -ForegroundResource surfaceText -ResourceMappings @{ 'sortButton' = 'TextDescendingIcon' }
        $script:atomSettings.SortPlugins.Value = 'Alphabetical'
        Save-AtomSettings
        Update-PluginList -SortMode Alphabetical
    }
})

# Toggle hidden plugins in both launch and download modes
$visibilityButton.Add_Click({
    $script:atomSettings.ShowHiddenPlugins.Value = !$script:atomSettings.ShowHiddenPlugins.Value
    Save-AtomSettings
    Update-PluginList
})

# Toggle permanent-download selection mode
$downloadModeButton.Add_Click({
    $script:downloadMode = !$script:downloadMode
    Clear-SearchTextBox

    if ($script:downloadMode) {
        $this.ToolTip = 'Exit download mode'
        Set-VectorIcon -ForegroundResource surfaceText -ResourceMappings @{ 'downloadModeButton' = 'CloseIcon' }
    } else {
        $this.ToolTip = 'Download programs for offline use'
        Set-VectorIcon -ForegroundResource surfaceText -ResourceMappings @{ 'downloadModeButton' = 'DownloadIcon' }
        Set-StatusQuip
    }

    Update-PluginList
})

# Enable or disable controls that cannot change during downloads and update checks
function Set-DownloadControlsEnabled {
    param ([Boolean]$Enabled)

    foreach ($control in $programUpdateButton, $visibilityButton, $downloadModeButton, $refreshButton, $sortButton) {
        $control.IsEnabled = $Enabled
    }
}
# Check installed portable programs, then pass available updates to the download workflow.
$programUpdateButton.Add_Click({
    $script:downloadButtonWasEnabled = $downloadSelectedButton.IsEnabled
    $statusBarStatus.Text = 'Checking for program updates...'
    $statusBarProgress.Value = 0
    $programUpdateButton.Content = 'Checking...'
    Set-DownloadControlsEnabled $false
    $downloadSelectedButton.IsEnabled = $false

    try {
        Invoke-Runspace -ScriptBlock {
            $updateCheckFailed = $false
            $updateNames = @()

            try {
                . $configPath\Plugins.ps1
                . $atomPath\Functions\DownloadManifest.ps1
                $updateNames = @(Get-ProgramUpdates -Programs $programs | ForEach-Object Name)
            } catch {
                $updateCheckFailed = $true
            }

            Invoke-Ui {
                $programUpdateButton.Content = 'Update'
                Set-DownloadControlsEnabled $true

                if ($updateCheckFailed) {
                    $downloadSelectedButton.IsEnabled = $downloadButtonWasEnabled
                    $statusBarStatus.Text = 'Unable to check for program updates'
                } elseif ($updateNames.Count -eq 0) {
                    $downloadSelectedButton.IsEnabled = $downloadButtonWasEnabled
                    $statusBarStatus.Text = 'No program updates found'
                } else {
                    $statusBarStatus.Text =
                        if ($updateNames.Count -eq 1) { '1 update found' }
                        else { "$($updateNames.Count) updates found" }
                    $window.Tag.UpdateQueue = @($updateNames)
                    $downloadSelectedButton.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Button]::ClickEvent))
                }
            }
        }
    } catch {
        $programUpdateButton.Content = 'Update'
        Set-DownloadControlsEnabled $true
        $statusBarStatus.Text = 'Unable to start update check'
        Update-DownloadSelectionState
    }
})

# Permanently download the selected portable programs in a background runspace
$downloadSelectedButton.Add_Click({
    $script:downloadIsUpdate = $null -ne $window.Tag.UpdateQueue
    $script:downloadNames =
        if ($script:downloadIsUpdate) {
            $queue = @($window.Tag.UpdateQueue)
            $window.Tag.UpdateQueue = $null
            $queue
        } else {
            @(Get-DownloadItems | Where-Object { $_.IsEnabled -and $_.Control.IsChecked } | ForEach-Object { $_.Control.Tag })
        }

    if ($script:downloadNames.Count -eq 0) { return }

    $script:downloadTransferState = [hashtable]::Synchronized(@{
        Program = $null
        Status = 'Pending'
        TotalBytes = $null
        PercentComplete = $null
        IsCompleted = $false
        TrackHash = $true
    })
    $statusBarProgress.Value = 0
    $downloadProgressTimer.Start()

    try {
        Invoke-Runspace -ScriptBlock {
            Set-Location $atomTemp
            $failedDownloads = 0
            $downloadProcessFailed = $false

            try {
                # Only lock download-related controls after the runspace is running.
                Invoke-Ui {
                    $downloadSelectedButton.Content = if ($downloadIsUpdate) { 'Updating...' } else { 'Downloading...' }
                    $downloadSelectedButton.IsEnabled = $false
                    Set-DownloadControlsEnabled $false
                }

                . $configPath\Plugins.ps1
                . $atomPath\Functions\Start-Program.ps1
                . $atomPath\Functions\DownloadManifest.ps1

                if (!(Test-Path $programsPath)) {
                    New-Item -Path $programsPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
                }

                foreach ($program in $downloadNames) {
                    $downloadTransferState.Program = $program
                    $downloadTransferState.Status = 'Connecting'
                    $downloadTransferState.TotalBytes = $null
                    $downloadTransferState.PercentComplete = $null
                    $downloadTransferState.IsCompleted = $false
                    $downloadTransferState.Version = $null
                    $downloadTransferState.Source = $null
                    $downloadTransferState.ResolvedUri = $null
                    $downloadTransferState.Uri = $null
                    $downloadTransferState.DownloadHash = $null

                    try {
                        $programParams = $programs[$program].ProgramInfo
                        if (!$programParams) { throw "No ProgramInfo configuration exists for '$program'." }

                        Start-Program @programParams -DownloadOnly -ProgressState $downloadTransferState -ErrorAction Stop | Out-Null

                        $programPath = Join-Path $programParams.DestinationPath $programParams.RelativePath
                        if (!(Test-Path $programPath)) { throw "Downloaded program was not found at '$programPath'." }

                        Set-DownloadRecord -Name $program -ProgramInfo $programParams -ProgressState $downloadTransferState | Out-Null
                    } catch {
                        $failedDownloads++
                    }
                }
            } catch {
                $downloadProcessFailed = $true
            } finally {
                # Hand completion back to a main-runspace timer. Do not mutate checkbox
                # controls from this background-owned dispatcher callback.
                Invoke-Ui {
                    $downloadProgressTimer.Stop()
                    $statusBarProgress.Value = 0
                    $window.Tag.DownloadCompletionStatus =
                        if ($downloadProcessFailed) { 'Download process failed' }
                        elseif ($failedDownloads) { if ($downloadIsUpdate) { 'Updates finished with errors' } else { 'Downloads finished with errors' } }
                        else { if ($downloadIsUpdate) { 'Updates complete' } else { 'Downloads complete' } }

                    $window.Tag.DownloadRefreshPending = $true
                    $downloadSelectedButton.Content = 'Download Selected'
                    $downloadSelectedButton.IsEnabled = $false
                    Set-DownloadControlsEnabled $true
                    $downloadRefreshTimer.Start()
                }
            }
        }
    } catch {
        # Handle a failure to create/start the runspace itself.
        $downloadSelectedButton.Content = 'Download Selected'
        $downloadSelectedButton.IsEnabled = $true
        Set-DownloadControlsEnabled $true
        $downloadProgressTimer.Stop()
        $statusBarProgress.Value = 0
        $statusBarStatus.Text = 'Unable to start download process'
    }
})
# Function to select random quip for status bar
function Set-StatusQuip {
    $statusBarStatus.Text = Get-Random -InputObject $quips
}

Set-StatusQuip

$refreshButton.Add_Click({
    Start-ButtonSpin $this
    Set-StatusQuip
    Update-PluginList -Reload
    $window.SizeToContent = "Height"
})

# Toggle visibility of plugins/settings
$settingsButton.Add_Click({
    if (!$settingsToggled -and $script:downloadMode) {
        $script:downloadMode = $false
        $downloadModeButton.ToolTip = 'Download programs for offline use'
        Set-VectorIcon -ForegroundResource surfaceText -ResourceMappings @{ 'downloadModeButton' = 'DownloadIcon' }
        $downloadSelectedButton.Visibility = 'Collapsed'
        $programUpdateButton.Visibility = 'Collapsed'
        Set-StatusQuip
        $script:pluginListDirty = $true
    }

    if ($settingsToggled) {
        $script:settingsToggled = $false
        $searchBar.Visibility = "Visible"
        $scrollViewer.Visibility = "Visible"
        $scrollViewerSettings.Visibility = "Collapsed"
        if ($script:pluginListDirty) {
            Update-PluginList
            $script:pluginListDirty = $false
        }
    } else {
        $script:settingsToggled = $true
        Clear-SearchTextBox
        $searchBar.Visibility = "Collapsed"
        $scrollViewer.Visibility = "Collapsed"
        $scrollViewerSettings.Visibility = "Visible"
    }
})

$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })

# Set the window width for the configured number of plugin columns
function Set-WindowColumns {
    param ([Int]$Count)

    $window.Width = switch ($Count) {
        1 { 255 }
        3 { 687 }
        default { 469 }
    }
}

Set-WindowColumns -Count $atomSettings.StartupColumns.Value


$closeButton.Add_Click({
    if (Get-ItemProperty -Path $runOncePath -Name "ATOM" -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $runOncePath -Name "ATOM" -Force | Out-Null
    }

    $window.Close()
})

# Make scrollviewer work with scrollwheel
$scrollViewer.AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{
    param($sender, $e)
    $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta)
}, $true)

# Click-to-drag window
$window.Add_MouseLeftButtonDown({$this.DragMove()})

Set-WindowSize

# ATOM settings

###################
##  Nav panel  ####
###################

$navButton = $window.FindName('navButton')
$navButton.Add_Click({
    $script:settingsToggled = $false
    Clear-SearchTextBox
    $searchBar.Visibility = "Visible"
    $scrollViewer.Visibility = "Visible"
    $scrollViewerSettings.Visibility = "Collapsed"

    if ($script:pluginListDirty) {
        Update-PluginList
        $script:pluginListDirty = $false
    }
})

####################
##  Update panel  ##
####################

$versionText = $window.FindName('versionText')
$versionText.Text = "$version"

$versionHash = $window.FindName('versionHash')
$localCommitPath = Join-Path $configPath "hash.txt"
$localCommitHash = Get-Content -Path $localCommitPath
$versionHash.Text = "$($localCommitHash.Substring(0, 7))"

$updateText = $window.FindName('updateText')
$lastCheckedPath = Join-Path $configPath "time.txt"
if (Test-Path $lastCheckedPath) { $lastCheckedContent = Get-Content -Path $lastCheckedPath }
$updateText.Text = "$lastCheckedContent"

function Test-AtomUpdate {
    $checkUpdateButton.IsEnabled = $false
    $updateText.Text = 'Checking for updates...'

    Invoke-Runspace -ScriptBlock {
        try {
            $apiUrl = 'https://api.github.com/repos/SkylerWallace/ATOM/commits?per_page=1'
            $response = Invoke-RestMethod -Uri $apiUrl
            $authorName = $response[0].commit.author.name
            $latestCommitHash =
                if ($authorName -eq 'GitHub Actions') { $response[0].parents[0].sha }
                else { $response[0].sha }
            $updateAvailable = $localCommitHash.Trim() -ne $latestCommitHash
            $checkedText = Get-Date -Format 'MM/dd/yy h:mmtt'

            if (!$updateAvailable) {
                [IO.File]::WriteAllText($lastCheckedPath, $checkedText)
            }

            Invoke-Ui {
                $updateButton.Opacity = if ($updateAvailable) { 1.0 } else { 0.44 }
                $updateButton.IsEnabled = $updateAvailable
                $updateText.Text = if ($updateAvailable) { 'Update available!' } else { $checkedText }
                $checkUpdateButton.IsEnabled = $true
            }
        } catch {
            $errorMessage = $_.Exception.Message
            Invoke-Ui {
                $updateText.Text = "Unable to check for updates: $errorMessage"
                $checkUpdateButton.IsEnabled = $true
            }
        }
    }
}
$checkUpdateButton = $window.FindName('checkUpdateButton')
$checkUpdateButton.Add_Click({ Test-AtomUpdate })

$updateButton = $window.FindName('updateButton')
$updateButton.Add_Click({
    $updateAtomPath = "$dependenciesPath\Update-ATOM.ps1"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$updateAtomPath`""
})

##################
##  Path panel  ##
##################

$pathButton = $window.FindName('pathButton')
$pathButton.Add_Click({ Start-Process explorer $atomPath })

####################
##  Github panel  ##
####################

$atomUrl = "https://github.com/SkylerWallace/ATOM"

$githubLinkButton = $window.FindName('githubLinkButton')
$githubLinkButton.Add_Click({ [System.Windows.Forms.Clipboard]::SetText($atomUrl) })

$githubLaunchButton = $window.FindName('githubLaunchButton')
$githubLaunchButton.Add_Click({ Start-Process $atomUrl })

$githubTextBox = $window.FindName('githubTextBox')
$githubTextBox.Text = $atomUrl
$githubTextBox.ToolTip = $atomUrl

###################
##  Theme panel  ##
###################

$themeSelectorButton = $window.FindName('themeSelectorButton')
$themeSelectorText = $window.FindName('themeSelectorText')
$themeSelectorIndicator = $window.FindName('themeSelectorIndicator')
$themePanel = $window.FindName('themePanel')
$themeSwatches = @{
    primaryBrush = $window.FindName('themePrimarySwatch')
    backgroundBrush = $window.FindName('themeBackgroundSwatch')
    surfaceBrush = $window.FindName('themeSurfaceSwatch')
    accentBrush = $window.FindName('themeAccentSwatch')
}

function Update-ThemeSelector {
    $themeName = [String]$script:atomSettings.Theme.Value
    $palette = $themes[$themeName]
    if (!$palette) { return }

    $themeSelectorText.Text = $themeName
    foreach ($entry in $themeSwatches.GetEnumerator()) {
        $color = [System.Windows.Media.ColorConverter]::ConvertFromString($palette[$entry.Key])
        $entry.Value.Background = [System.Windows.Media.SolidColorBrush]::new($color)
    }
}

function Set-ThemeSelectorExpanded {
    param ([Boolean]$Expanded)

    $themePanel.Visibility = if ($Expanded) { 'Visible' } else { 'Collapsed' }
    Set-VectorIcon -ForegroundResource surfaceText -ResourceMappings @{ 'themeSelectorIndicator' = $(if ($Expanded) { 'ArrowDropUpIcon' } else { 'ArrowDropDownIcon' }) }
    $themeSelectorButton.ToolTip = if ($Expanded) { 'Hide theme options' } else { 'Show theme options' }
}

$themeSelectorButton.Add_Click({
    Set-ThemeSelectorExpanded ($themePanel.Visibility -ne [System.Windows.Visibility]::Visible)
})

Update-ThemeSelector
Set-ThemeSelectorExpanded $false
foreach ($theme in $themes.GetEnumerator() | Sort-Object Key) {
    $themeButton = New-Object System.Windows.Controls.Button
    $themeButton.Width = 75
    $themeButton.Margin = 2.5
    $themeButton.Tag = $theme
    $themeButton.Background = 'Transparent'
    $themeButton.Style = $window.Resources['RoundedButton']
    $themeButton.Add_Click({
        # Save theme and update matching resources
        $script:atomSettings.Theme.Value = $this.Tag.Key
        Save-AtomSettings

        foreach ($key in $this.Tag.Value.Keys) {
            if (!$window.Resources.Contains($key)) { continue }

            $value = $this.Tag.Value[$key]
            $resource = $window.Resources[$key]
            $window.Resources[$key] =
                if ($resource -is [System.Windows.Media.SolidColorBrush]) {
                    [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString($value))
                } elseif ($resource -is [System.Windows.Media.Color]) {
                    [System.Windows.Media.ColorConverter]::ConvertFromString($value)
                } elseif ($resource -is [Double]) {
                    [Double]$value
                } else {
                    $resource
                }
        }

        Update-ThemeSelector
    })

    $themeLabel = New-Object System.Windows.Controls.TextBlock
    $themeLabel.Margin = '2.5,2.5,2.5,0'
    $themeLabel.FontSize = 11
    $themeLabel.Text = $theme.Key
    $themeLabel.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
    $themeLabel.TextAlignment = 'Center'
    $themeLabel.TextWrapping = 'Wrap'

    $swatchPanel = New-Object System.Windows.Controls.StackPanel
    $swatchPanel.Orientation = 'Horizontal'
    $swatchPanel.HorizontalAlignment = 'Center'
    $swatchPanel.Margin = 2.5
    $swatchKeys = 'primaryBrush', 'backgroundBrush', 'surfaceBrush', 'accentBrush'
    for ($index = 0; $index -lt $swatchKeys.Count; $index++) {
        $swatch = New-Object System.Windows.Controls.Border
        $swatch.Width = 12
        $swatch.Height = 12
        $swatch.Margin = 1
        $swatch.Background = $theme.Value[$swatchKeys[$index]]
        $swatch.CornerRadius = if ($index -eq 0) { '5,0,0,5' } elseif ($index -eq 3) { '0,5,5,0' } else { 0 }
        $swatchPanel.Children.Add($swatch) | Out-Null
    }

    $themeContent = New-Object System.Windows.Controls.StackPanel
    $themeContent.Children.Add($themeLabel) | Out-Null
    $themeContent.Children.Add($swatchPanel) | Out-Null
    $themeButton.Content = $themeContent
    $themePanel.Children.Add($themeButton) | Out-Null
}
####################
##  Toggle panel  ##
####################

function Save-AtomSettings {
    $lines = @(
        '$userAtomSettings = [ordered]@{'
        foreach ($setting in $script:atomSettings.GetEnumerator()) {
            $value = $setting.Value.Value
            $literal = if ($value -is [Boolean]) { '$' + $value.ToString().ToLowerInvariant() }
                       elseif ($value -is [String]) { "'$($value.Replace("'", "''"))'" }
                       else { $value }
            "    $($setting.Name) = @{ Value = $literal }"
        }
        '}'
    )
    Set-Content -Path "$configPath\SettingsUser.ps1" -Value $lines
}
$togglePanel = $window.FindName('togglePanel')

$toggleSettingChanged = {
    $script:atomSettings[$this.Tag].Value = [Boolean]$this.IsChecked
    if ($this.Tag -in 'ShowToolTips', 'SearchPluginTags', 'ShowHiddenPlugins') { $script:pluginListDirty = $true }
    if (!$script:restoringDefaults) { Save-AtomSettings }
}
$atomSettings.GetEnumerator() | Where-Object { $_.Value.ControlType } | ForEach-Object {
    $setting = $_.Value
    $settingName = $_.Name

    switch ($setting.ControlType) {
        'ToggleButton' {
            $listBoxItem = New-ListBoxControlItem -ControlType ToggleButton -ControlAlignment Right -Text $setting.Name -Tag $settingName -ToolTip $setting.ToolTip

            $listBoxItem.Text.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty,'surfaceText')
            $listBoxItem.Control.IsChecked = $setting.Value

            $listBoxItem.Control.Add_Checked($toggleSettingChanged)
            $listBoxItem.Control.Add_Unchecked($toggleSettingChanged)
        }

        'RadioButton' {
            $textBlock = New-Object System.Windows.Controls.TextBlock
            $textBlock.Text = $setting.Name
            $textBlock.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty,'surfaceText')
            $textBlock.VerticalAlignment = 'Center'
            $textBlock.FontSize = 12
            $textBlock.Margin = '2.5,0,2.5,0'

            $optionPanel = New-Object System.Windows.Controls.StackPanel
            $optionPanel.Orientation = 'Horizontal'
            $optionPanel.VerticalAlignment = 'Center'

            foreach ($option in $setting.Options.GetEnumerator()) {
                $radioButton = New-Object System.Windows.Controls.RadioButton
                $radioButton.Content = $option.Key
                $radioButton.GroupName = $settingName
                $radioButton.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
                $radioButton.Margin = '5,0,5,0'
                $radioButton.IsChecked = $setting.Value -eq $option.Value
                $radioButton.Tag = @{
                    Setting = $settingName
                    Value   = $option.Value
                }

                $radioButton.Add_Checked({
                    $script:atomSettings.($this.Tag.Setting).Value = $this.Tag.Value
                    if ($this.Tag.Setting -eq 'PluginClicks') { $script:pluginListDirty = $true }
                    if (!$script:restoringDefaults) { Save-AtomSettings }
                })

                $optionPanel.Children.Add($radioButton) | Out-Null
            }

            # Put controls in grid
            $settingsGrid = New-Object System.Windows.Controls.Grid
            $settingsGrid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = '1*' }))
            $settingsGrid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = [System.Windows.GridLength]::Auto }))
            $settingsGrid.Height = 20

            [System.Windows.Controls.Grid]::SetColumn($textBlock, 0)
            [System.Windows.Controls.Grid]::SetColumn($optionPanel, 1)

            $settingsGrid.Children.Add($textBlock) | Out-Null
            $settingsGrid.Children.Add($optionPanel) | Out-Null

            $listBoxItem = New-Object System.Windows.Controls.ListBoxItem
            $listBoxItem.Content = $settingsGrid
            $listBoxItem.ToolTip = $setting.ToolTip
            $listBoxItem.Tag = $optionPanel

            $listBoxItem.Add_MouseClick({
                $radioButtons = @($this.Tag.Children)

                for ($i = 0; $i -lt $radioButtons.Count; $i++) {
                    if ($radioButtons[$i].IsChecked) { break }
                }

                $radioButtons[(($i + 1) % $radioButtons.Count)].IsChecked = $true
            })
        }
    }

    $togglePanel.Children.Add($listBoxItem) | Out-Null
}

# Default settings button
$defaultSwitchButton = $window.FindName('defaultSwitchButton')
$defaultSwitchButton.Add_Click({
    # Load default settings
    . "$configPath\Settings.ps1"

    # Update toggle and radio-button controls without saving once per changed control.
    $script:restoringDefaults = $true
    try {
        $togglePanel.Children | Where-Object { $_ -is [System.Windows.Controls.ListBoxItem] } | ForEach-Object {
            $listBoxItem = $_

            if ($listBoxItem.Control -is [System.Windows.Controls.Primitives.ToggleButton]) {
                $settingName = $listBoxItem.Control.Tag
                $listBoxItem.Control.IsChecked = [bool]$atomSettings[$settingName].Value
            } elseif ($listBoxItem.Tag -is [System.Windows.Controls.StackPanel]) {
                $listBoxItem.Tag.Children | Where-Object { $_ -is [System.Windows.Controls.RadioButton] } | ForEach-Object {
                    $settingName = $_.Tag.Setting
                    $_.IsChecked = $_.Tag.Value -eq $atomSettings[$settingName].Value
                }
            }
        }
    } finally {
        $script:restoringDefaults = $false
    }

    # Save settings
    $script:pluginListDirty = $true
    Save-AtomSettings
})
$window.ShowDialog() | Out-Null
$versionData = Import-PowerShellDataFile -Path "$PSScriptRoot\Config\Version.psd1"
$version = "v$($versionData.Version)"
Add-Type -AssemblyName PresentationFramework

# Import module(s)
Import-Module "$psScriptRoot\Functions\AtomModule.psm1" -Function Get-AtomFileHash, Get-AtomUpdateContext, Get-AtomUpdateState, Invoke-Runspace, New-AtomFileManifest, Set-AtomPluginOverride, Set-WindowStyle, Write-AtomFileAtomic, Write-AtomSettingsFile, Write-AtomUpdateState -Variable *
Import-Module "$psScriptRoot\Functions\AtomWpfModule.psm1"
$script:programDefaults = $programDefaults

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
        <StackPanel Name="generalSettingsPanel"/>
    </Border>

    <!-- PLUGINS PANEL -->
    <TextBlock Text="Plugins" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <StackPanel Name="pluginSettingsPanel"/>
    </Border>

    <!-- QUIPS PANEL -->
    <TextBlock Text="Quips" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <StackPanel Name="quipSettingsPanel"/>
    </Border>

    <!-- APPEARANCE PANEL -->
    <TextBlock Text="Appearance" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <StackPanel>
            <Grid Margin="5,12,5,10">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>
                <TextBlock Text="UI scaling" Foreground="{DynamicResource surfaceText}" FontSize="12" VerticalAlignment="Center" Margin="5,0,0,0"/>
                <TextBlock Name="uiScalingValueText" Grid.Column="1" Foreground="{DynamicResource surfaceText}" FontSize="12" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,5,0"/>
                <Slider Name="uiScalingSlider" Grid.Row="1" Grid.ColumnSpan="2" Minimum="1" Maximum="1.5" TickFrequency="0.125" SmallChange="0.125" LargeChange="0.125" IsSnapToTickEnabled="True" IsMoveToPointEnabled="True" Margin="5,12,5,5" ToolTip="Scale the entire interface between 1.0x and 1.5x"/>
            </Grid>
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
            <Grid Margin="5,2.5">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <TextBlock Text="Update channel:" FontSize="12" Foreground="{DynamicResource surfaceText}" VerticalAlignment="Center" Margin="2.5,0"/>
                <ComboBox Name="updateChannelSelector" Grid.Column="1" Width="145" HorizontalAlignment="Right" Style="{StaticResource CustomComboBox}" SelectedValuePath="Tag" ToolTip="Choose the GitHub branch used for ATOM updates">
                    <ComboBoxItem Content="Stable" Tag="main"/>
                    <ComboBoxItem Content="Development" Tag="dev"/>
                </ComboBox>
            </Grid>
            <Grid>
                <TextBlock Text="Installed:" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                <TextBlock Name="installedVersionText" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
            </Grid>
            <Grid>
                <TextBlock Text="Status:" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                <TextBlock Name="updateText" MaxWidth="185" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Right" VerticalAlignment="Center" TextAlignment="Right" TextWrapping="Wrap" Margin="5"/>
            </Grid>
            <Button Name="updateActionButton" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" HorizontalAlignment="Stretch" Style="{StaticResource RoundedButton}" Margin="5" ToolTip="Check for updates or apply the available ATOM action">
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                    <ContentControl Name="updateActionImage" Width="16" Height="16" Margin="5"/>
                    <TextBlock Name="updateActionText" Text="Check for Updates" FontSize="11" VerticalAlignment="Center" Margin="0,5,5,5"/>
                </StackPanel>
            </Button>
            <Button Name="healthCheckButton" Background="Transparent" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Center" Style="{StaticResource RoundedButton}" Margin="5,0,5,5" ToolTip="Verify ATOM-owned files without affecting user-added files">
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                    <ContentControl Name="healthCheckImage" Width="14" Height="14" Margin="5"/>
                    <TextBlock Text="Verify ATOM Files" FontSize="11" VerticalAlignment="Center" Margin="0,5,5,5"/>
                </StackPanel>
            </Button>
            <TextBlock Name="healthCheckText" FontSize="11" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Center" TextAlignment="Center" TextWrapping="Wrap" Margin="5,0,5,5" Visibility="Collapsed"/>
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

            <Button Name="githubButton" Grid.Row="2" Grid.Column="0" Height="25" Width="25" VerticalAlignment="Center" Style="{StaticResource RoundHoverButtonStyle}" Margin="2" ToolTip="Open ATOM repository in browser"/>
            <TextBlock Name="githubTextBox" Grid.Row="2" Grid.Column="1" Foreground="{DynamicResource surfaceText}" TextTrimming="CharacterEllipsis" VerticalAlignment="Center" Margin="5,2"/>
        </Grid>
    </Border>

    <!-- RESET SETTINGS PANEL -->
    <TextBlock Text="Reset settings" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <Button Name="defaultSwitchButton" Width="130" Background="{DynamicResource accentBrush}" HorizontalAlignment="Center" Style="{StaticResource RoundedButton}" Margin="5">
            <StackPanel Orientation="Horizontal">
                <ContentControl Name="restoreImage" Width="16" Height="16" Margin="5"/>
                <TextBlock Text="Restore Defaults" FontSize="11" Foreground="{DynamicResource accentText}" VerticalAlignment="Center"/>
            </StackPanel>
        </Button>
    </Border>
</StackPanel>
"@

$contentXaml = @"
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="0"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

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
"@

$titleContentXaml = @'
<Viewbox x:Name="atomLogo" Grid.Column="0" Width="105" Height="30" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="15,5">
    <Canvas Width="1905" Height="358">
        <Path Data="{StaticResource AtomLogoGeometry}" Fill="{DynamicResource primaryText}"/>
    </Canvas>
</Viewbox>
'@

$headerActionsXaml = @'
<Button Name="settingsButton" Width="28" Height="28" Style="{StaticResource RoundHoverButtonStyle}" Margin="2" ToolTip="Settings"/>
'@

$windowParameters = @{
    Title                 = "ATOM $version"
    TitleContentXaml      = $titleContentXaml
    HeaderActionsXaml     = $headerActionsXaml
    ContentXaml           = $contentXaml
    Width                 = 469
    Height                = 600
    MinWidth              = 255
    MinHeight             = 600
    MaxWidth              = 923
    MaxHeight             = 800
    SizeToContent         = 'Height'
    WindowStartupLocation = 'Manual'
    WireWindowButtons     = $false
}
$window = New-AtomWindow @windowParameters
$window.Top = 0
$window.Left = 0

# Assign variables to elements in XAML
$refreshButton          = $window.FindName('refreshButton')
$settingsButton         = $window.FindName('settingsButton')
$minimizeButton         = $window.FindName('atomMinimizeButton')
$closeButton            = $window.FindName('atomCloseButton')
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
function Update-AtomStatusContentLayout {
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

$statusContentGrid.Add_SizeChanged({ Update-AtomStatusContentLayout })
$statusActions.Add_SizeChanged({ Update-AtomStatusContentLayout })

# Load quips
. $configPath\Quippy.ps1

# Automatically launch MountOS when ATOM is running in Windows PE.
$inPe = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
if ($inPe) {
    $mountOs = Get-ChildItem $atomPath -Filter 'MountOS.ps1' -Recurse | Select-Object -Expand FullName
    Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$mountOs`"" -Wait
}
# Set icon sources
$primaryIconResources = @{
    'settingsButton' = 'SettingsIcon'
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
    'githubButton' = 'GitHubIcon'
    'healthCheckImage' = 'CheckboxIcon'
}

$accentIconResources = @{
    'updateActionImage' = 'DownloadIcon'
    'restoreImage' = 'ResetWrenchIcon'
}

Set-VectorIcon -Window $window -ForegroundResource primaryText -ResourceMappings $primaryIconResources
Set-VectorIcon -Window $window -ForegroundResource backgroundText -ResourceMappings $backgroundIconResources
Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings $surfaceIconResources
Set-VectorIcon -Window $window -ForegroundResource accentText -ResourceMappings $accentIconResources

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
function Get-AtomDownloadItem {
    foreach ($categoryGrid in $pluginWrapPanel.Children) {
        $border = $categoryGrid.Children | Where-Object { $_ -is [System.Windows.Controls.Border] } | Select-Object -First 1
        if (!$border) { continue }

        foreach ($item in $border.Child.Items) {
            if ($item.Control -is [System.Windows.Controls.CheckBox]) { $item }
        }
    }
}

# Keep category checkboxes and the download action bar synchronized with checked plugins
function Update-AtomDownloadSelectionState {
    if (!$script:downloadMode -or $window.Tag.UpdatingDownloadSelection) { return }

    $selectedCount = 0
    $window.Tag.UpdatingDownloadSelection = $true

    try {
        foreach ($categoryGrid in $pluginWrapPanel.Children) {
            $border = $categoryGrid.Children | Where-Object { $_ -is [System.Windows.Controls.Border] } | Select-Object -First 1
            $categoryCheckBox = $categoryGrid.Tag
            if (!$border -or $categoryCheckBox -isnot [System.Windows.Controls.CheckBox]) { continue }

            $availableItems = @($border.Child.Items | Where-Object { $_.IsEnabled })
            $checkedItems = @($availableItems | Where-Object { $_.Control.IsChecked })
            $selectedCount += $checkedItems.Count

            $categoryCheckBox.IsEnabled = $availableItems.Count -gt 0
            $categoryCheckBox.Opacity = if ($categoryCheckBox.IsEnabled) { 1.0 } else { 0.44 }
            $categoryCheckBox.IsChecked = $availableItems.Count -gt 0 -and $checkedItems.Count -eq $availableItems.Count
        }
    } finally {
        $window.Tag.UpdatingDownloadSelection = $false
    }

    $statusBarStatus.Text = if ($selectedCount -eq 1) { '1 program selected' } else { "$selectedCount programs selected" }
    $downloadSelectedButton.IsEnabled = $selectedCount -gt 0
}


# Keep the hidden-plugin button synchronized with the persisted setting
function Update-AtomVisibilityButton {
    if ($atomSettings.ShowHiddenPlugins.Value) {
        $visibilityButton.ToolTip = 'Hide hidden plugins'
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'visibilityButton' = 'VisibilityIcon' }
    } else {
        $visibilityButton.ToolTip = 'Show hidden plugins'
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'visibilityButton' = 'VisibilityOffIcon' }
    }
}

# Persist one property in the canonical userPrograms hashtable.
function Set-AtomPluginPreference {
    param (
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][ValidateSet('Category', 'Hidden', 'Favorite')][String]$Property,
        [Parameter(Mandatory)][Object]$Value
    )

    $overridePath = Join-Path $configPath 'PluginsUser.ps1'
    Set-AtomPluginOverride -Path $overridePath -Defaults $script:programDefaults -Name $Name -Property $Property -Value $Value
}

# Persist a plugin category override without moving its launcher file
function Set-AtomPluginCategory {
    param (
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$Category
    )

    Set-AtomPluginPreference -Name $Name -Property Category -Value $Category
    Update-AtomPluginList -Reload
    $statusBarStatus.Text = "Moved $Name to $Category"
}

# Persist whether a plugin is hidden
function Set-AtomPluginVisibility {
    param (
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][Boolean]$Hidden
    )

    Set-AtomPluginPreference -Name $Name -Property Hidden -Value $Hidden
    Update-AtomPluginList -Reload
    $statusBarStatus.Text = if ($Hidden) { "Hid $Name" } else { "Unhid $Name" }
}

# Persist a favorite override and update only the affected plugin row.
function Set-AtomPluginFavorite {
    param (
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][Boolean]$Favorite
    )

    Set-AtomPluginPreference -Name $Name -Property Favorite -Value $Favorite
    $script:programs[$Name]['Favorite'] = $Favorite

    $pluginItem = foreach ($categoryGrid in @($pluginWrapPanel.Children)) {
        $listBox = @($categoryGrid.Children | Where-Object { $_ -is [Windows.Controls.Border] })[0].Child
        @($listBox.Items) | Where-Object { $_.Tag.Name -eq $Name }
    }

    if ($pluginItem) {
        $pluginItem.Tag.Config['Favorite'] = $Favorite
        $favoriteIcon = @($pluginItem.TrailingContent | Where-Object Tag -eq 'Favorite')[0]

        if ($Favorite -and !$favoriteIcon) {
            $favoriteIcon = New-VectorIcon -Window $window -Icon 'StarIcon' -ForegroundResource 'accentBrush' -Size 14 -OpticalSize 20 -Filled
            $favoriteIcon.Tag = 'Favorite'
            $favoriteIcon.Margin = '6,0,2.5,0'
            [Windows.Controls.DockPanel]::SetDock($favoriteIcon, 'Right')
            $insertAt = $pluginItem.Content.Children.IndexOf($pluginItem.Text)
            $pluginItem.Content.Children.Insert($insertAt, $favoriteIcon)
            $pluginItem.TrailingContent = @($favoriteIcon) + @($pluginItem.TrailingContent)
        } elseif (!$Favorite -and $favoriteIcon) {
            $pluginItem.Content.Children.Remove($favoriteIcon)
            $pluginItem.TrailingContent = @($pluginItem.TrailingContent | Where-Object { $_ -ne $favoriteIcon })
        }

        $favoriteMenuItem = @($pluginItem.ContextMenu.Items | Where-Object { $_.Tag.Name -eq $Name -and $null -ne $_.Tag.Favorite })[0]
        $favoriteMenuItem.Header = if ($Favorite) { 'Unfavorite' } else { 'Favorite' }
        $favoriteMenuItem.Tag.Favorite = !$Favorite
        $favoriteMenuItem.Icon = New-VectorIcon -Window $window -Icon 'StarIcon' -ForegroundResource 'accentText' -Size 14 -OpticalSize 20 -Filled:$Favorite
    }

    $statusBarStatus.Text = if ($Favorite) { "Favorited $Name" } else { "Unfavorited $Name" }
}

# Show configuration, file, executable, and download details for a plugin
function Show-AtomPluginProperties {
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
            Favorite             = [Boolean]$Plugin.Config.Favorite
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

    $text = foreach ($section in $sections.GetEnumerator()) {
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

    $dialog = New-Object Windows.Window
    $dialog.Title = "$($Plugin.Name) Properties"
    $dialog.Owner = $window
    $dialog.Width = 700
    $dialog.Height = 600
    $dialog.MinWidth = 450
    $dialog.MinHeight = 300
    $dialog.WindowStartupLocation = 'CenterOwner'
    $dialog.ShowInTaskbar = $false
    $dialog.Background = $window.FindResource('backgroundBrush')

    $details = New-Object Windows.Controls.TextBox
    $details.Text = ($text -join [Environment]::NewLine).TrimEnd()
    $details.IsReadOnly = $true
    $details.AcceptsReturn = $true
    $details.TextWrapping = 'NoWrap'
    $details.VerticalScrollBarVisibility = 'Auto'
    $details.HorizontalScrollBarVisibility = 'Auto'
    $details.FontFamily = 'Consolas'
    $details.FontSize = 12
    $details.Margin = 10
    $details.Padding = 10
    $details.Background = $window.FindResource('surfaceBrush')
    $details.Foreground = $window.FindResource('surfaceText')
    $details.BorderBrush = $window.FindResource('accentBrush')
    $dialog.Content = $details

    [void]$dialog.ShowDialog()
}

function Open-AtomPluginFileLocation {
    param ([Parameter(Mandatory)]$Plugin)

    if (!$Plugin.FullName -or !(Test-Path -LiteralPath $Plugin.FullName -PathType Leaf)) { return }

    $explorerArguments = '/select,"{0}"' -f $Plugin.FullName
    Start-Process -FilePath 'explorer.exe' -ArgumentList $explorerArguments
}

function Open-AtomPluginInEditor {
    param ([Parameter(Mandatory)]$Plugin)

    if (!$Plugin.FullName -or [IO.Path]::GetExtension($Plugin.FullName) -notin '.ps1', '.bat', '.cmd') { return }

    $configuredEditor = [String]$script:atomSettings.PluginEditor.Value
    $editorPath = if (
        $configuredEditor -eq 'notepad.exe' -or
        (Test-Path -LiteralPath $configuredEditor -PathType Leaf)
    ) { $configuredEditor } else { 'notepad.exe' }

    Start-Process -FilePath $editorPath -ArgumentList ('"{0}"' -f $Plugin.FullName)
}

function Get-AtomPluginEditorOptions {
    $options = [ordered]@{ 'Notepad' = 'notepad.exe' }
    $editorCandidates = [ordered]@{
        'Visual Studio Code' = @(
            "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
            "$env:ProgramFiles\Microsoft VS Code\Code.exe"
            "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
            (Get-Command 'code.exe' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source)
        )
        'Notepad++' = @(
            "$env:ProgramFiles\Notepad++\notepad++.exe"
            "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe"
            (Get-Command 'notepad++.exe' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source)
        )
    }

    foreach ($editor in $editorCandidates.GetEnumerator()) {
        $editorPath = @($editor.Value | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } | Select-Object -First 1)[0]
        if ($editorPath) { $options[$editor.Key] = $editorPath }
    }

    $configuredEditor = [String]$script:atomSettings.PluginEditor.Value
    if ($configuredEditor -ne 'notepad.exe' -and $options.Values -notcontains $configuredEditor) {
        $options[[IO.Path]::GetFileNameWithoutExtension($configuredEditor)] = $configuredEditor
    }
    $options['Choose application...'] = '__choose__'

    return $options
}

# Function to load plugins in listboxes
function Update-AtomPluginList {
    param (
        [ValidateSet('Category', 'Alphabetical')]
        [String]$SortMode = $(
            if ($script:atomSettings.SortPlugins.Value -eq 'Alphabetical') { 'Alphabetical' }
            else { 'Category' }
        ),
        [Switch]$Reload
    )

    Update-AtomVisibilityButton

    $selectedPrograms =
        if ($script:downloadMode) {
            @(Get-AtomDownloadItem | Where-Object { $_.IsEnabled -and $_.Control.IsChecked } | ForEach-Object { $_.Control.Tag })
        } else {
            @()
        }

    $pluginWrapPanel.Children.Clear()
    $downloadSelectedButton.Visibility = if ($script:downloadMode) { 'Visible' } else { 'Collapsed' }
    $programUpdateButton.Visibility = if ($script:downloadMode) { 'Visible' } else { 'Collapsed' }

    # Reload plugin configuration and file discovery only when explicitly invalidated.
    if ($Reload) {
        . $atomPath\Config\Plugins.ps1
        $script:programs = $programs
        $script:programDefaults = $programDefaults
    }
    if ($Reload -or !$script:pluginFiles) {
        $script:pluginFiles = @(Get-ChildItem -LiteralPath $pluginsPath -File | Where-Object Extension -in '.ps1', '.bat', '.cmd', '.exe', '.lnk')
    }

    $pluginSources = @($script:pluginFiles)
    if ($script:downloadMode) {
        $pluginFileNames = @($script:pluginFiles.BaseName)
        $pluginSources += @(
            $programs.GetEnumerator() | Where-Object {
                $_.Value.DownloadOnly -and $_.Value.ProgramInfo -and $pluginFileNames -notcontains $_.Key
            } | ForEach-Object {
                [PSCustomObject]@{
                    BaseName  = $_.Key
                    FullName  = $null
                    Extension = $null
                    Directory = [PSCustomObject]@{ FullName = $pluginsPath }
                }
            }
        )
    }

    $plugins = $pluginSources | ForEach-Object {
        $name = $_.BaseName
        $pluginConfig = $programs[$name]
        $category = if ($pluginConfig.Category) { [String]$pluginConfig.Category } elseif ($_.Directory.FullName -ne $pluginsPath) { $_.Directory.Name } else { 'Uncategorized' }
        $fullName = $_.FullName
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

        if (!$script:downloadMode -and $pluginConfig.DownloadOnly) {
            return
        } elseif ($script:downloadMode) {
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
            FullName     = $fullName
            Config       = $pluginConfig
            ProgramInfo  = $programInfo
            Category     = $category
            GroupCategory =
                if ($SortMode -eq 'Alphabetical') { 'All Plugins' }
                else { $category }
			LaunchParams = switch ($_.Extension) {
				'.bat' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$fullName`"" } }
				'.cmd' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$fullName`"" } }
				'.exe' { @{ FilePath = $fullName } }
				'.lnk' { @{ FilePath = $fullName } }
				'.ps1' { @{ FilePath = 'powershell'; ArgumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$fullName`"" } }
			}
        }
    } | Sort-Object GroupCategory, Name

    # Group plugins for UI
    $pluginGroups = $plugins | Group-Object GroupCategory

    foreach ($group in $pluginGroups) {
        # Create listbox for each plugin category
        $textBlock = New-Object System.Windows.Controls.TextBlock
        $textBlock.Text = $group.Name
        $textBlock.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'backgroundText')
        $textBlock.FontSize = 14
        $textBlock.Margin = '0,10,0,0'
        $textBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Bottom

        $listBox = New-Object System.Windows.Controls.ListBox
        $listBox.Background = 'Transparent'
        $listBox.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
        $listBox.BorderThickness = 0
        $listBox.Margin = 5
        $listBox.Padding = 0
        $listBox.Width = 200
        $listBox.SetValue([System.Windows.Controls.ScrollViewer]::HorizontalScrollBarVisibilityProperty, [System.Windows.Controls.ScrollBarVisibility]::Disabled)

        $categoryHeader = $textBlock
        $categoryCheckBox = $null

        if ($script:downloadMode) {
            $categoryCheckBox = New-Object System.Windows.Controls.CheckBox
            $categoryCheckBox.Tag = $listBox
            $categoryCheckBox.ToolTip = "Select all available programs in $($group.Name)"
            $categoryCheckBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Bottom
            $categoryCheckBox.Margin = '0,10,5,0'
            $categoryCheckBox.LayoutTransform = [System.Windows.Media.ScaleTransform]::new(0.8, 0.8)

            $categoryCheckBox.Add_Checked({
                if ($window.Tag.UpdatingDownloadSelection) { return }
                $window.Tag.UpdatingDownloadSelection = $true
                try {
                    $this.Tag.Items | Where-Object { $_.IsEnabled } | ForEach-Object { $_.Control.IsChecked = $true }
                } finally {
                    $window.Tag.UpdatingDownloadSelection = $false
                }
                Update-AtomDownloadSelectionState
            })
            $categoryCheckBox.Add_Unchecked({
                if ($window.Tag.UpdatingDownloadSelection) { return }
                $window.Tag.UpdatingDownloadSelection = $true
                try {
                    $this.Tag.Items | Where-Object { $_.IsEnabled } | ForEach-Object { $_.Control.IsChecked = $false }
                } finally {
                    $window.Tag.UpdatingDownloadSelection = $false
                }
                Update-AtomDownloadSelectionState
            })

            $categoryHeader = New-Object System.Windows.Controls.StackPanel
            $categoryHeader.Orientation = [System.Windows.Controls.Orientation]::Horizontal
            $categoryHeader.Children.Add($categoryCheckBox) | Out-Null
            $categoryHeader.Children.Add($textBlock) | Out-Null
        }

        $border = New-Object System.Windows.Controls.Border
        $border.Style = $window.FindResource('CustomBorder')
        $border.Margin = '0,5,0,0'
        $border.SetValue([System.Windows.Controls.Grid]::RowProperty, 1)
        $border.Child = $listBox

        # Configure listbox into plugin wrappanel
        $grid = New-Object System.Windows.Controls.Grid
        $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
        $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
        $grid.Margin = '0,0,10,0'
        $grid.Tag = $categoryCheckBox

        if (!$script:downloadMode -and $SortMode -eq 'Category') {
            $grid.AllowDrop = $true
            $grid.DataContext = $group.Name

            $grid.Add_DragOver({
                param($sender, $eventArgs)

                $sourceCategory =
                    if ($eventArgs.Data.GetDataPresent('ATOM.PluginCategory')) { [String]$eventArgs.Data.GetData('ATOM.PluginCategory') }
                    else { $null }

                $eventArgs.Effects =
                    if ($sourceCategory -and $sourceCategory -ne $sender.DataContext) { [Windows.DragDropEffects]::Move }
                    else { [Windows.DragDropEffects]::None }
                $eventArgs.Handled = $true
            })

            $grid.Add_Drop({
                param($sender, $eventArgs)

                if ($eventArgs.Data.GetDataPresent('ATOM.PluginName')) {
                    try {
                        Set-AtomPluginCategory -Name ([String]$eventArgs.Data.GetData('ATOM.PluginName')) -Category ([String]$sender.DataContext)
                    } catch {
                        $statusBarStatus.Text = "Unable to move plugin: $($_.Exception.Message)"
                    }
                }
                $eventArgs.Handled = $true
            })
        }

        $grid.Children.Add($categoryHeader) | Out-Null
        $grid.Children.Add($border) | Out-Null
        $grid.RowDefinitions[0].Height = [System.Windows.GridLength]::Auto
        $pluginWrapPanel.Children.Add($grid) | Out-Null

        foreach ($plugin in $group.Group) {
            $name = $plugin.Name
            $iconPath = "$resourcesPath\Icons\Program Icons\$name.png"

            if (!(Test-Path $iconPath)) {
                $firstLetter = $name.Substring(0,1)
                $iconPath =
                    if ($firstLetter -match '^[A-Z]') { "$resourcesPath\Icons\Default\$firstLetter.png" }
                    else { "$resourcesPath\Icons\Default\#.png" }
            }

            $listBoxItemParams = @{
                Text = $name
                ImageSource = $iconPath
                ToolTip =
                    if ($atomSettings.ShowToolTips.Value -and $plugin.Config.ToolTip) { $plugin.Config.ToolTip }
                    else { $null }
            }

            $trailingContent = @()
            if (!$script:downloadMode -and $plugin.Config.Favorite) {
                $favoriteIcon = New-VectorIcon -Window $window -Icon 'StarIcon' -ForegroundResource 'accentBrush' -Size 14 -OpticalSize 20 -Filled
                $favoriteIcon.Tag = 'Favorite'
                $favoriteIcon.Margin = '6,0,2.5,0'
                $trailingContent += $favoriteIcon
            }
            if ($plugin.Config.Hidden) {
                $hiddenIcon = New-VectorIcon -Window $window -Icon 'VisibilityOffIcon' -ForegroundResource 'surfaceText' -Size 14 -OpticalSize 20
                $hiddenIcon.Tag = 'Hidden'
                $hiddenIcon.Margin = '6,0,2.5,0'
                $trailingContent += $hiddenIcon
            }
            if ($trailingContent.Count) { $listBoxItemParams.TrailingContent = $trailingContent }

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

            $contextMenu = New-Object System.Windows.Controls.ContextMenu
            $contextMenu.Style = $window.FindResource('CustomContextMenu')
            $contextMenu.Background = $window.FindResource('accentBrush')
            $contextMenu.Add_Opened({
                $this.Background = $window.FindResource('accentBrush')
                foreach ($menuItem in $this.Items) {
                    $menuItem.Foreground = $window.FindResource('accentText')
                }
            }.GetNewClosure())

            $menuHeaderPanel = New-Object Windows.Controls.StackPanel
            $menuHeaderPanel.Orientation = [Windows.Controls.Orientation]::Horizontal

            $menuHeaderImage = New-Object Windows.Controls.Image
            $menuHeaderImage.Source = Get-CachedImage -Path $iconPath
            $menuHeaderImage.Width = 20
            $menuHeaderImage.Height = 20
            $menuHeaderImage.Margin = '0,0,8,0'
            $menuHeaderPanel.Children.Add($menuHeaderImage) | Out-Null

            $menuHeaderText = New-Object Windows.Controls.TextBlock
            $menuHeaderText.Text = $plugin.Name
            $menuHeaderText.FontWeight = [Windows.FontWeights]::SemiBold
            $menuHeaderText.VerticalAlignment = [Windows.VerticalAlignment]::Center
            $menuHeaderPanel.Children.Add($menuHeaderText) | Out-Null

            $menuHeaderItem = New-Object Windows.Controls.MenuItem
            $menuHeaderItem.Header = $menuHeaderPanel
            $menuHeaderItem.Style = $window.FindResource('CustomContextMenuHeader')
            $contextMenu.Items.Add($menuHeaderItem) | Out-Null

            $menuSeparator = New-Object Windows.Controls.Separator
            $menuSeparator.Style = $window.FindResource('CustomContextMenuSeparator')
            $contextMenu.Items.Add($menuSeparator) | Out-Null
            $favoriteMenuItem = New-Object Windows.Controls.MenuItem
            $favoriteMenuItem.Header = if ($plugin.Config.Favorite) { 'Unfavorite' } else { 'Favorite' }
            $favoriteMenuItem.Tag = @{
                Name = $plugin.Name
                Favorite = !$plugin.Config.Favorite
            }
            $favoriteMenuItem.Style = $window.FindResource('CustomContextMenuItem')
            $favoriteMenuItem.Icon = New-VectorIcon -Window $window -Icon 'StarIcon' -ForegroundResource 'accentText' -Size 14 -OpticalSize 20 -Filled:$plugin.Config.Favorite
            $favoriteMenuItem.Add_Click({
                Set-AtomPluginFavorite -Name $this.Tag.Name -Favorite $this.Tag.Favorite
            })
            $contextMenu.Items.Add($favoriteMenuItem) | Out-Null

            $visibilityMenuItem = New-Object Windows.Controls.MenuItem
            $visibilityMenuItem.Header = if ($plugin.Config.Hidden) { 'Unhide' } else { 'Hide' }
            $visibilityMenuItem.Tag = @{
                Name = $plugin.Name
                Hidden = !$plugin.Config.Hidden
            }
            $visibilityMenuItem.Style = $window.FindResource('CustomContextMenuItem')
            $visibilityIcon = if ($plugin.Config.Hidden) { 'VisibilityIcon' } else { 'VisibilityOffIcon' }
            $visibilityMenuItem.Icon = New-VectorIcon -Window $window -Icon $visibilityIcon -ForegroundResource 'accentText' -Size 14 -OpticalSize 20
            $visibilityMenuItem.Add_Click({
                Set-AtomPluginVisibility -Name $this.Tag.Name -Hidden $this.Tag.Hidden
            })
            $contextMenu.Items.Add($visibilityMenuItem) | Out-Null

            $actionMenuItems = @($favoriteMenuItem, $visibilityMenuItem)
            if ($plugin.FullName -and (Test-Path -LiteralPath $plugin.FullName -PathType Leaf)) {
                $utilitySeparator = New-Object Windows.Controls.Separator
                $utilitySeparator.Style = $window.FindResource('CustomContextMenuSeparator')
                $contextMenu.Items.Add($utilitySeparator) | Out-Null

                $fileLocationMenuItem = New-Object Windows.Controls.MenuItem
                $fileLocationMenuItem.Header = 'Open File Location'
                $fileLocationMenuItem.Tag = $plugin
                $fileLocationMenuItem.Style = $window.FindResource('CustomContextMenuItem')
                $fileLocationMenuItem.Icon = New-VectorIcon -Window $window -Icon 'FolderOpenIcon' -ForegroundResource 'accentText' -Size 14 -OpticalSize 20
                $fileLocationMenuItem.Add_Click({ Open-AtomPluginFileLocation -Plugin $this.Tag })
                $contextMenu.Items.Add($fileLocationMenuItem) | Out-Null
                $actionMenuItems += $fileLocationMenuItem

                if ([IO.Path]::GetExtension($plugin.FullName) -in '.ps1', '.bat', '.cmd') {
                    $editMenuItem = New-Object Windows.Controls.MenuItem
                    $editMenuItem.Header = 'Open in Editor'
                    $editMenuItem.Tag = $plugin
                    $editMenuItem.Style = $window.FindResource('CustomContextMenuItem')
                    $editMenuItem.Icon = New-VectorIcon -Window $window -Icon 'OpenInBrowserIcon' -ForegroundResource 'accentText' -Size 14 -OpticalSize 20
                    $editMenuItem.Add_Click({ Open-AtomPluginInEditor -Plugin $this.Tag })
                    $contextMenu.Items.Add($editMenuItem) | Out-Null
                    $actionMenuItems += $editMenuItem
                }
            }

            $propertiesMenuItem = New-Object Windows.Controls.MenuItem
            $propertiesMenuItem.Header = 'Properties'
            $propertiesMenuItem.Tag = $plugin
            $propertiesMenuItem.Style = $window.FindResource('CustomContextMenuItem')
            $propertiesMenuItem.Icon = New-VectorIcon -Window $window -Icon 'HelpIcon' -ForegroundResource 'accentText' -Size 14 -OpticalSize 20
            $propertiesMenuItem.Add_Click({ Show-AtomPluginProperties -Plugin $this.Tag })
            $contextMenu.Items.Add($propertiesMenuItem) | Out-Null
            $actionMenuItems += $propertiesMenuItem

            foreach ($actionMenuItem in $actionMenuItems) {
                $actionMenuItem.Add_MouseEnter({
                    $this.Background = $window.FindResource('accentHighlight')
                }.GetNewClosure())
                $actionMenuItem.Add_MouseLeave({
                    $this.Background = [Windows.Media.Brushes]::Transparent
                })
            }
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
                    $listBoxItem.Control.Add_Checked({ Update-AtomDownloadSelectionState })
                    $listBoxItem.Control.Add_Unchecked({ Update-AtomDownloadSelectionState })
                }

                $listBox.Items.Add($listBoxItem) | Out-Null
                continue
            }

            $listBoxItem.Tag = $plugin

            $listBoxItem.Add_PreviewMouseLeftButtonDown({
                param($sender, $eventArgs)
                $window.Tag.PluginDragSource = $sender
                $window.Tag.PluginDragStart = $eventArgs.GetPosition($window)
            })

            $listBoxItem.Add_PreviewMouseMove({
                param($sender, $eventArgs)

                if ($eventArgs.LeftButton -ne [Windows.Input.MouseButtonState]::Pressed -or $window.Tag.PluginDragSource -ne $sender) { return }

                $currentPoint = $eventArgs.GetPosition($window)
                if (
                    [Math]::Abs($currentPoint.X - $window.Tag.PluginDragStart.X) -lt [Windows.SystemParameters]::MinimumHorizontalDragDistance -and
                    [Math]::Abs($currentPoint.Y - $window.Tag.PluginDragStart.Y) -lt [Windows.SystemParameters]::MinimumVerticalDragDistance
                ) {
                    return
                }

                $data = New-Object Windows.DataObject
                $data.SetData('ATOM.PluginName', $sender.Tag.Name)
                $data.SetData('ATOM.PluginCategory', $sender.Tag.Category)
                $window.Tag.PluginDragSource = $null
                $eventArgs.Handled = $true
                [void][Windows.DragDrop]::DoDragDrop($sender, $data, [Windows.DragDropEffects]::Move)
            })

            # Run plugin with the configured click count
            $clicks =
                if ($atomSettings.PluginClicks.Value -eq 2) { 'Add_MouseDoubleClick' }
                else { 'Add_MouseClick' }

            $listBoxItem.$clicks({
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

            $listBox.Items.Add($listBoxItem) | Out-Null
        }
    }

    if ($script:downloadMode) { Update-AtomDownloadSelectionState }
}
Update-AtomPluginList

# Reuse existing plugin rows when only their visual grouping changes.
function Set-AtomPluginSortLayout {
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Category', 'Alphabetical')]
        [String]$SortMode
    )

    $pluginItems = foreach ($categoryGrid in @($pluginWrapPanel.Children)) {
        $border = @($categoryGrid.Children | Where-Object { $_ -is [Windows.Controls.Border] })[0]
        if (!$border -or $border.Child -isnot [Windows.Controls.ListBox]) { continue }

        $listBox = $border.Child
        $items = @($listBox.Items)
        $listBox.Items.Clear()
        $items
    }

    $pluginWrapPanel.Children.Clear()

    $sortedPluginItems = $pluginItems | Sort-Object { $_.Tag.Name }
    $pluginGroups = $sortedPluginItems | Group-Object {
        if ($SortMode -eq 'Alphabetical') { 'All Plugins' }
        else { $_.Tag.Category }
    } | Sort-Object Name

    foreach ($group in $pluginGroups) {
        $textBlock = New-Object Windows.Controls.TextBlock
        $textBlock.Text = $group.Name
        $textBlock.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'backgroundText')
        $textBlock.FontSize = 14
        $textBlock.Margin = '0,10,0,0'
        $textBlock.VerticalAlignment = [Windows.VerticalAlignment]::Bottom

        $listBox = New-Object Windows.Controls.ListBox
        $listBox.Background = 'Transparent'
        $listBox.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
        $listBox.BorderThickness = 0
        $listBox.Margin = 5
        $listBox.Padding = 0
        $listBox.Width = 200
        $listBox.SetValue([Windows.Controls.ScrollViewer]::HorizontalScrollBarVisibilityProperty, [Windows.Controls.ScrollBarVisibility]::Disabled)

        foreach ($item in $group.Group) { $listBox.Items.Add($item) | Out-Null }

        $border = New-Object Windows.Controls.Border
        $border.Style = $window.FindResource('CustomBorder')
        $border.Margin = '0,5,0,0'
        $border.SetValue([Windows.Controls.Grid]::RowProperty, 1)
        $border.Child = $listBox

        $grid = New-Object Windows.Controls.Grid
        $grid.RowDefinitions.Add((New-Object Windows.Controls.RowDefinition))
        $grid.RowDefinitions.Add((New-Object Windows.Controls.RowDefinition))
        $grid.Margin = '0,0,10,0'

        if ($SortMode -eq 'Category') {
            $grid.AllowDrop = $true
            $grid.DataContext = $group.Name
            $grid.Add_DragOver({
                param($sender, $eventArgs)

                $sourceCategory =
                    if ($eventArgs.Data.GetDataPresent('ATOM.PluginCategory')) { [String]$eventArgs.Data.GetData('ATOM.PluginCategory') }
                    else { $null }

                $eventArgs.Effects =
                    if ($sourceCategory -and $sourceCategory -ne $sender.DataContext) { [Windows.DragDropEffects]::Move }
                    else { [Windows.DragDropEffects]::None }
                $eventArgs.Handled = $true
            })
            $grid.Add_Drop({
                param($sender, $eventArgs)

                if ($eventArgs.Data.GetDataPresent('ATOM.PluginName')) {
                    try {
                        Set-AtomPluginCategory -Name ([String]$eventArgs.Data.GetData('ATOM.PluginName')) -Category ([String]$sender.DataContext)
                    } catch {
                        $statusBarStatus.Text = "Unable to move plugin: $($_.Exception.Message)"
                    }
                }
                $eventArgs.Handled = $true
            })
        }

        $grid.Children.Add($textBlock) | Out-Null
        $grid.Children.Add($border) | Out-Null
        $grid.RowDefinitions[0].Height = [Windows.GridLength]::Auto
        $pluginWrapPanel.Children.Add($grid) | Out-Null
    }
}

# Rebuild download controls on the main UI runspace after a background download finishes.
$downloadRefreshTimer = New-Object System.Windows.Threading.DispatcherTimer
$downloadRefreshTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$downloadRefreshTimer.Add_Tick({
    $this.Stop()
    if (!$window.Tag.DownloadRefreshPending) { return }

    try {
        Update-AtomPluginList
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

function Clear-AtomSearchTextBox {
    $searchTextBox.Clear()
    $searchTextBox.Focus()
    $backspaceButton.Focus()
}

$backspaceButton = $window.FindName('backspaceButton')
$backspaceButton.Tooltip = "Clear search box"
$backspaceButton.Add_Click({
    Clear-AtomSearchTextBox
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
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'sortButton' = 'CategoryIcon' }
        $script:atomSettings.SortPlugins.Value = 'Category'
        Save-AtomSettings
        Set-AtomPluginSortLayout -SortMode Category
    } else {
        $sortButton.ToolTip = "Sort by category"
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'sortButton' = 'TextDescendingIcon' }
        $script:atomSettings.SortPlugins.Value = 'Alphabetical'
        Save-AtomSettings
        Set-AtomPluginSortLayout -SortMode Alphabetical
    }
})

# Toggle hidden plugins in both launch and download modes
$visibilityButton.Add_Click({
    $script:atomSettings.ShowHiddenPlugins.Value = !$script:atomSettings.ShowHiddenPlugins.Value
    Save-AtomSettings
    Update-AtomVisibilityButton
    Update-AtomPluginList
})

# Toggle permanent-download selection mode
$downloadModeButton.Add_Click({
    $script:downloadMode = !$script:downloadMode
    Clear-AtomSearchTextBox

    if ($script:downloadMode) {
        $this.ToolTip = 'Exit download mode'
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'downloadModeButton' = 'CloseIcon' }
    } else {
        $this.ToolTip = 'Download programs for offline use'
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'downloadModeButton' = 'DownloadIcon' }
        Set-AtomQuip
    }

    Update-AtomPluginList
})

# Check installed portable programs, then pass available updates to the download workflow.
$programUpdateButton.Add_Click({
    $script:downloadButtonWasEnabled = $downloadSelectedButton.IsEnabled
    $statusBarStatus.Text = 'Checking for program updates...'
    $statusBarProgress.Value = 0
    $programUpdateButton.Content = 'Checking...'
    $programUpdateButton.IsEnabled = $false
    $downloadSelectedButton.IsEnabled = $false
    $visibilityButton.IsEnabled = $false
    $downloadModeButton.IsEnabled = $false
    $refreshButton.IsEnabled = $false
    $sortButton.IsEnabled = $false

    try {
        Invoke-Runspace -ScriptBlock {
            $checkFailed = $false
            $updateNames = @()

            try {
                . $configPath\Plugins.ps1
                . $atomPath\Functions\DownloadManifest.ps1
                $updateNames = @(Get-ProgramUpdates -Programs $programs | ForEach-Object Name)
            } catch {
                $checkFailed = $true
            }

            Invoke-Ui {
                $programUpdateButton.Content = 'Update'
                $programUpdateButton.IsEnabled = $true
                $visibilityButton.IsEnabled = $true
                $downloadModeButton.IsEnabled = $true
                $refreshButton.IsEnabled = $true
                $sortButton.IsEnabled = $true

                if ($checkFailed) {
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
        $programUpdateButton.IsEnabled = $true
        $visibilityButton.IsEnabled = $true
        $downloadModeButton.IsEnabled = $true
        $refreshButton.IsEnabled = $true
        $sortButton.IsEnabled = $true
        $statusBarStatus.Text = 'Unable to start update check'
        Update-AtomDownloadSelectionState
    }
})

# Permanently download the selected portable programs in a background runspace
$downloadSelectedButton.Add_Click({
    $script:downloadIsUpdate = $null -ne $window.Tag.UpdateQueue
    $script:checkedItems =
        if ($script:downloadIsUpdate) {
            $queue = @($window.Tag.UpdateQueue)
            $window.Tag.UpdateQueue = $null
            $queue
        } else {
            @(Get-AtomDownloadItem | Where-Object { $_.IsEnabled -and $_.Control.IsChecked } | ForEach-Object { $_.Control.Tag })
        }

    if ($script:checkedItems.Count -eq 0) { return }

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
            $failedDownloads = 0
            $downloadProcessFailed = $false

            try {
                # Only lock download-related controls after the runspace is running.
                Invoke-Ui {
                    $downloadSelectedButton.Content = if ($downloadIsUpdate) { 'Updating...' } else { 'Downloading...' }
                    $downloadSelectedButton.IsEnabled = $false
                    $programUpdateButton.IsEnabled = $false
                    $visibilityButton.IsEnabled = $false
                    $downloadModeButton.IsEnabled = $false
                    $refreshButton.IsEnabled = $false
                    $sortButton.IsEnabled = $false
                }

                . $configPath\Plugins.ps1
                . $atomPath\Functions\Start-Program.ps1
                . $atomPath\Functions\DownloadManifest.ps1

                if (!(Test-Path $programsPath)) {
                    New-Item -Path $programsPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
                }

                foreach ($program in $checkedItems) {
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
                    $programUpdateButton.IsEnabled = $true
                    $visibilityButton.IsEnabled = $true
                    $downloadModeButton.IsEnabled = $true
                    $refreshButton.IsEnabled = $true
                    $sortButton.IsEnabled = $true
                    $downloadRefreshTimer.Start()
                }
            }
        }
    } catch {
        # Handle a failure to create/start the runspace itself.
        $downloadSelectedButton.Content = 'Download Selected'
        $downloadSelectedButton.IsEnabled = $true
        $programUpdateButton.IsEnabled = $true
        $visibilityButton.IsEnabled = $true
        $downloadModeButton.IsEnabled = $true
        $refreshButton.IsEnabled = $true
        $sortButton.IsEnabled = $true
        $downloadProgressTimer.Stop()
        $statusBarProgress.Value = 0
        $statusBarStatus.Text = 'Unable to start download process'
    }
})
# Function to select random quip for status bar
function Set-AtomQuip {
    if (!$atomSettings.ShowQuips.Value) {
        $statusBarStatus.Text = ''
        return
    }

    $eligibleQuips = @(switch ($atomSettings.QuipTone.Value) {
        'Gentle'  { $quips | Where-Object { !$_.Tone -or $_.Tone -eq 'Gentle' } }
        'Playful' { $quips | Where-Object { $_.Tone -ne 'Snarky' } }
        'Snarky'  { $quips | Where-Object { $_.Tone -eq 'Snarky' } }
        default   { $quips }
    })

    $commonQuips = @($eligibleQuips | Where-Object { !$_.IsRare })
    $rareQuips = @($eligibleQuips | Where-Object { $_.IsRare })
    $useRarePool = (Get-Random -Minimum 0 -Maximum 8) -eq 0
    if ($atomSettings.InvertQuipRarity.Value) { $useRarePool = !$useRarePool }

    $quipPool = if ($useRarePool) { $rareQuips } else { $commonQuips }
    if (!$quipPool.Count) { $quipPool = if ($useRarePool) { $commonQuips } else { $rareQuips } }

    $statusBarStatus.Text = (Get-Random -InputObject $quipPool).Text
}

Set-AtomQuip

$refreshButton.Add_Click({
    Start-ButtonSpin $this
    Set-AtomQuip
    Update-AtomPluginList -Reload
    $window.SizeToContent = "Height"
})

# Toggle visibility of plugins/settings
$settingsButton.Add_Click({
    if (!$settingsToggled -and $script:downloadMode) {
        $script:downloadMode = $false
        $downloadModeButton.ToolTip = 'Download programs for offline use'
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'downloadModeButton' = 'DownloadIcon' }
        $downloadSelectedButton.Visibility = 'Collapsed'
        $programUpdateButton.Visibility = 'Collapsed'
        Set-AtomQuip
        $script:pluginListDirty = $true
    }

    if ($settingsToggled) {
        $script:settingsToggled = $false
        $searchBar.Visibility = "Visible"
        $scrollViewer.Visibility = "Visible"
        $scrollViewerSettings.Visibility = "Collapsed"
        if ($script:pluginListDirty) {
            Update-AtomPluginList
            $script:pluginListDirty = $false
        }
    } else {
        $script:settingsToggled = $true
        Clear-AtomSearchTextBox
        $searchBar.Visibility = "Collapsed"
        $scrollViewer.Visibility = "Collapsed"
        $scrollViewerSettings.Visibility = "Visible"
    }
})

$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })

# Size the window from the plugin layout instead of maintaining a width for each
# supported column count.
function Set-AtomPluginColumnCount {
    param (
        [Parameter(Mandatory)]
        [Int]$ColumnCount
    )

    $categoryWidths = foreach ($categoryGrid in @($pluginWrapPanel.Children)) {
        $categoryGrid.Measure([Windows.Size]::new([Double]::PositiveInfinity, [Double]::PositiveInfinity))
        $categoryGrid.DesiredSize.Width
    }
    if (!$categoryWidths) { return }

    $columnWidth = ($categoryWidths | Measure-Object -Maximum).Maximum
    $panelChromeWidth =
        $pluginWrapPanel.Margin.Left +
        $pluginWrapPanel.Margin.Right +
        [Windows.SystemParameters]::VerticalScrollBarWidth
    $scale = [Double]$window.Resources['uiScale']

    # MinWidth and MaxWidth describe the unscaled layout in the window parameters.
    # Scale those constraints along with the content so they do not clip it.
    $window.MinWidth = $windowParameters.MinWidth * $scale
    $window.MaxWidth = $windowParameters.MaxWidth * $scale

    $logicalWidth = [Math]::Max(
        $windowParameters.MinWidth,
        ($columnWidth * $ColumnCount) + $panelChromeWidth
    )
    $window.Width = [Math]::Min($window.MaxWidth, $logicalWidth * $scale)
}

# Set plugin columns from startup columns user-setting
Set-AtomPluginColumnCount -ColumnCount $atomSettings.StartupColumns.Value


$closeButton.Add_Click({
    if (Get-ItemProperty -Path $runOncePath -Name "ATOM" -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $runOncePath -Name "ATOM" -Force | Out-Null
    }

    $window.Close()
})

Add-AtomScrollViewerBehavior -Window $window -Name 'scrollViewer'

Set-WindowSize

# ATOM settings

###################
##  Nav panel  ####
###################

$navButton = $window.FindName('navButton')
$navButton.Add_Click({
    $script:settingsToggled = $false
    Clear-AtomSearchTextBox
    $searchBar.Visibility = "Visible"
    $scrollViewer.Visibility = "Visible"
    $scrollViewerSettings.Visibility = "Collapsed"

    if ($script:pluginListDirty) {
        Update-AtomPluginList
        $script:pluginListDirty = $false
    }
})

####################
##  Update panel  ##
####################

$installedVersionText = $window.FindName('installedVersionText')
$updateChannelSelector = $window.FindName('updateChannelSelector')
$updateActionButton = $window.FindName('updateActionButton')
$updateActionText = $window.FindName('updateActionText')
$updateActionImage = $window.FindName('updateActionImage')
$healthCheckButton = $window.FindName('healthCheckButton')
$healthCheckText = $window.FindName('healthCheckText')
$updateStatePath = Join-Path $configPath 'UpdateState.json'

$updateText = $window.FindName('updateText')
$lastCheckedPath = Join-Path $configPath "time.txt"
if (Test-Path $lastCheckedPath) { $lastCheckedContent = Get-Content -Path $lastCheckedPath }
$updateText.Text = if ($lastCheckedContent) { "Last checked $lastCheckedContent" } else { 'Not checked' }

$updateActionStates = @{
    Check      = @{ Text = 'Check for Updates'; Icon = 'DownloadIcon'; Enabled = $true; ToolTip = 'Check the selected channel for ATOM updates' }
    Checking   = @{ Text = 'Checking...'; Icon = 'RefreshIcon'; Enabled = $false; ToolTip = 'Checking the selected channel for ATOM updates' }
    CheckAgain = @{ Text = 'Check Again'; Icon = 'RefreshIcon'; Enabled = $true; ToolTip = 'Check the selected channel again' }
    Update     = @{ Text = 'Update ATOM'; Icon = 'UpdateIcon'; Enabled = $true; ToolTip = 'Install the available ATOM update' }
    Synchronize = @{ Text = 'Synchronize ATOM'; Icon = 'UpdateIcon'; Enabled = $true; ToolTip = 'Synchronize this source copy with the selected ATOM channel' }
    Repair     = @{ Text = 'Repair ATOM'; Icon = 'ResetWrenchIcon'; Enabled = $true; ToolTip = 'Replace missing or modified ATOM-owned files' }
    Retry      = @{ Text = 'Retry Update Check'; Icon = 'RefreshIcon'; Enabled = $true; ToolTip = 'Retry checking the selected channel for updates' }
}
$setUpdateAction = {
    param ([Parameter(Mandatory)][String]$State)

    $actionState = $updateActionStates[$State]
    if (!$actionState) { throw "Unknown update action state '$State'." }

    $updateActionButton.Tag = $State
    $updateActionButton.IsEnabled = $actionState.Enabled
    $updateActionButton.Opacity = if ($actionState.Enabled) { 1.0 } else { 0.44 }
    $updateActionButton.ToolTip = $actionState.ToolTip
    $updateActionText.Text = $actionState.Text
    $updateActionImage.Content = $window.FindResource($actionState.Icon)
}
& $setUpdateAction 'Check'

function Update-AtomUpdateContext {
    $requiresBootstrap = !(Test-Path -LiteralPath $updateStatePath -PathType Leaf)
    if (!$requiresBootstrap) {
        try { $requiresBootstrap = (Get-AtomUpdateState -Path $updateStatePath).SchemaVersion -ne 2 }
        catch { $requiresBootstrap = $true }
    }

    if ($requiresBootstrap) {
        $sourceRootName = Split-Path (Split-Path $atomPath) -Leaf
        $detectedChannel = if ($sourceRootName -eq 'ATOM-dev') { 'dev' } else { 'main' }
        if ($script:atomSettings.UpdateChannel.Value -ne $detectedChannel) {
            $script:atomSettings.UpdateChannel.Value = $detectedChannel
            Write-AtomSettingsFile -Path "$configPath\SettingsUser.ps1" -Settings $script:atomSettings
        }

        $bootstrapExclusions = @(
            '.git/*'
            '.github/*'
            '.gitignore'
            'LICENSE'
            'README.md'
            'Programs/*'
            'ATOM/Backups/*'
            'ATOM/Logs/*'
            'ATOM/Config/files.txt'
            'ATOM/Config/hash.txt'
            'ATOM/Config/PluginsUser.ps1'
            'ATOM/Config/PluginsParamsUser.ps1'
            'ATOM/Config/ProgramsParamsUser.ps1'
            'ATOM/Config/SavedTheme.ps1'
            'ATOM/Config/SettingsUser.ps1'
            'ATOM/Config/time.txt'
            'ATOM/Config/UpdateState.json'
        )
        $bootstrapFiles = New-AtomFileManifest -RootPath (Split-Path $atomPath) -Exclude $bootstrapExclusions
        Write-AtomUpdateState -Path $updateStatePath -Channel $detectedChannel -Files $bootstrapFiles
    }

    $script:atomUpdateContext = Get-AtomUpdateContext -StatePath $updateStatePath -UpdateChannel $script:atomSettings.UpdateChannel.Value
    $script:localCommitHash = $script:atomUpdateContext.LocalHash
    $script:updateBranch = $script:atomUpdateContext.Branch
    $installedVersionText.Text = if ($script:localCommitHash) {
        "$version ($($script:localCommitHash.Substring(0, 7)))"
    } else {
        "$version (Unmanaged)"
    }
}

Update-AtomUpdateContext
$updateChannelSelector.SelectedValue = $script:atomSettings.UpdateChannel.Value

function Test-AtomUpdate {
    & $setUpdateAction 'Checking'
    $updateText.Text = 'Checking for updates...'

    Invoke-Runspace -ScriptBlock {
        try {
            . (Join-Path $functionsPath 'Get-AtomChannelState.ps1')
            $latestCommitHash = (Get-AtomChannelState -Channel $updateBranch).CommitSha
            $requiresSynchronization = !$localCommitHash
            $updateAvailable = $localCommitHash -ne $latestCommitHash
            $checkedText = Get-Date -Format 'MM/dd/yy h:mmtt'
            [IO.File]::WriteAllText($lastCheckedPath, $checkedText)

            Invoke-Ui {
                if ($requiresSynchronization) {
                    & $setUpdateAction 'Synchronize'
                    $updateText.Text = "Synchronization required for '$updateBranch'"
                } elseif ($updateAvailable) {
                    & $setUpdateAction 'Update'
                    $updateText.Text = "Update available on '$updateBranch'"
                } else {
                    & $setUpdateAction 'CheckAgain'
                    $updateText.Text = "Up to date ($checkedText)"
                }
            }
        } catch {
            $errorMessage = $_.Exception.Message
            Invoke-Ui {
                $updateText.Text = "Unable to check for updates: $errorMessage"
                & $setUpdateAction 'Retry'
            }
        }
    }
}

function Start-AtomUpdate {
    if (!$script:atomUpdateContext.LocalHash) {
        $channelName = if ($script:atomUpdateContext.Branch -eq 'dev') { 'Development' } else { 'Stable' }
        $confirmationText = @"
This source copy is not linked to an ATOM release or development snapshot.

Synchronizing will replace ATOM-owned files with the latest $channelName channel files. User-added files will be preserved, and replaced files will be backed up.

Continue?
"@
        $confirmation = [Windows.MessageBox]::Show(
            $window,
            $confirmationText,
            'Synchronize ATOM',
            [Windows.MessageBoxButton]::YesNo,
            [Windows.MessageBoxImage]::Warning
        )
        if ($confirmation -ne [Windows.MessageBoxResult]::Yes) { return }
    }

    $updateAtomPath = "$dependenciesPath\Update-ATOM.ps1"
    $updateArguments = "-NoProfile -ExecutionPolicy Bypass -File `"$updateAtomPath`" -Branch $($script:atomUpdateContext.Branch)"
    Start-Process powershell -ArgumentList $updateArguments
}

$updateActionButton.Add_Click({
    switch ($this.Tag) {
        { $_ -in 'Check', 'CheckAgain', 'Retry' } { Test-AtomUpdate }
        { $_ -in 'Update', 'Synchronize', 'Repair' } { Start-AtomUpdate }
    }
})

function Test-AtomInstallationHealth {
    $healthCheckButton.IsEnabled = $false
    $healthCheckText.Visibility = 'Visible'
    $healthCheckText.Text = 'Verifying ATOM files...'
    $installedCommit = $script:atomUpdateContext.LocalHash
    $installedFiles = @($script:atomUpdateContext.UpdateState.Files)
    $healthBranch = $script:atomUpdateContext.Branch
    $installedRoot = Split-Path $atomPath

    $healthCheckInputs = @{
        installedCommit = $installedCommit
        installedFiles = $installedFiles
        healthBranch  = $healthBranch
        installedRoot = $installedRoot
    }
    Invoke-Runspace -InputVariables $healthCheckInputs -ScriptBlock {
        try {
            . (Join-Path $functionsPath 'Get-AtomChannelState.ps1')
            . (Join-Path $functionsPath 'Get-AtomFileHash.ps1')
            . (Join-Path $functionsPath 'Test-AtomFileManifest.ps1')

            $integrity = Test-AtomFileManifest -RootPath $installedRoot -Files $installedFiles
            $referenceCommit = if ($installedCommit) { $installedCommit } else { 'Unmanaged source copy' }
            try {
                $latestCommit = (Get-AtomChannelState -Channel $healthBranch).CommitSha
                $updateAvailable = $installedCommit -ne $latestCommit
            } catch {
                $channelCheckError = $_.Exception.Message
                $updateAvailable = $false
            }

            $summary = if ($integrity.IsHealthy) {
                "All $($integrity.CheckedCount) ATOM files verified successfully."
            } else {
                "$($integrity.MissingFiles.Count) missing, $($integrity.ModifiedFiles.Count) modified, and $($integrity.UnverifiableFiles.Count) unverifiable file(s)."
            }

            $details = [Collections.Generic.List[String]]::new()
            $details.Add("ATOM HEALTH CHECK")
            $details.Add("Installed commit: $(if ($installedCommit) { $installedCommit } else { 'Unmanaged source copy' })")
            $details.Add("Reference commit: $referenceCommit")
            $details.Add("Selected channel: $healthBranch")
            $details.Add("Files checked: $($integrity.CheckedCount)")
            $details.Add("Files verified: $($integrity.VerifiedCount)")
            $details.Add('')
            $details.Add($summary)

            foreach ($fileGroup in @(
                @{ Label = 'MISSING'; Files = $integrity.MissingFiles }
                @{ Label = 'MODIFIED'; Files = $integrity.ModifiedFiles }
                @{ Label = 'UNVERIFIABLE'; Files = $integrity.UnverifiableFiles }
            )) {
                if (!$fileGroup.Files.Count) { continue }
                $details.Add('')
                $details.Add($fileGroup.Label)
                foreach ($file in @($fileGroup.Files | Select-Object -First 15)) { $details.Add("- $file") }
                if ($fileGroup.Files.Count -gt 15) {
                    $details.Add("...and $($fileGroup.Files.Count - 15) more")
                }
            }

            if ($updateAvailable) {
                $details.Add('')
                $details.Add("A newer commit is available on '$healthBranch'.")
            } elseif ($channelCheckError) {
                $details.Add('')
                $details.Add("Update availability could not be checked: $channelCheckError")
            }

            $detailText = $details -join [Environment]::NewLine
            Invoke-Ui {
                $healthCheckText.Text = $summary
                if (!$installedCommit) {
                    & $setUpdateAction 'Synchronize'
                    $updateText.Text = "Synchronization required for '$healthBranch'"
                } elseif (!$integrity.IsHealthy) {
                    & $setUpdateAction 'Repair'
                    $updateText.Text = 'Repair available'
                } elseif ($updateAvailable) {
                    & $setUpdateAction 'Update'
                    $updateText.Text = "Update available on '$healthBranch'"
                } elseif ($channelCheckError) {
                    & $setUpdateAction 'Retry'
                    $updateText.Text = 'Files verified; update check unavailable'
                } else {
                    & $setUpdateAction 'CheckAgain'
                    $updateText.Text = 'Files verified; ATOM is up to date'
                }
                $healthCheckButton.IsEnabled = $true
                [void][Windows.MessageBox]::Show($window, $detailText, 'ATOM Health Check', 'OK', $(if ($integrity.IsHealthy) { 'Information' } else { 'Warning' }))
            }
        } catch {
            $errorMessage = $_.Exception.Message
            Invoke-Ui {
                $healthCheckText.Text = "Unable to verify ATOM files: $errorMessage"
                $healthCheckButton.IsEnabled = $true
            }
        }
    }
}
$healthCheckButton.Add_Click({ Test-AtomInstallationHealth })

$updateChannelSelector.Add_SelectionChanged({
    if (!$this.SelectedValue) { return }

    $script:atomSettings.UpdateChannel.Value = [String]$this.SelectedValue
    Update-AtomUpdateContext
    & $setUpdateAction 'Check'
    $updateText.Text = "Not checked for '$($script:updateBranch)'"
    $healthCheckText.Text = ''
    $healthCheckText.Visibility = 'Collapsed'

    if (!$script:restoringDefaults) { Save-AtomSettings }
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

$githubButton = $window.FindName('githubButton')
$githubButton.Add_Click({ Start-Process $atomUrl })

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
$uiScalingSlider = $window.FindName('uiScalingSlider')
$uiScalingValueText = $window.FindName('uiScalingValueText')

function Set-AtomUiScaling {
    param ([Double]$Scale)

    $scale = [Math]::Round($Scale * 8) / 8
    $window.Resources['uiScale'] = $scale
    $window.Resources['uiScaleTransform'] = [Windows.Media.ScaleTransform]::new($scale, $scale)

    foreach ($categoryGrid in @($pluginWrapPanel.Children)) {
        $listBox = @($categoryGrid.Children | Where-Object { $_ -is [Windows.Controls.Border] })[0].Child
        foreach ($pluginItem in @($listBox.Items)) {
            if ($pluginItem.ContextMenu) {
                $pluginItem.ContextMenu.LayoutTransform = [Windows.Media.ScaleTransform]::new($scale, $scale)
            }
        }
    }

    Set-AtomPluginColumnCount -ColumnCount $script:atomSettings.StartupColumns.Value

    $uiScalingValueText.Text = '{0:0.0##}x' -f $scale
}

$uiScalingSlider.Value = [Double]$atomSettings.UIScaling.Value
Set-AtomUiScaling -Scale $uiScalingSlider.Value
$uiScalingSlider.Add_PreviewMouseLeftButtonDown({
    $script:uiScalingDragActive = $true
})
$completeUiScalingDrag = {
    if (!$script:uiScalingDragActive) { return }

    $script:uiScalingDragActive = $false
    Set-AtomUiScaling -Scale $script:atomSettings.UIScaling.Value
    Save-AtomSettings
}
$uiScalingSlider.Add_PreviewMouseLeftButtonUp($completeUiScalingDrag)
$uiScalingSlider.Add_LostMouseCapture($completeUiScalingDrag)
$uiScalingSlider.Add_ValueChanged({
    $script:atomSettings.UIScaling.Value = [Math]::Round($this.Value * 8) / 8
    if ($script:uiScalingDragActive) {
        $uiScalingValueText.Text = '{0:0.0##}x' -f $script:atomSettings.UIScaling.Value
        return
    }

    Set-AtomUiScaling -Scale $script:atomSettings.UIScaling.Value
    if (!$script:restoringDefaults) { Save-AtomSettings }
})

$themeSwatches = @{
    primaryBrush = $window.FindName('themePrimarySwatch')
    backgroundBrush = $window.FindName('themeBackgroundSwatch')
    surfaceBrush = $window.FindName('themeSurfaceSwatch')
    accentBrush = $window.FindName('themeAccentSwatch')
}

function Update-AtomThemeSelector {
    $themeName = [String]$script:atomSettings.Theme.Value
    $palette = $themes[$themeName]
    if (!$palette) { return }

    $themeSelectorText.Text = $themeName
    foreach ($entry in $themeSwatches.GetEnumerator()) {
        $color = [System.Windows.Media.ColorConverter]::ConvertFromString($palette[$entry.Key])
        $entry.Value.Background = [System.Windows.Media.SolidColorBrush]::new($color)
    }
}

function Set-AtomThemeSelectorExpanded {
    param ([Boolean]$Expanded)

    $themePanel.Visibility = if ($Expanded) { 'Visible' } else { 'Collapsed' }
    Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'themeSelectorIndicator' = $(if ($Expanded) { 'ArrowDropUpIcon' } else { 'ArrowDropDownIcon' }) }
    $themeSelectorButton.ToolTip = if ($Expanded) { 'Hide theme options' } else { 'Show theme options' }
}

$themeSelectorButton.Add_Click({
    Set-AtomThemeSelectorExpanded ($themePanel.Visibility -ne [System.Windows.Visibility]::Visible)
})

Update-AtomThemeSelector
Set-AtomThemeSelectorExpanded $false
foreach ($theme in $themes.GetEnumerator() | Sort-Object Key) {
    $button = New-Object System.Windows.Controls.Button
    $button.Width = 75
    $button.Margin = 2.5
    $button.Tag = $theme.Name, $theme.Value
    $button.Background = "Transparent"
    $button.Style = $window.Resources["RoundedButton"]
    $button.Add_Click({
        # Save theme
        $script:atomSettings.Theme.Value = $this.Tag[0]
        Save-AtomSettings

        # Update variables
        foreach ($key in $this.Tag[1].Keys) {
            New-Variable -Name $key -Value $this.Tag[1].$key -Scope Global -Force
        }
        Get-AtomThemeShadowResources -Theme $this.Tag[1] -Defaults $themeShadowDefaults | ForEach-Object {
            $_.GetEnumerator() | ForEach-Object {
                New-Variable -Name $_.Key -Value $_.Value -Scope Global -Force
            }
        }

        # Update resources dynamically based on their type
        foreach ($resName in $window.Resources.Keys) {
            # Check if the resource key matches a global variable
            if (Get-Variable -Name $resName -Scope Global -ErrorAction SilentlyContinue) {
                $globalValue = (Get-Variable -Name $resName -Scope Global).Value

                # Determine the type of the resource and update accordingly
                $resource = $window.Resources[$resName]
                if ($resource -is [System.Windows.Media.SolidColorBrush]) {
                    $window.Resources[$resName] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString($globalValue))
                } elseif ($resource -is [System.Windows.Media.Color]) {
                    $window.Resources[$resName] = [System.Windows.Media.ColorConverter]::ConvertFromString($globalValue)
                } elseif ($resource -is [Double]) {
                    $window.Resources[$resName] = [Double]$globalValue
                }
            }
        }

        $window.Resources["gradientStrength"] = $gradientStrength
        Set-AtomThemeGradient -Window $window -Theme $this.Tag[1] -Defaults $themeGradientDefaults

        Update-AtomThemeSelector
    })

    $textBlock = New-Object System.Windows.Controls.TextBlock
    $textBlock.Margin = "2.5,2.5,2.5,0"
    $textBlock.FontSize = 11
    $textBlock.Text = $theme.Name
    $textBlock.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "surfaceText")
    $textBlock.Background = "Transparent"
    $textBlock.TextAlignment = "Center"
    $textBlock.TextWrapping = "Wrap"

    $border1 = New-Object System.Windows.Controls.Border
    $border1.Width = 12; $border1.Height = 12
    $border1.Margin = 1
    $border1.CornerRadius = "5,0,0,5"
    $border1.Background = $theme.Value.primaryBrush

    $border2 = New-Object System.Windows.Controls.Border
    $border2.Width = 12; $border2.Height = 12
    $border2.Margin = 1
    $border2.Background = $theme.Value.backgroundBrush

    $border3 = New-Object System.Windows.Controls.Border
    $border3.Width = 12; $border3.Height = 12
    $border3.Margin = 1
    $border3.Background = $theme.Value.surfaceBrush

    $border4 = New-Object System.Windows.Controls.Border
    $border4.Width = 12; $border4.Height = 12
    $border4.Margin = 1
    $border4.CornerRadius = "0,5,5,0"
    $border4.Background = $theme.Value.accentBrush

    $borderStackPanel = New-Object System.Windows.Controls.StackPanel
    $borderStackPanel.Orientation = "Horizontal"
    $borderStackPanel.HorizontalAlignment = "Center"
    $borderStackPanel.Margin = 2.5
    $borderStackPanel.AddChild($border1)
    $borderStackPanel.AddChild($border2)
    $borderStackPanel.AddChild($border3)
    $borderStackPanel.AddChild($border4)

    $stackPanel = New-Object System.Windows.Controls.StackPanel
    $stackPanel.AddChild($textBlock)
    $stackPanel.AddChild($borderStackPanel)
    $button.Content = $stackPanel

    $themePanel = $window.FindName('themePanel')
    $themePanel.AddChild($button)
}

####################
##  Toggle panel  ##
####################

function Set-AtomConsoleVisibility {
    param ([Boolean]$Visible)

    $windowStyle = if ($Visible) { 'Normal' } else { 'Hidden' }
    $processIds = @($PID) + @(Get-CimInstance Win32_Process -Filter "ParentProcessId = $PID" |
        Where-Object Name -in 'powershell.exe', 'pwsh.exe', 'cmd.exe' |
        Select-Object -ExpandProperty ProcessId)

    $processIds | Set-WindowStyle -WindowStyle $windowStyle
}

function Save-AtomSettings {
    Write-AtomSettingsFile -Path "$configPath\SettingsUser.ps1" -Settings $script:atomSettings
}

$settingsPanels = [ordered]@{
    General = $window.FindName('generalSettingsPanel')
    Plugins = $window.FindName('pluginSettingsPanel')
    Quips   = $window.FindName('quipSettingsPanel')
}
$settingsRowMinHeight = 28

$atomSettings.GetEnumerator() | Where-Object { $_.Value.ControlType } | ForEach-Object {
    $setting = $_.Value
    $settingName = $_.Name

    switch ($setting.ControlType) {
        'ToggleButton' {
            $listBoxItem = New-ListBoxControlItem -ControlType ToggleButton -ControlAlignment Right -Text $setting.Name -Tag $settingName -ToolTip $setting.ToolTip

            $listBoxItem.Text.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty,'surfaceText')
            $listBoxItem.Control.IsChecked = $setting.Value

            $listBoxItem.Control.Add_Checked({
                $script:atomSettings.($this.Tag).Value = $true

                if ($this.Tag -eq 'EnableDebugMode') {
                    Set-AtomConsoleVisibility -Visible $true
                }

                if ($this.Tag -in 'ShowQuips', 'InvertQuipRarity') { Set-AtomQuip }

                if ($this.Tag -in 'ShowToolTips', 'SearchPluginTags', 'ShowHiddenPlugins') { $script:pluginListDirty = $true }
                if (!$script:restoringDefaults) { Save-AtomSettings }
            })

            $listBoxItem.Control.Add_UnChecked({
                $script:atomSettings.($this.Tag).Value = $false

                if ($this.Tag -eq 'EnableDebugMode') {
                    Set-AtomConsoleVisibility -Visible $false
                }

                if ($this.Tag -in 'ShowQuips', 'InvertQuipRarity') { Set-AtomQuip }

                if ($this.Tag -in 'ShowToolTips', 'SearchPluginTags', 'ShowHiddenPlugins') { $script:pluginListDirty = $true }
                if (!$script:restoringDefaults) { Save-AtomSettings }
            })
        }

        'ComboBox' {
            $controlOptions = $setting.Options
            if ($settingName -eq 'PluginEditor') { $controlOptions = Get-AtomPluginEditorOptions }

            $comboBoxStyle = $window.FindResource('CustomComboBox')
            $listBoxItem = New-ListBoxControlItem -ControlType ComboBox -ControlAlignment Right -ControlOptions $controlOptions -SelectedValue $setting.Value -ControlStyle $comboBoxStyle -ControlWidth 110 -Text $setting.Name -Tag $settingName -ToolTip $setting.ToolTip
            $listBoxItem.Text.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')

            $listBoxItem.Control.Add_SelectionChanged({
                if ($null -eq $this.SelectedValue) { return }

                if ($this.Tag -eq 'PluginEditor' -and $this.SelectedValue -eq '__choose__') {
                    $previousEditor = $script:atomSettings.PluginEditor.Value
                    $editorDialog = New-Object Microsoft.Win32.OpenFileDialog
                    $editorDialog.Title = 'Choose a plugin editor'
                    $editorDialog.Filter = 'Applications (*.exe)|*.exe'
                    $editorDialog.CheckFileExists = $true
                    $editorDialog.Multiselect = $false

                    if ($editorDialog.ShowDialog($window)) {
                        $customItems = @($this.Items | Where-Object {
                            $_.Content -notin 'Notepad', 'Visual Studio Code', 'Notepad++', 'Choose application...'
                        })
                        foreach ($customItem in $customItems) { $this.Items.Remove($customItem) }

                        $existingEditor = @($this.Items | Where-Object Tag -eq $editorDialog.FileName)[0]
                        if (!$existingEditor) {
                            $editorItem = New-Object System.Windows.Controls.ComboBoxItem
                            $editorItem.Content = [IO.Path]::GetFileNameWithoutExtension($editorDialog.FileName)
                            $editorItem.Tag = $editorDialog.FileName
                            $this.Items.Insert($this.Items.Count - 1, $editorItem)
                        }
                        $this.SelectedValue = $editorDialog.FileName
                    } else {
                        $this.SelectedValue = $previousEditor
                    }
                    return
                }

                $script:atomSettings.($this.Tag).Value = $this.SelectedValue
                if ($this.Tag -eq 'PluginClicks') { $script:pluginListDirty = $true }
                if ($this.Tag -eq 'StartupColumns') { Set-AtomPluginColumnCount -ColumnCount $this.SelectedValue }
                if ($this.Tag -eq 'QuipTone') { Set-AtomQuip }
                if (!$script:restoringDefaults) { Save-AtomSettings }
            })
        }
    }

    $listBoxItem.MinHeight = $settingsRowMinHeight
    $listBoxItem.VerticalContentAlignment = 'Center'
    $settingsPanel = $settingsPanels[$setting.Category]
    if (!$settingsPanel) { throw "Unknown settings category '$($setting.Category)' for '$settingName'." }
    $settingsPanel.Children.Add($listBoxItem) | Out-Null
}

# Default settings button
$defaultSwitchButton = $window.FindName('defaultSwitchButton')
$defaultSwitchButton.Add_Click({
    $confirmationText = @(
        'Restore all eligible settings to their defaults?'
        ''
        'Your update channel will be preserved.'
    ) -join [Environment]::NewLine
    $confirmation = [Windows.MessageBox]::Show(
        $window,
        $confirmationText,
        'Restore Default Settings',
        [Windows.MessageBoxButton]::YesNo,
        [Windows.MessageBoxImage]::Question
    )
    if ($confirmation -ne [Windows.MessageBoxResult]::Yes) { return }

    $defaultSettings = & {
        . "$configPath\Settings.ps1"
        $atomSettings
    }

    foreach ($defaultSettingName in $defaultSettings.Keys) {
        if ($defaultSettings[$defaultSettingName].RestoreDefault -eq $false) { continue }
        $script:atomSettings[$defaultSettingName].Value = $defaultSettings[$defaultSettingName].Value
    }

    # Update controls without saving once per changed control.
    $script:restoringDefaults = $true
    try {
        $uiScalingSlider.Value = [Double]$script:atomSettings.UIScaling.Value
        $settingsPanels.Values.Children | Where-Object { $_ -is [System.Windows.Controls.ListBoxItem] } | ForEach-Object {
            $listBoxItem = $_

            if ($listBoxItem.Control -is [System.Windows.Controls.Primitives.ToggleButton]) {
                $settingName = $listBoxItem.Control.Tag
                $listBoxItem.Control.IsChecked = [bool]$script:atomSettings[$settingName].Value
            } elseif ($listBoxItem.Control -is [System.Windows.Controls.ComboBox]) {
                $settingName = $listBoxItem.Control.Tag
                $listBoxItem.Control.SelectedValue = $script:atomSettings[$settingName].Value
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

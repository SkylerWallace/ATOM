$version = "v2.12"
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# Import module(s)
Import-Module "$psScriptRoot\Functions\AtomModule.psm1" -Function Invoke-Runspace, Set-WindowStyle -Variable *
Import-Module "$psScriptRoot\Functions\AtomWpfModule.psm1"

$settingsXaml = @"
<StackPanel MaxWidth="300" Margin="5">
    <!-- NAV PANEL -->
    <StackPanel Orientation="Horizontal">
        <Button Name="navButton" Width="25" Height="25" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
        <TextBlock Text="Settings" FontSize="20" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
    </StackPanel>

    <!-- UPDATE PANEL -->
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5" Padding="5">
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
                        <Image Name="checkUpdatesImage" Width="16" Height="16" Margin="5"/>
                        <TextBlock Text="Check for Updates" FontSize="11" VerticalAlignment="Center" Margin="0,5,5,5"/>
                    </StackPanel>
                </Button>
                <Button Name="updateButton" Width="130" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" HorizontalAlignment="Center" Style="{StaticResource RoundedButton}" IsEnabled="False" Opacity="0.2" Margin="5" ToolTip="Updating ATOM will not remove custom plugins">
                    <StackPanel Orientation="Horizontal">
                        <Image Name="updateImage" Width="16" Height="16" Margin="5"/>
                        <TextBlock Text="Update ATOM" FontSize="11" VerticalAlignment="Center" Margin="0,5,5,5"/>
                    </StackPanel>
                </Button>
            </WrapPanel>
        </StackPanel>
    </Border>

    <!-- PATH PANEL -->
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5" Padding="5">
        <StackPanel>
            <Grid>
                <TextBlock Text="ATOM Path" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                <Button Name="pathButton" Height="25" Width="25" HorizontalAlignment="Right" VerticalAlignment="Center" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Open in Explorer"/>
            </Grid>
            <TextBox Name="pathTextBox" Text="$atomPath" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" TextAlignment="Center" VerticalAlignment="Center" IsReadOnly="True" Margin="5"/>
        </StackPanel>
    </Border>

    <!-- GITHUB PANEL -->
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5" Padding="5">
        <StackPanel>
            <Grid>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Left">
                    <Image Name="githubImage" Width="20" Height="20" VerticalAlignment="Center" Margin="5"/>
                    <TextBlock Text="GitHub" FontSize="12" Foreground="{DynamicResource surfaceText}" VerticalAlignment="Center" Margin="5"/>
                </StackPanel>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                    <Button Name="githubLinkButton" Height="25" Width="25" VerticalAlignment="Center" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Copy URL to clipboard"/>
                    <Button Name="githubLaunchButton" Height="25" Width="25" VerticalAlignment="Center" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Open URL in web browser"/>
                </StackPanel>
            </Grid>
            <TextBox Name="githubTextBox" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" TextAlignment="Center" VerticalAlignment="Center" Margin="5" IsReadOnly="True"/>
        </StackPanel>
    </Border>

    <!-- THEME PANEL -->
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5" Padding="5">
        <WrapPanel Name="themePanel" Orientation="Horizontal" HorizontalAlignment="Center"/>
    </Border>

    <!-- TOGGLE PANEL -->
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5" Padding="5">
        <StackPanel>

            <!-- TOGGLE BUTTONS -->
            <StackPanel Name="togglePanel"/>

            <!-- DEFAULT BUTTON -->
            <Button Name="defaultSwitchButton" Width="130" Background="{DynamicResource accentBrush}" HorizontalAlignment="Right" Style="{StaticResource RoundedButton}" Margin="5">
                <StackPanel Orientation="Horizontal">
                    <Image Name="restoreImage" Width="16" Height="16" Margin="5"/>
                    <TextBlock Text="Restore Defaults" FontSize="11" Foreground="{DynamicResource accentText}" VerticalAlignment="Center"/>
                </StackPanel>
            </Button>
        </StackPanel>
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
                <RowDefinition Height="70"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <Grid Grid.Row="0">
                <Border Background="{DynamicResource primaryBrush}" CornerRadius="{DynamicResource cornerStrength1}"/>
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <Grid Grid.Column="0" Margin="10,10,5,10">
                        <Image Name="logo" Width="130" Height="60" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5,5,0,0"/>
                    </Grid>

                    <Grid Grid.Column="1" Margin="5,10,10,10">
                        <Button Name="peButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,80,0" Opacity="0.44" ToolTip="Reboot to PE" IsEnabled="False"/>
                        <Button Name="refreshButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,40,0" ToolTip="Reload Plugins"/>
                        <Button Name="settingsButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,0,0" ToolTip="Settings"/>
                        <Button Name="minimizeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,0,80,0" ToolTip="Minimize"/>
                        <Button Name="columnButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,0,40,0"/>
                        <Button Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,0,0,0" ToolTip="Close"/>
                    </Grid>
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
                            </Grid.ColumnDefinitions>

                            <Button Name="backspaceButton" Grid.Column="0" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                            <Image Name="searchImage" Grid.Column="1" Opacity="0.38" Width="16" Height="16" Margin="0"/>
                            <TextBlock Name="searchTextBlock" Grid.Column="2" Text="Search" Foreground="{DynamicResource surfaceText}" TextAlignment="Left" VerticalAlignment="Center" Opacity="0.69" Margin="5"/>
                            <TextBox Name="searchTextBox" Grid.Column="2" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" TextAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                            <Button Name="visibilityButton" Grid.Column="3" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                            <Button Name="sortButton" Grid.Column="4" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
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
$peButton               = $window.FindName('peButton')
$refreshButton          = $window.FindName('refreshButton')
$settingsButton         = $window.FindName('settingsButton')
$minimizeButton         = $window.FindName('minimizeButton')
$columnButton           = $window.FindName('columnButton')
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

# Configure PE button based on online OS or PE environment
$inPe = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
$pePath = Join-Path $drivePath "sources\boot.wim"
$peOnDrive = Test-Path $pePath
$peDependencies = Join-Path $dependenciesPath "PE"

if ($inPe) {
    # Automatically launch MountOS if in PE
    $mountOs = Get-ChildItem $atomPath -Filter "MountOS.ps1" -Recurse | Select-Object -Expand FullName
    Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$mountOs`"" -Wait
} elseif ($peOnDrive) {
    $peButton.isEnabled = $true
    $peButton.Opacity = 1.0
}

$peButton.Add_Click({
    $boot2PE = Join-Path $peDependencies "Boot2PE.bat"
    Start-Process cmd.exe -WindowStyle Hidden -ArgumentList "/c `"$boot2PE`""
})

# Set icon sources
$primaryResources = @{
    "logo" = "ATOM Logo"
    "peButton" = "Reboot2PE"
    "settingsButton" = "Settings"
    "refreshButton" = "Refresh"
    "minimizeButton" = "Minimize"
    "closeButton" = "Close"
}

$backgroundResources = @{
    "navButton" = "Back"
}

$surfaceResources = @{
    "backspaceButton" = "Backspace"
    "searchImage" = "Browse"
    "checkedImage" = "Checkbox - Checked"
    "uncheckedImage" = "Checkbox - Unchecked"
    "visibilityButton" = $(if ($atomSettings.ShowHiddenPlugins.Value) { "Visibility" } else { "Visibility Off" })
    "downloadModeButton" = "Download"
    "sortButton" = $(if ($atomSettings.SortPlugins.Value -eq 'Alphabetical') { "Text Descending" } else { "Category" })
    "pathButton" = "Folder"
    "githubImage" = "GitHub"
    "githubLinkButton" = "Link"
    "githubLaunchButton" = "Launch"
}

$accentResources = @{
    "checkUpdatesImage" = "Download"
    "updateImage" = "Update"
    "restoreImage" = "Restore"
}

Set-ResourcePath -ColorRole "Primary" -ResourceMappings $primaryResources
Set-ResourcePath -ColorRole "Background" -ResourceMappings $backgroundResources
Set-ResourcePath -ColorRole "Surface" -ResourceMappings $surfaceResources
Set-ResourcePath -ColorRole "Accent" -ResourceMappings $accentResources

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
        $border = $categoryGrid.Children | Where-Object { $_ -is [System.Windows.Controls.Border] } | Select-Object -First 1
        if (!$border) { continue }

        foreach ($item in $border.Child.Items) {
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
function Update-VisibilityButton {
    if ($atomSettings.ShowHiddenPlugins.Value) {
        $visibilityButton.ToolTip = 'Hide hidden plugins'
        Set-ResourcePath -ColorRole Surface -ResourceMappings @{ 'visibilityButton' = 'Visibility' }
    } else {
        $visibilityButton.ToolTip = 'Show hidden plugins'
        Set-ResourcePath -ColorRole Surface -ResourceMappings @{ 'visibilityButton' = 'Visibility Off' }
    }
}

# Function to load plugins in listboxes
function Import-Plugins {
    param (
        [ValidateSet('Category', 'Alphabetical')]
        [String]$SortMode = $(
            if ($script:atomSettings.SortPlugins.Value -eq 'Alphabetical') { 'Alphabetical' }
            else { 'Category' }
        )
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

    # Load plugin and program params
    . $atomPath\Config\Plugins.ps1

    # Collect and prepare plugins
    $plugins = Get-ChildItem "$pluginsPath\*" -Depth 1 -Include *.ps1,*.bat,*.cmd,*.exe,*.lnk | ForEach-Object {
        $name = $_.BaseName
        $fullName = $_.FullName
        $pluginConfig = $programs[$name]
        $programInfo = $programs[$name].ProgramInfo

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
            FullName     = $fullName
            Config       = $pluginConfig
            ProgramInfo  = $programInfo
            CategoryPath = $_.Directory.FullName
            Category     =
                if ($SortMode -eq 'Alphabetical') { 'All Plugins' }
                else { $_.Directory.Name }
			LaunchParams = switch ($_.Extension) {
				'.bat' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$fullName`"" } }
				'.cmd' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$fullName`"" } }
				'.exe' { @{ FilePath = $fullName } }
				'.lnk' { @{ FilePath = $fullName } }
				'.ps1' { @{ FilePath = 'powershell'; ArgumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$fullName`"" } }
			}
        }
    } | Sort-Object Category, Name

    # Group plugins for UI
    $pluginGroups = $plugins | Group-Object Category
    $categoryPaths = Get-ChildItem $pluginsPath -Directory | Sort-Object Name

    foreach ($group in $pluginGroups) {
        # Keep all downloadable programs discoverable in download mode.
        if (!$script:downloadMode -and !$atomSettings.ShowAdditionalPlugins.Value -and $group.Name -eq 'Additional Plugins') { continue }

        # Create listbox for each plugin category
        $textBlock = New-Object System.Windows.Controls.TextBlock
        $textBlock.Text = $group.Name
        $textBlock.Foreground = $backgroundText
        $textBlock.FontSize = 14
        $textBlock.Margin = '0,10,0,0'
        $textBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Bottom

        $listBox = New-Object System.Windows.Controls.ListBox
        $listBox.Background = 'Transparent'
        $listBox.Foreground = $surfaceText
        $listBox.BorderThickness = 0
        $listBox.Margin = 5
        $listBox.Padding = 0
        $listBox.Width = 200

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
                $this.Tag.Items | Where-Object { $_.IsEnabled } | ForEach-Object { $_.Control.IsChecked = $true }
                Update-DownloadSelectionState
            })
            $categoryCheckBox.Add_Unchecked({
                if ($window.Tag.UpdatingDownloadSelection) { return }
                $this.Tag.Items | Where-Object { $_.IsEnabled } | ForEach-Object { $_.Control.IsChecked = $false }
                Update-DownloadSelectionState
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
        $grid.Children.Add($categoryHeader) | Out-Null
        $grid.Children.Add($border) | Out-Null
        $grid.RowDefinitions[0].Height = [System.Windows.GridLength]::new(30)
        $pluginWrapPanel.Children.Add($grid) | Out-Null

        foreach ($plugin in $group.Group) {
            $name = $plugin.Name
            $iconPath = "$resourcesPath\Icons\Plugins\$name.png"

            if (!(Test-Path $iconPath)) {
                $firstLetter = $name.Substring(0,1)
                $iconPath =
                    if ($firstLetter -match '^[A-Z]') { "$resourcesPath\Icons\Default\$firstLetter.png" }
                    else { "$resourcesPath\Icons\Default\#.png" }
            }

            $listBoxItemParams = @{
                Text = $name
                TextForeground = $surfaceText
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

            if ($script:downloadMode) {
                # Match the checkbox template's 20px artwork to the launch row's 16px icon height.
                $listBoxItem.Control.LayoutTransform = [System.Windows.Media.ScaleTransform]::new(0.8, 0.8)
                $programPath = Join-Path $plugin.ProgramInfo.DestinationPath $plugin.ProgramInfo.RelativePath

                if (Test-Path $programPath) {
                    $listBoxItem.IsEnabled = $false
                    $listBoxItem.Opacity = 0.44
                    $listBoxItem.ToolTip = 'Already downloaded for offline use'
                } else {
                    $listBoxItem.Control.IsChecked = $selectedPrograms -contains $name
                    $listBoxItem.Control.Add_Checked({ Update-DownloadSelectionState })
                    $listBoxItem.Control.Add_Unchecked({ Update-DownloadSelectionState })
                }

                $listBox.Items.Add($listBoxItem) | Out-Null
                continue
            }

            $listBoxItem.Tag = $plugin

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

            # Open context-menu with right-click
            $listBoxItem.Add_MouseRightButtonUp({
                $contextMenu = New-Object System.Windows.Controls.ContextMenu
                $contextMenu.Background = $accentBrush
                $contextMenu.Style = $window.FindResource('CustomContextMenu')
                $selectedFile = $this.Tag

                foreach ($categoryPath in $categoryPaths) {
                    $menuItem = New-Object System.Windows.Controls.MenuItem
                    $menuItem.Foreground = $accentText
                    $menuItem.Header = "Move to $($categoryPath.Name)"
                    $menuItem.Tag = @{
                        File        = $selectedFile
                        Destination = $categoryPath.FullName
                    }

                    $menuItem.Add_Click({
                        Move-Item -LiteralPath $this.Tag.File -Destination $this.Tag.Destination -Force
                        Import-Plugins
                    })

                    $contextMenu.Items.Add($menuItem)
                }

                $contextMenu.IsOpen = $true
            }.GetNewClosure())

            $listBox.Items.Add($listBoxItem) | Out-Null
        }
    }

    if ($script:downloadMode) { Update-DownloadSelectionState }
}
Import-Plugins

# Rebuild download controls on the main UI runspace after a background download finishes.
$downloadRefreshTimer = New-Object System.Windows.Threading.DispatcherTimer
$downloadRefreshTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$downloadRefreshTimer.Add_Tick({
    $this.Stop()
    if (!$window.Tag.DownloadRefreshPending) { return }

    try {
        Import-Plugins
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

$searchTextBox.Add_TextChanged({
    $searchText = [regex]::Escape($searchTextBox.Text) # Escape regex special characters

    $pluginWrapPanel.Children | ForEach-Object {
        $listBox = $_.Children.Child

        # Determine visibility for each item based on the search text
        $visibleItems = $listBox.Items | ForEach-Object {
            $item = $_
            $programName = $item.Text.Text.ToLower()
            $item.Visibility = if ($programName -match $searchText) { "Visible" } else { "Collapsed" }
            $item.Visibility -eq "Visible" # Output visibility status
        }

        # Sync visibility of the category header with the ListBox
        $anyVisibleItems = $visibleItems -contains $true
        $_.Visibility = if ($anyVisibleItems) { "Visible" } else { "Collapsed" }
    }
})

# Plugin sort button
$sortButton = $window.FindName('sortButton')

$sortButton.ToolTip =
    if ($atomSettings.SortPlugins.Value -eq 'Alphabetical') { "Sort by category" }
    else { "Sort alphabetically" }

$sortButton.Add_Click({
    if ($atomSettings.SortPlugins.Value -eq 'Alphabetical') {
        $sortButton.ToolTip = "Sort alphabetically"
        Set-ResourcePath -ColorRole Surface -ResourceMappings @{ "sortButton" = "Category" }
        $script:atomSettings.SortPlugins.Value = 'Category'
        Set-SettingsFile
        Import-Plugins -SortMode Category
    } else {
        $sortButton.ToolTip = "Sort by category"
        Set-ResourcePath -ColorRole Surface -ResourceMappings @{ "sortButton" = "Text Descending" }
        $script:atomSettings.SortPlugins.Value = 'Alphabetical'
        Set-SettingsFile
        Import-Plugins -SortMode Alphabetical
    }
})

# Toggle hidden plugins in both launch and download modes
$visibilityButton.Add_Click({
    $script:atomSettings.ShowHiddenPlugins.Value = !$script:atomSettings.ShowHiddenPlugins.Value
    Set-SettingsFile
    Update-VisibilityButton
    Import-Plugins
})

# Toggle permanent-download selection mode
$downloadModeButton.Add_Click({
    $script:downloadMode = !$script:downloadMode
    Clear-SearchTextBox

    if ($script:downloadMode) {
        $this.ToolTip = 'Exit download mode'
        Set-ResourcePath -ColorRole Surface -ResourceMappings @{ 'downloadModeButton' = 'Close' }
    } else {
        $this.ToolTip = 'Download programs for offline use'
        Set-ResourcePath -ColorRole Surface -ResourceMappings @{ 'downloadModeButton' = 'Download' }
        Set-Quip
    }

    Import-Plugins
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
        Update-DownloadSelectionState
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
            @(Get-DownloadItems | Where-Object { $_.IsEnabled -and $_.Control.IsChecked } | ForEach-Object { $_.Control.Tag })
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
            Set-Location $atomTemp
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
function Set-Quip {
    $randomQuip = Get-Random -InputObject $quips -Count 1
    $statusBarStatus.Text = "$randomQuip"
}

Set-Quip

$refreshButton.Add_Click({
    Start-ButtonSpin $this
    Set-Quip
    Import-Plugins
    $window.SizeToContent = "Height"
})

# Toggle visibility of plugins/settings
$settingsButton.Add_Click({
    if (!$settingsToggled -and $script:downloadMode) {
        $script:downloadMode = $false
        $downloadModeButton.ToolTip = 'Download programs for offline use'
        Set-ResourcePath -ColorRole Surface -ResourceMappings @{ 'downloadModeButton' = 'Download' }
        $downloadSelectedButton.Visibility = 'Collapsed'
        $programUpdateButton.Visibility = 'Collapsed'
        Set-Quip
    }

    if ($settingsToggled) {
        $script:settingsToggled = $false
        $searchBar.Visibility = "Visible"
        $scrollViewer.Visibility = "Visible"
        $scrollViewerSettings.Visibility = "Collapsed"
    } else {
        $script:settingsToggled = $true
        Clear-SearchTextBox
        $searchBar.Visibility = "Collapsed"
        $scrollViewer.Visibility = "Collapsed"
        $scrollViewerSettings.Visibility = "Visible"
    }

    Import-Plugins
})

$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })

# Function to configure window width per plugin column
function Columns {
    param(
        [switch]$get,
        [switch]$set,
        [int]$columns
    )

    switch ($columns) {
        1       { $width = 255 }
        2       { $width = 469 }
        3       { $width = 687 }
        default { $width = 469 }
    }

    if ($get) { return $width }
    if ($set) { $window.Width = $width }
}

# Set plugin columns from startup columns user-setting
Columns -Set $atomSettings.StartupColumns.Value

# Toggle between 1 & 2 columns
$columnButton.Add_Click({
    Columns -Set $(
        if ($window.Width -gt ((Columns -Get 1) + 2) -and $window.Width -le (Columns -Get 2)) { 1 }
        else { 2 }
    )
})

# Function to update column button image based on window width
function Update-ExpandCollapseButton {
    if ($window.Width -gt ((Columns -Get 1) + 2) -and $window.Width -le (Columns -Get 2)) {
        $columnButton.ToolTip = "One-Column View"
        $columnResource = @{ "columnButton" = "Column-1" }
        Set-ResourcePath -ColorRole "Primary" -ResourceMappings $columnResource
    } else {
        $columnButton.ToolTip = "Two-Column View"
        $columnResource = @{ "columnButton" = "Column-2" }
        Set-ResourcePath -ColorRole "Primary" -ResourceMappings $columnResource
    }
}

Update-ExpandCollapseButton

$window.Add_SizeChanged({ Update-ExpandCollapseButton })

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

    Import-Plugins
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
    $apiUrl = "https://api.github.com/repos/SkylerWallace/ATOM/commits?per_page=1"
    $response = Invoke-RestMethod -Uri $apiUrl
    $authorName = $response[0].commit.author.name
    $latestCommitHash =
        if ($authorName -eq "GitHub Actions") { $response[0].parents[0].sha }
        else { $response[0].sha }

    if ($localCommitHash -ne $latestCommitHash) {
        $updateButton.Opacity = 1.0
        $updateButton.IsEnabled = "True"
        $updateText.Text = "Update available!"
    } else {
        Get-Date -Format "MM/dd/yy h:mmtt" | Out-File $lastCheckedPath
        $lastCheckedContent = Get-Content -Path $lastCheckedPath
        $updateText.Text = "$lastCheckedContent"
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

###################
##  Theme panel  ##
###################

foreach ($theme in $themes.GetEnumerator()) {
    $button = New-Object System.Windows.Controls.Button
    $button.Width = 83
    $button.Margin = 5
    $button.Tag = $theme.Name, $theme.Value
    $button.Background = "Transparent"
    $button.Style = $window.Resources["RoundedButton"]
    $button.Add_Click({
        #$selectedTheme = $_.Source.Tag
        #$selectedThemeName = $_.Source.Content.Children[0].Text

        # Save theme
        $script:atomSettings.Theme.Value = $this.Tag[0]
        Set-SettingsFile

        # Update variables
        foreach ($key in $this.Tag[1].Keys) {
            New-Variable -Name $key -Value $this.Tag[1].$key -Scope Global -Force
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
                }
            }
        }

        $window.Resources["gradientStrength"] = $gradientStrength
        #$window.Resources["cornerStrength"] = [System.Windows.CornerRadius]($cornerStrength)
        #$window.Resources["cornerStrength1"] = New-Object System.Windows.CornerRadius($cornerStrength, $cornerStrength, 0, 0)
        #$window.Resources["cornerStrength2"] = New-Object System.Windows.CornerRadius(0, 0, $cornerStrength, $cornerStrength)

        Set-ResourcePath -ColorRole "Primary" -ResourceMappings $primaryResources
        Set-ResourcePath -ColorRole "Background" -ResourceMappings $backgroundResources
        Set-ResourcePath -ColorRole "Surface" -ResourceMappings $surfaceResources
        Set-ResourcePath -ColorRole "Accent" -ResourceMappings $accentResources
        Update-ExpandCollapseButton
    })

    $textBlock = New-Object System.Windows.Controls.TextBlock
    $textBlock.Margin = 5
    $textBlock.Text = $theme.Name
    $textBlock.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "surfaceText")
    $textBlock.Background = "Transparent"
    $textBlock.TextAlignment = "Center"
    $textBlock.TextWrapping = "Wrap"

    $border1 = New-Object System.Windows.Controls.Border
    $border1.Width = 15; $border1.Height = 15
    $border1.Margin = 1
    $border1.CornerRadius = "5,0,0,5"
    $border1.Background = $theme.Value.primaryBrush

    $border2 = New-Object System.Windows.Controls.Border
    $border2.Width = 15; $border2.Height = 15
    $border2.Margin = 1
    $border2.Background = $theme.Value.backgroundBrush

    $border3 = New-Object System.Windows.Controls.Border
    $border3.Width = 15; $border3.Height = 15
    $border3.Margin = 1
    $border3.Background = $theme.Value.surfaceBrush

    $border4 = New-Object System.Windows.Controls.Border
    $border4.Width = 15; $border4.Height = 15
    $border4.Margin = 1
    $border4.CornerRadius = "0,5,5,0"
    $border4.Background = $theme.Value.accentBrush

    $borderStackPanel = New-Object System.Windows.Controls.StackPanel
    $borderStackPanel.Orientation = "Horizontal"
    $borderStackPanel.HorizontalAlignment = "Center"
    $borderStackPanel.Margin = 5
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

function Set-SettingsFile {
    Set-Content -Path "$configPath\SettingsUser.ps1" -Value @(
        "`$userAtomSettings = [ordered]@{"
        $script:atomSettings.GetEnumerator() | ForEach-Object {
            "    $($_.Name) = @{"

            if ($_.Value.Value -is [bool]) {
                "        Value = `$$($_.Value.Value.ToString().ToLower())"
            } elseif ($_.Value.Value -is [string]) {
                "        Value = `"$($_.Value.Value)`""
            } elseif ($_.Value.Value -is [int] -or $_.Value.Value -is [double]) {
                "        Value = $($_.Value.Value)"
            }
            "    }"
        }
        "}"
    )
}

$togglePanel = $window.FindName('togglePanel')

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
                Set-SettingsFile
            })

            $listBoxItem.Control.Add_UnChecked({
                $script:atomSettings.($this.Tag).Value = $false
                Set-SettingsFile
            })
        }

        'RadioButton' {
            $textBlock = New-Object System.Windows.Controls.TextBlock
            $textBlock.Text = $setting.Name
            $textBlock.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty,'surfaceText')
            $textBlock.VerticalAlignment = 'Center'
            $textBlock.FontSize = 12
            $textBlock.Margin = '2.5,0,2.5,0'

            $panel = New-Object System.Windows.Controls.StackPanel
            $panel.Orientation = 'Horizontal'
            $panel.VerticalAlignment = 'Center'

            foreach ($option in $setting.Options.GetEnumerator()) {
                $radioButton = New-Object System.Windows.Controls.RadioButton
                $radioButton.Content = $option.Key
                $radioButton.GroupName = $settingName
                $radioButton.Foreground = $surfaceText
                $radioButton.Margin = '5,0,5,0'
                $radioButton.IsChecked = $setting.Value -eq $option.Value
                $radioButton.Tag = @{
                    Setting = $settingName
                    Value   = $option.Value
                }

                $radioButton.Add_Checked({
                    $script:atomSettings.($this.Tag.Setting).Value = $this.Tag.Value
                    Set-SettingsFile
                })

                $panel.Children.Add($radioButton) | Out-Null
            }

            # Put controls in grid
            $grid = New-Object System.Windows.Controls.Grid
            $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = '1*' }))
            $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = [System.Windows.GridLength]::Auto }))
            $grid.Height = 20

            [System.Windows.Controls.Grid]::SetColumn($textBlock, 0)
            [System.Windows.Controls.Grid]::SetColumn($panel, 1)

            $grid.Children.Add($textBlock) | Out-Null
            $grid.Children.Add($panel) | Out-Null

            $listBoxItem = New-Object System.Windows.Controls.ListBoxItem
            $listBoxItem.Content = $grid
            $listBoxItem.ToolTip = $setting.ToolTip
            $listBoxItem.Tag = $panel

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

    # Update toggle and radio-button controls
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

    # Save settings
    Set-SettingsFile
})

$window.ShowDialog() | Out-Null
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
                <RowDefinition Height="Auto"/>
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
                    <WrapPanel Name="pluginWrapPanel" Orientation="Horizontal" HorizontalAlignment="Center" Margin="10,50,0,10"/>
                </ScrollViewer>

                <Border Name="searchBar" Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" VerticalAlignment="Top" Margin="10,10,28,5" Padding="5">
                    <Grid Height="Auto">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>

                        <Button Name="backspaceButton" Grid.Column="0" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                        <Image Name="searchImage" Grid.Column="1" Opacity="0.38" Width="16" Height="16" Margin="0"/>
                        <TextBlock Name="searchTextBlock" Grid.Column="2" Text="Search plugins" Foreground="{DynamicResource surfaceText}" TextAlignment="Left" VerticalAlignment="Center" Opacity="0.69" Margin="5"/>
                        <TextBox Name="searchTextBox" Grid.Column="2" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" TextAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                        <Button Name="sortButton" Grid.Column="3" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                    </Grid>
                </Border>
            </Grid>

            <ScrollViewer Name="scrollViewerSettings" Grid.Row="1" VerticalScrollBarVisibility="Visible" Style="{StaticResource CustomScrollViewerStyle}" Visibility="Collapsed">
                $settingsXaml
            </ScrollViewer>

            <Grid Grid.Row="2" Margin="10,0,10,10">
                <Rectangle Height="20" Fill="{DynamicResource accentBrush}" RadiusX="5" RadiusY="5"/>
                <TextBlock Name="statusBarStatus" Foreground="{DynamicResource accentText}" FontSize="10" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,0,5,0"/>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

# Load XAML
$window = [Windows.Markup.XamlReader]::Parse($mainXaml)

# Assign variables to elements in XAML
$peButton             = $window.FindName('peButton')
$refreshButton        = $window.FindName('refreshButton')
$settingsButton       = $window.FindName('settingsButton')
$minimizeButton       = $window.FindName('minimizeButton')
$columnButton         = $window.FindName('columnButton')
$closeButton          = $window.FindName('closeButton')
$scrollViewer         = $window.FindName('scrollViewer')
$scrollViewerSettings = $window.FindName('scrollViewerSettings')
$pluginWrapPanel      = $window.FindName('pluginWrapPanel')
$statusBarStatus      = $window.FindName('statusBarStatus')

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

# Function to load plugins in listboxes
function Import-Plugins {
    param (
        [ValidateSet('Category', 'Alphabetical')]
        [String]$SortMode = $(
            if ($script:atomSettings.SortPlugins.Value -eq 'Alphabetical') { 'Alphabetical' }
            else { 'Category' }
        )
    )

    $pluginWrapPanel.Children.Clear()

    # Load plugin params
    . $atomPath\Config\Plugins.ps1

    # Collect and prepare plugins
    $plugins = Get-ChildItem "$pluginsPath\*" -Depth 1 -Include *.ps1,*.bat,*.cmd,*.exe,*.lnk | ForEach-Object {
        $name = $_.BaseName
        $info = $programs[$name].PluginInfo

        if ($info) {
            if (
                (!$inPE -and $info.WorksInOs -eq $false) -or
                ($inPE -and $info.WorksInPe -eq $false) -or
                (!$atomSettings.ShowHiddenPlugins.Value -and $info.Hidden)
            ) {
                return
            }
        }

        [PSCustomObject]@{
            Name         = $name
            FullName     = $_.FullName
            Info         = $info
            CategoryPath = $_.Directory.FullName
            Category     =
                if ($SortMode -eq 'Alphabetical') { 'All Plugins' }
                else { $_.Directory.Name }
        }
    } | Sort-Object Category, Name

    # Group plugins for UI
    $pluginGroups = $plugins | Group-Object Category

    $categoryPaths = Get-ChildItem $pluginsPath -Directory | Sort-Object Name

    foreach ($group in $pluginGroups) {
        # Early continue: 'Show Additional Plugins' setting disabled
        if (!$atomSettings.ShowAdditionalPlugins.Value -and $group.Name -eq "Additional Plugins") { continue }

        # Create listbox for each plugin category
        $textBlock = New-Object System.Windows.Controls.TextBlock
        $textBlock.Text = $group.Name
        $textBlock.Foreground = $backgroundText
        $textBlock.FontSize = 14
        $textBlock.Margin = "0,10,0,0"
        $textBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Bottom

        $listBox = New-Object System.Windows.Controls.ListBox
        $listBox.Background = "Transparent"
        $listBox.Foreground = $surfaceText
        $listBox.BorderThickness = 0
        $listBox.Margin = 5
        $listBox.Padding = 0
        $listBox.Width = 200

        $border = New-Object System.Windows.Controls.Border
        $border.Style = $window.FindResource("CustomBorder")
        $border.Margin = "0,5,0,0"
        $border.SetValue([System.Windows.Controls.Grid]::RowProperty, 1)
        $border.Child = $listBox

        # Configure listbox into plugin wrappanel
        $grid = New-Object System.Windows.Controls.Grid
        $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
        $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
        $grid.Margin = "0,0,10,0"
        $grid.Children.Add($textBlock) | Out-Null
        $grid.Children.Add($border) | Out-Null
        $grid.RowDefinitions[0].Height = [System.Windows.GridLength]::new(30)
        $pluginWrapPanel.Children.Add($grid) | Out-Null

        foreach ($plugin in $group.Group) {
            # Add plugin to category stackpanel
            $name = $plugin.Name

            # Add icon path
            $iconPath = "$resourcesPath\Icons\Plugins\$name.png"

            if (!(Test-Path $iconPath)) {
                $firstLetter = $name.Substring(0,1)
                $iconPath =
                    if ($firstLetter -match "^[A-Z]") { "$resourcesPath\Icons\Default\$firstLetter.png" }
                    else { "$resourcesPath\Icons\Default\#.png" }
            }

            # Setup plugin for listbox
            $listBoxItemParams = @{
                Text = $name
                TextForeground = $surfaceText
                ImageSource = $iconPath
                ToolTip =
                    if ($atomSettings.ShowToolTips.Value -and $plugin.Info.ToolTip) {$plugin.Info.ToolTip}
                    else { $null }
            }

            $listBoxItem = New-ListBoxControlItem @listBoxItemParams
            $listBoxItem.Tag = $plugin.FullName

            # Run plugin with double-click
            $clicks = 
                if ($atomSettings.PluginClicks.Value -eq 2) { 'Add_MouseDoubleClick' }
                else { 'Add_MouseClick' }

            $listBoxItem.$clicks({
                $selectedFile = $this.Tag
                $extension = [System.IO.Path]::GetExtension($selectedFile).ToLower()
                $name = [System.IO.Path]::GetFileNameWithoutExtension($selectedFile)
                $statusBarStatus.Text = "Running $name"

                $launchParams = switch ($extension) {
                    '.bat' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$selectedFile`"" } }
                    '.cmd' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$selectedFile`"" } }
                    '.exe' { @{ FilePath = $selectedFile } }
                    '.lnk' { @{ FilePath = $selectedFile } }
                    '.ps1' { @{ FilePath = 'powershell'; ArgumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$selectedFile`"" } }
                }

                $launchParams.WindowStyle =
                    if ($programs.$name.PluginInfo.Silent -and !$atomSettings.EnableDebugMode.Value) {
                        'Hidden'
                    }
                    else {
                        'Normal'
                    }

                Start-Process @launchParams
            })

            # Open context-menu with right-click
            $listBoxItem.Add_MouseRightButtonUp({
                $contextMenu = New-Object System.Windows.Controls.ContextMenu
                $contextMenu.Background = $accentBrush
                $contextMenu.Style = $window.FindResource("CustomContextMenu")

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
}

Import-Plugins

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

        $categoryName = $_.Children[0].Text
        $pluginName = $listBox.Items.Text.Text
        $pluginPath = $listBox.Items.Tag

        # Determine visibility for each item based on the search text
        $visibleItems = $listBox.Items | ForEach-Object {
            $item = $_
            $programName = $item.Content.Children[1].Text.ToLower()
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
    if ($atomSettings.SortPlugins.Value -eq 'Alphabetical') { "Sort alphabetically" }
    else { "Sort by category" }

$sortButton.Add_Click({
    if ($sortButton.ToolTip -match "alphabetically") {
        $sortButton.ToolTip = "Sort by category"
        Set-ResourcePath -ColorRole Surface -ResourceMappings @{ "sortButton" = "Category" }
        $script:atomSettings.SortPlugins.Value = 'Category'
        Set-SettingsFile
        Import-Plugins -SortMode Category
    } else {
        $sortButton.ToolTip = "Sort alphabetically"
        Set-ResourcePath -ColorRole Surface -ResourceMappings @{ "sortButton" = "Text Descending" }
        $script:atomSettings.SortPlugins.Value = 'Alphabetical'
        Set-SettingsFile
        Import-Plugins -SortMode Alphabetical
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

    # Update toggles
    $togglePanel.Children | Where-Object { $_ -is [System.Windows.Controls.ListBoxItem] } | ForEach-Object {
        $_.Control.Tag
        $_.Control.IsChecked = if ($atomSettings[$_.Control.Tag].Value) { $true } else { $false }
    }

    $startupColumnsStackPanel.Children | Where-Object { $_ -is [System.Windows.Controls.RadioButton] } | ForEach-Object { $_.IsChecked = ($_.Tag -eq $atomSettings.StartupColumns.Value) }

    # Save settings
    Set-SettingsFile
})

$window.ShowDialog() | Out-Null
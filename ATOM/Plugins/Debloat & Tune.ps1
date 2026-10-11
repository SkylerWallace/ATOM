<#
.SYNOPSIS
Selectively applies optimizations and removes selected applications, or opens the debloat and tune window.
.PARAMETER Optimizations
Optimization IDs from Debloat & Tune/Optimizations.psd1.
.PARAMETER NonInteractive
Runs selected actions without opening the window and returns structured results.
AllowInteractiveUninstall can still open external uninstaller windows.
.PARAMETER ProgramNames
Exact catalog names from the Unwanted Apps and Bloatware categories. By default, only registered
quiet uninstall commands and MSI product-code uninstallers are supported.
.PARAMETER UnusedAppx
Selects installed current-user catalog packages that are not marked Important and
have no detected data in standard app-data folders. This is a heuristic, not usage history.
Does not remove provisioned packages, other users' packages, or framework packages.
.PARAMETER ProgramCategories
Selects detected programs from Unwanted Apps and/or Bloatware. Can be combined with Programs;
overlapping selections are processed once. Removals are silent unless AllowInteractiveUninstall is set.
.PARAMETER AllowInteractiveUninstall
Launches registered interactive uninstallers first when no silent command is available,
then runs silent removals and waits for the interactive uninstallers before returning.
.PARAMETER Preview
Validates selections and unattended uninstall support, and lists the plan without making changes.
.EXAMPLE
& '.\Debloat & Tune.ps1' -ProgramCategories 'Unwanted Apps',Bloatware -Preview
Previews detected programs in both categories without uninstalling anything.
.EXAMPLE
& '.\Debloat & Tune.ps1' -Programs OneLaunch,ClearBar -UnusedAppx -Preview
Previews specific program removals and eligible current-user AppX packages.
.EXAMPLE
& '.\Debloat & Tune.ps1' -Optimizations DisableSCOOBE,DisableTelemetry -NonInteractive
.EXAMPLE
& '.\Debloat & Tune.ps1' -Optimizations DisableSCOOBE -Preview
#>
param(
    [string[]]$Optimizations,
    [Alias('Programs')]
    [string[]]$ProgramNames,
    [ValidateSet('Unwanted Apps', 'Bloatware')]
    [string[]]$ProgramCategories,
    [switch]$UnusedAppx,
    [switch]$AllowInteractiveUninstall,
    [switch]$NonInteractive,
    [switch]$Preview
)

$dependencies = Join-Path $PSScriptRoot 'Debloat & Tune'
$script:debloatIsAdministrator = ([Security.Principal.WindowsPrincipal]::new(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
. (Join-Path $dependencies 'Functions/Debloat-Removals.ps1')
$optimizationCatalog = Import-PowerShellDataFile (Join-Path $dependencies 'Optimizations.psd1')
if ($PSBoundParameters.ContainsKey('Optimizations') -or $PSBoundParameters.ContainsKey('ProgramNames') -or $PSBoundParameters.ContainsKey('ProgramCategories') -or $UnusedAppx -or $NonInteractive -or $Preview) {
    if (!$Optimizations.Count -and !$ProgramNames.Count -and !$ProgramCategories.Count -and !$UnusedAppx) { throw 'Select optimizations, programs, program categories, or UnusedAppx.' }
    $queue = @(foreach ($id in ($Optimizations | Select-Object -Unique)) {
        if (!$optimizationCatalog.ContainsKey($id)) { throw "Unknown optimization: $id" }
        [pscustomobject]@{ Kind='Optimization'; Id=$id; Name=$optimizationCatalog[$id].Name }
    })
    if ($ProgramNames.Count -or $ProgramCategories.Count -or $UnusedAppx) {
        . (Join-Path $PSScriptRoot '../Functions/Import-Atom.ps1') -Function Get-App
        $queue += @(New-DebloatRemovalQueue -ProgramNames $ProgramNames -ProgramCategories $ProgramCategories -UnusedAppx:$UnusedAppx -DependenciesPath $dependencies)
    }
    . (Join-Path $dependencies 'Functions/Invoke-DebloatQueue.ps1')
    Invoke-DebloatQueue -Queue @($queue) -DependenciesPath $dependencies -FunctionsPath (Join-Path $PSScriptRoot '../Functions') -Preview:$Preview -AllowInteractiveUninstall:$AllowInteractiveUninstall
    return
}
Add-Type -AssemblyName PresentationFramework

# Import module(s)
. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Add-AtomScrollViewerBehavior','Get-App','Invoke-Runspace','New-AtomWindow','New-ListBoxControlItem','New-VectorIcon','Set-VectorIcon','Set-WindowSize','Set-ThingProperty' -Feature Context,Wpf
$debloatTuneDependencies  = "$psScriptRoot\Debloat & Tune"
$debloatTuneFunctions     = "$debloatTuneDependencies\Functions"
$debloatTuneOptimizations = "$debloatTuneDependencies\Optimizations"
$customizationsPath     = "$debloatTuneDependencies\Customizations.ps1"

$contentXaml = @"
<Grid>
    <Grid>
        <ScrollViewer Name="scrollViewer0" HorizontalScrollBarVisibility="Disabled" VerticalScrollBarVisibility="Visible" Style="{StaticResource CustomScrollViewerStyle}">
            <StackPanel>
                <Border Height="{Binding ActualHeight, ElementName=floatingControls}" Margin="0,10,0,5"/>

                <TextBlock Name="loadingText" Text="Loading settings and installed apps..." Foreground="{DynamicResource backgroundText}" HorizontalAlignment="Center" Margin="10,30" Opacity="0.69"/>
                <StackPanel Name="uninstallPanel" Margin="0,0,10,5"/>
                <Border Height="48"/>
            </StackPanel>
        </ScrollViewer>
        <StackPanel Name="floatingControls" Panel.ZIndex="10" VerticalAlignment="Top" Margin="10,10,28,5">
        <Border Name="searchBar" Style="{StaticResource CustomBorder}" Padding="5">
            <Grid>
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <Button Name="clearSearchButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Clear search"/>
                <ContentControl Name="searchImage" Grid.Column="1" Opacity="0.38" Width="16" Height="16"/>
                <TextBlock Name="searchPlaceholder" Grid.Column="2" Text="Search" Foreground="{DynamicResource surfaceText}" Opacity="0.69" VerticalAlignment="Center" Margin="5" IsHitTestVisible="False"/>
                <TextBox Name="searchTextBox" Grid.Column="2" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" VerticalAlignment="Center" Margin="5"/>
                <Button Name="descriptionButton" Grid.Column="3" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Hide descriptions"/>
                <Grid Grid.Row="1" Grid.ColumnSpan="4" Height="2" Margin="5,2">
                    <Border Height="1" Background="{DynamicResource surfaceText}" Opacity="0.44"/>
                    <ProgressBar Name="overallProgress" Height="2" Minimum="0" Maximum="1" Value="0" Background="Transparent" Foreground="{DynamicResource surfaceText}" IsHitTestVisible="False"/>
                </Grid>
                <TextBlock Name="progressText" Grid.Row="2" Grid.ColumnSpan="4" Text="Loading settings and installed apps..." Foreground="{DynamicResource surfaceText}" FontSize="10" Margin="5" TextWrapping="Wrap"/>
            </Grid>
        </Border>
                <Border Style="{StaticResource CustomBorder}" Margin="0,10,0,0" Padding="5">
                    <StackPanel>
                    <DockPanel>
                        <Button Name="openLogButton" DockPanel.Dock="Right" Style="{StaticResource RoundedButton}" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" Margin="5,0,0,0">
                            <TextBlock Text="Open log" Margin="10,5"/>
                        </Button>
                        <ContentControl Name="logsControlHost"/>
                    </DockPanel>
                        <Button Name="resultsToggleButton" Foreground="{DynamicResource surfaceText}" Background="Transparent" Style="{StaticResource RoundedButton}" HorizontalContentAlignment="Stretch" Margin="0,5,0,2" ToolTip="Expand results">
                            <Grid>
                                <TextBlock Text="Results" Foreground="{DynamicResource surfaceText}" Margin="2.5,0,25,0"/>
                                <ContentControl Name="resultsIndicator" Width="16" Height="16" HorizontalAlignment="Right" VerticalAlignment="Center"/>
                            </Grid>
                        </Button>
                        <ScrollViewer Name="resultsBox" Height="128" Visibility="Collapsed" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Style="{StaticResource CustomScrollViewerStyle}">
                            <TextBlock Name="resultsText" Foreground="{DynamicResource surfaceText}" FontSize="12" LineHeight="16" LineStackingStrategy="BlockLineHeight" TextWrapping="Wrap"/>
                        </ScrollViewer>
                    </StackPanel>
                </Border>
        </StackPanel>
        <StackPanel Name="floatingActions" Panel.ZIndex="11" Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="10,10,28,10">
            <Button Name="cancelButton" Height="28" Padding="10,3" Margin="0,0,6,0" Foreground="{DynamicResource onErrorText}" Background="{DynamicResource errorBrush}" Style="{StaticResource RoundedButton}" Visibility="Collapsed" ToolTip="Finish the current action, then stop the run">
                <Border Padding="{Binding Padding, RelativeSource={RelativeSource AncestorType=Button}}"><StackPanel Orientation="Horizontal">
                    <ContentControl Width="16" Height="16" Style="{StaticResource VectorIconStyle}" Content="{StaticResource CloseIcon}" Foreground="{DynamicResource onErrorText}" Margin="0,0,6,0" VerticalAlignment="Center"/>
                    <TextBlock Text="Cancel" VerticalAlignment="Center"/>
                </StackPanel></Border>
            </Button>
            <Button Name="runButton" IsEnabled="False" Height="28" MinWidth="90" Padding="10,3" Background="{DynamicResource controlBrush}" Foreground="{DynamicResource controlText}" Style="{StaticResource RoundedButton}">
                <Border Padding="{Binding Padding, RelativeSource={RelativeSource AncestorType=Button}}"><StackPanel Orientation="Horizontal">
                    <ContentControl Width="16" Height="16" Style="{StaticResource VectorIconStyle}" Content="{StaticResource PlayArrowIcon}" Foreground="{DynamicResource controlText}" Margin="0,0,6,0" VerticalAlignment="Center"/>
                    <TextBlock Name="runLabel" Text="Run selected actions" VerticalAlignment="Center"/>
                </StackPanel></Border>
            </Button>
        </StackPanel>
    </Grid>
</Grid>
"@
$windowParameters = @{
    Title       = 'Debloat & Tune'
    IconPath    = "$debloatTuneDependencies\Debloat & Tune.png"
    ContentXaml = $contentXaml
    Width       = 487
    Height      = 600
    MinWidth    = 400
    MinHeight   = 400
}
$window = New-AtomWindow @windowParameters

# Assign variables to elements in XAML
$runButton      = $window.Findname('runButton')
$cancelButton = $window.FindName('cancelButton')
$uninstallPanel = $window.FindName('uninstallPanel')
$searchTextBox = $window.FindName('searchTextBox')
$searchPlaceholder = $window.FindName('searchPlaceholder')
$logsItem = New-ListBoxControlItem -ControlType ComboBox -ControlOptions @{} -ControlAlignment Right -ControlWidth ([double]::NaN) -ControlStyle $window.Resources['CustomComboBox'] -Text 'Logs' -TextForeground $surfaceText
$logsItem.Margin = 0
$logsItem.BorderThickness = 1
$logsItem.Text.Margin = '4,0,10,0'
[Windows.Controls.DockPanel]::SetDock($logsItem.Text, 'Left')
$logsItem.Content.Children.Remove($logsItem.Text)
$logsItem.Content.Children.Insert(0, $logsItem.Text)
$window.FindName('logsControlHost').Content = $logsItem
$logSelector = $logsItem.Control
$logSelector.DisplayMemberPath = 'Name'
$logSelector.SelectedValuePath = 'FullName'
$openLogButton = $window.FindName('openLogButton')
$progressText = $window.FindName('progressText')
$overallProgress = $window.FindName('overallProgress')
$resultsText = $window.FindName('resultsText')
$resultsBox = $window.FindName('resultsBox')
$script:debloatShowDescriptions = $false

# Set icon sources
Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{
    'clearSearchButton' = 'BackspaceIcon'
    'searchImage' = 'SearchIcon'
    'resultsIndicator' = 'ArrowDropDownIcon'
}
$window.FindName('resultsToggleButton').Add_Click({
    Set-DebloatResultsExpanded -Expanded ($resultsBox.Visibility -ne 'Visible')
})
function Set-DebloatResultsExpanded {
    param([bool]$Expanded)
    $resultsBox.Visibility = if ($Expanded) { 'Visible' } else { 'Collapsed' }
    $window.FindName('resultsToggleButton').ToolTip = if ($Expanded) { 'Collapse results' } else { 'Expand results' }
    Set-VectorIcon -Window $window -ResourceMappings @{ resultsIndicator = $(if ($expanded) { 'ArrowDropUpIcon' } else { 'ArrowDropDownIcon' }) }
    $resultsBox.ScrollToEnd()
}
$resultsBox.Add_ScrollChanged({
    param($sender, $eventArgs)
    if ($eventArgs.ExtentHeightChange -ne 0 -or $eventArgs.ViewportHeightChange -ne 0) { $sender.ScrollToEnd() }
})
function Write-DebloatResults {
    param([string]$Message)
    if ($resultsText.Text.Length) { $resultsText.Text += [Environment]::NewLine }
    $resultsText.Text += $Message
    $resultsBox.ScrollToEnd()
}
# Construct panels
# Notification panel
<# Disabled: browser notification detection is not consistently supported.
Add-Type -AssemblyName System.Windows.Forms

$whitelistSites = @(
    ("www.calendar.google.com"),
    ("www.facebook.com"),
    ("www.mail.google.com"),
    ("www.outlook.live.com"),
    ("www.meet.google.com"),
    ("www.netflix.com"),
    ("www.youtube.com"),
    ("www.zoom.us")
)

function Check-Notifications {
    $textBlock = New-Object System.Windows.Controls.TextBlock
    $textBlock.Foreground = $surfaceText
    $textBlock.Margin = "5"
    $stackPanel.Children.Add($textBlock) | Out-Null
    
    $browserButton = New-Object System.Windows.Controls.Button
    $browserButton.Background = $accentBrush
    $browserButton.Foreground = $accentText
    $browserButton.Tag = $browserName
    $browserButton.Content = $buttonContent
    $browserButton.Tooltip = $buttonTooltip
    $browserButton.Style = $window.Resources["RoundedButton"]
    $browserButton.Margin = "5"
    $browserButton.Tag = @{ "Name" = $browserName; "URL" = $notificationsUrl }
    $stackPanel.Children.Add($browserButton) | Out-Null
    $browserButton.Add_Click({
        $buttonTag = $_.Source.Tag
        [System.Windows.Forms.Clipboard]::SetText($buttonTag["URL"])
        start $buttonTag["Name"]
    })
    
    $preferencesFilePaths = @("$userDataPath\Default\Preferences")
    $profiles = Get-ChildItem "$userDataPath" | Where-Object {$_.PSIsContainer -and $_.Name.StartsWith("Profile")}
    foreach ($profile in $profiles) {
        $preferencesFilePaths += "$($profile.FullName)\Preferences"
    }
    $totalSiteCounter = 0
    $totalWhitelistCounter = 0
    
    $textBlock.Text = $browserName
    foreach ($preferencesFilePath in $preferencesFilePaths) {
        $preferences = Get-Content $preferencesFilePath -Raw
        $userName = if ($browserName -eq "Chrome") { ($preferences | ConvertFrom-Json).account_info[0].full_name }
                    elseif ($browserName -eq "MSEdge") { [regex]::Match($preferences, '"edge_account_first_name":"([^"]+)"').Groups[1].Value }
        
        $notifications = ($preferences | Select-String -Pattern '(?<="notifications":{)(.*?)(?=},"password_protection":)').Matches.Value | Out-String
        $urls = [regex]::Matches($notifications, '(?:www\.)?[a-z]+\.[a-z]+(?:\.[a-z]+)*') | ForEach-Object { $_.Value }
        $whitelistCounter = 0
        foreach ($url in $urls) {
            if ($whitelistSites -contains $url) {
                $whitelistCounter++
                $totalWhitelistCounter++
            } else {
                $totalSiteCounter++
            }
        }
        $totalSiteCounter += $whitelistCounter
        
        $textBlock.Text += "`n- $($username): $whitelistCounter / $($urls.Count) sites whitelisted"
    }
}

$browserTextBlock = New-Object System.Windows.Controls.TextBlock
$browserTextBlock.Text = "Browser Notifications"
$browserTextBlock.FontWeight = "Bold"
$browserTextBlock.Foreground = $backgroundText
$browserTextBlock.Margin = "10,5,0,0"
$uninstallPanel.Children.Add($browserTextBlock) | Out-Null

$border = New-Object System.Windows.Controls.Border
$border.Style = $window.Resources["CustomBorder"]
$border.Margin = "10,10,0,10"
$border.Padding = "5"
$uninstallPanel.Children.Add($border) | Out-Null

$stackPanel = New-Object System.Windows.Controls.StackPanel
$border.Child = $stackPanel

# Edge
$browserPath = "C:\Program Files*\Microsoft\Edge"
$userDataPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
$preferencesPath = "$userDataPath\*\Preferences"

if ((Test-Path $browserPath) -And (Test-Path $preferencesPath)) {
    $buttonContent = "Launch Edge"
    $buttonTooltip = "- Launches Edge`n- Adds notification URL to clipboard"
    
    $browserName = "MSEdge"
    $notificationsUrl = "edge://settings/content/notifications"

    Check-Notifications
}

# Chrome
$browserPath = "C:\Program Files*\Google\Chrome"
$userDataPath = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$preferencesPath = "$userDataPath\*\Preferences"

if ((Test-Path $browserPath) -And (Test-Path $preferencesPath)) {
    $buttonContent = "Launch Chrome"
    $buttonTooltip = "- Launches Chrome`n- Adds notification URL to clipboard"
    
    $browserName = "Chrome"
    $notificationsUrl = "chrome://settings/content/notifications"

    Check-Notifications
}

#>

# Timezones panel
<# Disabled: timezone configuration is not consistently supported.
$timezoneTextBlock = New-Object System.Windows.Controls.TextBlock
$timezoneTextBlock.Text = "Timezones"
$timezoneTextBlock.FontWeight = "Bold"
$timezoneTextBlock.Foreground = $backgroundText
$timezoneTextBlock.Margin = "10,5,0,0"
$uninstallPanel.Children.Add($timezoneTextBlock) | Out-Null

$timezoneBorder = New-Object System.Windows.Controls.Border
$timezoneBorder.Style = $window.Resources["CustomBorder"]
$timezoneBorder.Margin = "10,5,0,5"
$timezoneBorder.Padding = "5"
$uninstallPanel.Children.Add($timezoneBorder) | Out-Null

$timezonePanel = New-Object System.Windows.Controls.StackPanel
$timezoneBorder.Child = $timezonePanel

function New-TimezoneRadioButton {
    param(
        [string]$Name,
        [string]$TimezoneId,
        [string]$Content
    )

    $radioButton = New-Object System.Windows.Controls.RadioButton
    $radioButton.Name = $Name
    $radioButton.Content = $Content
    $radioButton.Tag = $TimezoneId
    $radioButton.GroupName = "Timezone"
    $radioButton.Margin = "5"
    $radioButton.Foreground = $surfaceText
    $radioButton.VerticalContentAlignment = "Center"
    $radioButton.Add_Checked({ $script:checkedTimezone = $this.Tag })

    return $radioButton
}

@(
    (New-TimezoneRadioButton -Name "rbPST" -Content "Pacific Time" -TimezoneId "Pacific Standard Time")
    (New-TimezoneRadioButton -Name "rbMST" -Content "Mountain Time" -TimezoneId "Mountain Standard Time")
    (New-TimezoneRadioButton -Name "rbCST" -Content "Central Time" -TimezoneId "Central Standard Time")
    (New-TimezoneRadioButton -Name "rbEST" -Content "Eastern Time" -TimezoneId "Eastern Standard Time")
) | ForEach-Object { $timezonePanel.Children.Add($_) | Out-Null }

#>

$script:debloatSessionLogPath = Join-Path $atomTemp ('debloat-and-tune-' + [DateTime]::Now.ToString('yyyyMMdd-HHmmss-fffffff') + '.txt')
. $customizationsPath

function New-DebloatCategoryHeader {
    param([string]$Text, [string]$ToolTip, [string]$Tag)
    $header = New-ListBoxControlItem -ControlType CheckBox -Text $Text -ToolTip $ToolTip -Tag $Tag -TextForeground $backgroundText
    $header.FontWeight = 'Bold'
    $header.Margin = '4.5,5,0,0'
    $header.BorderThickness = 1
    return $header
}

function Set-DebloatAdminRequired {
    param($Item)
    $icon = New-VectorIcon -Window $window -Icon 'LockIcon' -ForegroundResource 'warningText' -Size 14 -OpticalSize 20
    $icon.Margin = '6,0,2.5,0'
    [Windows.Automation.AutomationProperties]::SetName($icon, 'Requires administrator privileges')
    [Windows.Controls.DockPanel]::SetDock($icon, 'Right')
    $Item.Content.Children.Insert(0, $icon)
    $Item.TrailingContent += $icon
    $Item.IsEnabled = $false
    $Item.Opacity = 0.44
    $Item.ToolTip += "`nRequires administrator privileges."
    [Windows.Controls.ToolTipService]::SetShowOnDisabled($Item, $true)
}

function Update-DebloatView {
    $selected = @{}
    foreach ($child in $uninstallPanel.Children) {
        if ($child -is [Windows.Controls.ListBox]) {
            foreach ($item in $child.Items) {
                if ($item.Control -is [Windows.Controls.CheckBox] -and $item.Control.IsChecked) { $selected[$item.Text.Text] = $true }
            }
        }
    }
    $uninstallPanel.Children.Clear()
# Customizations panel
$customizationsTextBlock = New-Object System.Windows.Controls.TextBlock
$customizationsTextBlock.Text = "Customizations"
$customizationsTextBlock.ToolTip = 'Changes apply immediately. On means the named feature is enabled. Some changes require signing out.'
$customizationsTextBlock.TextWrapping = 'Wrap'
$customizationsTextBlock.FontWeight = "Bold"
$customizationsTextBlock.Foreground = $backgroundText
$customizationsTextBlock.Margin = "10,5,0,0"
$uninstallPanel.Children.Add($customizationsTextBlock) | Out-Null

$customizationPanel = New-Object System.Windows.Controls.ListBox
$customizationPanel.Background = $surfaceBrush
$customizationPanel.Foreground = $surfaceText
$customizationPanel.BorderThickness = 0
$customizationPanel.Margin = "10,5,0,5"
$customizationPanel.Style = $window.Resources["CustomListBoxStyle"]
[Windows.Controls.ScrollViewer]::SetHorizontalScrollBarVisibility($customizationPanel, 'Disabled')
$uninstallPanel.Children.Add($customizationPanel) | Out-Null

$winBuild = [int][Microsoft.Win32.Registry]::GetValue('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'CurrentBuildNumber', [Environment]::OSVersion.Version.Build)
foreach ($name in $customizations.Keys) {
    $customization = $customizations[$name]
    if (($customization.MinimumWindowsBuild -and $winBuild -lt $customization.MinimumWindowsBuild) -or
        ($customization.MaximumWindowsBuild -and $winBuild -gt $customization.MaximumWindowsBuild)) { continue }
    $item = New-ListBoxControlItem -ControlType ToggleButton -ControlAlignment Right -Text $name -Description $customization.Description -ToolTip $customization.ToolTip -TextForeground $surfaceText -Tag @{ Name = $name; Definition = $customization; Item = $null }
    $item.Control.Tag.Item = $item
    $item.BorderThickness = 1
    if (!$script:debloatIsAdministrator -and $customization.RequiresAdmin) { Set-DebloatAdminRequired $item }
    try {
        $item.Control.IsChecked = Get-DebloatCustomizationState $customization
        if ($null -eq $item.Control.IsChecked) { $item.Text.Text += ' (mixed)'; $item.ToolTip += "`nCurrent values are mixed. Click to select a consistent setting." }
    } catch { $item.IsEnabled = $false; $item.Opacity = 0.44; $item.ToolTip += "`nState could not be read: $($_.Exception.Message)" }
    $item.Control.Add_Click({
        $target = $this.Tag
        $message = ''
        try {
            Set-DebloatCustomizationState -Definition $target.Definition -Enabled ([bool]$this.IsChecked)
            $message = "$($target.Name) - $(if ($this.IsChecked) { 'On' } else { 'Off' })."
        } catch { $message = "$($target.Name) failed: $($_.Exception.Message)" }
        try {
            $this.IsChecked = Get-DebloatCustomizationState $target.Definition
            $target.Item.Text.Text = $target.Name + $(if ($null -eq $this.IsChecked) { ' (mixed)' } else { '' })
        } catch { $target.Item.IsEnabled = $false; $target.Item.Opacity = 0.44 }
        $progressText.Text = $message
        Write-DebloatResults $message
        try {
            Add-Content -LiteralPath $script:debloatSessionLogPath -Value ('[{0}] {1}' -f [DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss'), $message) -Encoding UTF8 -ErrorAction Stop
            Update-DebloatLogs -SelectNewest
        } catch { $progressText.Text += " Log failed: $($_.Exception.Message)" }
    })
    [void]$customizationPanel.Items.Add($item)
}

# Optimizations panel
$optimizationHeader = New-DebloatCategoryHeader -Text 'Optimizations' -ToolTip 'Apply privacy, maintenance, and service changes. Review each action before running. Check this box to select all available optimizations.'
$optimizationsCheckbox = $optimizationHeader.Control
$uninstallPanel.Children.Add($optimizationHeader) | Out-Null

$optimizationsListBox = New-Object System.Windows.Controls.ListBox
$optimizationsListBox.Background = $surfaceColor
$optimizationsListBox.Foreground = $surfaceText
$optimizationsListBox.BorderThickness = 0
$optimizationsListBox.Margin = "10,5,0,5"
$optimizationsListBox.Style = $window.Resources["CustomListBoxStyle"]
[Windows.Controls.ScrollViewer]::SetHorizontalScrollBarVisibility($optimizationsListBox, 'Disabled')
$uninstallPanel.Children.Add($optimizationsListBox) | Out-Null

$optimizationCatalog.GetEnumerator() | Sort-Object { $_.Key -eq 'DisableSysMain' }, { $_.Value.Name } | ForEach-Object {
    $trailingContent = @()
    if ($_.Value.Caution) {
        $icon = New-VectorIcon -Window $window -Icon 'WorkflowWarningIcon' -ForegroundResource 'warningText' -Size 14 -Filled
        $icon.Margin = '6,0,2.5,0'
        [Windows.Automation.AutomationProperties]::SetName($icon, $_.Value.Caution)
        $trailingContent += $icon
    }
    $checkBox = New-ListBoxControlItem -ControlType CheckBox -Text $_.Value.Name -Description $_.Value.Description -ToolTip $_.Value.ToolTip -TrailingContent $trailingContent -Tag $_.Key -TextForeground $surfaceText
    if ($_.Value.Caution) { $checkBox.ToolTip += "`n$($_.Value.Caution)" }
    $checkBox.BorderThickness = 1
    if (!$script:debloatIsAdministrator -and $_.Value.RequiresAdmin -ne $false) {
        Set-DebloatAdminRequired $checkBox
    } elseif ($_.Value.DetectionScriptFile) {
        try { $checkBox.IsEnabled = [bool](& (Join-Path $debloatTuneOptimizations $_.Value.DetectionScriptFile)) }
        catch { $checkBox.IsEnabled = $false; $checkBox.ToolTip += "`nState could not be read: $($_.Exception.Message)" }
        if (!$checkBox.IsEnabled) { $checkBox.Opacity = 0.44 }
    }
    $optimizationsItems = $optimizationsListBox.Items
    $optimizationsItems.Add($checkBox) | Out-Null
}
$optimizationsCheckbox.Add_Checked({
    foreach ($item in $optimizationsItems) {
        if ($item.IsEnabled) {
            $item.Control.IsChecked = $true
        }
    }
})

$optimizationsCheckbox.Add_Unchecked({
    foreach ($item in $optimizationsItems) {
        if ($item.IsEnabled) {
            $item.Control.IsChecked = $false
        }
    }
})

# Programs panel
$divider = [Windows.Controls.Border]::new()
$divider.Height = 1
$divider.Margin = '10,10,0,10'
$divider.Opacity = 0.3
$divider.SetResourceReference([Windows.Controls.Border]::BackgroundProperty, 'surfaceText')
[void]$uninstallPanel.Children.Add($divider)
# Import programs hashtable
$programsHashtable = Join-Path $debloatTuneDependencies "Programs.ps1"
. $programsHashtable

$detectedPrograms = @{}
$detectionErrors = @{}
foreach ($category in ($programs.Values.Category | Sort-Object -Unique)) { $detectedPrograms[$category] = @{} }
try { $installedApps = @(Get-App -ErrorAction Stop) } catch {
    $installedApps = @()
    foreach ($category in $detectedPrograms.Keys) { $detectionErrors[$category] = $true }
    Write-Warning "Unable to scan installed programs: $($_.Exception.Message)"
}
$detectionContext = [PSCustomObject]@{ InstalledApps = $installedApps }
$installedAppsByName = @{}
foreach ($app in $installedApps) {
    if (!$installedAppsByName.ContainsKey($app.DisplayName)) { $installedAppsByName[$app.DisplayName] = [Collections.Generic.List[object]]::new() }
    $installedAppsByName[$app.DisplayName].Add($app)
}
$installedAppNames = [string[]]@($installedAppsByName.Keys)
$seenPrograms = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($name in $programs.Keys) {
    $definition = $programs[$name]
    try {
        if ($definition.Detect) {
            if (!$definition.Uninstall) { throw 'Custom detection requires an Uninstall action.' }
            $detectedMatches = @(& { $ErrorActionPreference = 'Stop'; & $definition.Detect $detectionContext })
        } else {
            $patterns = if ($definition.Match) { @($definition.Match) } else { @($name) }
            $detectedMatches = @(foreach ($pattern in $patterns) {
                foreach ($matchedName in ($installedAppNames -like $pattern)) { $installedAppsByName[$matchedName] }
            })
        }
        foreach ($match in $detectedMatches) {
            $id = if ($definition.Detect) { "custom:$name|$($match.Id)" } else { "registry:$($match.PsPath)" }
            if (!$match.DisplayName -or ($definition.Detect -and !$match.Id) -or (!$definition.Detect -and !$match.PsPath)) {
                throw 'Detection returned a record without a name or stable ID.'
            }
            # Overlapping definitions must not select the same installation twice.
            if (!$seenPrograms.Add($id)) { continue }
            $detectedPrograms[$definition.Category][$id] = [PSCustomObject]@{
                Id = $id
                Definition = $name
                DisplayName = $match.DisplayName
                ToolTip = $definition.ToolTip
                Target = $match
                RequiresAdmin = Test-DebloatProgramRequiresAdmin -App $match -Definition $definition
            }
        }
    } catch {
        $detectionErrors[$definition.Category] = $true
        Write-Warning "Unable to detect '$name': $($_.Exception.Message)"
    }
}

# Listboxes hashtable
$listBoxes = @{}

# Show every catalog category, including empty or incomplete scans.
foreach ($category in ($detectedPrograms.Keys | Sort-Object @{ Expression = { !$detectedPrograms[$_].Count -and !$detectionErrors[$_] } }, @{ Expression = { $_ } })) {
    $categoryHeader = New-DebloatCategoryHeader -Text $category -Tag $category -ToolTip "Check all $category apps that are safe to remove."
    $categoryCheckBox = $categoryHeader.Control
    $categoryHeader.IsEnabled = $detectedPrograms[$category].Count -gt 0
    $uninstallPanel.Children.Add($categoryHeader) | Out-Null
    
    # create a listBox for the programs in this category
    $listBox = New-Object System.Windows.Controls.ListBox
    $listBox.Background = $surfaceBrush
    $listBox.Foreground = $surfaceText
    $listBox.BorderThickness = 0
    $listBox.Margin = "10,5,0,5"
    $listBox.Style = $window.Resources["CustomListBoxStyle"]
    [Windows.Controls.ScrollViewer]::SetHorizontalScrollBarVisibility($listBox, 'Disabled')
    $uninstallPanel.Children.Add($listBox) | Out-Null
    
    $listBoxes.$category = $listBox
    if (!$detectedPrograms[$category].Count -and !$detectionErrors[$category]) {
        $categoryHeader.Text.Text = "$category - None detected"
        $categoryHeader.Opacity = 0.44
        $listBox.Visibility = 'Collapsed'
    }
    if ($detectionErrors[$category]) {
        $statusText = 'Scan incomplete'
        $statusItem = New-ListBoxControlItem -Text $statusText -TextForeground $surfaceText
        $statusItem.IsEnabled = $false
        $listBox.Items.Add($statusItem) | Out-Null
    }
    
    $categoryCheckBox.Add_Checked({
        $currentCategory = $this.Tag
        foreach ($item in $listBoxes.$currentCategory.Items) {
            if ($item.IsEnabled -and $item.Control) { $item.Control.IsChecked = $true }
        }
    })
    
    $categoryCheckBox.Add_Unchecked({
        $currentCategory = $this.Tag
        foreach ($item in $listBoxes.$currentCategory.Items) {
            if ($item.IsEnabled -and $item.Control) { $item.Control.IsChecked = $false }
        }
    })
    
    # Add programs under the category
    foreach ($record in ($detectedPrograms[$category].Values | Sort-Object DisplayName, Id)) {
        $checkBox = New-ListBoxControlItem -ControlType CheckBox -Text $record.DisplayName -Tag $record -TextForeground $surfaceText
        $checkBox.BorderThickness = 1
        if ($record.ToolTip) { $checkBox.ToolTip = $record.ToolTip }
        if (!$script:debloatIsAdministrator -and $record.RequiresAdmin) { Set-DebloatAdminRequired $checkBox }
        $checkBox.Foreground = $surfaceText
        $checkBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

        $listBox.Items.Add($checkbox) | Out-Null
    }
}

# Apps panel
# Import $apps hashtable
$appsHashtable = Join-Path $debloatTuneDependencies "Apps.ps1"
. $appsHashtable

# Variables needed in foreach loop
$detectedApps = @()
$packagesPath = Join-Path $env:LOCALAPPDATA "Packages"

# Iterate through $apps hashtable and search for apps
foreach ($app in $apps.Keys) {
    $packageName = $apps[$app]["PackageName"]
    $publisherId = $apps[$app]["PublisherId"]
    $appPath = Join-Path $packagesPath "$($packageName)_$($publisherId)"
    
    # Add app to detectedApps array if detected
    if ([IO.Directory]::Exists($appPath)) {
        $detectedApps += $app
        $apps[$app].UserDataDetected = Test-DebloatAppxUserData -Path $appPath
    }
}

# Create panel for apps
$appxListBox = $null
if ($detectedApps.Count -ge 1) {
    # Master checkbox
    $appxHeader = New-DebloatCategoryHeader -Text 'AppX Bloatware' -ToolTip 'Select catalog apps without detected app data. This is a heuristic; review before removal.'
    $appxCheckbox = $appxHeader.Control

    $appxListBox = New-Object System.Windows.Controls.ListBox
    $appxListBox.Margin = "10,5,0,5"
    $appxListBox.Style = $window.Resources["CustomListBoxStyle"]
    [Windows.Controls.ScrollViewer]::SetHorizontalScrollBarVisibility($appxListBox, 'Disabled')
    
    $uninstallPanel.Children.Add($appxHeader) | Out-Null
    $uninstallPanel.Children.Add($appxListBox) | Out-Null
    
    # Create individual checkboxes for all detected apps
    foreach ($detectedApp in $detectedApps) {
        $isImportant = $apps[$detectedApp]["Important"] -eq $true
        $isUserDataDetected = $apps[$detectedApp]["UserDataDetected"] -eq $true
        $trailingContent = @()
        $messages = @()
        if ($isImportant) {
            $icon = New-VectorIcon -Window $window -Icon 'PriorityHighIcon' -ForegroundResource 'warningText' -Size 14 -OpticalSize 20
            $icon.Margin = '6,0,2.5,0'
            [Windows.Automation.AutomationProperties]::SetName($icon, 'Potentially important app')
            $trailingContent += $icon
            $messages += 'Potentially important app.'
        }
        if ($isUserDataDetected) {
            $icon = New-VectorIcon -Window $window -Icon 'FolderOpenIcon' -ForegroundResource 'infoText' -Size 14 -OpticalSize 20
            $icon.Margin = '6,0,2.5,0'
            [Windows.Automation.AutomationProperties]::SetName($icon, 'Potential app data detected')
            $trailingContent += $icon
            $messages += 'Potential app data detected; it may be created automatically. Review before removal.'
        }
        if ($messages.Count) { $messages += 'Excluded from the AppX Bloatware select-all checkbox.' }
        $checkBox = New-ListBoxControlItem -ControlType CheckBox -Text $detectedApp -Tag $detectedApp -TextForeground $surfaceText -TrailingContent $trailingContent -ToolTip ($messages -join "`n")
        $checkBox.BorderThickness = 1
        $appxListBox.Items.Add($checkBox) | Out-Null
    }
    
    # Master checkbox - check event handler
    $appxCheckbox.Add_Checked({
        foreach ($item in $appxListBox.Items) {
            $important = $apps[$item.Control.Tag]["Important"]
            $userDataDetected = $apps[$item.Control.Tag]["UserDataDetected"]
            
            if ($item.IsEnabled -and ($important -ne $true) -and ($userDataDetected -ne $true)) {
                $item.Control.IsChecked = $true
            }
        }
    })
    
    # Master checkbox - uncheck event handler
    $appxCheckbox.Add_Unchecked({
        foreach ($item in $appxListBox.Items) {
            $item.Control.IsChecked = $false
        }
    })
}

    $emptyRows = @(for ($i = 0; $i -lt $uninstallPanel.Children.Count - 1; $i++) {
        $header = $uninstallPanel.Children[$i]
        if ($header -is [Windows.Controls.ListBoxItem] -and $header.Text.Text -like '* - None detected') {
            $header
            $uninstallPanel.Children[$i + 1]
        }
    })
    foreach ($row in $emptyRows) { $uninstallPanel.Children.Remove($row); [void]$uninstallPanel.Children.Add($row) }
    foreach ($name in 'customizationPanel','optimizationsListBox','optimizationsItems','listBoxes','apps','appxListBox','programs') {
        Set-Variable -Name $name -Value (Get-Variable -Name $name -ValueOnly) -Scope Script
    }
    foreach ($child in $uninstallPanel.Children) {
        if ($child -is [Windows.Controls.ListBox]) {
            foreach ($item in $child.Items) {
                if ($item.IsEnabled -and $item.Control -is [Windows.Controls.CheckBox] -and $selected[$item.Text.Text]) { $item.Control.IsChecked = $true }
            }
        }
    }
}
Add-AtomScrollViewerBehavior -Window $window -Name 'scrollViewer0'

$runButton.Tooltip = "- Perform selected optimizations `n- Uninstall selected apps"
$script:debloatRunState = [Hashtable]::Synchronized(@{ Running = $false; Complete = $false; CancelRequested = $false; Results = [Collections.Concurrent.ConcurrentQueue[string]]::new() })
function Update-DebloatResults {
    if (!$logSelector.SelectedItem) { $resultsText.Text = ''; return }
    try {
        $stream = [IO.File]::Open($logSelector.SelectedItem.FullName, 'Open', 'Read', 'ReadWrite')
        $reader = [IO.StreamReader]::new($stream)
        try { $resultsText.Text = $reader.ReadToEnd() } finally { $reader.Dispose() }
        $resultsBox.ScrollToEnd()
    } catch { $resultsText.Text = "Unable to load results: $($_.Exception.Message)" }
}
function Update-DebloatLogs {
    param([switch]$SelectNewest)
    $logSelector.ItemsSource = @(Get-ChildItem -LiteralPath $atomTemp -Filter 'debloat-and-tune-*.txt' -File | Sort-Object LastWriteTime,Name -Descending)
    $logSelector.SelectedIndex = if ($SelectNewest -and $logSelector.Items.Count) { 0 } else { -1 }
    $openLogButton.IsEnabled = $logSelector.SelectedIndex -ge 0
}
$logSelector.Add_SelectionChanged({
    $openLogButton.IsEnabled = $null -ne $logSelector.SelectedItem
    Update-DebloatResults
})
$openLogButton.Add_Click({
    if ($logSelector.SelectedItem) { Start-Process -FilePath notepad.exe -ArgumentList ('"' + $logSelector.SelectedItem.FullName + '"') }
})
Update-DebloatLogs

function Update-DebloatLayout {
$itemsPanel = [Windows.Markup.XamlReader]::Parse('<ItemsPanelTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"><WrapPanel Orientation="Horizontal" MaxWidth="880" HorizontalAlignment="Center"/></ItemsPanelTemplate>')
$descriptionPanel = [Windows.Markup.XamlReader]::Parse('<ItemsPanelTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"><WrapPanel Orientation="Horizontal" MaxWidth="1760" HorizontalAlignment="Center"/></ItemsPanelTemplate>')
$script:groups = @(for ($i = 1; $i -lt $uninstallPanel.Children.Count; $i++) {
    $list = $uninstallPanel.Children[$i]
    if ($list -isnot [Windows.Controls.ListBox]) { continue }
    $wideColumns = $script:debloatShowDescriptions -and ($list -eq $customizationPanel -or $list -eq $optimizationsListBox)
    $list.ItemsPanel = if ($wideColumns) { $descriptionPanel } else { $itemsPanel }
    $itemWidth = if ($wideColumns) { 439 } else { 219 }
    if ($list.ActualWidth -gt 0) { $itemWidth = [Math]::Min($itemWidth, [Math]::Max(1, $list.ActualWidth - 11)) }
    foreach ($item in $list.Items) {
        $item.Width = $itemWidth
        $item.Margin = 0.5
        if ($item.Description) {
            $item.Description.Visibility = if ($script:debloatShowDescriptions) { 'Visible' } else { 'Collapsed' }
            [Windows.Controls.ToolTipService]::SetIsEnabled($item, !$script:debloatShowDescriptions)
        }
    }
    [pscustomobject]@{ Header = $uninstallPanel.Children[$i - 1]; ListBox = $list }
})
$button = $window.FindName('descriptionButton')
$button.ToolTip = if ($script:debloatShowDescriptions) { 'Hide descriptions' } else { 'Show descriptions' }
[Windows.Automation.AutomationProperties]::SetName($button, $button.ToolTip)
$icon = if ($script:debloatShowDescriptions) { 'SubtitlesIcon' } else { 'SubtitlesOffIcon' }
Set-VectorIcon -Window $window -ResourceMappings @{ descriptionButton = $icon } -Filled:($script:debloatShowDescriptions)
}
Update-DebloatLayout
$uninstallPanel.Add_SizeChanged({
    if ($_.WidthChanged) { Update-DebloatLayout }
})
$window.FindName('scrollViewer0').Add_ScrollChanged({
    param($sender, $eventArgs)
    if ($eventArgs.ViewportWidthChange -ne 0) { Update-DebloatLayout }
})
$window.FindName('descriptionButton').Add_Click({
    $script:debloatShowDescriptions = !$script:debloatShowDescriptions
    Update-DebloatLayout
})
$searchTimer = [Windows.Threading.DispatcherTimer]::new()
$searchTimer.Interval = [TimeSpan]::FromMilliseconds(125)
$searchTimer.Add_Tick({
    $this.Stop()
    $query = $searchTextBox.Text.Trim()
    foreach ($group in $groups) {
        $heading = if ($group.Header -is [Windows.Controls.ListBoxItem]) { $group.Header.Text.Text } elseif ($group.Header -is [Windows.Controls.TextBlock]) { $group.Header.Text } else { [string]$group.Header.Content }
        $categoryMatches = $heading.IndexOf($query, [StringComparison]::OrdinalIgnoreCase) -ge 0
        $visible = 0
        foreach ($item in $group.ListBox.Items) {
            $matches = $categoryMatches -or $item.Text.Text.IndexOf($query, [StringComparison]::OrdinalIgnoreCase) -ge 0
            $item.Visibility = if ($matches) { $visible++; 'Visible' } else { 'Collapsed' }
        }
        $group.Header.Visibility = if ($visible -or (!$group.ListBox.Items.Count -and $categoryMatches)) { 'Visible' } else { 'Collapsed' }
        $group.ListBox.Visibility = if ($visible) { 'Visible' } else { 'Collapsed' }
    }
})
$searchTextBox.Add_TextChanged({
    $searchPlaceholder.Visibility = if ($searchTextBox.Text.Length) { 'Collapsed' } else { 'Visible' }
    $searchTimer.Stop(); $searchTimer.Start()
})
$window.FindName('clearSearchButton').Add_Click({ $searchTextBox.Clear(); $searchTextBox.Focus() })
$statusTimer = [Windows.Threading.DispatcherTimer]::new([Windows.Threading.DispatcherPriority]::Background)
$statusTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$statusTimer.Add_Tick({
    $line = $null
    $updated = $false
    while ($script:debloatRunState.Results.TryDequeue([ref]$line)) { $updated = $true }
    if ($updated -and $logSelector.SelectedItem.FullName -eq $script:debloatSessionLogPath) { Update-DebloatResults }
    $progress = $script:debloatRunState.Progress
    if ($progress) { $overallProgress.Value = $progress.Completed; $progressText.Text = if ($script:debloatRunState.CancelRequested -and !$script:debloatRunState.Complete) { 'Cancelling after the current action finishes...' } else { $progress.Text } }
    if ($script:debloatRunState.Complete) {
        $this.Stop()
        $cancelButton.Visibility = 'Collapsed'
        $window.FindName('runLabel').Text = 'Run selected actions'
        $runButton.IsEnabled = $true
        $uninstallPanel.IsEnabled = $true
        $script:debloatRunState.Running = $false
        Update-DebloatLogs -SelectNewest
        try {
            Update-DebloatView
            Update-DebloatLayout
            $searchTimer.Start()
        } catch { $progressText.Text += " Refresh failed: $($_.Exception.Message)" }
    }
})
$window.Add_Closed({ $statusTimer.Stop(); $searchTimer.Stop() })
$cancelButton.Add_Click({
    if (!$script:debloatRunState.Running -or $script:debloatRunState.Complete) { return }
    $script:debloatRunState.CancelRequested = $true
    $cancelButton.IsEnabled = $false
    $progressText.Text = 'Cancelling after the current action finishes...'
    Write-DebloatResults $progressText.Text
})
$runButton.Add_Click({
    if ($script:debloatRunState.Running) { return }

    # Capture data before dispatch; workers never read mutable selection controls.
    $queue = [Collections.Generic.List[Object]]::new()
    foreach ($item in $optimizationsListBox.Items) {
        if ($item.IsEnabled -and $item.Control.IsChecked) {
            $queue.Add([PSCustomObject]@{ Kind = 'Optimization'; Name = [String]$item.Text.Text; Id = [String]$item.Control.Tag })
        }
    }
    foreach ($list in $listBoxes.Values) {
        foreach ($item in $list.Items) {
            if ($item.IsEnabled -and $item.Control.IsChecked) {
                $record = $item.Control.Tag
                $queue.Add([PSCustomObject]@{
                    Kind = 'Program'
                    Name = $record.DisplayName
                    Target = $record.Target.PSObject.Copy()
                    Script = [String]$programs[$record.Definition].Uninstall
                    RequiresAdmin = $record.RequiresAdmin
                })
            }
        }
    }
    if ($appxListBox) {
        foreach ($item in $appxListBox.Items) {
            if ($item.IsEnabled -and $item.Control.IsChecked) {
                $queue.Add([PSCustomObject]@{ Kind = 'AppX'; Name = [String]$item.Control.Tag; PackageName = $apps[$item.Control.Tag].PackageName })
            }
        }
    }
    if (!$queue.Count) {
        $progressText.Text = 'Select at least one action to run.'
        return
    }

    $script:debloatRunState.Running = $true
    $script:debloatRunState.Complete = $false
    $script:debloatRunState.CancelRequested = $false
    $script:debloatRunState.LogError = $null
    $cancelButton.IsEnabled = $true
    $cancelButton.Visibility = 'Visible'
    $script:debloatRunState.Progress = @{ Completed = 0; Text = "0/$($queue.Count) actions finished" }
    $overallProgress.Maximum = $queue.Count
    $overallProgress.Value = 0
    $progressText.Text = $script:debloatRunState.Progress.Text
    $runButton.IsEnabled = $false
    $window.FindName('runLabel').Text = 'Running...'
    $uninstallPanel.IsEnabled = $false
    $statusTimer.Start()
    $runHeader = ('[{0}] Run' -f [DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss')) + [Environment]::NewLine
    $logPath = $script:debloatSessionLogPath
    try {
        Set-DebloatResultsExpanded -Expanded $true
        [IO.File]::AppendAllText($logPath, $runHeader)
        Update-DebloatLogs -SelectNewest
        $logSelector.SelectedItem = $logSelector.Items | Where-Object FullName -eq $logPath | Select-Object -First 1
        Invoke-Runspace -Isolated -InputVariables @{
            Queue = $queue.ToArray()
            LogPath = $logPath
            FunctionsPath = $functionsPath
            DependenciesPath = $debloatTuneDependencies
            RunState = $script:debloatRunState
        } -ScriptBlock {
            $ErrorActionPreference = 'Stop'
            $completed = 0
            $failed = 0
            $skipped = 0
            $attempted = 0
            $fatalError = $null
            function Write-Host {
                param([Parameter(ValueFromRemainingArguments)] [Object[]]$Object)
                $text = $Object -join ' '
                try { [IO.File]::AppendAllText($LogPath, $text + [Environment]::NewLine) }
                catch { $RunState.LogError = $_.Exception.Message }
                if ($null -ne $RunState.Results) { $RunState.Results.Enqueue($text) }
            }
            try {
                . (Join-Path $FunctionsPath 'Import-Atom.ps1') -Function Remove-App
                . (Join-Path $DependenciesPath 'Functions/Invoke-DebloatQueue.ps1')
                foreach ($action in $Queue) {
                    if ($RunState.CancelRequested) { break }
                    $attempted++
                    $RunState.Progress = @{ Completed = $attempted - 1; Text = "$($attempted - 1)/$($Queue.Count) actions finished - $($action.Name)" }
                    Write-Host $action.Name
                    try {
                        $result = Invoke-DebloatQueue -Queue @($action) -DependenciesPath $DependenciesPath -FunctionsPath $FunctionsPath
                        if ($result.Status -ne 'Succeeded') { throw $result.Output.Tasks[0].Summary }
                        if ($result.Output.SkippedTasks) {
                            $skipped++
                            Write-Host '- Skipped'
                        } else {
                            $completed++
                            Write-Host '- Completed'
                        }
                    } catch {
                        $failed++
                        Write-Host "- Failed: $($_.Exception.Message)"
                    } finally {
                        $RunState.Progress = @{ Completed = $attempted; Text = "$attempted/$($Queue.Count) actions finished" }
                    }
                }
            } catch {
                $fatalError = $_.Exception.Message
                Write-Host "Run stopped: $fatalError"
            } finally {
                $notRun = $Queue.Count - $attempted
                $summary = "$completed completed; $failed failed; $skipped skipped; $notRun not run."
                if ($RunState.CancelRequested -and $notRun) { $summary = "Cancelled. $summary" }
                if ($fatalError) { $summary += " Run error: $fatalError" }
                if ($RunState.LogError) { $summary += " Could not save log: $($RunState.LogError)" }
                $RunState.Progress = @{ Completed = $attempted; Text = $summary }
                Write-Host $summary
                if (!$RunState.LogError) {
                    Write-Host "`nLog saved to $LogPath"
                }
                $RunState.Complete = $true
            }
        }
    } catch {
        $message = "Unable to start run: $($_.Exception.Message)"
        try {
            [IO.File]::AppendAllText($logPath, $message + [Environment]::NewLine)
            $message += "`nLog saved to $logPath"
        } catch { $message += "`nCould not save log: $($_.Exception.Message)" }
        finally {
            $statusTimer.Stop()
            $progressText.Text = $message
            Write-DebloatResults $message
            Update-DebloatLogs -SelectNewest
            $cancelButton.Visibility = 'Collapsed'
            $window.FindName('runLabel').Text = 'Run selected actions'
            $runButton.IsEnabled = $true
            $uninstallPanel.IsEnabled = $true
            $script:debloatRunState.Running = $false
        }
    }
})

Set-WindowSize

$script:debloatViewInitializationStarted = $false
$window.Add_ContentRendered({
    if ($script:debloatViewInitializationStarted) { return }
    $script:debloatViewInitializationStarted = $true
    $window.Dispatcher.BeginInvoke([Action]{
        try {
            Update-DebloatView
            Update-DebloatLayout
            $searchTimer.Start()
            $progressText.Text = 'Select actions to run'
            $window.FindName('loadingText').Visibility = 'Collapsed'
            $runButton.IsEnabled = $true
        } catch {
            $progressText.Text = "Unable to load settings and apps: $($_.Exception.Message)"
            $window.FindName('loadingText').Text = 'Unable to load settings and apps.'
        }
    }, [Windows.Threading.DispatcherPriority]::ApplicationIdle) | Out-Null
})

$window.ShowDialog() | Out-Null

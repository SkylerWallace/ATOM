Add-Type -AssemblyName PresentationFramework

# Import module(s)
. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Get-AtomProgramIcons','Add-AtomScrollViewerBehavior','Install-Choco','Install-Program','Install-Scoop','Invoke-Runspace','New-AtomWindow','New-ListBoxControlItem','Set-VectorIcon','Set-WindowSize' -Feature Context,Wpf
$bulkAppInstallerDependencies = "$psScriptRoot\Bulk App Installer"
$programIcons        = "$resourcesPath\Icons\Program Icons"
$hashtable           = "$bulkAppInstallerDependencies\Programs.ps1"
$programPanelTemplate = [Windows.Markup.XamlReader]::Parse(@'
<ItemsPanelTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
    <WrapPanel Orientation="Horizontal" MaxWidth="880" HorizontalAlignment="Center"/>
</ItemsPanelTemplate>
'@)
$descriptionPanelTemplate = [Windows.Markup.XamlReader]::Parse('<ItemsPanelTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"><WrapPanel Orientation="Horizontal" MaxWidth="1760" HorizontalAlignment="Center"/></ItemsPanelTemplate>')
# Avoid applying a shadow to the whole scrolling list on every hover repaint.
$programListTemplate = [Windows.Markup.XamlReader]::Parse(@'
<ControlTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" TargetType="ListBox">
    <Border CornerRadius="5" Padding="5" Background="{DynamicResource surfaceListBrush}">
        <ItemsPresenter Name="ProgramPresenter"/>
    </Border>
</ControlTemplate>
'@)

$contentXaml = @"
<Grid>
    <Grid>
        <ScrollViewer Name="scrollViewer0" HorizontalScrollBarVisibility="Disabled" VerticalScrollBarVisibility="Visible" Style="{StaticResource CustomScrollViewerStyle}">
            <StackPanel>
                <Border Height="{Binding ActualHeight, ElementName=floatingControls}" Margin="0,10,0,5"/>
                <StackPanel Name="installPanel" Margin="0,0,10,5"/>
                <Border Height="48"/>
            </StackPanel>
        </ScrollViewer>
        <StackPanel Name="floatingControls" Panel.ZIndex="10" VerticalAlignment="Top" Margin="10,10,28,5">
        <Border Name="searchBar" Style="{StaticResource CustomBorder}" Padding="5">
            <Grid>
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <Button Name="backspaceButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Clear search"/>
                <ContentControl Name="searchImage" Grid.Column="1" Opacity="0.38" Width="16" Height="16"/>
                <TextBlock Name="searchTextBlock" Grid.Column="2" Text="Search" Foreground="{DynamicResource surfaceText}" Opacity="0.69" VerticalAlignment="Center" Margin="5" IsHitTestVisible="False"/>
                <TextBox Name="searchTextBox" Grid.Column="2" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" VerticalAlignment="Center" Margin="5"/>
                <Button Name="descriptionButton" Grid.Column="3" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Hide descriptions"/>
                <Button Name="sortButton" Grid.Column="4" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                <Grid Grid.Row="1" Grid.ColumnSpan="5" Height="2" Margin="5,2">
                    <Border Height="1" Background="{DynamicResource surfaceText}" Opacity="0.44"/>
                    <ProgressBar Name="installProgress" Height="2" Minimum="0" Maximum="100" Value="0" Background="Transparent" Foreground="{DynamicResource surfaceText}" IsHitTestVisible="False"/>
                </Grid>
                <TextBlock Name="installStatus" Grid.Row="2" Grid.ColumnSpan="5" Text="Select programs to install" Foreground="{DynamicResource surfaceText}" FontSize="10" Margin="5" TextWrapping="Wrap"/>
            </Grid>
        </Border>
                <Border Style="{StaticResource CustomBorder}" Margin="0,10,0,0" Padding="5">
                    <StackPanel>
                    <Grid Name="installOptionsHost" Margin="0,0,0,5">
                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                    </Grid>
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
            <StackPanel.Effect>
                <DropShadowEffect Color="{DynamicResource shadowColor}" Opacity="{DynamicResource shadowOpacity}" BlurRadius="{DynamicResource shadowBlur}" ShadowDepth="{DynamicResource shadowDepth}" Direction="{DynamicResource shadowDirection}"/>
            </StackPanel.Effect>
            <Button Name="cancelButton" Height="28" Padding="10,3" Margin="0,0,6,0" Foreground="{DynamicResource onErrorText}" Background="{DynamicResource errorBrush}" Style="{StaticResource RoundedButton}" Visibility="Collapsed" ToolTip="Finish the current action, then stop the run">
                <Border Padding="{Binding Padding, RelativeSource={RelativeSource AncestorType=Button}}"><StackPanel Orientation="Horizontal">
                    <ContentControl Width="16" Height="16" Style="{StaticResource VectorIconStyle}" Content="{StaticResource CloseIcon}" Foreground="{DynamicResource onErrorText}" Margin="0,0,6,0" VerticalAlignment="Center"/>
                    <TextBlock Text="Cancel" VerticalAlignment="Center"/>
                </StackPanel></Border>
            </Button>
            <Button Name="runButton" Height="28" MinWidth="90" Padding="10,3" Background="{DynamicResource controlBrush}" Foreground="{DynamicResource controlText}" Style="{StaticResource RoundedButton}">
                <Border Padding="{Binding Padding, RelativeSource={RelativeSource AncestorType=Button}}"><StackPanel Orientation="Horizontal">
                    <ContentControl Width="16" Height="16" Style="{StaticResource VectorIconStyle}" Content="{StaticResource PlayArrowIcon}" Foreground="{DynamicResource controlText}" Margin="0,0,6,0" VerticalAlignment="Center"/>
                    <TextBlock Name="runLabel" Text="Install selected programs" VerticalAlignment="Center"/>
                </StackPanel></Border>
            </Button>
        </StackPanel>
    </Grid>
</Grid>
"@

$windowParameters = @{
    Title       = 'Bulk App Installer'
    IconPath    = "$bulkAppInstallerDependencies\Bulk App Installer.png"
    ContentXaml = $contentXaml
    Width       = 487
    Height      = 600
    MinWidth    = 400
    MinHeight   = 400
}
$window = New-AtomWindow @windowParameters
# Assign variables to elements in XAML
$runButton          = $window.Findname('runButton')
$installPanel       = $window.FindName('installPanel')
$searchTextBlock    = $window.FindName('searchTextBlock')
$searchTextBox      = $window.FindName('searchTextBox')
$installOptionsHost = $window.FindName('installOptionsHost')
$installProgress    = $window.FindName('installProgress')
$installStatus      = $window.FindName('installStatus')
$cancelButton = $window.FindName('cancelButton')
$resultsBox = $window.FindName('resultsBox')
$resultsText = $window.FindName('resultsText')
$openLogButton = $window.FindName('openLogButton')
$script:bulkShowDescriptions = $false
$script:bulkSessionLogPath = Join-Path $atomTemp ('bulk-app-installer-' + [DateTime]::Now.ToString('yyyyMMdd-HHmmss-fffffff') + '.txt')
$bulkInstallState = [Hashtable]::Synchronized(@{
    Running = $false
    Complete = $false
    CancelRequested = $false
    CloseRequested = $false
    LogError = $null
    Results = [Collections.Concurrent.ConcurrentQueue[string]]::new()
})
$installMethodItem = New-ListBoxControlItem -ControlType ComboBox -ControlAlignment Right -ControlOptions ([ordered]@{
    'Automatic' = 'Automatic'
    'WinGet' = 'WinGet'
    'Choco' = 'Choco'
    'Scoop' = 'Scoop'
    'URL' = 'URL'
}) -SelectedValue 'Automatic' -ControlStyle $window.FindResource('CustomComboBox') -ControlWidth 100 -Text 'Install method' -ToolTip 'Choose how selected programs are installed'
$installMethodItem.Width = 200
$installMethodItem.HorizontalAlignment = 'Left'
$installMethodItem.Margin = 0
$installMethodItem.BorderThickness = 1
$installMethodItem.Text.Margin = '4,0,10,0'
$installMethodItem.MinHeight = 30
$installMethodItem.VerticalContentAlignment = 'Center'
$installMethodItem.Text.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
$installOptionsHost.Children.Add($installMethodItem) | Out-Null
$methodComboBox = $installMethodItem.Control
$directFallbackItem = New-ListBoxControlItem -ControlType ToggleButton -ControlAlignment Right -Text 'Direct fallback' -Tag 'AllowWinGetDirect' -ToolTip 'Allow unverified direct downloads from WinGet metadata if installation fails. Hash mismatches still require confirmation.'
$directFallbackItem.Width = 145
$directFallbackItem.Margin = 0
$directFallbackItem.BorderThickness = 1
$directFallbackItem.HorizontalAlignment = 'Right'
[Windows.Controls.Grid]::SetColumn($directFallbackItem, 1)
$directFallbackItem.MinHeight = 30
$directFallbackItem.Text.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
$installOptionsHost.Children.Add($directFallbackItem) | Out-Null
$directFallbackToggle = $directFallbackItem.Control
$script:selectedMethod = 'Automatic'
$directFallbackItem.Visibility = 'Visible'
$logsItem = New-ListBoxControlItem -ControlType ComboBox -ControlOptions @{} -ControlAlignment Right -ControlWidth ([double]::NaN) -ControlStyle $window.FindResource('CustomComboBox') -Text 'Logs' -TextForeground $surfaceText
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

function Update-BulkResults {
    if (!$logSelector.SelectedItem) { $resultsText.Text = ''; return }
    try {
        $stream = [IO.File]::Open($logSelector.SelectedItem.FullName, 'Open', 'Read', 'ReadWrite')
        $reader = [IO.StreamReader]::new($stream)
        try { $resultsText.Text = $reader.ReadToEnd() } finally { $reader.Dispose() }
        $resultsBox.ScrollToEnd()
    } catch { $resultsText.Text = "Unable to load results: $($_.Exception.Message)" }
}

function Update-BulkLogs {
    param([switch]$SelectNewest)
    $logSelector.ItemsSource = @(Get-ChildItem -LiteralPath $atomTemp -Filter 'bulk-app-installer-*.txt' -File | Sort-Object LastWriteTime,Name -Descending)
    $logSelector.SelectedIndex = if ($SelectNewest -and $logSelector.Items.Count) { 0 } else { -1 }
    $openLogButton.IsEnabled = $logSelector.SelectedIndex -ge 0
}

function Set-BulkResultsExpanded {
    param([bool]$Expanded)
    $resultsBox.Visibility = if ($Expanded) { 'Visible' } else { 'Collapsed' }
    $window.FindName('resultsToggleButton').ToolTip = if ($Expanded) { 'Collapse results' } else { 'Expand results' }
    Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ resultsIndicator = $(if ($Expanded) { 'ArrowDropUpIcon' } else { 'ArrowDropDownIcon' }) }
    $resultsBox.ScrollToEnd()
}

$logSelector.Add_SelectionChanged({
    $openLogButton.IsEnabled = $null -ne $logSelector.SelectedItem
    Update-BulkResults
})
$openLogButton.Add_Click({
    if ($logSelector.SelectedItem) { Start-Process -FilePath notepad.exe -ArgumentList ('"' + $logSelector.SelectedItem.FullName + '"') }
})
$window.FindName('resultsToggleButton').Add_Click({ Set-BulkResultsExpanded -Expanded ($resultsBox.Visibility -ne 'Visible') })
$resultsBox.Add_ScrollChanged({
    param($sender, $eventArgs)
    if ($eventArgs.ExtentHeightChange -ne 0 -or $eventArgs.ViewportHeightChange -ne 0) { $sender.ScrollToEnd() }
})
Update-BulkLogs

# Set icon sources
Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{
    'backspaceButton' = 'BackspaceIcon'
    'searchImage' = 'SearchIcon'
    'sortButton' = 'CategoryIcon'
    'resultsIndicator' = 'ArrowDropDownIcon'
}

# Programs panel

# Pull programs hashtable
. $hashtable

$selectedPrograms = @{}
$script:programSortMode = 'Category'
$script:programItems = @{}
$script:programGroups = @()
$script:programImageRequests = [Collections.Generic.List[Object]]::new()
$script:programImageResults = [Collections.Concurrent.ConcurrentQueue[Object]]::new()
$script:programImageState = [Hashtable]::Synchronized(@{ Closed = $false; Complete = $false })
$script:programImageTargets = @{}
$script:programEntries = @($installPrograms.GetEnumerator() | Sort-Object Key | ForEach-Object {
    [PSCustomObject]@{ Name = $_.Key; Info = $_.Value }
})
$script:programIconNames = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($name in (Get-AtomProgramIcons -Directory $programIcons).Keys) {
    [void]$script:programIconNames.Add([IO.Path]::GetFileNameWithoutExtension($name))
}

function Import-Programs {
    param (
        [ValidateSet('Category', 'Alphabetical')]
        [String]$SortMode = $script:programSortMode
    )

    # Detach retained controls before moving them to a different category list.
    foreach ($group in $script:programGroups) { $group.ListBox.Items.Clear() }
    $installPanel.Children.Clear()
    $script:programGroups = [Collections.Generic.List[Object]]::new()

    $programs = foreach ($entry in $script:programEntries) {
        [PSCustomObject]@{
            Name          = $entry.Name
            Info          = $entry.Info
            GroupCategory = if ($SortMode -eq 'Alphabetical') { 'All Programs' } else { $entry.Info.Category }
        }
    }

    foreach ($group in ($programs | Group-Object GroupCategory | Sort-Object Name)) {
        $category = $group.Name

        $textBlock = New-Object System.Windows.Controls.TextBlock
        $textBlock.Text = $category
        $textBlock.FontWeight = 'Bold'
        $textBlock.Foreground = $backgroundText
        $textBlock.Margin = '10,5,0,0'
        $textBlock.Tag = $category
        $installPanel.Children.Add($textBlock) | Out-Null

        $listBox = New-Object System.Windows.Controls.ListBox
        $listBox.Background = $surfaceBrush
        $listBox.Foreground = $surfaceText
        $listBox.BorderThickness = 0
        $listBox.Margin = '10,5,0,5'
        $listBox.Style = $window.Resources['CustomListBoxStyle']
        $listBox.Template = $programListTemplate
        $listBox.ItemsPanel = $programPanelTemplate
        $listBox | Add-Member -NotePropertyName ProgramItems -NotePropertyValue ([Collections.Generic.List[Object]]::new())
        [Windows.Controls.ScrollViewer]::SetHorizontalScrollBarVisibility($listBox, 'Disabled')
        $listBox.Tag = $category
        $installPanel.Children.Add($listBox) | Out-Null
        $script:programGroups.Add([PSCustomObject]@{ Header = $textBlock; ListBox = $listBox })

        foreach ($entry in $group.Group) {
            $program = $entry.Name
            $programInfo = $entry.Info
            if ($script:programItems.ContainsKey($program)) {
                $listBoxItem = $script:programItems[$program]
                $listBoxItem.Visibility = 'Visible'
                $listBox.ProgramItems.Add($listBoxItem)
                [void]$listBox.Items.Add($listBoxItem)
                continue
            }
            $iconPath = "$programIcons\$program.png"

            if (!$script:programIconNames.Contains($program)) {
                $firstLetter = $program.Substring(0,1)
                $iconPath =
                    if ($firstLetter -match '^[A-Z]') { "$resourcesPath\Icons\Default\$firstLetter.png" }
                    else { "$resourcesPath\Icons\Default\#.png" }
            }

            $listBoxItemParams = @{
                DeferImageLoad = $true
                ControlType = 'CheckBox'
                Text = $program
                Description = if ($programInfo.Description) { $programInfo.Description } else { $programInfo.ToolTip }
                TextForeground = $surfaceText
                ImageSource = $iconPath
                Tag = $program, $programInfo
                ToolTip =
                    if ($atomSettings.ShowToolTips.Value -and $programInfo.ToolTip) { $programInfo.ToolTip }
                    else { $null }
            }

            $listBoxItem = New-ListBoxControlItem @listBoxItemParams
            $listBoxItem.Width = 219
            $listBoxItem.Margin = 0.5
            # Reserve the hover border so IsMouseOver does not invalidate layout.
            $listBoxItem.BorderThickness = 1
            $listBoxItem.BorderBrush = 'Transparent'
            $script:programImageTargets[$program] = $listBoxItem.Image
            $script:programImageRequests.Add([PSCustomObject]@{ Name = $program; Path = $iconPath })
            $listBoxItem.DataContext = $program
            $listBoxItem.Control.IsChecked = $selectedPrograms.ContainsKey($program)
            $listBoxItem.Control.Add_Checked({ $selectedPrograms[$this.Tag[0]] = $this.Tag[1] })
            $listBoxItem.Control.Add_Unchecked({ $selectedPrograms.Remove($this.Tag[0]) })
            $script:programItems[$program] = $listBoxItem
            $listBox.ProgramItems.Add($listBoxItem)
            [void]$listBox.Items.Add($listBoxItem)
        }
    }

    Update-Checkboxes
    Update-BulkLayout
}

function Update-BulkLayout {
    foreach ($group in $script:programGroups) {
        $list = $group.ListBox
        $list.ItemsPanel = if ($script:bulkShowDescriptions) { $descriptionPanelTemplate } else { $programPanelTemplate }
        $itemWidth = if ($script:bulkShowDescriptions) { 439 } else { 219 }
        if ($list.ActualWidth -gt 0) { $itemWidth = [Math]::Min($itemWidth, [Math]::Max(1, $list.ActualWidth - 11)) }
        foreach ($item in $list.ProgramItems) {
            $item.Width = $itemWidth
            if ($item.Description) { $item.Description.Visibility = if ($script:bulkShowDescriptions) { 'Visible' } else { 'Collapsed' } }
            [Windows.Controls.ToolTipService]::SetIsEnabled($item, !$script:bulkShowDescriptions)
        }
    }
    $button = $window.FindName('descriptionButton')
    $button.ToolTip = if ($script:bulkShowDescriptions) { 'Hide descriptions' } else { 'Show descriptions' }
    [Windows.Automation.AutomationProperties]::SetName($button, $button.ToolTip)
    Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ descriptionButton = $(if ($script:bulkShowDescriptions) { 'SubtitlesIcon' } else { 'SubtitlesOffIcon' }) } -Filled:($script:bulkShowDescriptions)
}
$window.FindName('descriptionButton').Add_Click({
    $script:bulkShowDescriptions = !$script:bulkShowDescriptions
    Update-BulkLayout
})
$installPanel.Add_SizeChanged({ if ($_.WidthChanged) { Update-BulkLayout } })
$window.FindName('scrollViewer0').Add_ScrollChanged({ if ($_.ViewportWidthChange -ne 0) { Update-BulkLayout } })

# Search bar controls
$searchTextBlock = $window.FindName('searchTextBlock')
$searchTextBox   = $window.FindName('searchTextBox')
$backspaceButton = $window.FindName('backspaceButton')
$sortButton      = $window.FindName('sortButton')

function Clear-SearchTextBox {
    $searchTextBox.Clear()
    $searchTextBox.Focus()
    $backspaceButton.Focus()
}

$backspaceButton.ToolTip = 'Clear search box'
$backspaceButton.Add_Click({ Clear-SearchTextBox })

$searchTextBox.Add_GotFocus({
    if ($searchTextBlock.Visibility -eq 'Visible') { $searchTextBlock.Visibility = 'Collapsed' }
})

$searchTextBox.Add_LostFocus({
    if ($searchTextBox.Text -eq '') { $searchTextBlock.Visibility = 'Visible' }
})

$searchTimer = [System.Windows.Threading.DispatcherTimer]::new()
$searchTimer.Interval = [TimeSpan]::FromMilliseconds(125)
$searchTimer.Add_Tick({
    $this.Stop()
    $searchText = $searchTextBox.Text

    foreach ($group in $script:programGroups) {
        $listBox = $group.ListBox
        $anyVisibleItems = $false

        foreach ($item in $listBox.ProgramItems) {
            $isVisible = ([String]$item.DataContext).IndexOf($searchText, [StringComparison]::OrdinalIgnoreCase) -ge 0
            $visibility = if ($isVisible) { 'Visible' } else { 'Collapsed' }
            if ($item.Visibility -ne $visibility) {
                $item.Visibility = $visibility
            }
            if ($isVisible) { $anyVisibleItems = $true }
        }

        $visibility = if ($anyVisibleItems) { 'Visible' } else { 'Collapsed' }
        $group.Header.Visibility = $visibility
        $listBox.Visibility = $visibility
    }
})

$searchTextBox.Add_TextChanged({
    $searchTimer.Stop()
    $searchTimer.Start()
})

# Program sort button
$sortButton.ToolTip = 'Sort alphabetically'
$sortButton.Add_Click({
    Clear-SearchTextBox

    if ($script:programSortMode -eq 'Alphabetical') {
        $script:programSortMode = 'Category'
        $sortButton.ToolTip = 'Sort alphabetically'
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'sortButton' = 'CategoryIcon' }
    } else {
        $script:programSortMode = 'Alphabetical'
        $sortButton.ToolTip = 'Sort by category'
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'sortButton' = 'TextDescendingIcon' }
    }

    Import-Programs
})

# 'Install method' checkboxes
function Update-Checkboxes {
    foreach ($listBoxItem in $script:programItems.Values) {
        $programInfo = $listBoxItem.Control.Tag[1]
        $isEnabled = if ($script:selectedMethod -eq 'Automatic') { [Boolean]($programInfo.WinGet -or $programInfo.Choco -or $programInfo.Scoop -or $programInfo.Url) } else { [Boolean]$programInfo[$script:selectedMethod] }
        if ($listBoxItem.IsEnabled -ne $isEnabled) {
            $listBoxItem.IsEnabled = $isEnabled
            $listBoxItem.Opacity = if ($isEnabled) { 1 } else { 0.44 }
        }
        if (!$isEnabled -and $listBoxItem.Control.IsChecked) { $listBoxItem.Control.IsChecked = $false }
    }
}

$methodComboBox.Add_SelectionChanged({
    $selectedItem = $methodComboBox.SelectedItem
    if (!$selectedItem) { return }
    $script:selectedMethod = [String]$selectedItem.Tag
    $allowFallback = $script:selectedMethod -in 'Automatic', 'WinGet'
    $directFallbackItem.IsEnabled = $allowFallback
    $directFallbackItem.Opacity = if ($allowFallback) { 1 } else { 0.44 }
    Update-Checkboxes
})

# Construct program list and update checkbox statuses
Import-Programs

$programImageTimer = [Windows.Threading.DispatcherTimer]::new([Windows.Threading.DispatcherPriority]::Background)
$programImageTimer.Interval = [TimeSpan]::FromMilliseconds(1)
$programImageTimer.Add_Tick({
    for ($i = 0; $i -lt 24; $i++) {
        $result = $null
        if (!$script:programImageResults.TryDequeue([ref]$result)) {
            if ($script:programImageState.Complete) { $this.Stop() }
            return
        }
        if ($result.Source) { $script:programImageTargets[$result.Name].Source = $result.Source }
        elseif ($result.Error) { Write-Warning "Unable to load program icon '$($result.Name)': $($result.Error)" }
    }
})
Invoke-Runspace -Isolated -InputVariables @{
    Requests = $script:programImageRequests.ToArray()
    Results = $script:programImageResults
    State = $script:programImageState
    ImageFunctionsPath = "$functionsPath/WPF"
} -ScriptBlock {
    try {
        Add-Type -AssemblyName PresentationFramework
        . "$ImageFunctionsPath/Get-AtomProgramIcons.ps1"
        . "$ImageFunctionsPath/Get-CachedImage.ps1"
        foreach ($request in $Requests) {
            if ($State.Closed) { break }
            $bitmap = $null
            $errorMessage = $null
            try {
                $bitmap = Get-CachedImage -Path $request.Path
            } catch { $bitmap = $null; $errorMessage = $_.Exception.Message }
            if (!$State.Closed) {
                $Results.Enqueue([PSCustomObject]@{ Name = $request.Name; Source = $bitmap; Error = $errorMessage })
            }
        }
    } finally { $State.Complete = $true }
}
$script:programImageRequests.Clear()
$programImageTimer.Start()

Add-AtomScrollViewerBehavior -Window $window -Name 'scrollViewer0'

function Complete-BulkInstallation {
    $installTimer.Stop()
    $bulkInstallState.Running = $false
    $installStatus.Text = $bulkInstallState.Summary
    $installProgress.IsIndeterminate = $false
    $window.FindName('runLabel').Text = 'Install selected programs'
    $runButton.IsEnabled = $true
    $installPanel.IsEnabled = $true
    $sortButton.IsEnabled = $true
    $installOptionsHost.IsEnabled = $true
    $cancelButton.Visibility = 'Collapsed'
    Update-BulkLogs -SelectNewest
    if ($bulkInstallState.CloseRequested) { $window.Close() }
}
$installTimer = [Windows.Threading.DispatcherTimer]::new([Windows.Threading.DispatcherPriority]::Background)
$installTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$installTimer.Add_Tick({
    $updated = $false
    $line = $null
    while ($bulkInstallState.Results.TryDequeue([ref]$line)) { $updated = $true }
    if ($updated -and $logSelector.SelectedItem.FullName -eq $script:bulkSessionLogPath) { Update-BulkResults }
    if ($bulkInstallState.Complete) { Complete-BulkInstallation }
})
$cancelButton.ToolTip = 'Finish the current program, then stop the remaining installations'
$cancelButton.Add_Click({
    if (!$bulkInstallState.Running) { return }
    $bulkInstallState.CancelRequested = $true
    $cancelButton.IsEnabled = $false
    $installStatus.Text = 'Cancellation requested; finishing the current program...'
})
$window.Add_Closing({
    param($sender, $eventArgs)
    if ($bulkInstallState.Running) {
        $eventArgs.Cancel = $true
        $bulkInstallState.CloseRequested = $true
        $cancelButton.RaiseEvent([Windows.RoutedEventArgs]::new([Windows.Controls.Primitives.ButtonBase]::ClickEvent))
    }
})

$runButton.Tooltip = "Install selected programs"
$runButton.Add_Click({
    if ($bulkInstallState.Running) { return }
    if (!$selectedPrograms.Count) {
        $installStatus.Text = 'Select at least one program to install'
        return
    }
    $script:installQueue = $selectedPrograms.Clone()
    $script:runMethod = $script:selectedMethod
    $script:allowWinGetDirect = $runMethod -in 'Automatic', 'WinGet' -and $directFallbackToggle.IsChecked
    $bulkInstallState.Running = $true
    $bulkInstallState.Complete = $false
    $bulkInstallState.CancelRequested = $false
    $bulkInstallState.CloseRequested = $false
    $bulkInstallState.LogError = $null
    $cancelButton.IsEnabled = $true
    $cancelButton.Visibility = 'Visible'
    $runButton.IsEnabled = $false
    $window.FindName('runLabel').Text = 'Installing...'
    $installPanel.IsEnabled = $false
    $sortButton.IsEnabled = $false
    $installOptionsHost.IsEnabled = $false
    $installProgress.Value = 0
    $installProgress.IsIndeterminate = $true
    $installStatus.Text = 'Preparing package managers...'
    try {
        Set-BulkResultsExpanded -Expanded $true
        [IO.File]::AppendAllText($script:bulkSessionLogPath, ('[{0}] Run' -f [DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss')) + [Environment]::NewLine)
        Update-BulkLogs -SelectNewest
        $logSelector.SelectedItem = $logSelector.Items | Where-Object FullName -eq $script:bulkSessionLogPath | Select-Object -First 1
        $installTimer.Start()
        Invoke-Runspace -InputVariables @{ LogPath = $script:bulkSessionLogPath; BulkInstallState = $bulkInstallState } -ScriptBlock {
            $completed = 0
            $failed = 0
            $fatalError = $null
            function Write-Host {
                param([Parameter(ValueFromRemainingArguments)][Object[]]$Object)
                $text = $Object -join ' '
                try { [IO.File]::AppendAllText($LogPath, $text + [Environment]::NewLine) }
                catch { $bulkInstallState.LogError = $_.Exception.Message }
                $bulkInstallState.Results.Enqueue($text)
                Invoke-Ui {
                    if (![String]::IsNullOrWhiteSpace($text) -and !$bulkInstallState.CancelRequested) { $installStatus.Text = $text.Trim() }
                }
            }
            function Install-BulkProgram {
                param([String]$FilePath, [String]$ArgumentList, [Alias('Url')][String]$Uri, [String]$Description)
                Invoke-Ui { $installStatus.Text = "$($completed + 1)/$($installQueue.Count): $program - $Description"; $installProgress.IsIndeterminate = $true }
                $script:lastInstallResult = @{ ExitCode = $null }
                $arguments = @{ Description = $Description; Result = $script:lastInstallResult }
                if ($Uri) { $arguments.Uri = $Uri } else { $arguments.FilePath = $FilePath; $arguments.ArgumentList = $ArgumentList }
                try { Install-Program @arguments -ErrorAction Stop }
                catch { Write-Host "$program - $Description failed: $($_.Exception.Message)"; return $false }
                finally { Invoke-Ui { $installProgress.IsIndeterminate = $false } }
            }
            function Install-BulkWinGetPackage {
                param([String]$Id)
                $script:lastInstallResult = @{ ExitCode = $null }
                try {
                    $adapter = [Atom.WinGet.PackageAdapter]::new()
                    Invoke-Ui { $installStatus.Text = "$program - WinGet"; $installProgress.IsIndeterminate = $true }
                    $adapter.Install($Id, $false)
                    do {
                        $record = $null
                        while ($adapter.Progress.TryDequeue([ref]$record)) {
                            Invoke-Ui {
                                $installProgress.IsIndeterminate = $record.Percent -lt 0
                                if ($record.Percent -ge 0) { $installProgress.Value = $record.Percent }
                                if (!$bulkInstallState.CancelRequested) {
                                    $installStatus.Text = "$program - $($record.State)"
                                    if ($record.BytesRequired -gt 0) { $installStatus.Text += ' {0:N0}% ({1:N1} / {2:N1} MB)' -f $record.Percent, ($record.BytesDownloaded / 1MB), ($record.BytesRequired / 1MB) }
                                }
                            }
                        }
                        if (!$adapter.Complete) { Start-Sleep -Milliseconds 100 }
                    } while (!$adapter.Complete -or !$adapter.Progress.IsEmpty)
                    $result = $adapter.Result
                    $script:lastInstallResult.ExitCode = $result.ErrorCode
                    if (!$result.InstallationStarted -and !$result.Succeeded) {
                        Write-Host "$program - WinGet API unavailable: $($result.Message); using CLI."
                        return Install-BulkProgram -FilePath 'winget' -ArgumentList "install --id $Id --exact --accept-package-agreements --accept-source-agreements" -Description 'WinGet'
                    }
                    Write-Host "$program - WinGet: $($result.Status)"
                    if (!$result.Succeeded) { Write-Host "Error: $($result.ErrorCode); installer error: $($result.InstallerErrorCode) $($result.Message)" }
                    if ($result.RebootRequired) { Write-Host '- Restart required' }
                    return $result.Succeeded
                } catch {
                    $script:lastInstallResult.ExitCode = $_.Exception.HResult
                    Write-Host "$program - WinGet failed: $($_.Exception.Message)"
                    return $false
                } finally { Invoke-Ui { $installProgress.IsIndeterminate = $false } }
            }
            function Install-BulkWinGetModulePackage {
                param([String]$Id)
                $script:lastInstallResult = @{ ExitCode = $null }
                try {
                    $winGetModuleWorker.Commands.Clear()
                    $winGetModuleWorker.Streams.ClearStreams()
                    $null = $winGetModuleWorker.AddScript({
                        param($packageId)
                        $ProgressPreference = 'Continue'
                        $result = Install-WinGetPackage -Id $packageId -Source winget -MatchOption EqualsCaseInsensitive -Mode Default -ErrorAction Stop
                        if (!$result) { throw 'WinGet did not return an installation result.' }
                        [PSCustomObject]@{
                            Status = $result.Status
                            Succeeded = $result.Succeeded()
                            ErrorCode = if ($result.ExtendedErrorCode) { $result.ExtendedErrorCode.HResult } else { 0 }
                            InstallerErrorCode = $result.InstallerErrorCode
                            RebootRequired = $result.RebootRequired
                        }
                    }).AddArgument($Id)
                    Invoke-Ui { $installStatus.Text = "$program - WinGet"; $installProgress.IsIndeterminate = $true }
                    $handle = $winGetModuleWorker.BeginInvoke()
                    $progressIndex = 0
                    do {
                        while ($progressIndex -lt $winGetModuleWorker.Streams.Progress.Count) {
                            $record = $winGetModuleWorker.Streams.Progress[$progressIndex++]
                            if ($record.RecordType -eq 'Completed') { continue }
                            Invoke-Ui {
                                $installProgress.IsIndeterminate = $record.PercentComplete -lt 0
                                if ($record.PercentComplete -ge 0) { $installProgress.Value = $record.PercentComplete }
                                if (!$bulkInstallState.CancelRequested) { $installStatus.Text = "$program - $($record.StatusDescription)" }
                            }
                        }
                        if (!$handle.IsCompleted) { Start-Sleep -Milliseconds 100 }
                    } while (!$handle.IsCompleted -or $progressIndex -lt $winGetModuleWorker.Streams.Progress.Count)
                    $results = @($winGetModuleWorker.EndInvoke($handle))
                    if ($winGetModuleWorker.HadErrors) { throw $winGetModuleWorker.Streams.Error[0] }
                    if ($results.Count -ne 1) { throw 'WinGet did not return a single installation result.' }
                    $result = $results[0]
                    $script:lastInstallResult.ExitCode = $result.ErrorCode
                    Write-Host "$program - WinGet: $($result.Status)"
                    if (!$result.Succeeded) { Write-Host "Error: $($result.ErrorCode); installer error: $($result.InstallerErrorCode)" }
                    if ($result.RebootRequired) { Write-Host '- Restart required' }
                    return $result.Succeeded
                } catch {
                    $script:lastInstallResult.ExitCode = $_.Exception.HResult
                    Write-Host "$program - WinGet failed: $($_.Exception.Message)"
                    return $false
                } finally { Invoke-Ui { $installProgress.IsIndeterminate = $false } }
            }
            $winGetModuleWorker = $null
            try {
                . (Join-Path $functionsPath 'Import-Atom.ps1') -Function 'Copy-WebItem', 'Install-Choco', 'Install-Program', 'Install-Scoop', 'Install-WinGet'
                Write-Host "Install method: $runMethod; allow WinGet direct download: $allowWinGetDirect"
                $preparedMethods = @{}
                $methodOrder = if ($runMethod -eq 'Automatic') {
                    @('WinGet') + @('WinGetDirect' | Where-Object { $allowWinGetDirect }) + @('Choco', 'Scoop', 'URL')
                } elseif ($runMethod -eq 'WinGet' -and $allowWinGetDirect) {
                    @('WinGet', 'WinGetDirect')
                } else { @($runMethod) }
                Invoke-Ui { $installProgress.IsIndeterminate = $false }
                foreach ($program in @($installQueue.Keys | Sort-Object)) {
                    if ($bulkInstallState.CancelRequested) { break }
                    $params = $installQueue[$program]
                    $installed = $false
                    try {
                        Write-Host "Installing $program"
                        $hashMismatch = $false
                        $directConsent = $false
                        foreach ($method in $methodOrder) {
                            $key = if ($method -eq 'WinGetDirect') { 'WinGet' } else { $method }
                            if (!$params[$key]) { continue }
                            if ($hashMismatch -and $method -in 'WinGetDirect', 'URL' -and !$directConsent) {
                                $directConsent = Invoke-Ui -GetValue {
                                    [Windows.MessageBox]::Show($window, "$program failed WinGet's hash check. The installer may have changed or been tampered with. Download directly without verifying WinGet's expected hash?", 'Installer hash mismatch', 'YesNo', 'Warning', 'No') -eq 'Yes'
                                }
                                if (!$directConsent) { Write-Host "$program - direct download declined"; break }
                            }
                            if ($method -in 'WinGet', 'Choco', 'Scoop' -and !$preparedMethods.ContainsKey($method)) {
                                try {
                                    Invoke-Ui { $installStatus.Text = "Preparing $method..."; $installProgress.IsIndeterminate = $true }
                                    switch ($method) {
                                        'WinGet' {
                                            Install-WinGet
                                            $winGetAdapterReady = $false
                                            $modulePath = Join-Path $programsPath 'Microsoft.WinGet.Client/Microsoft.WinGet.Client.psd1'
                                            if (Test-Path -LiteralPath $modulePath -PathType Leaf) {
                                                try {
                                                    $winGetModuleWorker = [PowerShell]::Create()
                                                    $null = $winGetModuleWorker.AddCommand('Import-Module').AddParameter('Name', $modulePath).AddParameter('ErrorAction', 'Stop')
                                                    $null = $winGetModuleWorker.Invoke()
                                                    if ($winGetModuleWorker.HadErrors) { throw $winGetModuleWorker.Streams.Error[0] }
                                                    Write-Host 'WinGet progress: cached PowerShell module'
                                                } catch {
                                                    if ($winGetModuleWorker) { $winGetModuleWorker.Dispose(); $winGetModuleWorker = $null }
                                                    Write-Host "Cached WinGet module unavailable: $($_.Exception.Message)"
                                                }
                                            }
                                            if (!$winGetModuleWorker) {
                                                try {
                                                    & (Join-Path $bulkAppInstallerDependencies 'WinGet/WinGetAdapter.ps1') -CachePath (Join-Path $programsPath 'Bulk App Installer/WinGet') -ErrorAction Stop
                                                    $winGetAdapterReady = $true
                                                    Write-Host 'WinGet progress: bundled adapter'
                                                } catch {
                                                    Write-Host "Real-time WinGet progress unavailable; using CLI queue progress: $($_.Exception.Message)"
                                                }
                                            }
                                        }
                                        'Choco' { Install-Choco }
                                        'Scoop' { Install-Scoop }
                                    }
                                    $preparedMethods[$method] = $true
                                } catch { $preparedMethods[$method] = $false; Write-Host "$method unavailable: $($_.Exception.Message)" }
                            }
                            if ($preparedMethods.ContainsKey($method) -and !$preparedMethods[$method]) { continue }
                            switch ($method) {
                                'WinGet' {
                                    $installed = if ($winGetModuleWorker) {
                                        Install-BulkWinGetModulePackage -Id $params.WinGet
                                    } elseif ($winGetAdapterReady) {
                                        Install-BulkWinGetPackage -Id $params.WinGet
                                    } else {
                                        Install-BulkProgram -FilePath 'winget' -ArgumentList "install --id $($params.WinGet) --exact --accept-package-agreements --accept-source-agreements" -Description 'WinGet'
                                    }
                                    $hashMismatch = $script:lastInstallResult.ExitCode -eq -1978335215
                                }
                                'WinGetDirect' {
                                    try {
                                        Invoke-Ui { $installStatus.Text = "$program - resolving WinGet installer URL" }
                                        $match = winget show --id $params.WinGet --exact --accept-source-agreements 2>&1 | Select-String '^\s*Installer Url:\s*(https?://\S+)' | Select-Object -First 1
                                        if ($LASTEXITCODE -eq 0 -and $match) { $installed = Install-BulkProgram -Uri $match.Matches[0].Groups[1].Value -Description 'WinGet direct download (unverified)' }
                                    } catch { Write-Host "$program - WinGet URL unavailable: $($_.Exception.Message)" }
                                }
                                'Choco' { $installed = Install-BulkProgram -FilePath 'choco' -ArgumentList "install $($params.Choco) -y" -Description 'Choco' }
                                'Scoop' { $installed = Install-BulkProgram -FilePath 'powershell' -ArgumentList "scoop install $($params.Scoop)" -Description 'Scoop' }
                                'URL' { $installed = Install-BulkProgram -Uri $params.Url -Description 'URL' }
                            }
                            if ($installed) { break }
                        }
                    } catch {
                        Write-Host "$program failed: $($_.Exception.Message)"
                    } finally {
                        $completed++
                        if (!$installed) { $failed++; Write-Host "$program was not installed." }
                        Invoke-Ui { $installProgress.IsIndeterminate = $false; $installProgress.Value = 100.0 * $completed / $installQueue.Count }
                    }
                }
            } catch {
                $fatalError = $_.Exception.Message
                Write-Host "Installation stopped: $fatalError"
            } finally {
                if ($winGetModuleWorker) { $winGetModuleWorker.Dispose() }
                $notRun = $installQueue.Count - $completed
                $summary = "$($completed - $failed) installed; $failed failed; $notRun not run."
                if ($bulkInstallState.CancelRequested) { $summary = "Cancelled. $summary" }
                if ($fatalError) { $summary += " Stopped: $fatalError" }
                Write-Host $summary
                Write-Host ''
                Write-Host "Log saved to $LogPath"
                if ($bulkInstallState.LogError) { $summary += " Log could not be saved: $($bulkInstallState.LogError)" }
                $bulkInstallState.Summary = $summary
                $bulkInstallState.Complete = $true
            }
        }
    } catch {
        $bulkInstallState.Summary = "Unable to start installation: $($_.Exception.Message)"
        Complete-BulkInstallation
    }
})

Set-WindowSize

$window.Add_Closed({
    $searchTimer.Stop()
    $programImageTimer.Stop()
    $installTimer.Stop()
    $script:programImageState.Closed = $true
    $script:programImageTargets.Clear()
})
$window.ShowDialog() | Out-Null

Add-Type -AssemblyName PresentationFramework

# Import module(s)
Import-Module "$psScriptRoot\..\Functions\AtomModule.psm1"
Import-Module "$psScriptRoot\..\Functions\AtomWpfModule.psm1"
$bulkAppInstallerDependencies = "$psScriptRoot\Bulk App Installer"
$programIcons        = "$resourcesPath\Icons\Program Icons"
$hashtable           = "$bulkAppInstallerDependencies\Programs.ps1"

$contentXaml = @"
            <Grid Margin="0">
                <Grid.RowDefinitions>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Grid Grid.Column="0">
                    <ScrollViewer Name="scrollViewer0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                        <StackPanel>
                            <Border Height="{Binding ActualHeight, ElementName=searchBar}" Margin="0,10,0,5"/>
<Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" VerticalAlignment="Top" Margin="10,5,10,5" Padding="5">
                                <StackPanel>
                                    <TextBlock Text="Install Methods" FontWeight="Bold" Foreground="{DynamicResource surfaceText}" TextAlignment="Center" VerticalAlignment="Center" Margin="5"/>

                                    <WrapPanel Orientation="Horizontal" HorizontalAlignment="Center">
                                        <CheckBox Name="wingetCheckBox" Content="Winget" Foreground="{DynamicResource surfaceText}" IsChecked="True" Margin="5" ToolTip="Download w/ Winget [Priority-1]&#x0a;[Package Manager] [Very safe]"/>
                                        <CheckBox Name="chocoCheckBox" Content="Choco" Foreground="{DynamicResource surfaceText}" IsChecked="False" Margin="5" ToolTip="Download w/ Chocolatey [Priority-2]&#x0a;[Package Manager] [Safe]"/>
                                        <CheckBox Name="scoopCheckBox" Content="Scoop" Foreground="{DynamicResource surfaceText}" IsChecked="False" Margin="5" ToolTip="Download w/ Scoop [Priority-3]&#x0a;[Package Manager] [Safe] [BETA]"/>
                                        <CheckBox Name="urlCheckBox" Content="URL" Foreground="{DynamicResource surfaceText}" IsChecked="True" Margin="5" ToolTip="Download using Winget's installer URL, falling back to the configured URL [Priority-4]&#x0a;Direct download; no Winget hash validation"/>
                                    </WrapPanel>
                                </StackPanel>
                            </Border>

                            <StackPanel Name="installPanel" Margin="10,0,10,5"/>
                        </StackPanel>
                    </ScrollViewer>

                    <Border Name="searchBar" Panel.ZIndex="10" Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" VerticalAlignment="Top" Margin="10,10,28,5" Padding="5">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <Button Name="backspaceButton" Grid.Column="0" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                            <ContentControl Name="searchImage" Grid.Column="1" Opacity="0.38" Width="16" Height="16" Margin="0"/>
                            <TextBlock Name="searchTextBlock" Grid.Column="2" Text="Search" Foreground="{DynamicResource surfaceText}" TextAlignment="Left" VerticalAlignment="Center" Opacity="0.69" Margin="5"/>
                            <TextBox Name="searchTextBox" Grid.Column="2" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" TextAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                            <Button Name="sortButton" Grid.Column="3" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                            <Grid Grid.Row="1" Grid.ColumnSpan="4" Height="2" Margin="5,2">
                                <Border Height="1" Background="{DynamicResource surfaceText}" Opacity="0.44"/>
                                <ProgressBar Name="installProgress" Height="2" Minimum="0" Maximum="100" Value="0" Background="Transparent" Foreground="{DynamicResource surfaceText}" IsHitTestVisible="False"/>
                            </Grid>
                            <TextBlock Name="installStatus" Grid.Row="2" Grid.ColumnSpan="4" Text="Select programs to install" Foreground="{DynamicResource surfaceText}" FontSize="10" Margin="5" TextWrapping="Wrap"/>
                        </Grid>
                    </Border>
                </Grid>

                <Button Name="runButton" Grid.Row="1" Content="Run"
                        Background="{DynamicResource accentBrush}"
                        Foreground="{DynamicResource accentText}"
                        Style="{StaticResource RoundedButton}" Margin="10,0,10,10"/>
            </Grid>
"@


$windowParameters = @{
    Title       = 'Bulk App Installer'
    IconPath    = "$bulkAppInstallerDependencies\Bulk App Installer.png"
    ContentXaml = $contentXaml
    Width       = 800
    Height      = 800
    MinWidth    = 600
    MinHeight   = 600
    MaxWidth    = 1600
    MaxHeight   = 1000
}
$window = New-AtomWindow @windowParameters
# Assign variables to elements in XAML
$runButton          = $window.Findname('runButton')
$installPanel       = $window.FindName('installPanel')
$searchTextBlock    = $window.FindName('searchTextBlock')
$searchTextBox      = $window.FindName('searchTextBox')
$wingetCheckBox     = $window.FindName('wingetCheckBox')
$chocoCheckBox      = $window.FindName('chocoCheckBox')
$scoopCheckBox      = $window.FindName('scoopCheckBox')
$urlCheckBox        = $window.FindName('urlCheckBox')
$installProgress    = $window.FindName('installProgress')
$installStatus      = $window.FindName('installStatus')

# Set icon sources
Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{
    'backspaceButton' = 'BackspaceIcon'
    'searchImage' = 'SearchIcon'
    'sortButton' = 'CategoryIcon'
}

# Programs panel

# Pull programs hashtable
. $hashtable

$selectedPrograms = @{}
$script:programSortMode = 'Category'

function Update-ProgramColumnOrder {
    param([System.Windows.Controls.ListBox]$ListBox)

    $visible = @($ListBox.Items | Where-Object Visibility -ne 'Collapsed' | Sort-Object DataContext)
    $hidden = @($ListBox.Items | Where-Object Visibility -eq 'Collapsed')
    $columns = if ($ListBox.ActualWidth -gt 0) { [Math]::Max(1, [Int][Math]::Floor(($ListBox.ActualWidth - 10) / 200)) } else { 2 }
    if ($ListBox.ColumnCount -ne $columns) {
        $ListBox.ColumnCount = $columns
        $ListBox.ItemsPanel = [Windows.Markup.XamlReader]::Parse("<ItemsPanelTemplate xmlns=`"http://schemas.microsoft.com/winfx/2006/xaml/presentation`"><UniformGrid Columns=`"$columns`" Width=`"$($columns * 200)`" HorizontalAlignment=`"Left`"/></ItemsPanelTemplate>")
    }
    $rows = [Int][Math]::Ceiling($visible.Count / [Double]$columns)
    $shortColumnSize = [Int][Math]::Floor($visible.Count / [Double]$columns)
    $longColumns = $visible.Count % $columns
    $ListBox.Items.Clear()
    for ($row = 0; $row -lt $rows; $row++) {
        for ($column = 0; $column -lt $columns; $column++) {
            $columnSize = $shortColumnSize + [Int]($column -lt $longColumns)
            if ($row -lt $columnSize) {
                $index = $column * $shortColumnSize + [Math]::Min($column, $longColumns) + $row
                [void]$ListBox.Items.Add($visible[$index])
            }
        }
    }
    foreach ($item in $hidden) { [void]$ListBox.Items.Add($item) }
}

function Import-Programs {
    param (
        [ValidateSet('Category', 'Alphabetical')]
        [String]$SortMode = $script:programSortMode
    )

    $installPanel.Children.Clear()

    $programs = $installPrograms.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            Name          = $_.Key
            Info          = $_.Value
            GroupCategory = if ($SortMode -eq 'Alphabetical') { 'All Programs' } else { $_.Value.Category }
        }
    } | Sort-Object GroupCategory, Name

    foreach ($group in ($programs | Group-Object GroupCategory)) {
        $category = $group.Name

        $textBlock = New-Object System.Windows.Controls.TextBlock
        $textBlock.Text = $category
        $textBlock.FontWeight = 'Bold'
        $textBlock.Foreground = $backgroundText
        $textBlock.Margin = '5,5,0,0'
        $textBlock.Tag = $category
        $installPanel.Children.Add($textBlock) | Out-Null

        $listBox = New-Object System.Windows.Controls.ListBox
        $listBox.Background = $surfaceBrush
        $listBox.Foreground = $surfaceText
        $listBox.BorderThickness = 0
        $listBox.Margin = '0,5,0,5'
        $listBox.Style = $window.Resources['CustomListBoxStyle']
        $listBox | Add-Member -NotePropertyName ColumnCount -NotePropertyValue 2
        $listBox.ItemsPanel = [Windows.Markup.XamlReader]::Parse('<ItemsPanelTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"><UniformGrid Columns="2" Width="400" HorizontalAlignment="Left"/></ItemsPanelTemplate>')
        $listBox.Add_SizeChanged({
            $columns = [Math]::Max(1, [Int][Math]::Floor(($this.ActualWidth - 10) / 200))
            if ($this.ColumnCount -ne $columns) { Update-ProgramColumnOrder -ListBox $this }
        })
        [Windows.Controls.ScrollViewer]::SetHorizontalScrollBarVisibility($listBox, 'Disabled')
        $listBox.Tag = $category
        $installPanel.Children.Add($listBox) | Out-Null

        foreach ($entry in $group.Group) {
            $program = $entry.Name
            $programInfo = $entry.Info
            $iconPath = "$programIcons\$program.png"

            if (!(Test-Path $iconPath)) {
                $firstLetter = $program.Substring(0,1)
                $iconPath =
                    if ($firstLetter -match '^[A-Z]') { "$resourcesPath\Icons\Default\$firstLetter.png" }
                    else { "$resourcesPath\Icons\Default\#.png" }
            }

            $listBoxItemParams = @{
                ControlType = 'CheckBox'
                Text = $program
                TextForeground = $surfaceText
                ImageSource = $iconPath
                Tag = $program, $programInfo
                ToolTip =
                    if ($atomSettings.ShowToolTips.Value -and $programInfo.ToolTip) { $programInfo.ToolTip }
                    else { $null }
            }

            $listBoxItem = New-ListBoxControlItem @listBoxItemParams
            $listBoxItem.DataContext = $program
            $listBoxItem.Control.IsChecked = $selectedPrograms.ContainsKey($program)
            $listBoxItem.Control.Add_Checked({ $selectedPrograms[$this.Tag[0]] = $this.Tag[1] })
            $listBoxItem.Control.Add_Unchecked({ $selectedPrograms.Remove($this.Tag[0]) })
            $listBox.Items.Add($listBoxItem) | Out-Null
        }
        Update-ProgramColumnOrder -ListBox $listBox
    }

    Update-Checkboxes
}

# Search bar controls
$searchBar       = $window.FindName('searchBar')
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

    foreach ($listBox in ($installPanel.Children | Where-Object { $_ -is [System.Windows.Controls.ListBox] })) {
        $anyVisibleItems = $false

        foreach ($item in $listBox.Items) {
            $isVisible = ([String]$item.DataContext).IndexOf($searchText, [StringComparison]::OrdinalIgnoreCase) -ge 0
            $item.Visibility = if ($isVisible) { 'Visible' } else { 'Collapsed' }
            if ($isVisible) { $anyVisibleItems = $true }
        }

        Update-ProgramColumnOrder -ListBox $listBox
        $categoryHeader = $installPanel.Children | Where-Object {
            $_ -is [System.Windows.Controls.TextBlock] -and $_.Tag -eq $listBox.Tag
        }

        $visibility = if ($anyVisibleItems) { 'Visible' } else { 'Collapsed' }
        $categoryHeader.Visibility = $visibility
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
    $installPanel.Children | ForEach-Object {
        if ($_ -isnot [System.Windows.Controls.ListBox]) { return }
        
        $listBox = $_
        $listBox.Items | ForEach-Object {
            $listBoxItem = $_
            $program = $listBoxItem.Control.Tag[0]
            $programInfo = $installPrograms[$program]
            
            if ($programInfo -eq $null) { return }
            
            $isEnabled = ($script:useWinget -and $programInfo.Winget) -or
                         ($script:useChoco -and $programInfo.Choco) -or
                         ($script:useScoop -and $programInfo.Scoop) -or
                         ($script:useUrl -and ($programInfo.Winget -or $programInfo.Url))
            
            $listBoxItem.IsEnabled = $isEnabled
            $listBoxItem.Opacity = if ($isEnabled) { 1 } else { 0.44 }
            if (-not $isEnabled) {
                $listBoxItem.Control.IsChecked = $false
            }
        }
    }
}

# Winget checkbox
if ($wingetCheckBox.IsChecked) { $script:useWinget = $true }
$wingetCheckBox.Add_Checked({
    $script:useWinget = $true
    Update-Checkboxes
})
$wingetCheckBox.Add_UnChecked({
    $script:useWinget = $false
    Update-Checkboxes
})

# Choco checkbox
if ($chocoCheckBox.IsChecked) { $script:useChoco = $true }
$chocoCheckBox.Add_Checked({
    $script:useChoco = $true
    Update-Checkboxes
})
$chocoCheckBox.Add_UnChecked({
    $script:useChoco = $false
    Update-Checkboxes
})

# Scoop checkbox
if ($scoopCheckBox.IsChecked) { $script:useScoop = $true }
$scoopCheckBox.Add_Checked({
    $script:useScoop = $true
    Update-Checkboxes
})
$scoopCheckBox.Add_UnChecked({
    $script:useScoop = $false
    Update-Checkboxes
})

# Url checkbox
if ($urlCheckBox.IsChecked) { $script:useUrl = $true }
$urlCheckBox.Add_Checked({
    $script:useUrl = $true
    Update-Checkboxes
})
$urlCheckBox.Add_UnChecked({
    $script:useUrl = $false
    Update-Checkboxes
})

# Construct program list and update checkbox statuses
Import-Programs

Add-AtomScrollViewerBehavior -Window $window -Name 'scrollViewer0'

$runButton.Tooltip = "Install selected programs"
$runButton.Add_Click({
    if (!$selectedPrograms.Count) {
        $installStatus.Text = 'Select at least one program to install'
        return
    }
    $script:installQueue = $selectedPrograms.Clone()
    $runButton.IsEnabled = $false
    $runButton.Content = 'Running...'
    $installPanel.IsEnabled = $false
    $sortButton.IsEnabled = $false
    foreach ($control in @($wingetCheckBox, $chocoCheckBox, $scoopCheckBox, $urlCheckBox)) { $control.IsEnabled = $false }
    $installProgress.Value = 0
    $installProgress.IsIndeterminate = $true
    $installStatus.Text = 'Preparing package managers...'
    try {
        Invoke-Runspace -ScriptBlock {
            $completed = 0
            $failed = 0
            $fatalError = $null
            $installLog = [Text.StringBuilder]::new()
            # Keep the complete log independent of the status-line presentation.
            function Write-Host {
                param([String]$Object)
                [void]$installLog.AppendLine($Object)
                Invoke-Ui {
                    if (![String]::IsNullOrWhiteSpace($Object)) { $installStatus.Text = $Object.Trim() }
                }
            }
            function Install-BulkProgram {
                param([String]$FilePath, [String]$ArgumentList, [Alias('Url')][String]$Uri, [String]$Description)
                Invoke-Ui { $installStatus.Text = "$($completed + 1)/$($installQueue.Count): $program - $Description" }
                $arguments = @{ Description = $Description }
                if ($Uri) { $arguments.Uri = $Uri } else { $arguments.FilePath = $FilePath; $arguments.ArgumentList = $ArgumentList }
                try { Install-Program @arguments -ErrorAction Stop } catch { Write-Host "$program - $Description failed: $($_.Exception.Message)"; return $false }
            }
            try {
                'Copy-WebItem', 'Install-Choco', 'Install-Program', 'Install-Scoop', 'Install-Winget' | ForEach-Object {
                    . "$functionsPath\$_.ps1"
                }
                # URL-only installations can still fall back if Winget is unavailable.
                if ($useWinget -or ($useUrl -and @($installQueue.Values | Where-Object Winget).Count)) {
                    try { Install-Winget } catch { Write-Host "Winget unavailable; other selected methods will be tried: $($_.Exception.Message)" }
                }
                if ($useChoco) { Install-Choco }
                if ($useScoop) { Install-Scoop }
                Invoke-Ui { $installProgress.IsIndeterminate = $false }
                foreach ($program in @($installQueue.Keys | Sort-Object)) {
                    $params = $installQueue[$program]
                    $installed = $false
                    try {
                        Write-Host "Installing $program"
                        if ($useWinget -and $params.Winget -and ($installed = Install-BulkProgram -FilePath 'winget' -ArgumentList "install --id $($params.Winget) --accept-package-agreements --accept-source-agreements --force" -Description 'Winget')) { continue }
                        if ($useChoco -and $params.Choco -and ($installed = Install-BulkProgram -FilePath 'choco' -ArgumentList "install $($params.Choco) -y" -Description 'Choco')) { continue }
                        if ($useScoop -and $params.Scoop -and ($installed = Install-BulkProgram -FilePath 'powershell' -ArgumentList "scoop install $($params.Scoop)" -Description 'Scoop')) { continue }
                        if ($useUrl -and $params.Winget) {
                            try {
                                Invoke-Ui { $installStatus.Text = "$program - resolving Winget installer URL" }
                                $installerUrl = (winget show --id $params.Winget --exact --accept-source-agreements 2>&1 | Select-String '^\s*Installer Url:\s*(https?://\S+)' | Select-Object -First 1)
                                if ($LASTEXITCODE -eq 0 -and $installerUrl) {
                                    if ($installed = Install-BulkProgram -Url $installerUrl.Matches[0].Groups[1].Value -Description 'Winget URL') { continue }
                                }
                            } catch { Write-Host "$program - Winget URL unavailable: $($_.Exception.Message)" }
                        }
                        if ($useUrl -and $params.Url -and ($installed = Install-BulkProgram -Url $params.Url -Description 'URL')) { continue }
                    } catch {
                        Write-Host "$program failed: $($_.Exception.Message)"
                    } finally {
                        $completed++
                        if (!$installed) { $failed++; Write-Host "$program was not installed." }
                        Invoke-Ui { $installProgress.Value = 100.0 * $completed / $installQueue.Count }
                    }
                }
            } catch {
                $fatalError = $_.Exception.Message
                Write-Host "Installation stopped: $fatalError"
            } finally {
                $summary = if ($fatalError) { "Stopped: $fatalError" } else { "$($completed - $failed) installed; $failed failed" }
                try {
                    [void]$installLog.AppendLine($summary)
                    $logPath = Join-Path $atomTemp ("bulk-app-installer-{0}.txt" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
                    $installLog.ToString() | Out-File -FilePath $logPath -ErrorAction Stop
                    Write-Host "Log saved to $logPath"
                } catch { $summary += '; log could not be saved' }
                Invoke-Ui {
                    $installStatus.Text = $summary
                    $installProgress.IsIndeterminate = $false
                    $runButton.Content = 'Run'
                    $runButton.IsEnabled = $true
                    $installPanel.IsEnabled = $true
                    $sortButton.IsEnabled = $true
                    foreach ($control in @($wingetCheckBox, $chocoCheckBox, $scoopCheckBox, $urlCheckBox)) { $control.IsEnabled = $true }
                }
            }
        }
    } catch {
        $installStatus.Text = "Unable to start installation: $($_.Exception.Message)"
        $installProgress.IsIndeterminate = $false
        $runButton.Content = 'Run'
        $runButton.IsEnabled = $true
        $installPanel.IsEnabled = $true
        $sortButton.IsEnabled = $true
        foreach ($control in @($wingetCheckBox, $chocoCheckBox, $scoopCheckBox, $urlCheckBox)) { $control.IsEnabled = $true }
    }
})

Set-WindowSize

$window.ShowDialog() | Out-Null

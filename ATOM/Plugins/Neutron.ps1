Add-Type -AssemblyName PresentationFramework

# Import module(s)
Import-Module "$psScriptRoot\..\Functions\AtomModule.psm1"
Import-Module "$psScriptRoot\..\Functions\AtomWpfModule.psm1"
$neutronDependencies = "$dependenciesPath\Neutron"
$programIcons        = "$resourcesPath\Icons\Program Icons"
$neutronShortcuts    = "$neutronDependencies\Shortcuts"
$hashtable           = "$neutronDependencies\Programs.ps1"

$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Neutron"
    WindowStartupLocation="CenterScreen"
    WindowStyle="None"
    AllowsTransparency="True"
    Background="Transparent"
    Width="800" Height="800"
    MinWidth="800" MinHeight="600"
    MaxWidth="800" MaxHeight="1000"
    UseLayoutRounding="True"
    RenderOptions.BitmapScalingMode="HighQuality">
    
    <Window.Resources>
        $resourceDictionary
    </Window.Resources>
    
    <WindowChrome.WindowChrome>
        <WindowChrome CaptionHeight="0" CornerRadius="10"/>
    </WindowChrome.WindowChrome>
    
    <Border BorderBrush="Transparent" BorderThickness="1" Background="{DynamicResource backgroundBrush}" CornerRadius="5">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="60"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            
            <Grid Grid.Row="0">
                <Border Background="{DynamicResource primaryBrush}" CornerRadius="5,5,0,0"/>
                <Image Width="40" Height="40" Source="$resourcesPath\Icons\Program Icons\Neutron.png" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="15,0,0,0"/>
                <Image Width="130" Height="130" Source="$neutronDependencies\Neutron.png" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="60,5,0,0"/>
                <Button Name="minimizeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,45,0" ToolTip="Minimize"/>
                <Button Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,10,0" ToolTip="Close"/>
            </Grid>
            
            <Grid Grid.Row="1" Margin="0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                
                <ScrollViewer Name="scrollViewer0" Grid.Column="0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                    <StackPanel Margin="10,10,10,0">
                        <Label Content="Customizations" Foreground="{DynamicResource backgroundText}" FontWeight="Bold"/>
                        <Border Style="{StaticResource CustomBorder}">
                            <ListBox Name="customizationPanel" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderThickness="0" Padding="5"/>
                        </Border>
                        <Label Content="Timezone" Foreground="{DynamicResource backgroundText}" FontWeight="Bold" Margin="0,5,0,0"/>
                        <Border Style="{StaticResource CustomBorder}" Padding="5">
                            <StackPanel Name="timezonePanel"/>
                        </Border>
                        <Label Content="Shortcuts" Foreground="{DynamicResource backgroundText}" FontWeight="Bold" Margin="0,5,0,0"/>
                        <StackPanel Name="shortcutPanel"/>
                    </StackPanel>
                </ScrollViewer>
                
                <Grid Grid.Column="1">
                    <ScrollViewer Name="scrollViewer1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                        <StackPanel>
                            <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" VerticalAlignment="Top" Margin="0,70,10,5" Padding="5">
                                <StackPanel>
                                    <TextBlock Text="Install Methods" FontWeight="Bold" Foreground="{DynamicResource surfaceText}" TextAlignment="Center" VerticalAlignment="Center" Margin="5"/>
                                    
                                    <WrapPanel Orientation="Horizontal" HorizontalAlignment="Center">
                                        <CheckBox Name="wingetCheckBox" Content="Winget" Foreground="{DynamicResource surfaceText}" IsChecked="True" Margin="5" ToolTip="Download w/ Winget [Priority-1]&#x0a;[Package Manager] [Very safe]"/>
                                        <CheckBox Name="chocoCheckBox" Content="Choco" Foreground="{DynamicResource surfaceText}" IsChecked="False" Margin="5" ToolTip="Download w/ Chocolatey [Priority-2]&#x0a;[Package Manager] [Safe]"/>
                                        <CheckBox Name="scoopCheckBox" Content="Scoop" Foreground="{DynamicResource surfaceText}" IsChecked="False" Margin="5" ToolTip="Download w/ Scoop [Priority-3]&#x0a;[Package Manager] [Safe] [BETA]"/>
                                        <CheckBox Name="wingetAltCheckBox" Content="Winget alt" Foreground="{DynamicResource surfaceText}" IsChecked="True" Margin="5" ToolTip="Download w/ Winget's 'Installer Url' [Priority-4]&#x0a;[URL] [Winget] [No Hash Validation]"/>
                                        <CheckBox Name="urlCheckBox" Content="URL" Foreground="{DynamicResource surfaceText}" IsChecked="True" Margin="5" ToolTip="Download w/ direct URL [Priority-5]&#x0a;[URL] [Vendor Site]"/>
                                        <CheckBox Name="mirrorCheckBox" Content="Mirror" Foreground="{DynamicResource surfaceText}" IsChecked="False" Margin="5" ToolTip="Download w/ mirror URL [Priority-6]&#x0a;[URL] [Mirror Site]"/>
                                    </WrapPanel>
                                </StackPanel>
                            </Border>
                            
                            <StackPanel Name="installPanel" Margin="0,0,10,5"/>
                        </StackPanel>
                    </ScrollViewer>
                    
                    <Border Name="searchBar" Panel.ZIndex="10" Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" VerticalAlignment="Top" Margin="0,10,28,5" Padding="5">
                        <Grid>
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
                        </Grid>
                    </Border>
                </Grid>
                
                <Border Grid.Column="2" Style="{StaticResource CustomBorder}" Margin="0,10,10,10">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="30"/>
                        </Grid.RowDefinitions>
                        
                        <ScrollViewer Name="scrollViewer2" Grid.Row="0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                            <TextBlock Name="outputBox" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Stretch" TextWrapping="Wrap" VerticalAlignment="Stretch" Padding="10"/>
                        </ScrollViewer>
                        
                        <ProgressBar Name="progressBar" Grid.Row="1" Margin="10,0,10,10"/>
                        <TextBlock Name="progressBarText" Grid.Row="1" Foreground="{DynamicResource primaryText}" TextAlignment="Center" VerticalAlignment="Center" FontSize="10" Margin="10,0,10,10"/>
                    </Grid>
                </Border>
            </Grid>
            
            <Grid Grid.Row="2">
                <Button Name="runButton" Content="Run" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" Margin="10,0,10,10" Style="{StaticResource RoundedButton}"/>
            </Grid>
            
        </Grid>
    </Border>
</Window>
"@

# Load XAML
$window = [Windows.Markup.XamlReader]::Parse($xaml)

# Assign variables to elements in XAML
$minimizeButton     = $window.FindName('minimizeButton')
$closeButton        = $window.FindName('closeButton')
$runButton          = $window.Findname('runButton')
$customizationPanel = $window.FindName('customizationPanel')
$timezonePanel      = $window.FindName('timezonePanel')
$shortcutPanel      = $window.FindName('shortcutPanel')
$installPanel       = $window.FindName('installPanel')
$searchTextBlock    = $window.FindName('searchTextBlock')
$searchTextBox      = $window.FindName('searchTextBox')
$wingetCheckBox     = $window.FindName('wingetCheckBox')
$chocoCheckBox      = $window.FindName('chocoCheckBox')
$scoopCheckBox      = $window.FindName('scoopCheckBox')
$wingetAltCheckBox  = $window.FindName('wingetAltCheckBox')
$urlCheckBox        = $window.FindName('urlCheckBox')
$mirrorCheckBox     = $window.FindName('mirrorCheckBox')
$outputBox          = $window.FindName('outputBox')
$progressBar        = $window.FindName('progressBar')
$progressBarText    = $window.FindName('progressBarText')

# Set icon sources
Set-VectorIcon -ForegroundResource primaryText -ResourceMappings @{
    'minimizeButton' = 'MinimizeIcon'
    'closeButton' = 'CloseIcon'
}
Set-VectorIcon -ForegroundResource surfaceText -ResourceMappings @{
    'backspaceButton' = 'BackspaceIcon'
    'searchImage' = 'SearchIcon'
    'sortButton' = 'CategoryIcon'
}

# Customizations panel
# Get the major Windows version number (11, 10, etc.) and build numbers, used for some predicates
$winVer = ((Get-CimInstance -ClassName Win32_OperatingSystem).Caption.Split(' ')[-2])
$winBuild = (Get-CimInstance -ClassName Win32_OperatingSystem).BuildNumber

$customizationsPath = Join-Path $neutronDependencies "Customizations.ps1"
. $customizationsPath

$selectedScripts = New-Object System.Collections.ArrayList
foreach ($key in $customizations.Keys) {
    $customization = $customizations[$key]
    $name = $key
    $tooltip = $customization.Tooltip
    $predicate = $customization.Predicate
    $scriptblock = $customization.Scriptblock.ToString()
    
    $checkBox = New-Object System.Windows.Controls.CheckBox
    $checkBox.Content = $name
    $checkBox.ToolTip = $tooltip
    $checkBox.Tag = $scriptblock
    $checkBox.Foreground = $surfaceText
    $checkBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $checkBox.Add_Checked({ $selectedScripts.Add($this.Tag) })
    $checkBox.Add_Unchecked({ $selectedScripts.Remove($this.Tag) | Out-Null })
    
    # Enable/disable checkbox depending on predicate's return value
    $predicateResult = &$predicate
    if (-not $predicateResult) {
        $checkBox.IsEnabled = $false
        $checkbox.Opacity = 0.44
    }
    
    $customizationPanel.Items.Add($checkBox) | Out-Null
}

# Timezone panel
function Increment-TextBox {
    param(
        [Parameter(Mandatory=$true)]
        [System.Windows.Controls.TextBox]$textBox,
        
        [Parameter(Mandatory=$false)]
        [int]$increment = 1
    )
    
    $minValue = -12
    $maxValue = 14
    
    $currentValue = [int]$textBox.Text
    $newValue = $currentValue + $increment
    
    # Clamp to range
    if ($newValue -lt $minValue) {
        $newValue = $minValue
    } elseif ($newValue -gt $maxValue) {
        $newValue = $maxValue
    }
    
    $textBox.Text = $newValue.ToString()
}

function New-RadioButton {
    param(
        [string]$name,
        [string]$timezoneId,
        [string]$content,
        [boolean]$special
    )
    
    $radioButton = New-Object Windows.Controls.RadioButton
    $radioButton.Name = $name
    $radioButton.Content = $content
    $radioButton.VerticalContentAlignment = "Center"
    $radioButton.GroupName = "UpdateOption"
    $radioButton.IsChecked = $false
    $radioButton.Margin = 5
    $radioButton.Add_Checked({ $script:checkedTimezone = $true })
    
    if (!$special) {
        $radioButton.Tag = $timezoneId
        return $radioButton
    }
    
    $script:textBox = New-Object Windows.Controls.TextBox
    $script:textBox.Text = "0"
    $script:textBox.Width = 25
    $script:textBox.VerticalAlignment = "Center"
    $script:textBox.HorizontalAlignment = "Left"
    $script:textBox.TextAlignment = "Center"
    $script:textBox.Add_TextChanged({
        $radioButton.Tag = 
        switch ($script:textBox.Text) {
            -12 { "Dateline Standard Time" }
            -11 { "UTC-11" }
            -10 { "Aleutian Standard Time" }
            -9 { "Alaskan Standard Time" }
            -8 { "Pacific Standard Time" }
            -7 { "Mountain Standard Time" }
            -6 { "Central Standard Time" }
            -5 { "Eastern Standard Time" }
            -4 { "Atlantic Standard Time" }
            -3 { "Argentina Standard Time" }
            -2 { "Greenland Standard Time" }
            -1 { "Azores Standard Time" }
            0 { "GMT Standard Time" }
            1 { "Central Europe Standard Time" }
            2 { "Middle East Standard Time" }
            3 { "Arabic Standard Time" }
            4 { "Caucasus Standard Time" }
            5 { "Pakistan Standard Time" }
            6 { "Bangladesh Standard Time" }
            7 { "North Asia Standard Time" }
            8 { "W. Australia Standard Time" }
            9 { "North Korea Standard Time" }
            10 { "Tasmania Standard Time" }
            11 { "Norfolk Standard Time" }
            12 { "New Zealand Standard Time" }
            13 { "Samoa Standard Time" }
            14 { "Line Islands Standard Time" }
            default { "GMT Standard Time" }
        }
    })
    
    $upButton = New-Object Windows.Controls.Button
    $upButton.Content = "▲"
    $upButton.FontSize = "5"
    $upButton.Width = "15"
    $upButton.Height = "7"
    $upButton.Style = $window.Resources["RoundedTopButton"]
    $upButton.Add_Click({
        $radioButton.IsChecked = $true
        Increment-TextBox -TextBox $script:textBox -Increment 1
    })

    $downButton = New-Object Windows.Controls.Button
    $downButton.Content = "▼"
    $downButton.FontSize = "5"
    $downButton.Width = "15"
    $downButton.Height = "7"
    $downButton.Style = $window.Resources["RoundedBottomButton"]
    $downButton.Add_Click({
        $radioButton.IsChecked = $true
        Increment-TextBox -TextBox $script:textBox -Increment -1
    })

    $incrementStackPanel = New-Object System.Windows.Controls.StackPanel
    $incrementStackPanel.Margin = 5
    $incrementStackPanel.VerticalAlignment = "Center"
    $incrementStackPanel.Children.Add($upButton) | Out-Null
    $incrementStackPanel.Children.Add($downButton) | Out-Null

    $horizStackPanel = New-Object System.Windows.Controls.StackPanel
    $horizStackPanel.Orientation = "Horizontal"
    $horizStackPanel.VerticalAlignment = "Center"
    $horizStackPanel.Children.Add($radioButton) | Out-Null
    $horizStackPanel.Children.Add($textBox) | Out-Null
    $horizStackPanel.Children.Add($incrementStackPanel) | Out-Null
    
    return $horizStackPanel
}

# Add other radio buttons
$radioButtons = @(
    (New-RadioButton -Name "rbPST" -Content "Pacific Time" -TimezoneId "Pacific Standard Time"),
    (New-RadioButton -Name "rbMST" -Content "Mountain Time" -TimezoneId "Mountain Standard Time"),
    (New-RadioButton -Name "rbCST" -Content "Central Time" -TimezoneId "Central Standard Time"),
    (New-RadioButton -Name "rbEST" -Content "Eastern Time" -TimezoneId "Eastern Standard Time")
    #(New-RadioButton -Name "rbUTC" -Content "UTC:" -TimezoneId "GMT Standard Time" -Special $true)
)

$radioButtons | ForEach-Object { $timezonePanel.Children.Add($_) | Out-Null }

# Shortcuts panel
Get-ChildItem -Path $neutronShortcuts -Include *.ps1,*.bat -Recurse | ForEach-Object {
    $shortcutButton = New-Object System.Windows.Controls.Button
    $shortcutButton.Content = $_.BaseName
    $shortcutButton.Background = $accentBrush
    $shortcutButton.Foreground = $accentText
    $shortcutButton.Margin = "0,0,0,10"
    $shortcutButton.Style = $window.Resources["RoundedButton"]
    $shortcutButton.Tag = $_.FullName
    $shortcutButton.Add_Click({
        $scriptPath = $this.Tag
        if ($scriptPath -like "*.ps1") {
            & $scriptPath
        } elseif ($scriptPath -like "*.bat") {
            Start-Process cmd.exe -ArgumentList "/C `"$scriptPath`""
        }
    })
    $shortcutPanel.Children.Add($shortcutButton) | Out-Null
}

# Programs panel
$outputBox.Text += "`n`n"

# Pull programs hashtable
. $hashtable

$selectedPrograms = @{}
$script:programSortMode = 'Category'

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
        Set-VectorIcon -ForegroundResource surfaceText -ResourceMappings @{ 'sortButton' = 'CategoryIcon' }
    } else {
        $script:programSortMode = 'Alphabetical'
        $sortButton.ToolTip = 'Sort by category'
        Set-VectorIcon -ForegroundResource surfaceText -ResourceMappings @{ 'sortButton' = 'TextDescendingIcon' }
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
            $program = $listBoxItem.Tag.Tag
            $programInfo = $installPrograms[$program]
            
            if ($programInfo -eq $null) { return }
            
            $isEnabled = ($script:useWinget -and $programInfo.Winget) -or
                         ($script:useChoco -and $programInfo.Choco) -or
                         ($script:useScoop -and $programInfo.Scoop) -or
                         ($script:useWingetAlt -and $programInfo.Winget) -or
                         ($script:useUrl -and $programInfo.Url) -or
                         ($script:useMirror -and $programInfo.Mirror)
            
            $listBoxItem.IsEnabled = $isEnabled
            $listBoxItem.Opacity = if ($isEnabled) { 1 } else { 0.44 }
            if (-not $isEnabled) {
                $listBoxItem.Content.Children[0].IsChecked = $false
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

# Winget alt checkbox
if ($wingetAltCheckBox.IsChecked) { $script:useWingetAlt = $true }
$wingetAltCheckBox.Add_Checked({
    $script:useWingetAlt = $true
    Update-Checkboxes
})
$wingetAltCheckBox.Add_UnChecked({
    $script:useWingetAlt = $false
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

# Mirror checkbox
if ($mirrorCheckBox.IsChecked) { $script:useMirror = $true }
$mirrorCheckBox.Add_Checked({
    $script:useMirror = $true
    Update-Checkboxes
})
$mirrorCheckBox.Add_UnChecked({
    $script:useMirror = $false
    Update-Checkboxes
})

# Construct program list and update checkbox statuses
Import-Programs

0..2 | ForEach-Object { $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }
$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({$this.DragMove()})

$runButton.Tooltip = "- Perform selected customizations `n- Set selected timezone`n- Install selected programs"
$runButton.Add_Click({
    $script:scrollToEnd = $window.FindName("scrollViewer2").ScrollToEnd()
    
    Invoke-Runspace -ScriptBlock {
        # Disable run button while runspace is running
        Invoke-Ui { $runButton.Content = "Running..."; $runButton.IsEnabled = $false }

        # Import functions into runspace
        'Copy-WebItem', 'Install-Choco', 'Install-Program', 'Install-Scoop', 'Install-Winget' | ForEach-Object {
            . "$functionsPath\$_.ps1"
        }
        
        # Run Customizations
        if ($selectedScripts -ne $null) {
            Write-Host "Customizations:"
            foreach ($script in $selectedScripts) { Invoke-Expression $script }
            Write-Host ""
        }
        
        # Set Timezone
        if ($checkedTimezone) {
            Write-Host "Timezone"

            try {
                Start-Service w32time
                w32tm /resync
                Write-Host "- Time synchronized"
            } catch {
                Write-Host "- Failed to sync time"
            }
        }
        
        # Install package managers
        if ($selectedPrograms -ne $null) {
            switch ($true) {
                $useWinget { Install-Winget }
                $useChoco  { Install-Choco }
                $useScoop  { Install-Scoop }
            }
        }

        # Install selected programs
        foreach ($program in $selectedPrograms.Keys) {
            $params = $selectedPrograms.$program

            Write-Host $program

            if ($useWinget -and $params.Winget -and (Install-Program -FilePath 'winget' -ArgumentList "install --id $($params.Winget) --accept-package-agreements --accept-source-agreements --force" -Description 'Winget')) { continue }
            if ($useChoco -and $params.Choco -and (Install-Program -FilePath 'choco' -ArgumentList "install $($params.Choco) -y" -Description 'Choco')) { continue }
            if ($useScoop -and $params.Scoop -and (Install-Program -FilePath 'powershell' -ArgumentList "scoop install $($params.Scoop)" -Description 'Scoop')) { continue }
            if ($useWingetAlt -and $params.Winget -and (Install-Program -Url (winget show $params.Winget | Select-String "Installer Url").Line.Replace("Installer Url: ", "").Trim() -Description 'Winget URL')) { continue }
            if ($useUrl -and $params.Url -and (Install-Program -Url $params.Url -Description 'URL')) { continue }
            if ($useMirror -and $params.Mirror -and (Install-Program -Url $params.Mirror -Description 'Mirror')) { continue }
        }
        
        # Uncheck customizations checkboxes
        Invoke-Ui {
            foreach ($item in $customizationPanel.Items) {
                if ($item.IsChecked) {
                    $item.IsChecked = $false
                    $item.IsEnabled = $false
                    $item.Opacity = 0.44
                }
            }
        }
        
        # Uncheck programs checkboxes
        Invoke-Ui {
            foreach ($item in $installPanel.Children.Items.Content.Children) {
                if ($item -is [System.Windows.Controls.CheckBox]) {
                    $item.IsChecked = $false
                }
            }
        }
        
        # Save log
        $outputText = Invoke-Ui -GetValue { $outputBox.Text }
        $dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
        $logPath = Join-Path $atomTemp "neutron-$dateTime.txt"
        $outputText | Out-File -FilePath $logPath
        Write-Host "`nLog saved to $logPath"
        
        # Success message
        Write-Host "`nNeutron completed."
        
        # Re-enable run button
        Invoke-Ui { $runButton.Content = "Run"; $runButton.IsEnabled = $true }
    }
})

Set-WindowSize

$window.ShowDialog() | Out-Null
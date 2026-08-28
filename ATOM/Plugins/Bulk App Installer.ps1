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
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

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
                                        <CheckBox Name="wingetAltCheckBox" Content="Winget alt" Foreground="{DynamicResource surfaceText}" IsChecked="True" Margin="5" ToolTip="Download w/ Winget's 'Installer Url' [Priority-4]&#x0a;[URL] [Winget] [No Hash Validation]"/>
                                        <CheckBox Name="urlCheckBox" Content="URL" Foreground="{DynamicResource surfaceText}" IsChecked="True" Margin="5" ToolTip="Download w/ direct URL [Priority-5]&#x0a;[URL] [Vendor Site]"/>
                                        <CheckBox Name="mirrorCheckBox" Content="Mirror" Foreground="{DynamicResource surfaceText}" IsChecked="False" Margin="5" ToolTip="Download w/ mirror URL [Priority-6]&#x0a;[URL] [Mirror Site]"/>
                                    </WrapPanel>
                                </StackPanel>
                            </Border>

                            <StackPanel Name="installPanel" Margin="10,0,10,5"/>
                        </StackPanel>
                    </ScrollViewer>

                    <Border Name="searchBar" Panel.ZIndex="10" Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" VerticalAlignment="Top" Margin="10,10,28,5" Padding="5">
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

                <Border Grid.Column="1" Style="{StaticResource CustomOutputBorder}" Margin="0,10,10,10">
                    <Grid>

                        <ScrollViewer Name="scrollViewer1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                            <TextBlock Name="outputBox" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Stretch" TextWrapping="Wrap" VerticalAlignment="Stretch" Padding="10"/>
                        </ScrollViewer>

                    </Grid>
                </Border>

                <Button Name="runButton" Grid.Row="1" Grid.ColumnSpan="2" Content="Run"
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
    MinWidth    = 800
    MinHeight   = 600
    MaxWidth    = 800
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
$wingetAltCheckBox  = $window.FindName('wingetAltCheckBox')
$urlCheckBox        = $window.FindName('urlCheckBox')
$mirrorCheckBox     = $window.FindName('mirrorCheckBox')
$outputBox          = $window.FindName('outputBox')

# Set icon sources
Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{
    'backspaceButton' = 'BackspaceIcon'
    'searchImage' = 'SearchIcon'
    'sortButton' = 'CategoryIcon'
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

Add-AtomScrollViewerBehavior -Window $window -Name 'scrollViewer0', 'scrollViewer1'

$runButton.Tooltip = "Install selected programs"
$runButton.Add_Click({
    $script:scrollToEnd = $window.FindName("scrollViewer1").ScrollToEnd()
    
    Invoke-Runspace -ScriptBlock {
        # Disable run button while runspace is running
        Invoke-Ui { $runButton.Content = "Running..."; $runButton.IsEnabled = $false }

        # Import functions into runspace
        'Copy-WebItem', 'Install-Choco', 'Install-Program', 'Install-Scoop', 'Install-Winget' | ForEach-Object {
            . "$functionsPath\$_.ps1"
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
        $logPath = Join-Path $atomTemp "bulk-app-installer-$dateTime.txt"
        $outputText | Out-File -FilePath $logPath
        Write-Host "`nLog saved to $logPath"
        
        # Success message
        Write-Host "`nBulk App Installer completed."
        
        # Re-enable run button
        Invoke-Ui {
            $runButton.Content = 'Run'
            $runButton.IsEnabled = $true
        }
    }
})

Set-WindowSize

$window.ShowDialog() | Out-Null

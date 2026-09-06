Add-Type -AssemblyName PresentationFramework

# Import module(s)
$debloatFunctions = @(
    'Get-App'
    'Invoke-Runspace'
)
Import-Module "$psScriptRoot\..\Functions\AtomModule.psm1" -ArgumentList (,$debloatFunctions) -Function $debloatFunctions -Variable *
Import-Module "$psScriptRoot\..\Functions\AtomWpfModule.psm1"
$windowsDebloatTuneDependencies  = "$psScriptRoot\Windows Debloat & Tune"
$windowsDebloatTuneFunctions     = "$windowsDebloatTuneDependencies\Functions"
$windowsDebloatTuneOptimizations = "$windowsDebloatTuneDependencies\Optimizations"
$customizationsPath     = "$windowsDebloatTuneDependencies\Customizations.ps1"

$contentXaml = @"
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="0"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            
            
            <Grid Grid.Row="1" Margin="0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                
                <ScrollViewer Name="scrollViewer0" Grid.Column="0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                    <StackPanel Name="uninstallPanel" Margin="0,10,10,5"/>
                </ScrollViewer>
                
                <Border Grid.Column="1" Style="{StaticResource CustomOutputBorder}" Margin="5,10,10,0">
                    <TextBox Name="outputBox" IsReadOnly="True" IsUndoEnabled="False" AcceptsReturn="True" Background="Transparent" BorderThickness="0" Foreground="{DynamicResource surfaceText}" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Padding="10"/>
                </Border>
            </Grid>
            
            <Grid Grid.Row="2">
                <Button Name="runButton" Content="Run" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" Margin="10" Style="{StaticResource RoundedButton}"/>
            </Grid>
            
        </Grid>
"@

$windowParameters = @{
    Title       = 'Windows Debloat & Tune'
    IconPath    = "$windowsDebloatTuneDependencies\Windows Debloat & Tune.png"
    ContentXaml = $contentXaml
    Width       = 600
    Height      = 800
    MinWidth    = 400
    MinHeight   = 600
    MaxWidth    = 800
    MaxHeight   = 1000
}
$window = New-AtomWindow @windowParameters

# Assign variables to elements in XAML
$runButton      = $window.Findname('runButton')
$uninstallPanel = $window.FindName('uninstallPanel')
$outputBox      = $window.FindName('outputBox')

# Set icon sources
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

# Customizations panel
$customizationsTextBlock = New-Object System.Windows.Controls.TextBlock
$customizationsTextBlock.Text = "Customizations"
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
$uninstallPanel.Children.Add($customizationPanel) | Out-Null

$winVer = ((Get-CimInstance -ClassName Win32_OperatingSystem).Caption.Split(' ')[-2])
$winBuild = (Get-CimInstance -ClassName Win32_OperatingSystem).BuildNumber

. $customizationsPath

foreach ($name in $customizations.Keys) {
    $customization = $customizations[$name]
    $checkBox = New-ListBoxControlItem -ControlType CheckBox -Text $name -ToolTip $customization.ToolTip -Tag $customization.Action.ToString() -TextForeground $surfaceText
    $checkBox.BorderThickness = 1

    $isAvailable = (!$customization.MinimumWindowsVersion -or $winVer -ge $customization.MinimumWindowsVersion) -and
        (!$customization.MinimumWindowsBuild -or $winBuild -ge $customization.MinimumWindowsBuild)

    if ($isAvailable -and $customization.ShowIf) {
        $isAvailable = & $customization.ShowIf
    }

    if (!$isAvailable) {
        $checkBox.IsEnabled = $false
        $checkBox.Opacity = 0.44
    }

    $customizationPanel.Items.Add($checkBox) | Out-Null
}

# Optimizations panel
$optimizationsCheckbox = New-Object System.Windows.Controls.CheckBox
$optimizationsCheckbox.Content = "Optimizations"
$optimizationsCheckbox.ToolTip = "Check all optimizations."
$optimizationsCheckbox.FontWeight = "Bold"
$optimizationsCheckbox.Foreground = $backgroundText
$optimizationsCheckbox.Margin = "10,5,0,0"
$uninstallPanel.Children.Add($optimizationsCheckbox) | Out-Null

$optimizationsListBox = New-Object System.Windows.Controls.ListBox
$optimizationsListBox.Background = $surfaceColor
$optimizationsListBox.Foreground = $surfaceText
$optimizationsListBox.BorderThickness = 0
$optimizationsListBox.Margin = "10,5,0,5"
$optimizationsListBox.Style = $window.Resources["CustomListBoxStyle"]
$uninstallPanel.Children.Add($optimizationsListBox) | Out-Null

Get-ChildItem -Path $windowsDebloatTuneOptimizations -Filter *.ps1 | Sort-Object | ForEach-Object {
    $checkBox = New-ListBoxControlItem -ControlType CheckBox -Text $_.BaseName -Tag $_.FullName -TextForeground $surfaceText
    $checkBox.BorderThickness = 1
    
    # Add tooltip if first line of script starts with "$tooltip = "
    $firstLine = Get-Content $_.FullName -First 1
    if ($firstLine.StartsWith('$tooltip = ')) {
        Invoke-Expression $firstLine
        $checkBox.ToolTip = $tooltip
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
# Import programs hashtable
$programsHashtable = Join-Path $windowsDebloatTuneDependencies "Programs.ps1"
. $programsHashtable

$installedApps = @(Get-App)
$detectionContext = [PSCustomObject]@{ InstalledApps = $installedApps }
$seenPrograms = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
$detectedPrograms = @{}
foreach ($name in $programs.Keys) {
    $definition = $programs[$name]
    try {
        if ($definition.Detect) {
            if (!$definition.Uninstall) { throw 'Custom detection requires an Uninstall action.' }
            $detectedMatches = @(& $definition.Detect $detectionContext)
        } else {
            $patterns = if ($definition.Match) { @($definition.Match) } else { @([regex]::Escape($name)) }
            $detectedMatches = @(foreach ($app in $installedApps) {
                foreach ($pattern in $patterns) {
                    if ($app.DisplayName -match $pattern) { $app; break }
                }
            })
        }
        foreach ($match in $detectedMatches) {
            $id = if ($definition.Detect) { "custom:$name|$($match.Id)" } else { "registry:$($match.PsPath)" }
            if (!$match.DisplayName -or ($definition.Detect -and !$match.Id) -or (!$definition.Detect -and !$match.PsPath)) {
                throw 'Detection returned a record without a name or stable ID.'
            }
            # Overlapping definitions must not select the same installation twice.
            if (!$seenPrograms.Add($id)) { continue }
            if (!$detectedPrograms.ContainsKey($definition.Category)) { $detectedPrograms[$definition.Category] = @{} }
            $detectedPrograms[$definition.Category][$id] = [PSCustomObject]@{
                Id = $id
                Definition = $name
                DisplayName = $match.DisplayName
                ToolTip = $definition.ToolTip
                Target = $match
            }
        }
    } catch { Write-Warning "Unable to detect '$name': $($_.Exception.Message)" }
}

# Listboxes hashtable
$listBoxes = @{}

# Create listboxes w/ checkboxes for detected programs.
# If no matching programs are detected, this loop simply does nothing;
# do not return here because this code runs in the script scope.
foreach ($category in $detectedPrograms.Keys) {
    # create a TextBlock for the category name and add it to the stackPanel
    $categoryCheckBox = New-Object System.Windows.Controls.CheckBox
    $categoryCheckBox.Content = $category
    $categoryCheckBox.Tag = $category
    $categoryCheckBox.ToolTip = "Check all $category apps that are safe to remove."
    $categoryCheckBox.FontWeight = "Bold"
    $categoryCheckBox.Foreground = $backgroundText
    $categoryCheckBox.Margin = "10,5,0,0"
    $uninstallPanel.Children.Add($categoryCheckBox) | Out-Null
    
    # create a listBox for the programs in this category
    $listBox = New-Object System.Windows.Controls.ListBox
    $listBox.Background = $surfaceBrush
    $listBox.Foreground = $surfaceText
    $listBox.BorderThickness = 0
    $listBox.Margin = "10,5,0,5"
    $listBox.Style = $window.Resources["CustomListBoxStyle"]
    $uninstallPanel.Children.Add($listBox) | Out-Null
    
    $listBoxes.$category = $listBox
    
    $categoryCheckBox.Add_Checked({
        $currentCategory = $this.Tag
        foreach ($item in $listBoxes.$currentCategory.Items) {
            $item.Control.IsChecked = $true
        }
    })
    
    $categoryCheckBox.Add_Unchecked({
        $currentCategory = $this.Tag
        foreach ($item in $listBoxes.$currentCategory.Items) {
            $item.Control.IsChecked = $false
        }
    })
    
    # Add programs under the category
    foreach ($record in ($detectedPrograms[$category].Values | Sort-Object DisplayName, Id)) {
        $checkBox = New-ListBoxControlItem -ControlType CheckBox -Text $record.DisplayName -Tag $record -TextForeground $surfaceText
        $checkBox.BorderThickness = 1
        if ($record.ToolTip) { $checkBox.ToolTip = $record.ToolTip }
        $checkBox.Foreground = $surfaceText
        $checkBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

        $listBox.Items.Add($checkbox) | Out-Null
    }
}

# Apps panel
# Import $apps hashtable
$appsHashtable = Join-Path $windowsDebloatTuneDependencies "Apps.ps1"
. $appsHashtable

# Variables needed in foreach loop
$detectedApps = @()
$packagesPath = Join-Path $env:LOCALAPPDATA "Packages"

# Iterate through $apps hashtable and search for apps
foreach ($app in $apps.Keys) {
    $packageName = $apps[$app]["PackageName"]
    $publisherId = $apps[$app]["PublisherId"]
    $appPath = Join-Path $packagesPath "$($packageName)_$($publisherId)"
    $userDataPath = Join-Path $appPath $apps[$app]["UserData"]
    
    # Add app to detectedApps array if detected
    if (Test-Path $appPath) {
        $detectedApps += $app
    }
    
    # Add user data detection to hashtable
    if (($apps[$app]["UserData"] -ne $null) -and (Test-Path $userDataPath)) {
        $apps[$app].UserDataDetected = $true
    }
}

# Create panel for apps
$appxListBox = $null
if ($detectedApps.Count -ge 1) {
    # Master checkbox
    $appxCheckbox = New-Object System.Windows.Controls.CheckBox
    $appxCheckbox.Content = "AppX Bloatware"
    $appxCheckbox.ToolTip = "Check all AppX apps that are safe to remove."
    $appxCheckbox.FontWeight = "Bold"
    $appxCheckbox.Foreground = $backgroundText
    $appxCheckbox.Margin = "10,5,0,0"

    $appxListBox = New-Object System.Windows.Controls.ListBox
    $appxListBox.Margin = "10,5,0,5"
    $appxListBox.Style = $window.Resources["CustomListBoxStyle"]
    
    $uninstallPanel.Children.Add($appxCheckbox) | Out-Null
    $uninstallPanel.Children.Add($appxListBox) | Out-Null
    
    # Create individual checkboxes for all detected apps
    foreach ($detectedApp in $detectedApps) {
        $checkBox = New-ListBoxControlItem -ControlType CheckBox -Text $detectedApp -Tag $detectedApp -TextForeground $surfaceText
        $checkBox.BorderThickness = 1
        
        # Variables to check key booleans
        $isImportant = $apps[$detectedApp]["Important"] -eq $true
        $isUserDataDetected = $apps[$detectedApp]["UserDataDetected"] -eq $true
        
        # If Important key or UserDataDetected key are true
        if ($isImportant -or $isUserDataDetected) {
            $checkBox.ToolTip = "$($detectedApp)`n"
        }
        
        # If Important key is $true
        if ($isImportant) {
            $checkBox.Text.Text += " [I]"
            $checkBox.ToolTip += "[I] Important`n"
            $checkBox.ToolTip += "Potentially important app.`n"
            $checkBox.ToolTip += "This app will not be checked by the AppX Bloatware checkbox."
        }
        
        # If UserDataDetected key is $true
        if ($isUserDataDetected) {
            $checkBox.Text.Text += " [UD]"
            if ($checkBox.ToolTip -ne $null) { $checkBox.ToolTip += "`n" }
            $checkBox.ToolTip += "[UD] User Data`n"
            $checkBox.ToolTip += "User data detected, user has used app.`n"
            $checkBox.ToolTip += "This app will not be checked by the AppX Bloatware checkbox."
        }
        
        $appxListBox.Items.Add($checkBox) | Out-Null
    }
    
    # Master checkbox - check event handler
    $appxCheckbox.Add_Checked({
        foreach ($item in $appxListBox.Items) {
            $important = $apps[$item.Control.Tag]["Important"]
            $userDataDetected = $apps[$item.Control.Tag]["UserDataDetected"]
            
            if (($important -ne $true) -and ($userDataDetected -ne $true)) {
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

Add-AtomScrollViewerBehavior -Window $window -Name 'scrollViewer0'

$runButton.Tooltip = "- Perform selected customizations `n- Perform selected optimizations `n- Uninstall selected apps"
$script:debloatRunState = [Hashtable]::Synchronized(@{ Running = $false; Complete = $false; Closed = $false })
$script:debloatOutputQueue = [Collections.Concurrent.ConcurrentQueue[String]]::new()
$outputTimer = [Windows.Threading.DispatcherTimer]::new([Windows.Threading.DispatcherPriority]::Background)
$outputTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$outputTimer.Add_Tick({
    $batch = [Text.StringBuilder]::new()
    $line = $null
    for ($i = 0; $i -lt 128 -and $batch.Length -lt 32768; $i++) {
        if (!$script:debloatOutputQueue.TryDequeue([ref]$line)) { break }
        [void]$batch.AppendLine($line)
    }
    if ($batch.Length) {
        $atBottom = $outputBox.VerticalOffset + $outputBox.ViewportHeight -ge $outputBox.ExtentHeight - 1
        $offset = $outputBox.VerticalOffset
        $outputBox.BeginChange()
        try {
            $outputBox.AppendText($batch.ToString())
            # Keep only recent output in the control; the saved log is complete.
            if ($outputBox.Text.Length -gt 100000) {
                $remove = $outputBox.Text.Length - 75000
                $lineEnd = $outputBox.Text.IndexOf("`n", $remove)
                if ($lineEnd -ge 0) { $remove = $lineEnd + 1 }
                $selectionStart = $outputBox.SelectionStart
                $selectionEnd = $selectionStart + $outputBox.SelectionLength
                $outputBox.UpdateLayout()
                $oldHeight = $outputBox.ExtentHeight
                $outputBox.Select(0, $remove)
                $outputBox.SelectedText = ''
                $outputBox.Select([Math]::Max(0, $selectionStart - $remove), [Math]::Max(0, $selectionEnd - [Math]::Max($selectionStart, $remove)))
                $outputBox.UpdateLayout()
                $offset = [Math]::Max(0, $offset - ($oldHeight - $outputBox.ExtentHeight))
            }
        } finally { $outputBox.EndChange() }
        if ($atBottom) { $outputBox.ScrollToEnd() } else { $outputBox.ScrollToVerticalOffset($offset) }
    }
    # Drain the completion summary before another run can clear the output.
    if ($script:debloatRunState.Complete -and $script:debloatOutputQueue.IsEmpty) {
        $this.Stop()
        $runButton.Content = 'Run'
        $runButton.IsEnabled = $true
        $uninstallPanel.IsEnabled = $true
        $script:debloatRunState.Running = $false
    }
})
$window.Add_Closed({
    $script:debloatRunState.Closed = $true
    $outputTimer.Stop()
})
$runButton.Add_Click({
    if ($script:debloatRunState.Running) { return }

    # Capture data before dispatch; workers never read mutable selection controls.
    $queue = [Collections.Generic.List[Object]]::new()
    foreach ($item in $customizationPanel.Items) {
        if ($item.IsEnabled -and $item.Control.IsChecked) {
            $queue.Add([PSCustomObject]@{ Kind = 'Customization'; Name = [String]$item.Text.Text; Script = [String]$item.Control.Tag })
        }
    }
    foreach ($item in $optimizationsListBox.Items) {
        if ($item.IsEnabled -and $item.Control.IsChecked) {
            $queue.Add([PSCustomObject]@{ Kind = 'Optimization'; Name = [String]$item.Text.Text; Path = [String]$item.Control.Tag })
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
        $outputBox.Text = 'Select at least one action to run.'
        return
    }

    $script:debloatRunState.Running = $true
    $script:debloatRunState.Complete = $false
    $runButton.IsEnabled = $false
    $runButton.Content = 'Running...'
    $uninstallPanel.IsEnabled = $false
    $outputBox.Text = ''
    $outputTimer.Start()
    $runLog = [Text.StringBuilder]::new()
    $logPath = Join-Path $atomTemp ("windows-debloat-and-tune-{0}-{1}.txt" -f (Get-Date -Format 'yyyyMMdd_HHmmss'), [Guid]::NewGuid().ToString('N').Substring(0,8))

    try {
        Invoke-Runspace -Isolated -InputVariables @{
            Queue = $queue.ToArray()
            RunLog = $runLog
            LogPath = $logPath
            FunctionsPath = $functionsPath
            RunState = $script:debloatRunState
            OutputQueue = $script:debloatOutputQueue
        } -ScriptBlock {
            $ErrorActionPreference = 'Stop'
            $completed = 0
            $failed = 0
            $attempted = 0
            $fatalError = $null
            function Write-Host {
                param([Parameter(ValueFromRemainingArguments)] [Object[]]$Object)
                $text = $Object -join ' '
                [void]$RunLog.AppendLine($text)
                if (!$RunState.Closed) {
                    if ($text.Length -gt 75000) { $text = $text.Substring($text.Length - 75000) }
                    $OutputQueue.Enqueue($text)
                }
            }
            try {
                . (Join-Path $FunctionsPath 'Remove-App.ps1')
                Write-Host "Running $($Queue.Count) selected actions."
                foreach ($action in $Queue) {
                    $attempted++
                    Write-Host "$attempted/$($Queue.Count): $($action.Name)"
                    try {
                        # A child scope keeps action-local variables out of the queue runner.
                        & {
                            $ErrorActionPreference = 'Stop'
                            switch ($action.Kind) {
                                'Customization' { & ([ScriptBlock]::Create($action.Script)) }
                                'Optimization' { & $action.Path }
                                'Program' {
                                    if ($action.Script) { & ([ScriptBlock]::Create($action.Script)) $action.Target }
                                    else { Remove-App -App $action.Target -ErrorAction Stop }
                                }
                                'AppX' {
                                    $packages = @(Get-AppxPackage -Name $action.PackageName -ErrorAction Stop)
                                    if (!$packages.Count) { Write-Host '  Already absent'; break }
                                    $packages | Remove-AppxPackage -ErrorAction Stop
                                    if (Get-AppxPackage -Name $action.PackageName -ErrorAction Stop) {
                                        throw 'App package is still installed.'
                                    }
                                }
                                default { throw "Unknown action type: $($action.Kind)" }
                            }
                        } | ForEach-Object { Write-Host ([String]$_) }
                        $completed++
                        Write-Host '  Completed'
                    } catch {
                        $failed++
                        Write-Host "  Failed: $($_.Exception.Message)"
                    }
                }
            } catch {
                $fatalError = $_.Exception.Message
                Write-Host "Run stopped: $fatalError"
            } finally {
                $notRun = $Queue.Count - $attempted
                $summary = "$completed completed; $failed failed; $notRun not run."
                if ($fatalError) { $summary += " Run error: $fatalError" }
                Write-Host $summary
                try {
                    [IO.File]::WriteAllText($LogPath, $RunLog.ToString())
                    Write-Host "Log saved to $LogPath"
                } catch {
                    Write-Host "Could not save log: $($_.Exception.Message)"
                } finally {
                    $RunState.Complete = $true
                }
            }
        }
    } catch {
        $message = "Unable to start run: $($_.Exception.Message)"
        [void]$runLog.AppendLine($message)
        try {
            [IO.File]::WriteAllText($logPath, $runLog.ToString())
            $message += "`nLog saved to $logPath"
        } catch { $message += "`nCould not save log: $($_.Exception.Message)" }
        finally {
            $outputTimer.Stop()
            $outputBox.Text = $message
            $runButton.Content = 'Run'
            $runButton.IsEnabled = $true
            $uninstallPanel.IsEnabled = $true
            $script:debloatRunState.Running = $false
        }
    }
})

Set-WindowSize

$window.ShowDialog() | Out-Null

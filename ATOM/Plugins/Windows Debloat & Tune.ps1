Add-Type -AssemblyName PresentationFramework

# Import module(s)
Import-Module "$psScriptRoot\..\Functions\AtomModule.psm1"
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
                    <ScrollViewer Name="scrollViewer1" Grid.Column="1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                        <TextBlock Name="outputBox" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Stretch" TextWrapping="Wrap" VerticalAlignment="Stretch" Padding="10"/>
                    </ScrollViewer>
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

$selectedCustomizations = New-Object System.Collections.ArrayList
foreach ($key in $customizations.Keys) {
    $customization = $customizations[$key]

    $checkBox = New-Object System.Windows.Controls.CheckBox
    $checkBox.Content = $key
    $checkBox.ToolTip = $customization.Tooltip
    $checkBox.Tag = $customization.Scriptblock.ToString()
    $checkBox.Foreground = $surfaceText
    $checkBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $checkBox.Add_Checked({ $selectedCustomizations.Add($this.Tag) | Out-Null })
    $checkBox.Add_Unchecked({ $selectedCustomizations.Remove($this.Tag) | Out-Null })

    if (!(& $customization.Predicate)) {
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
    $checkBox = New-Object System.Windows.Controls.CheckBox
    $checkBox.Content = $_.BaseName
    $checkBox.Tag = $_.FullName
    $checkBox.Foreground = $surfaceText
    $checkBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    
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
            $item.IsChecked = $true
        }
    }
})

$optimizationsCheckbox.Add_Unchecked({
    foreach ($item in $optimizationsItems) {
        if ($item.IsEnabled) {
            $item.IsChecked = $false
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
            $item.IsChecked = $true
        }
    })
    
    $categoryCheckBox.Add_Unchecked({
        $currentCategory = $this.Tag
        foreach ($item in $listBoxes.$currentCategory.Items) {
            $item.IsChecked = $false
        }
    })
    
    # Add programs under the category
    foreach ($record in ($detectedPrograms[$category].Values | Sort-Object DisplayName, Id)) {
        $checkBox = New-Object System.Windows.Controls.CheckBox
        $checkBox.Content = $record.DisplayName
        $checkBox.Tag = $record
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
    $selectedApps = New-Object System.Collections.ArrayList
    foreach ($detectedApp in $detectedApps) {
        $checkBox = New-Object System.Windows.Controls.CheckBox
        $checkBox.Content = $detectedApp
        $checkBox.Tag = $detectedApp
        $checkBox.Foreground = $surfaceText
        $checkBox.VerticalAlignment = "Center"
        
        # Variables to check key booleans
        $isImportant = $apps[$detectedApp]["Important"] -eq $true
        $isUserDataDetected = $apps[$detectedApp]["UserDataDetected"] -eq $true
        
        # If Important key or UserDataDetected key are true
        if ($isImportant -or $isUserDataDetected) {
            $checkBox.ToolTip = "$($detectedApp)`n"
        }
        
        # If Important key is $true
        if ($isImportant) {
            $checkBox.Content += " [I]"
            $checkBox.ToolTip += "[I] Important`n"
            $checkBox.ToolTip += "Potentially important app.`n"
            $checkBox.ToolTip += "This app will not be checked by the AppX Bloatware checkbox."
        }
        
        # If UserDataDetected key is $true
        if ($isUserDataDetected) {
            $checkBox.Content += " [UD]"
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
            $important = $apps[$item.Tag]["Important"]
            $userDataDetected = $apps[$item.Tag]["UserDataDetected"]
            
            if (($important -ne $true) -and ($userDataDetected -ne $true)) {
                $item.IsChecked = $true
                if (!$selectedApps.Contains($item.Tag)) {
                    $selectedApps.Add($item.Tag) | Out-Null
                }
            }
        }
    })
    
    # Master checkbox - uncheck event handler
    $appxCheckbox.Add_Unchecked({
        foreach ($item in $appxListBox.Items) {
            $item.IsChecked = $false
            $selectedApps.Remove($item.Tag) | Out-Null
        }
    })
}

Add-AtomScrollViewerBehavior -Window $window -Name 'scrollViewer0', 'scrollViewer1'

$runButton.Tooltip = "- Perform selected customizations `n- Perform selected optimizations `n- Uninstall selected apps"
$runButton.Add_Click({
    $script:outputScrollViewer = $window.FindName('scrollViewer1')

    $script:customizationsToRun = @($selectedCustomizations)
    $script:selectedScripts = ($optimizationsItems | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag }) -join ";"
    $script:selectedPrograms = $listBoxes.Values | ForEach-Object { $_.Items } | Where-Object { $_.IsChecked } | ForEach-Object { $_.Tag }
    $script:selectedApps = $appxListBox.Items | Where-Object { $_.IsChecked } | ForEach-Object { $_.Tag }

    Invoke-Runspace -ScriptBlock {
        # Disable update button while runspace is running
        Invoke-Ui { $runButton.Content = "Running..."; $runButton.IsEnabled = $false }
        
        # Import programs and apps hashtables into runspace
        . $programsHashtable
        . $appsHashtable
        . (Join-Path $functionsPath 'Remove-App.ps1')
        
        # Import functions into runspace
        Get-ChildItem -Path $windowsDebloatTuneFunctions -Filter *.ps1 | ForEach-Object {
            Invoke-Expression -Command (Get-Content $_.FullName | Out-String)
        }
        
        # Set Timezone
        <# Disabled with the Timezones panel.
        if ($checkedTimezone) {
            Write-Host "Timezone"

            try {
                tzutil /s "$checkedTimezone"
                Start-Service w32time
                w32tm /resync
                Write-Host "- Set to $checkedTimezone"
            } catch {
                Write-Host "- Failed to set timezone"
            }

            Write-Host ""
        }

        #>

        # Run Customizations
        if ($customizationsToRun.Count) {
            Write-Host "Customizations:"
            foreach ($script in $customizationsToRun) { Invoke-Expression $script }
            Write-Host ""
        }

        # Perform checked optimizations
        Perform-Optimizations
        
        # Uninstall checked programs
        if ($selectedPrograms) { Write-Host 'Programs' }
        foreach ($record in $selectedPrograms) {
            try {
                $definition = $programs[$record.Definition]
                if (!$definition) { throw "Definition '$($record.Definition)' is unavailable." }
                Write-Host "- Uninstalling $($record.DisplayName)"
                if ($definition.Uninstall) {
                    & $definition.Uninstall $record.Target
                    Write-Host '  > Custom removal completed'
                } else {
                    Remove-App -App $record.Target -ErrorAction Stop
                    Write-Host '  > Program uninstalled'
                }
            } catch {
                Write-Host "  > Failed: $($_.Exception.Message)"
            }
        }
        
        # Uninstall checked apps
        Uninstall-Apps
        
        # Uncheck customizations
        Invoke-Ui {
            foreach ($item in $customizationPanel.Items) {
                if ($item.IsChecked) { $item.IsChecked = $false }
            }
        }

        # Save log
        $outputText = Invoke-Ui -GetValue { $outputBox.Text }
        $dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
        $logPath = Join-Path $atomTemp "windows-debloat-and-tune-$dateTime.txt"
        $outputText | Out-File -FilePath $logPath
        Write-Host "Log saved to $logPath"
        
        # Success message
        Write-Host "`nWindows Debloat & Tune finished."
        
        # Re-enable run button
        Invoke-Ui { $runButton.Content = "Run"; $runButton.IsEnabled = $true }
    }
})

Set-WindowSize

$window.ShowDialog() | Out-Null

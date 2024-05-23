Add-Type -AssemblyName System.Windows.Forms

#############################
####   NAV STACKPANEL    ####
#############################

$navButton = $window.FindName("navButton")
$navButton.Add_Click({
	$script:settingsToggled = $false
	$scrollViewer.Visibility = "Visible"
	$scrollViewerSettings.Visibility = "Collapsed"
	
	Load-Plugins
})

#############################
####  UPDATE  STACKPANEL ####
#############################

$versionText = $window.FindName("versionText")
$versionText.Text = "$version"

$versionHash = $window.FindName("versionHash")
$localCommitPath = Join-Path $settingsPath "hash.txt"
$localCommitHash = Get-Content -Path $localCommitPath
$versionHash.Text = "$($localCommitHash.Substring(0, 7))"

$updateText = $window.FindName("updateText")
$lastCheckedPath = Join-Path $settingsPath "time.txt"
if (Test-Path $lastCheckedPath) { $lastCheckedContent = Get-Content -Path $lastCheckedPath }
$updateText.Text = "$lastCheckedContent"

function Check-Updates {
	$apiUrl = "https://api.github.com/repos/SkylerWallace/ATOM/commits?per_page=1"
	$response = Invoke-RestMethod -Uri $apiUrl
	$authorName = $response[0].commit.author.name
	$latestCommitHash = 
		if ($authorName -eq "GitHub Actions") { $response[0].parents[0].sha }
		else { $response[0].sha }
	
	if ($localCommitHash -ne $latestCommitHash) {
		$updateButton.Opacity = 1.0
		$updateButton.IsEnabled = "True"
		$updateButtonText.Text = "Update ATOM"
		$updateText.Text = "Update available!"
	} else {
		Get-Date -Format "MM/dd/yy h:mmtt" | Out-File $lastCheckedPath
		$lastCheckedContent = Get-Content -Path $lastCheckedPath
		$updateText.Text = "$lastCheckedContent"
	}
}

$checkUpdateButton = $window.FindName("checkUpdateButton")
$checkUpdateButton.Add_Click({ Check-Updates })

$updateButton = $window.FindName("updateButton")
$updateButton.Add_Click({
	$updateAtomPath = Join-Path $dependenciesPath "Update-ATOM.ps1"
	Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$updateAtomPath`""
})

#############################
#### SWITCHES STACKPANEL ####
#############################

function Create-Switch {
	param($switchName,$variableName)
	
	New-Variable -Name $switchName -Value $window.FindName($switchName) -Scope Script
	(Get-Variable -Name $switchName -ValueOnly).IsChecked = if ((Get-Variable -Name $variableName -ValueOnly) -eq $true) { $true } else { $false }
	
	(Get-Variable -Name $switchName -ValueOnly).Tag = $variableName
	(Get-Variable -Name $switchName -ValueOnly).Add_Click({
		Set-Variable -Name $this.Tag -Value $this.IsChecked -Scope Script
	})
}

## SWITCHES
###########

Create-Switch -SwitchName "keysSwitch" -VariableName "saveEncryptionKeys"
Create-Switch -SwitchName "restartSwitch" -VariableName "launchOnRestart"
Create-Switch -SwitchName "tooltipSwitch" -VariableName "showTooltips"
Create-Switch -SwitchName "hiddenSwitch" -VariableName "showHiddenPlugins"
Create-Switch -SwitchName "additionalSwitch" -VariableName "showAdditionalPlugins"
Create-Switch -SwitchName "debugSwitch" -VariableName "debugMode"

## STARTUP COLUMNS
##################

$startupColumnsStackPanel = $window.FindName("startupColumnsStackPanel")
for ($i = 1; $i -le 3; $i++) {
	$columnRdBtn = New-Object System.Windows.Controls.RadioButton
	$columnRdBtn.Content = $i
	$columnRdBtn.Tag = $i
	$columnRdBtn.Foreground = $surfaceText
	$columnRdBtn.GroupName = "Columns"
	$columnRdBtn.Margin = 5
	$columnRdBtn.Add_Click({ $script:startupColumns = $this.Content })
	if ($startupColumns -eq $i) { $columnRdBtn.IsChecked = $true } else { $columnRdBtn.IsChecked = $false }
	$startupColumnsStackPanel.Children.Add($columnRdBtn) | Out-Null
}

## DEFAULT/SAVE SETTINGS
########################

$defaultSwitchButton = $window.FindName("defaultSwitchButton")
$defaultSwitchButton.Add_Click({
	# Load default settings
	. (Join-Path $settingsPath "Settings-Default.ps1")
	
	# Update switches
	$keysSwitch.IsChecked = if ($saveEncryptionKeys -eq $true) { $true } else { $false }
	$restartSwitch.IsChecked = if ($launchOnRestart -eq $true) { $true } else { $false }
	$tooltipSwitch.IsChecked = if ($showTooltips -eq $true) { $true } else { $false }
	$hiddenSwitch.IsChecked = if ($showHiddenPlugins -eq $true) { $true } else { $false }
	$additionalSwitch.IsChecked = if ($showAdditionalPlugins -eq $true) { $true } else { $false }
	$debugSwitch.IsChecked = if ($debugMode -eq $true) { $true } else { $false }
	$startupColumnsStackPanel.Children | Where-Object { $_ -is [System.Windows.Controls.RadioButton] } | ForEach-Object { $_.IsChecked = ($_.Tag -eq $startupColumns) }
})

$saveSwitchButton = $window.FindName("saveSwitchButton")
$saveSwitchButton.Add_Click({
	$scriptContents = @(
		"`$saveEncryptionKeys = $" + $saveEncryptionKeys.ToString().ToLower()
		"`$launchOnRestart = $" + $launchOnRestart.ToString().ToLower()
		"`$showTooltips = $" + $showTooltips.ToString().ToLower()
		"`$showHiddenPlugins = $" + $showHiddenPlugins.ToString().ToLower()
		"`$showAdditionalPlugins = $" + $showAdditionalPlugins.ToString().ToLower()
		"`$debugMode = $" + $debugMode.ToString().ToLower()
		"`$startupColumns = " + $startupColumns
	)
	
	$customSettingsPath = Join-Path $settingsPath "Settings-Custom.ps1"
	Set-Content -Path $customSettingsPath -Value $scriptContents
})

#############################
####  COLORS STACKPANEL  ####
#############################

foreach ($theme in $themes.GetEnumerator()) {
	$button = New-Object System.Windows.Controls.Button
	$button.Width = 83
	$button.Margin = 5
	$button.Tag = $theme.Value
	$button.Background = "Transparent"
	$button.Style = $window.Resources["RoundedButton"]
	$button.Add_Click({
		$selectedTheme = $_.Source.Tag
		$selectedThemeName = $_.Source.Content.Children[0].Text
		
		# Save theme
		Set-Content -Path $savedThemePath -Value "`$savedTheme = `"$selectedThemeName`""
		
		foreach ($key in $selectedTheme.Keys) {
			$value = $selectedTheme[$key]
			New-Variable -Name $key -Value $value -Scope Global -Force
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
		
		Set-ResourceIcons -iconCategory "Primary" -resourceMappings $primaryResources
		Set-ResourceIcons -iconCategory "Background" -resourceMappings $backgroundResources
		Set-ResourceIcons -iconCategory "Surface" -resourceMappings $surfaceResources
		Set-ResourceIcons -iconCategory "Accent" -resourceMappings $accentResources
		Update-ExpandCollapseButton
	})
	
	$textBlock = New-Object System.Windows.Controls.TextBlock
	$textBlock.Height = 20
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
	
	$colorsPanel = $window.FindName("colorsPanel")
	$colorsPanel.AddChild($button)
}

#############################
####   PATH STACKPANEL   ####
#############################

$pathButton = $window.FindName("pathButton")
$pathButton.Add_Click({ Start-Process explorer $atomPath })

#############################
####  GITHUB STACKPANEL  ####
#############################

$githubLinkButton = $window.FindName("githubLinkButton")
$githubLinkButton.Add_Click({ [System.Windows.Forms.Clipboard]::SetText("https://github.com/SkylerWallace/ATOM") })

$githubLaunchButton = $window.FindName("githubLaunchButton")
$githubLaunchButton.Add_Click({ Start-Process "https://github.com/SkylerWallace/ATOM" })

$githubTextBox = $window.FindName("githubTextBox")
$githubTextBox.Text = "https://github.com/SkylerWallace/ATOM"
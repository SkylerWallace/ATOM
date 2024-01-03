# Icons theming
if ($secondaryIcons -eq "Light") {
	$navButtonIcon = "Back (Light)"
	$pathButtonIcon = "Folder (Light)"
	$githubImageIcon = Join-Path $iconsPath "GitHub (Light).png"
	$linkButtonIcon = "Link (Light)"
	$launchButtonIcon = "Launch (Light)"
} else {
	$navButtonIcon = "Back (Dark)"
	$pathButtonIcon = "Folder (Dark)"
	$githubImageIcon = Join-Path $iconsPath "GitHub (Dark).png"
	$linkButtonIcon = "Link (Dark)"
	$launchButtonIcon = "Launch (Dark)"
}

$downloadImageIcon =
	if ($accentIcons -eq "Light") { Join-Path $iconsPath "Download (Light).png" }
	else { Join-Path $iconsPath "Download (Dark).png" }

# Create the main StackPanel
$settingsStackPanel = New-Object System.Windows.Controls.StackPanel
$settingsStackPanel.MaxWidth = 300
$settingsStackPanel.Margin = 5

#############################
####   NAV STACKPANEL    ####
#############################

$navButton = New-Object System.Windows.Controls.Button
$navButton.Name = "navButton"
Set-ButtonIcon $navButton $navButtonIcon
$navButton.Width = 25; $navButton.Height = 25
$navButton.Style = $window.Resources["RoundHoverButtonStyle"]
$navButton.Margin = 5
$navButton.Add_Click({ $scrollViewer.Content = $pluginStackPanel; Load-Scripts })

$settingsTextBlock = New-Object System.Windows.Controls.TextBlock
$settingsTextBlock.Text = "Settings"
$settingsTextBlock.FontSize = 20; $settingsTextBlock.FontWeight = "Bold"
$settingsTextBlock.Foreground = $secondaryText
$settingsTextBlock.HorizontalAlignment = "Left"; $settingsTextBlock.VerticalAlignment = "Center"
$settingsTextBlock.Margin = 5

$navStackPanel = New-Object System.Windows.Controls.StackPanel
$navStackPanel.Orientation = "Horizontal"
$navStackPanel.AddChild($navButton)
$navStackPanel.AddChild($settingsTextBlock)

#############################
####  UPDATE  STACKPANEL ####
#############################

$borderUpdate = New-Object System.Windows.Controls.Border
$borderUpdate.Background = $secondaryColor1
$borderUpdate.HorizontalAlignment = "Stretch"
$borderUpdate.CornerRadius = 5
$borderUpdate.Margin = 5; $borderUpdate.Padding = 5

$innerStackPanel1 = New-Object System.Windows.Controls.StackPanel

$versionText = New-Object System.Windows.Controls.TextBlock
$versionText.Name = "versionText"
$versionText.Text = "ATOM Core Version:    $version"
$versionText.FontSize = 12
$versionText.Foreground = $secondaryText
$versionText.HorizontalAlignment = "Center"; $versionText.VerticalAlignment = "Center"
$versionText.Margin = 5

$versionHash = New-Object System.Windows.Controls.TextBlock
$versionHash.Name = "versionHash"
$localCommitPath = Join-Path $dependenciesPath "Settings\hash.txt"
$localCommitHash = Get-Content -Path $localCommitPath
$versionHash.Text = "Hash:                     $($localCommitHash.Substring(0, 7))"
$versionHash.FontSize = 12
$versionHash.Foreground = $secondaryText
$versionHash.HorizontalAlignment = "Center"; $versionHash.VerticalAlignment = "Center"
$versionHash.Margin = 5

$updateButton = New-Object System.Windows.Controls.Button
$updateButton.Name = "updateButton"
$updateButton.Background = $accentColor; $updateButton.Foreground = $accentText
$updateButton.MaxWidth = 250
$updateButton.HorizontalAlignment = "Center"
$updateButton.Style = $window.Resources["RoundedButton"]
$updateButton.Margin = 5; $updateButton.Padding = 5
$updateButton.Tooltip = "Check GitHub for ATOM updates"
$lastCheckedPath = Join-Path $dependenciesPath "Settings\time.txt"

$updateButtonContent = New-Object System.Windows.Controls.StackPanel
$updateButtonContent.Orientation = "Horizontal"

$updateIcon = New-Object System.Windows.Controls.Image
$updateIcon.Name = "updateIcon"
$updateIcon.Source = $downloadImageIcon
$updateIcon.Width = 16; $updateIcon.Height = 16
$updateIcon.Margin = 5

$updateButtonText = New-Object System.Windows.Controls.TextBlock
$updateButtonText.Text = "Check for Updates"
$updateButtonText.VerticalAlignment = "Center"
$updateButtonText.Margin = "0,5,5,5"

$updateButtonContent.AddChild($updateIcon)
$updateButtonContent.AddChild($updateButtonText)
$updateButton.Content = $updateButtonContent

$updateText = New-Object System.Windows.Controls.TextBlock
$updateText.Name = "updateText"
if (Test-Path $lastCheckedPath) { $lastCheckedContent = Get-Content -Path $lastCheckedPath }
$updateText.Text = "Last checked: $lastCheckedContent"
$updateText.FontSize = 12
$updateText.Foreground = $secondaryText
$updateText.HorizontalAlignment = "Center"; $updateText.VerticalAlignment = "Center"
$updateText.Margin = 5

$borderUpdate.Child = $innerStackPanel1
$innerStackPanel1.AddChild($versionText)
$innerStackPanel1.AddChild($versionHash)
$innerStackPanel1.AddChild($updateButton)
$innerStackPanel1.AddChild($updateText)

#############################
#### SWITCHES STACKPANEL ####
#############################

$borderSwitches = New-Object System.Windows.Controls.Border
$borderSwitches.Background = $secondaryColor1
$borderSwitches.CornerRadius = 5
$borderSwitches.Margin = 5; $borderSwitches.Padding = 5

$switchesText = New-Object System.Windows.Controls.TextBlock
$switchesText.Text = "WORK IN PROGRESS"
$switchesText.FontSize = 12
$switchesText.Foreground = $secondaryText
$switchesText.HorizontalAlignment = "Center"; $switchesText.VerticalAlignment = "Center"
$switchesText.Margin = 5

$switchesStackPanel = New-Object System.Windows.Controls.StackPanel
$switchesStackPanel.AddChild($switchesText)

$borderSwitches.Child = $switchesStackPanel

#############################
####   PATH STACKPANEL   ####
#############################

$borderPath = New-Object System.Windows.Controls.Border
$borderPath.Background = $secondaryColor1
$borderPath.CornerRadius = 5
$borderPath.Margin = 5; $borderPath.Padding = 5

$pathText = New-Object System.Windows.Controls.TextBlock
$pathText.Text = "ATOM Path"
$pathText.FontSize = 12
$pathText.Foreground = $secondaryText
$pathText.HorizontalAlignment = "Center"; $pathText.VerticalAlignment = "Center"
$pathText.Margin = "10,5,5,5"

$pathButton = New-Object System.Windows.Controls.Button
$pathButton.Name = "pathLaunchButton"
Set-ButtonIcon $pathButton $pathButtonIcon
$pathButton.Height = 25; $pathButton.Height = 25
$pathButton.HorizontalAlignment = "Center"; $pathButton.VerticalAlignment = "Center"
$pathButton.Style = $window.Resources["RoundHoverButtonStyle"]
$pathButton.Margin = "100,5,5,5"
$pathButton.Tooltip = "Open in explorer"
$pathButton.Add_Click({ Start-Process explorer $atomPath })

$pathTextBox = New-Object System.Windows.Controls.TextBox
$pathTextBox.Name = "pathTextBox"
$pathTextBox.Text = $atomPath
$pathTextBox.Background = "Transparent"; $pathTextBox.Foreground = $secondaryText; $pathTextBox.BorderBrush = "Transparent"
$pathTextBox.TextAlignment = "Center"; $pathTextBox.VerticalAlignment = "Center"
$pathTextBox.Margin = 5
$pathTextBox.IsReadOnly = $true

$pathHorizStackPanel = New-Object System.Windows.Controls.StackPanel
$pathHorizStackPanel.Orientation = "Horizontal"
$pathHorizStackPanel.HorizontalAlignment = "Center"
$pathHorizStackPanel.AddChild($pathText)
$pathHorizStackPanel.AddChild($pathButton)

$pathStackPanel = New-Object System.Windows.Controls.StackPanel
$pathStackPanel.AddChild($pathHorizStackPanel)
$pathStackPanel.AddChild($pathTextBox)

$borderPath.Child = $pathStackPanel

#############################
####  GITHUB STACKPANEL  ####
#############################

$borderGithub = New-Object System.Windows.Controls.Border
$borderGithub.Background = $secondaryColor1
$borderGithub.CornerRadius = 5
$borderGithub.Margin = 5; $borderGithub.Padding = 5

$githubIcon = New-Object System.Windows.Controls.Image
$githubIcon.Name = "githubIcon"
$githubIcon.Source = $githubImageIcon
$githubIcon.Width = 20; $githubIcon.Height = 20
$githubIcon.HorizontalAlignment = "Center"; $githubIcon.VerticalAlignment = "Center"
$githubIcon.Margin = 5

$githubText = New-Object System.Windows.Controls.TextBlock
$githubText.Text = "GitHub"
$githubText.FontSize = 12
$githubText.Foreground = $secondaryText
$githubText.HorizontalAlignment = "Center"; $githubText.VerticalAlignment = "Center"
$githubText.Margin = 5

$githubLinkButton = New-Object System.Windows.Controls.Button
$githubLinkButton.Name = "githubLinkButton"
Set-ButtonIcon $githubLinkButton $linkButtonIcon
$githubLinkButton.Height = 25; $githubLinkButton.Height = 25
$githubLinkButton.HorizontalAlignment = "Center"; $githubLinkButton.VerticalAlignment = "Center"
$githubLinkButton.Style = $window.Resources["RoundHoverButtonStyle"]
$githubLinkButton.Margin = "60,5,5,5"
$githubLinkButton.Tooltip = "Copy URL to clipboard"
$githubLinkButton.Add_Click({ [System.Windows.Forms.Clipboard]::SetText("https://github.com/SkylerWallace/ATOM") })

$githubLaunchButton = New-Object System.Windows.Controls.Button
$githubLaunchButton.Name = "githubLaunchButton"
Set-ButtonIcon $githubLaunchButton $launchButtonIcon
$githubLaunchButton.Height = 25; $githubLaunchButton.Height = 25
$githubLaunchButton.HorizontalAlignment = "Center"; $githubLaunchButton.VerticalAlignment = "Center"
$githubLaunchButton.Style = $window.Resources["RoundHoverButtonStyle"]
$githubLaunchButton.Margin = 5
$githubLaunchButton.Tooltip = "Open in browser"
$githubLaunchButton.Add_Click({ Start-Process "https://github.com/SkylerWallace/ATOM" })

$githubHorizStackPanel = New-Object System.Windows.Controls.StackPanel
$githubHorizStackPanel.Orientation = "Horizontal"
$githubHorizStackPanel.HorizontalAlignment = "Center"
$githubHorizStackPanel.AddChild($githubIcon)
$githubHorizStackPanel.AddChild($githubText)
$githubHorizStackPanel.AddChild($githubLinkButton)
$githubHorizStackPanel.AddChild($githubLaunchButton)

$githubTextBox = New-Object System.Windows.Controls.TextBox
$githubTextBox.Name = "githubTextBox"
$githubTextBox.Text = "https://github.com/SkylerWallace/ATOM"
$githubTextBox.Background = "Transparent"; $githubTextBox.Foreground = $secondaryText; $githubTextBox.BorderBrush = "Transparent"
$githubTextBox.TextAlignment = "Center"; $githubTextBox.VerticalAlignment = "Center"
$githubTextBox.Margin = 5
$githubTextBox.IsReadOnly = $true

$githubStackPanel = New-Object System.Windows.Controls.StackPanel
$githubStackPanel.AddChild($githubHorizStackPanel)
$githubStackPanel.AddChild($githubTextBox)

$borderGithub.Child = $githubStackPanel

# Add the sub-stack panels to the main StackPanel
$settingsStackPanel.AddChild($navStackPanel)
$settingsStackPanel.AddChild($borderUpdate)
$settingsStackPanel.AddChild($borderSwitches)
$settingsStackPanel.AddChild($borderPath)
$settingsStackPanel.AddChild($borderGithub)

function Check-Updates {
	$apiUrl = "https://api.github.com/repos/SkylerWallace/ATOM/commits?per_page=1"
	$response = Invoke-RestMethod -Uri $apiUrl
	$latestCommitHash = $response[0].sha
	
	if ($localCommitHash -ne $latestCommitHash) {
		$script:updateAvailable = $true
		
		$downloadImageIcon =
			if ($primaryIcons -eq "Light") { Join-Path $iconsPath "Download (Light).png" }
			else { Join-Path $iconsPath "Download (Dark).png" }
		
		$updateIcon.Source = $downloadImageIcon	
		$updateButton.Background = $primaryColor
		$updateButton.Tooltip = "Updating ATOM will not remove any custom plugins"
		$updateButtonText.Foreground = $primaryText
		$updateButtonText.Text = "Update ATOM"
		$updateText.Text = "Update available!"
	} else {
		Get-Date -Format "MM/dd/yy h:mmtt" | Out-File $lastCheckedPath
		$lastCheckedContent = Get-Content -Path $lastCheckedPath
		$updateText.Text = "Last checked: $lastCheckedContent"
	}
}

$updateButton.Add_Click({
	if ($script:updateAvailable) {
		$updateAtomPath = Join-Path $dependenciesPath "Update-ATOM.ps1"
		Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$updateAtomPath`""
	} else {
		Check-Updates
	}
})
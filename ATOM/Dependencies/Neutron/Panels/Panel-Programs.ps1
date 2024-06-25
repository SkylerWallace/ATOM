# Download up-to-date programs hashtable
$internetConnected = (Get-NetConnectionProfile | Where-Object { $_.IPv4Connectivity -eq 'Internet' -or $_.IPv6Connectivity -eq 'Internet' }) -ne $null
if ($internetConnected) {
	# Download latest Programs.ps1 from Github
	$programsUrl = "https://raw.githubusercontent.com/SkylerWallace/ATOM/main/ATOM/Dependencies/Neutron/Programs.ps1"
	$programsDestination = Join-Path $env:TEMP "Programs.ps1"
	
	try {
		$progressPreference = "SilentlyContinue"
		Invoke-WebRequest -Uri $programsUrl -OutFile $programsDestination
	} catch {
		$outputBox.Text += "Unable to download programs list from Github. Programs list may not be up-to-date."
	}
	
	# Compare current Programs.ps1 to downloaded Programs.ps1
	$currentHash = (Get-FileHash -Path $hashtable -Algorithm SHA256).Hash
	$downloadedHash = (Get-FileHash -Path $programsDestination -Algorithm SHA256).Hash
	
	# Update programs hashtable
	if ($currentHash -eq $downloadedHash) {
		$outputBox.Text += "Programs list already up-to-date."
	} else {
		# Hashtable
		try {
			Copy-Item $programsDestination -Destination $hashtable -Force
			$outputBox.Text += "Updated programs list."
		} catch {
			$outputBox.Text += "Issues updating programs list."
		}
		
		# Icons
		try {
			$programsApi = "https://api.github.com/repos/SkylerWallace/ATOM/contents/ATOM/Dependencies/Neutron/Icons"

			$token = $null
			$headers =	if ($token) { @{ Authorization = "token $token" } }
						else { @{} }

			$progressPreference = "SilentlyContinue"
			$response = Invoke-RestMethod -Uri $programsApi -Method Get -Headers $headers

			foreach ($icon in $response) {
				$iconUrl = $icon.download_url
				$iconName = $icon.name
				$iconPath = Join-Path $programIcons $iconName
				
				$iconExists = Test-Path $iconPath
				if (!$iconExists) {
					Invoke-RestMethod -Uri $iconUrl -OutFile $iconPath -Headers $headers
				}
			}
		} catch {
			$outputBox.Text += "Issues updating program icons."
		}
	}
	
	# Cleanup
	Remove-Item $programsDestination -Force
} else {
	$outputBox.Text += "No internet connection detected. Could not verify if programs in Neutron are up-to-date."
}

$outputBox.Text += "`n`n"

# Search bar controls
$backspaceButton = $window.FindName("backspaceButton")
$backspaceButton.Tooltip = "Clear search box"
$backspaceButton.Add_Click({
	$searchTextBox.Clear()
	$searchTextBox.Focus()
	$backspaceButton.Focus()
})

$searchTextBox.Add_GotFocus({
	if ($searchTextBlock.Visibility -eq "Visible") { $searchTextBlock.Visibility = "Collapsed" }
})

$searchTextBox.Add_LostFocus({
	if ($searchTextBox.Text -eq "") { $searchTextBlock.Visibility = "Visible" }
})

$searchTextBox.Add_TextChanged({
	$searchText = [regex]::Escape($searchTextBox.Text) # Escape regex special characters

	# Process each ListBox and corresponding category header
	$installPanel.Children | Where-Object { $_ -is [System.Windows.Controls.ListBox] } | ForEach-Object {
		$listBox = $_
		# Determine visibility for each item based on the search text
		$visibleItems = $listBox.Items | ForEach-Object {
			$item = $_
			$programName = $item.Content.Children[2].Text.ToLower()
			$item.Visibility = if ($programName -match $searchText) { "Visible" } else { "Collapsed" }
			$item.Visibility -eq "Visible" # Output visibility status
		}

		# Locate the corresponding TextBlock using the Tag property
		$categoryHeader = $installPanel.Children | Where-Object { $_.Tag -eq $listBox.Tag -and $_ -is [System.Windows.Controls.TextBlock] }
		
		# Sync visibility of the category header with the ListBox
		$anyVisibleItems = $visibleItems -contains $true
		$categoryHeader.Visibility = $listBox.Visibility = if ($anyVisibleItems) { "Visible" } else { "Collapsed" }
	}
})

# Pull programs hashtable
. $hashtable
$selectedInstallPrograms = New-Object System.Collections.ArrayList

# Construct programs panel
foreach ($category in $installPrograms.Keys) {
	$textBlock = New-Object System.Windows.Controls.TextBlock
	$textBlock.Text = $category
	$textBlock.FontWeight = "Bold"
	$textBlock.Foreground = $surfaceText
	$textBlock.Margin = "5,5,0,0"
	$textBlock.Tag = $category
	$installPanel.Children.Add($textBlock) | Out-Null

	$listBox = New-Object System.Windows.Controls.ListBox
	$listBox.Background = $surfaceBrush
	$listBox.Foreground = $surfaceText
	$listBox.BorderThickness = 0
	$listBox.Margin = "0,5,0,5"
	$listBox.Style = $window.Resources["CustomListBoxStyle"]
	$listBox.Tag = $category
	$installPanel.Children.Add($listBox) | Out-Null

	foreach ($program in $installPrograms[$category].Keys) {
		$checkBox = New-Object System.Windows.Controls.CheckBox
		$checkBox.Tag = $program
		$checkBox.Style = $window.Resources["CustomCheckBoxStyle"]
		$checkBox.Add_Checked({ $selectedInstallPrograms.Add($this.Tag) | Out-Null })
		$checkBox.Add_Unchecked({ $selectedInstallPrograms.Remove($this.Tag) | Out-Null })

		$iconPath = Join-Path $programIcons "$program.png"
		$iconExists = Test-Path $iconPath
		if (!$iconExists) {
			$firstLetter = $program.Substring(0,1)
			$iconPath = if ($firstLetter -match "^[A-Z]") { Join-Path $iconsPath "\Default\Default$firstLetter.png" }
						else { Join-Path $iconsPath "\Default\Default.png" }
		}
		
		$image = New-Object System.Windows.Controls.Image
		$image.Source = $iconPath
		$image.Width = 16
		$image.Height = 16

		$textBlock = New-Object System.Windows.Controls.TextBlock
		$textBlock.Text = $program
		$textBlock.Foreground = $surfaceText
		$textBlock.VerticalAlignment = "Center"
		$textBlock.Margin = "5,0,5,0"
		
		$programStackPanel = New-Object System.Windows.Controls.StackPanel
		$programStackPanel.Orientation = "Horizontal"
		$programStackPanel.Children.Add($checkBox) | Out-Null
		$programStackPanel.Children.Add($image) | Out-Null
		$programStackPanel.Children.Add($textBlock) | Out-Null
		
		$listBoxItem = New-Object System.Windows.Controls.ListBoxItem
		$listBoxItem.Content = $programStackPanel
		$listBoxItem.Tag = $checkBox
		$listBoxItem.Add_MouseUp({ $this.Tag.IsChecked = !$this.Tag.IsChecked })
		$listBox.Items.Add($listBoxItem) | Out-Null
	}
}

# 'Install method' checkboxes
function Update-Checkboxes {
	$installPanel.Children | ForEach-Object {
		if ($_ -isnot [System.Windows.Controls.ListBox]) { return }
		
		$listBox = $_
		$listBox.Items | ForEach-Object {
			$listBoxItem = $_
			$program = $listBoxItem.Tag.Tag
			$category = $listBox.Tag
			$programInfo = $installPrograms[$category][$program]
			
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

# Update checkbox statuses
Update-Checkboxes
# Download up-to-date programs hashtable
$internetConnected = (Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq 'Public' -or $_.NetworkCategory -eq 'Private' }) -ne $null
if ($internetConnected) {
	# Download latest Programs.ps1 from Github
	$programsUrl = "https://raw.githubusercontent.com/SkylerWallace/ATOM/main/ATOM/Dependencies/Neutron/Programs.ps1"
	$programsDestination = Join-Path $env:TEMP "Programs.ps1"
	
	try {
		$progressPreference = 'SilentlyContinue'
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
			$programsApi = 'https://api.github.com/repos/SkylerWallace/ATOM/contents/ATOM/Dependencies/Neutron/Icons'

			$token = $null
			$headers =	if ($token) { @{ Authorization = "token $token" } }
						else { @{} }

			$progressPreference = 'SilentlyContinue'
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

# Construct programs panel
. $hashtable
$selectedInstallPrograms = New-Object System.Collections.ArrayList
foreach ($category in $installPrograms.Keys) {
	$textBlock = New-Object System.Windows.Controls.TextBlock
	$textBlock.Text = $category
	$textBlock.FontWeight = "Bold"
	$textBlock.Foreground = $secondaryText
	$textBlock.Margin = "5,5,0,0"
	$installPanel.Children.Add($textBlock) | Out-Null

	$listBox = New-Object System.Windows.Controls.ListBox
	$listBox.Background = $secondaryColor1
	$listBox.Foreground = $secondaryText
	$listBox.BorderThickness = 0
	$listBox.Margin = "0,5,0,5"
	$listBox.Style = $window.Resources["CustomListBoxStyle"]
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
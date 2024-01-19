$appsHashtable = Join-Path $detectronPrograms "Apps.ps1"
. $appsHashtable

$detectedApps = [ordered]@{}
function Detect-Apps {
	foreach ($app in $apps) {
		$appName = $app[0]
		$appString = $app.Split("\")[1]
		$packageName = $app.Split("_")[1]
		$installPath = "C:\Users\$env:username\AppData\Local\Packages\$appString"
		$userDataPath = "C:\Users\$env:username\AppData\Local\Packages\$($app[1])"
		
		if (Test-Path $installPath) {
			$detectedApps[$appName] = @{
				'PackageName' = $packageName
				'UserData' = $userDataPath
			}
		}
	}
}

Detect-Apps

if ($detectedApps.Count -ge 1) {
	$appxCheckbox = New-Object System.Windows.Controls.CheckBox
	$appxCheckbox.Content = "AppX Bloatware"
	$appxCheckbox.FontWeight = "Bold"
	$appxCheckbox.Foreground = $surfaceText
	$appxCheckbox.Margin = "10,5,0,0"
	$appxCheckbox.Style = $window.Resources["CustomCheckBoxStyle"]
	$uninstallPanel.Children.Add($appxCheckbox) | Out-Null

	$appxListBox = New-Object System.Windows.Controls.ListBox
	#$appxListBox.Background = $surfaceBrush
	#$appxListBox.Foreground = $surfaceText
	$appxListBox.Margin = "10,5,0,5"
	$appxListBox.Style = $window.Resources["CustomListBoxStyle"]
	$uninstallPanel.Children.Add($appxListBox) | Out-Null

	$selectedApps = New-Object System.Collections.ArrayList
	foreach ($detectedApp in $detectedApps.Keys) {
		$checkBox = New-Object System.Windows.Controls.CheckBox
		$checkBox.Content = $detectedApp
		$checkBox.Tag = $detectedApps[$detectedApp]['PackageName']
		$checkBox.Foreground = $surfaceText
		$checkBox.VerticalAlignment = "Center"
		$checkBox.Style = $window.Resources["CustomCheckBoxStyle"]
		
		if (Test-Path $detectedApps[$detectedApp]['UserData']) {
			$checkBox.IsEnabled = $false
			$checkBox.Opacity = '0.25'
		}
		
		$appxListBox.Items.Add($checkBox) | Out-Null
	}

	$appxCheckbox.Add_Checked({
		foreach ($item in $appxListBox.Items) {
			if ($item.IsEnabled) {
				$item.IsChecked = $true
				if (!$selectedApps.Contains($item.Tag)) {
					$selectedApps.Add($item.Tag) | Out-Null
				}
			}
		}
	})

	$appxCheckbox.Add_Unchecked({
		foreach ($item in $appxListBox.Items) {
			if ($item.IsEnabled) {
				$item.IsChecked = $false
				$selectedApps.Remove($item.Tag) | Out-Null
			}
		}
	})
}
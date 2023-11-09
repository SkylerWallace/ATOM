$programsHashtable = Join-Path $detectronPrograms "Programs.ps1"
. $programsHashtable

$detectedPrograms = @{}
$uninstallPaths = @(
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", # 64-bit programs
	"HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall", # 32-bit programs
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" # User programs
)

function Detect-Programs {
	foreach ($uninstallPath in $uninstallPaths) {
		foreach ($category in $uninstallPrograms.Keys) {
			$programRegex = ($uninstallPrograms[$category].Keys -join "|")
			$uninstallKeys = Get-ChildItem $uninstallPath | Where-Object { $_.GetValue("DisplayName") -match $programRegex }
			foreach ($key in $uninstallKeys) {
				$programName = $key.GetValue("DisplayName")
				$uninstallString = $key.GetValue("QuietUninstallString")
				$iconPath = $key.GetValue("DisplayIcon")

				if (-not $detectedPrograms.ContainsKey($category)) {
					$detectedPrograms[$category] = @{}
				}

				if (![string]::IsNullOrWhiteSpace($uninstallString)) {
					$chosenUninstallString = $uninstallString
				} else {
					$chosenUninstallString = $key.GetValue("UninstallString")
				}

				$detectedPrograms[$category][$programName] = @{
					'UninstallString' = $chosenUninstallString;
					'IconPath' = $iconPath
				}
			}
		}
	}
}

Detect-Programs

$listBoxes = @{}
foreach ($category in $detectedPrograms.Keys) {
	# create a TextBlock for the category name and add it to the stackPanel
	$categoryCheckBox = New-Object System.Windows.Controls.CheckBox
	$categoryCheckBox.Content = $category
	$categoryCheckBox.Tag = $category
	$categoryCheckBox.FontWeight = "Bold"
	$categoryCheckBox.Foreground = "White"
	$categoryCheckBox.Margin = "10,5,0,0"
	$categoryCheckBox.Style = $window.Resources["CustomCheckBoxStyle"]
	$uninstallPanel.Children.Add($categoryCheckBox) | Out-Null
	
	# create a listBox for the programs in this category
	$listBox = New-Object System.Windows.Controls.ListBox
	$listBox.Background = "#49494A"
	$listBox.Foreground = 'White'
	$listBox.BorderThickness = 0
	$listBox.Margin = "10,5,0,5"
	$listBox.Style = $window.Resources["CustomListBoxStyle"]
	$uninstallPanel.Children.Add($listBox) | Out-Null
	
	$listBoxes[$category] = $listBox
	
	$categoryCheckBox.Add_Checked({
		$currentCategory = $this.Tag
		foreach ($item in $listBoxes[$currentCategory].Items) {
			$item.IsChecked = $true
		}
	})

	$categoryCheckBox.Add_Unchecked({
		$currentCategory = $this.Tag
		foreach ($item in $listBoxes[$currentCategory].Items) {
			$item.IsChecked = $false
		}
	})
	
	# Add programs under the category
	foreach ($programName in $detectedPrograms[$category].Keys) {
		$checkBox = New-Object System.Windows.Controls.CheckBox
		$checkBox.Content = $programName
		$checkBox.Tag = $programName
		$checkBox.Foreground = "White"
		$checkBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
		$checkBox.Style = $window.Resources["CustomCheckBoxStyle"]

		$listBox.Items.Add($checkbox) | Out-Null
	}
}
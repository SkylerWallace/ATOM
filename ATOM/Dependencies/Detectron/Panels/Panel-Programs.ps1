# Import programs hashtable
$programsHashtable = Join-Path $detectronPrograms "Programs.ps1"
. $programsHashtable

# All uninstall keys
$uninstallPaths = @(
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", # 64-bit programs
	"HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall", # 32-bit programs
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" # User programs
)

# Store all uninstall keys in single variable
$uninstallKeys = Get-ChildItem $uninstallPaths | ForEach {
	Get-ItemProperty $_.PSPath | Where { $_.DisplayName -and $_.UninstallString } | Select DisplayName, PsPath, QuietUninstallString, UninstallString
}

# Detect programs
$detectedPrograms = @{}
foreach ($category in $programs.Keys) {
	foreach ($program in $programs.$category) {
		# Detect programs from programs hashtable
		$detectedProgram = $uninstallKeys | Where { $_.DisplayName -match $program }
		
		# Early exit
		if (!$detectedProgram) { continue }
		
		# Add category to hashtable if not detected
		if (!$detectedPrograms.ContainsKey($category)) {
			$detectedPrograms.$category = @{}
		}
		
		# Add to detectedPrograms hashtable
		$detectedProgram | ForEach {
			$detectedPrograms.$category.($_.DisplayName) = @{
				DisplayName = $_.DisplayName
				Key = $_.PsPath
				UninstallString = $(
					if ($_.QuietUninstallString -ne $null) { $_.QuietUninstallString }
					else { $_.UninstallString }
				) -replace '(?<!")([a-zA-Z]:\\[^"]+\.(exe|msi))(?!")', '"$1"'
			}
		}
	}
}

# Listboxes hashtable
$listBoxes = @{}

# Early return
if ($detectedPrograms.Count -le 0) { return }

# Create listboxes w/ checkboxes for detected programs
foreach ($category in $detectedPrograms.Keys) {
	# create a TextBlock for the category name and add it to the stackPanel
	$categoryCheckBox = New-Object System.Windows.Controls.CheckBox
	$categoryCheckBox.Content = $category
	$categoryCheckBox.Tag = $category
	$categoryCheckBox.ToolTip = "Check all $category apps that are safe to remove."
	$categoryCheckBox.FontWeight = "Bold"
	$categoryCheckBox.Foreground = $surfaceText
	$categoryCheckBox.Margin = "10,5,0,0"
	$categoryCheckBox.Style = $window.Resources["CustomCheckBoxStyle"]
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
	foreach ($programName in $detectedPrograms.$category.Keys) {
		$checkBox = New-Object System.Windows.Controls.CheckBox
		$checkBox.Content = $programName
		$checkBox.Tag = $programName
		$checkBox.Foreground = $surfaceText
		$checkBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
		$checkBox.Style = $window.Resources["CustomCheckBoxStyle"]

		$listBox.Items.Add($checkbox) | Out-Null
	}
}
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
$uninstallKeys = Get-ChildItem $uninstallPaths | Where-Object { $_.Property -contains "DisplayName" }

# Detect programs
$detectedPrograms = @{}
foreach ($category in $programs.Keys) {
	foreach ($program in $programs[$category].Keys) {
		# Detect programs from programs hashtable
		$detectedProgram = $uninstallKeys | Where-Object { $_.GetValue("DisplayName") -match $program }
		
		# Early exit
		if (!$detectedProgram) {
			continue
		}
		
		# Get values from programs hashtable
		$folder = $programs[$category][$program]['folder']
		$process = $programs[$category][$program]['process']
		
		# Get values from uninstall key
		$displayName = $detectedProgram.GetValue("DisplayName")
		$uninstallString = $detectedProgram.GetValue("QuietUninstallString")
		if ($uninstallString -eq $null) {
			$uninstallString = $detectedProgram.GetValue("UninstallString")
		}
		
		# Add quotation marks to the file path only if it contains spaces and does not already have them
		$uninstallString = $uninstallString -replace '(?<!")([a-zA-Z]:\\[^"]+\.(exe|msi))(?!")', '"$1"'
		
		# Add category to hashtable if not detected
		if (-not $detectedPrograms.ContainsKey($category)) {
			$detectedPrograms[$category] = @{}
		}
		
		# Add to detectedPrograms hashtable
		$detectedPrograms[$category][$displayName] = @{
			DisplayName = $displayName
			Folder = $folder
			Key = $detectedProgram.PsPath
			Process = $process
			UninstallString = $uninstallString
		}
	}
}

# Listboxes hashtable
$listBoxes = @{}

# Create listboxes w/ checkboxes for detected programs
if ($detectedPrograms.Count -gt 0) {
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
			$checkBox.Foreground = $surfaceText
			$checkBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
			$checkBox.Style = $window.Resources["CustomCheckBoxStyle"]

			$listBox.Items.Add($checkbox) | Out-Null
		}
	}
}
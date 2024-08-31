# Get the major Windows version number (11, 10, etc.) and build numbers, used for some predicates
$winVer = ((Get-CimInstance -ClassName Win32_OperatingSystem).Caption.Split(' ')[-2])
$winBuild = (Get-CimInstance -ClassName Win32_OperatingSystem).BuildNumber

$customizationsPath = Join-Path $neutronDependencies "Customizations.ps1"
. $customizationsPath

$selectedScripts = New-Object System.Collections.ArrayList
foreach ($key in $customizations.Keys) {
	$customization = $customizations[$key]
	$name = $key
	$tooltip = $customization.Tooltip
	$predicate = $customization.Predicate
	$scriptblock = $customization.Scriptblock.ToString()
	
	$checkBox = New-Object System.Windows.Controls.CheckBox
	$checkBox.Content = $name
	$checkBox.ToolTip = $tooltip
	$checkBox.Tag = $scriptblock
	$checkBox.Foreground = $surfaceText
	$checkBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
	$checkBox.Style = $window.Resources["CustomCheckBoxStyle"]
	$checkBox.Add_Checked({ $selectedScripts.Add($this.Tag)	})
	$checkBox.Add_Unchecked({ $selectedScripts.Remove($this.Tag) | Out-Null })
	
	# Enable/disable checkbox depending on predicate's return value
	$predicateResult = &$predicate
	if (-not $predicateResult) {
		$checkBox.IsEnabled = $false
		$checkbox.Opacity = 0.44
	}
	
	$customizationPanel.Items.Add($checkBox) | Out-Null
}
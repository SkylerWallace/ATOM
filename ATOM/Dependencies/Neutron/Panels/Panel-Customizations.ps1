$selectedScripts = New-Object System.Collections.ArrayList
Get-ChildItem -Path $neutronCustomizations -Filter *.ps1 | Sort-Object | ForEach-Object {
	$checkBox = New-Object System.Windows.Controls.CheckBox
	$checkBox.Content = $_.BaseName
	$checkBox.Tag = $_.FullName
	$checkBox.Foreground = "White"
	$checkBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
	$checkBox.Style = $window.Resources["CustomCheckBoxStyle"]
	$checkBox.Add_Checked({ $selectedScripts.Add($this.Tag)	})
	$checkBox.Add_Unchecked({ $selectedScripts.Remove($this.Tag) | Out-Null })
	
	$customizationPanel.Items.Add($checkBox) | Out-Null
}
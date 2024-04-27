function Update-Checkboxes {
	# Uncheck customizations checkboxes
	Invoke-Ui {
		foreach ($item in $customizationPanel.Items) {
			if ($item.IsChecked) {
				$item.IsChecked = $false
				$item.IsEnabled = $false
				$item.Opacity = 0.44
			}
		}
	}
	
	# Uncheck programs checkboxes
	Invoke-Ui {
		foreach ($item in $installPanel.Children.Items.Content.Children) {
			if ($item -is [System.Windows.Controls.CheckBox]) {
				$item.IsChecked = $false
			}
		}
	}
}
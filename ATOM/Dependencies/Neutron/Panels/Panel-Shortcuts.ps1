Get-ChildItem -Path $neutronShortcuts -Include *.ps1,*.bat -Recurse | ForEach-Object {
	$shortcutButton = New-Object System.Windows.Controls.Button
	$shortcutButton.Content = $_.BaseName
	$shortcutButton.Background = $accentBrush
	$shortcutButton.Foreground = $accentText
	$shortcutButton.Margin = "0,0,0,10"
	$shortcutButton.Style = $window.Resources["RoundedButton"]
	$shortcutButton.Tag = $_.FullName
	$shortcutButton.Add_Click({
		$scriptPath = $this.Tag
		if ($scriptPath -like "*.ps1") {
			& $scriptPath
		} elseif ($scriptPath -like "*.bat") {
			Start-Process cmd.exe -ArgumentList "/C `"$scriptPath`""
		}
	})
	$shortcutPanel.Children.Add($shortcutButton) | Out-Null
}
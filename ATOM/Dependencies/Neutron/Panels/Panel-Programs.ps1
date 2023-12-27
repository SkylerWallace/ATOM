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
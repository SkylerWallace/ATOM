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
		$listBoxItem = New-Object System.Windows.Controls.ListBoxItem

		$programStackPanel = New-Object System.Windows.Controls.StackPanel
		$programStackPanel.Orientation = "Horizontal"
		$listBoxItem.Content = $programStackPanel

		$checkBox = New-Object System.Windows.Controls.CheckBox
		$checkBox.Tag = $program
		$checkBox.Style = $window.Resources["CustomCheckBoxStyle"]
		$checkBox.Add_Checked({ $selectedInstallPrograms.Add($this.Tag) | Out-Null })
		$checkBox.Add_Unchecked({ $selectedInstallPrograms.Remove($this.Tag) | Out-Null })
		$programStackPanel.Children.Add($checkBox) | Out-Null

		$image = New-Object System.Windows.Controls.Image
		$image.Width = 16
		$image.Height = 16
		$iconPath = Join-Path $programIcons "$program.png"
		$imageExists = Test-Path $iconPath

		if (!$imageExists) {
			if ($program -match "^[A-Z]") {
				$firstLetter = $program.Substring(0,1)
				$iconPath = Join-Path $iconsPath "\Default\Default$firstLetter.png"
			} else {
				$iconPath = Join-Path $iconsPath "\Default\Default.png"
			}
		}

		$image.Source = New-Object System.Windows.Media.Imaging.BitmapImage (New-Object System.Uri $iconPath)
		$programStackPanel.Children.Add($image) | Out-Null

		$textBlock = New-Object System.Windows.Controls.TextBlock
		$textBlock.Text = $program
		$textBlock.VerticalAlignment = "Center"
		$textBlock.Margin = "5,0,5,0"
		$programStackPanel.Children.Add($textBlock) | Out-Null

		$listBox.Items.Add($listBoxItem) | Out-Null
	}
}
function Set-AtomPluginFavorite {
    param (
        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [Boolean]$Favorite
    )

    Set-AtomPluginPreference -Name $Name -Property Favorite -Value $Favorite
    $script:programs[$Name]['Favorite'] = $Favorite

    $pluginItem = foreach ($categoryGrid in @($pluginWrapPanel.Children)) {
        $listBox = @($categoryGrid.Children | Where-Object { $_ -is [Windows.Controls.Border] })[0].Child
        @($listBox.Items) | Where-Object { $_.Tag.Name -eq $Name }
    }

    if ($pluginItem) {
        $pluginItem.Tag.Config['Favorite'] = $Favorite
        $favoriteIcon = @($pluginItem.TrailingContent | Where-Object Tag -eq 'Favorite')[0]

        if ($Favorite -and !$favoriteIcon) {
            $favoriteIcon = New-VectorIcon -Window $window -Icon 'StarIcon' -ForegroundResource 'accentBrush' -Size 14 -OpticalSize 20 -Filled
            $favoriteIcon.Tag = 'Favorite'
            $favoriteIcon.Margin = '6,0,2.5,0'
            [Windows.Controls.DockPanel]::SetDock($favoriteIcon, 'Right')
            $insertAt = $pluginItem.Content.Children.IndexOf($pluginItem.Text)
            $pluginItem.Content.Children.Insert($insertAt, $favoriteIcon)
            $pluginItem.TrailingContent = @($favoriteIcon) + @($pluginItem.TrailingContent)
        } elseif (!$Favorite -and $favoriteIcon) {
            $pluginItem.Content.Children.Remove($favoriteIcon)
            $pluginItem.TrailingContent = @($pluginItem.TrailingContent | Where-Object { $_ -ne $favoriteIcon })
        }

        if ($pluginItem.ContextMenu) {
            $favoriteMenuItem = @($pluginItem.ContextMenu.Items | Where-Object { $_.Tag.Name -eq $Name -and $null -ne $_.Tag.Favorite })[0]
            $favoriteMenuItem.Header = if ($Favorite) { 'Unfavorite' } else { 'Favorite' }
            $favoriteMenuItem.Tag.Favorite = !$Favorite
            $favoriteMenuItem.Icon = New-VectorIcon -Window $window -Icon 'StarIcon' -ForegroundResource 'accentText' -Size 14 -OpticalSize 20 -Filled:$Favorite
        }
    }

    $statusBarStatus.Text = if ($Favorite) { "Favorited $Name" } else { "Unfavorited $Name" }
}

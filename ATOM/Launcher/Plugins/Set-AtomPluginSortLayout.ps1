function Set-AtomPluginSortLayout {
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Category', 'Alphabetical')]
        [String]$SortMode
    )

    if ($script:downloadMode) {
        Update-AtomPluginList -SortMode $SortMode
        return
    }

    $pluginItems = foreach ($categoryGrid in @($pluginWrapPanel.Children)) {
        $border = @($categoryGrid.Children | Where-Object { $_ -is [Windows.Controls.Border] })[0]
        if (!$border -or $border.Child -isnot [Windows.Controls.ListBox]) { continue }

        $listBox = $border.Child
        $items = @($listBox.Items)
        $listBox.Items.Clear()
        $items
    }

    $pluginWrapPanel.Children.Clear()

    $sortedPluginItems = $pluginItems | Sort-Object { $_.Tag.Name }
    $pluginGroups = $sortedPluginItems | Group-Object {
        if ($SortMode -eq 'Alphabetical') { 'All Plugins' }
        else { $_.Tag.Category }
    } | Sort-Object Name

    foreach ($group in $pluginGroups) {
        $textBlock = New-Object Windows.Controls.TextBlock
        $textBlock.Text = $group.Name
        $textBlock.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'backgroundText')
        $textBlock.FontSize = 14
        $textBlock.Margin = '0,10,0,0'
        $textBlock.VerticalAlignment = [Windows.VerticalAlignment]::Bottom

        $listBox = New-Object Windows.Controls.ListBox
        $listBox.Background = 'Transparent'
        $listBox.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
        $listBox.BorderThickness = 0
        $listBox.Margin = 5
        $listBox.Padding = 0
        $listBox.Width = 200
        $listBox.SetValue([Windows.Controls.ScrollViewer]::HorizontalScrollBarVisibilityProperty, [Windows.Controls.ScrollBarVisibility]::Disabled)

        foreach ($item in $group.Group) { $listBox.Items.Add($item) | Out-Null }

        $border = New-Object Windows.Controls.Border
        $border.Style = $window.FindResource('CustomBorder')
        $border.Margin = '0,5,0,0'
        $border.SetValue([Windows.Controls.Grid]::RowProperty, 1)
        $border.Child = $listBox

        $grid = New-Object Windows.Controls.Grid
        $grid.RowDefinitions.Add((New-Object Windows.Controls.RowDefinition))
        $grid.RowDefinitions.Add((New-Object Windows.Controls.RowDefinition))
        $grid.Margin = '0,0,10,0'

        if ($SortMode -eq 'Category') {
            $grid.AllowDrop = $true
            $grid.DataContext = $group.Name
            $grid.Add_DragOver({
                param($sender, $eventArgs)

                $sourceCategory =
                    if ($eventArgs.Data.GetDataPresent('ATOM.PluginCategory')) { [String]$eventArgs.Data.GetData('ATOM.PluginCategory') }
                    else { $null }

                $eventArgs.Effects =
                    if ($sourceCategory -and $sourceCategory -ne $sender.DataContext) { [Windows.DragDropEffects]::Move }
                    else { [Windows.DragDropEffects]::None }
                $eventArgs.Handled = $true
            })
            $grid.Add_Drop({
                param($sender, $eventArgs)

                if ($eventArgs.Data.GetDataPresent('ATOM.PluginName')) {
                    try {
                        Set-AtomPluginCategory -Name ([String]$eventArgs.Data.GetData('ATOM.PluginName')) -Category ([String]$sender.DataContext)
                    } catch {
                        $statusBarStatus.Text = "Unable to move plugin: $($_.Exception.Message)"
                    }
                }
                $eventArgs.Handled = $true
            })
        }

        $grid.Children.Add($textBlock) | Out-Null
        $grid.Children.Add($border) | Out-Null
        $grid.RowDefinitions[0].Height = [Windows.GridLength]::Auto
        $pluginWrapPanel.Children.Add($grid) | Out-Null
    }
}

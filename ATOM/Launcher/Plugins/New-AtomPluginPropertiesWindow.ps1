function New-AtomPluginPropertiesWindow {
    <# .SYNOPSIS
        Creates an on-demand native-title-bar dialog for viewing or editing metadata.
    #>
    param($Plugin, [Collections.IDictionary]$Sections = @{}, [String]$Category = 'Uncategorized')
    $creating = !$Plugin
    $editable = $creating -or [Boolean]$Plugin.UserPluginId
    $dialog = [Windows.Window]::new()
    $dialog.Title = if ($creating) { 'Add plugin' } else { "$($Plugin.Name) Properties" }
    $dialog.Owner = $window
    $dialog.Width = 560
    $dialog.Height = 680
    $dialog.MinWidth = 500
    $dialog.MinHeight = 360
    $dialog.WindowStartupLocation = 'CenterOwner'
    $dialog.ShowInTaskbar = $false
    $dialog.Resources = $window.Resources
    $dialog.FontFamily = $window.FontFamily
    $dialog.SetResourceReference([Windows.Controls.Control]::BackgroundProperty, 'backgroundBrush')
    $layout = [Windows.Controls.DockPanel]::new()
    $layout.Margin = '10'
    $footer = [Windows.Controls.StackPanel]::new()
    [Windows.Controls.DockPanel]::SetDock($footer, 'Bottom')
    [void]$layout.Children.Add($footer)
    $errorText = [Windows.Controls.TextBlock]::new()
    $errorText.TextWrapping = 'Wrap'
    $errorText.Margin = '5'
    $errorText.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'backgroundText')
    [void]$footer.Children.Add($errorText)
    $buttons = [Windows.Controls.StackPanel]::new()
    $buttons.Orientation = 'Horizontal'
    $buttons.HorizontalAlignment = 'Right'
    [void]$footer.Children.Add($buttons)
    $save = [Windows.Controls.Button]::new()
    $save.Content = if ($creating) { 'Create' } else { 'Save' }
    $save.Style = $window.FindResource('RoundedButton')
    $save.SetResourceReference([Windows.Controls.Control]::BackgroundProperty, 'controlBrush')
    $save.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'controlText')
    $save.Padding = '18,6'
    $save.Width = 100
    $save.Height = 32
    $save.Margin = '5'
    $save.Visibility = if ($editable) { 'Visible' } else { 'Collapsed' }
    [void]$buttons.Children.Add($save)
    $dialog.Add_PreviewKeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.Key -ne [Windows.Input.Key]::Escape) { return }
        if (@($sender.Tag.Fields.Values | Where-Object { $_ -is [Windows.Controls.ComboBox] -and $_.IsDropDownOpen }).Count) { return }
        $sender.Close()
        $eventArgs.Handled = $true
    })
    $scroll = [Windows.Controls.ScrollViewer]::new()
    $scroll.Style = $window.FindResource('CustomScrollViewerStyle')
    $scroll.VerticalScrollBarVisibility = 'Auto'
    $scroll.HorizontalScrollBarVisibility = 'Disabled'
    [void]$layout.Children.Add($scroll)
    $content = [Windows.Controls.StackPanel]::new()
    $content.Margin = '0,0,12,0'
    $scroll.Content = $content
    $fields = @{}
    $config = if ($Plugin.Config) { $Plugin.Config } else { @{} }
    $groups = [ordered]@{ General = @('Name', 'Type', 'Category', 'NewCategory'); Metadata = @('Description', 'ToolTip', 'Tags', 'Aliases', 'Silent', 'Hidden', 'WorksInOs', 'WorksInPe', 'Icon') }
    if ($creating) { $groups.General += 'Source' }
    foreach ($group in $groups.GetEnumerator()) {
        $heading = [Windows.Controls.TextBlock]::new()
        $heading.Text = $group.Key
        $heading.FontWeight = 'Bold'
        $heading.Margin = '5,10,5,5'
        $heading.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'backgroundText')
        [void]$content.Children.Add($heading)
        $border = [Windows.Controls.Border]::new()
        $border.Style = $window.FindResource('CustomBorder')
        $border.Padding = '5'
        $panel = [Windows.Controls.StackPanel]::new()
        $border.Child = $panel
        [void]$content.Children.Add($border)
        foreach ($key in $group.Value) {
            if ($key -eq 'NewCategory' -and !$editable) { continue }
            $fieldArguments = @{ Panel = $panel; Label = $key; Value = $config[$key]; ReadOnly = !$editable }
            switch ($key) {
                Name { $fieldArguments.Value = $Plugin.Name }
                Type {
                    $fieldArguments.Label = 'Script type'
                    if ($editable) {
                        $fieldArguments.Kind = 'Choice'
                        $fieldArguments.Options = [ordered]@{ 'PowerShell (.ps1)' = 'script.ps1'; 'Batch (.cmd)' = 'script.cmd'; 'Batch (.bat)' = 'script.bat' }
                        $fieldArguments.Value = if ($creating) { 'script.ps1' } else { 'script' + [IO.Path]::GetExtension($Plugin.FullName) }
                        $fieldArguments.ReadOnly = !$creating
                    } else { $fieldArguments.Value = [IO.Path]::GetExtension($Plugin.FullName) }
                }
                Category {
                    $fieldArguments.Value = if ($Plugin.Category) { $Plugin.Category } else { $Category }
                    if ($editable) {
                        $fieldArguments.Kind = 'Choice'
                        $categories = [ordered]@{}
                        @('Uncategorized'; $programs.Values | ForEach-Object Category; $script:pluginFiles | ForEach-Object { if ($_.Directory.FullName -ne $pluginsPath) { $_.Directory.Name } }) | Where-Object { $_ } | Sort-Object -Unique | ForEach-Object { $categories[$_] = $_ }
                        if (!$categories.Contains($fieldArguments.Value)) { $categories[$fieldArguments.Value] = $fieldArguments.Value }
                        $categories['New category...'] = '__new_category__'
                        $fieldArguments.Options = $categories
                    }
                }
                NewCategory { $fieldArguments.Label = 'New category'; $fieldArguments.Value = '' }
                Description { $fieldArguments.Multiline = $true }
                ToolTip { $fieldArguments.Label = 'Tooltip' }
                Tags { $fieldArguments.Label = 'Tags (comma-separated)'; $fieldArguments.Value = @($config.Tags) -join ', ' }
                Aliases { $fieldArguments.Label = 'Aliases (comma-separated)'; $fieldArguments.Value = @($config.Aliases) -join ', ' }
                Silent { $fieldArguments.Label = 'Silent launch'; $fieldArguments.Kind = 'Boolean' }
                Hidden { $fieldArguments.Kind = 'Boolean' }
                WorksInOs {
                    $fieldArguments.Label = 'Works in OS'
                    $fieldArguments.Kind = 'Boolean'
                    $fieldArguments.Value = if ($config.Contains('WorksInOs')) { $config.WorksInOs } else { $true }
                }
                WorksInPe {
                    $fieldArguments.Label = 'Works in PE'
                    $fieldArguments.Kind = 'Boolean'
                    $fieldArguments.Value = if ($config.Contains('WorksInPe')) { $config.WorksInPe } else { !$creating }
                }
                Icon { $fieldArguments.Label = 'Icon file'; $fieldArguments.Value = $Plugin.IconPath }
                Source { $fieldArguments.Label = 'Copy script from (optional)'; $fieldArguments.Value = '' }
            }
            $fields[$key] = Add-AtomPluginPropertyField @fieldArguments
            if ($key -in 'Icon', 'Source' -and $editable) {
                $browse = [Windows.Controls.Button]::new()
                $browse.Content = 'Browse'
                $browse.Style = $window.FindResource('RoundedButton')
                $browse.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
                $browse.SetResourceReference([Windows.Controls.Control]::BackgroundProperty, 'surfaceHighlight')
                $browse.Width = 72
                $browse.Height = 30
                $browse.Tag = @{ Dialog = $dialog; Field = $fields[$key]; Kind = $key; Fields = $fields }
                $browse.Add_Click({
                    $picker = [Microsoft.Win32.OpenFileDialog]::new()
                    $picker.Filter = if ($this.Tag.Kind -eq 'Icon') { 'Images (*.png;*.jpg;*.jpeg;*.ico)|*.png;*.jpg;*.jpeg;*.ico' } else { 'Scripts (*.ps1;*.cmd;*.bat)|*.ps1;*.cmd;*.bat' }
                    if ($picker.ShowDialog($this.Tag.Dialog)) {
                        $this.Tag.Field.Text = $picker.FileName
                        if ($this.Tag.Kind -eq 'Source') { $this.Tag.Fields.Type.SelectedValue = 'script' + [IO.Path]::GetExtension($picker.FileName).ToLowerInvariant() }
                    }
                })
                $browseBorder = [Windows.Controls.Border]::new()
                $browseBorder.BorderThickness = 1
                $browseBorder.SetResourceReference([Windows.Controls.Border]::BorderBrushProperty, 'surfaceText')
                $browseBorder.SetResourceReference([Windows.Controls.Border]::CornerRadiusProperty, 'cornerStrength')
                $browseBorder.Margin = '10,0,0,0'
                $browseBorder.VerticalAlignment = 'Center'
                $browseBorder.Child = $browse
                $fieldRow = $fields[$key].Parent
                $browseColumn = [Windows.Controls.ColumnDefinition]::new()
                $browseColumn.Width = [Windows.GridLength]::Auto
                [void]$fieldRow.ColumnDefinitions.Add($browseColumn)
                [Windows.Controls.Grid]::SetColumn($browseBorder, 2)
                [void]$fieldRow.Children.Add($browseBorder)
            }
        }
    }
    if ($editable) {
        $fields.NewCategory.Parent.Visibility = 'Collapsed'
        $fields.Category.Tag = $fields.NewCategory.Parent
        $fields.Category.Add_SelectionChanged({ $this.Tag.Visibility = if ($this.SelectedValue -eq '__new_category__') { 'Visible' } else { 'Collapsed' } })
    }
    foreach ($section in $Sections.GetEnumerator()) {
        $heading = [Windows.Controls.TextBlock]::new()
        $heading.Text = $section.Key
        $heading.FontWeight = 'Bold'
        $heading.Margin = '5,10,5,5'
        $heading.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'backgroundText')
        [void]$content.Children.Add($heading)
        $border = [Windows.Controls.Border]::new()
        $border.Style = $window.FindResource('CustomBorder')
        $border.Padding = '5'
        $panel = [Windows.Controls.StackPanel]::new()
        $border.Child = $panel
        [void]$content.Children.Add($border)
        foreach ($entry in $section.Value.GetEnumerator()) {
            $value = if ($entry.Value -is [Boolean]) { if ($entry.Value) { 'Yes' } else { 'No' } } else { [String]$entry.Value }
            [void](Add-AtomPluginPropertyField -Panel $panel -Label $entry.Key -Value $value -ReadOnly)
        }
    }
    $dialog.Content = $layout
    $dialog.Tag = @{ Fields = $fields; Save = $save; Error = $errorText; Plugin = $Plugin }
    return $dialog
}

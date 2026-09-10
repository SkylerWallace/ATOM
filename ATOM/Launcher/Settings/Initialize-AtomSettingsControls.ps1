function Initialize-AtomSettingsControls {
    if ($script:settingsControlsInitialized) { return }
    $script:settingsSearchEntries = [Collections.Generic.List[Object]]::new()

    $atomSettings.GetEnumerator() | Where-Object { $_.Value.ControlType } | ForEach-Object {
    $setting = $_.Value
    $settingName = $_.Name

    switch ($setting.ControlType) {
        'ToggleButton' {
            $listBoxItem = New-ListBoxControlItem -ControlType ToggleButton -ControlAlignment Right -Text $setting.Name -Tag $settingName -ToolTip $setting.ToolTip

            $listBoxItem.Text.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty,'surfaceText')
            $listBoxItem.Control.IsChecked = $setting.Value

            $listBoxItem.Control.Add_Checked({
                $script:atomSettings.($this.Tag).Value = $true

                if ($this.Tag -eq 'EnableDebugMode') {
                    Set-AtomConsoleVisibility -Visible $true
                }

                if ($this.Tag -in 'ShowQuips', 'InvertQuipRarity') { Set-AtomQuip }

                if ($this.Tag -in 'ShowToolTips', 'SearchPluginTags', 'ShowHiddenPlugins') { $script:pluginListDirty = $true }
                if (!$script:restoringDefaults) { Save-AtomSettings }
            })

            $listBoxItem.Control.Add_UnChecked({
                $script:atomSettings.($this.Tag).Value = $false

                if ($this.Tag -eq 'EnableDebugMode') {
                    Set-AtomConsoleVisibility -Visible $false
                }

                if ($this.Tag -in 'ShowQuips', 'InvertQuipRarity') { Set-AtomQuip }

                if ($this.Tag -in 'ShowToolTips', 'SearchPluginTags', 'ShowHiddenPlugins') { $script:pluginListDirty = $true }
                if (!$script:restoringDefaults) { Save-AtomSettings }
            })
        }

        'ComboBox' {
            $controlOptions = $setting.Options
            if ($settingName -eq 'ThemeGraphic') {
                $library = $window.Resources['Atom.TitleBarGraphic.Library']
                if (!$library) {
                    $library = Import-PowerShellDataFile -LiteralPath (Join-Path $resourcesPath 'ThemeGraphics.psd1')
                    $window.Resources['Atom.TitleBarGraphic.Library'] = $library
                }
                $controlOptions = [ordered]@{ 'Disabled' = 'Disabled'; 'Automatic' = 'Automatic' }
                foreach ($graphicName in ($library.Keys | Sort-Object)) {
                    $label = $graphicName -creplace '([a-z])([A-Z])', '$1 $2'
                    $controlOptions[$label] = $graphicName
                }
                $setting.Options = $controlOptions
            }
            if ($settingName -eq 'PluginEditor') { $controlOptions = Get-AtomPluginEditorOptions }

            $comboBoxStyle = $window.FindResource('CustomComboBox')
            $listBoxItem = New-ListBoxControlItem -ControlType ComboBox -ControlAlignment Right -ControlOptions $controlOptions -SelectedValue $setting.Value -ControlStyle $comboBoxStyle -ControlWidth 110 -Text $setting.Name -Tag $settingName -ToolTip $setting.ToolTip
            $listBoxItem.Text.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
            if ($settingName -eq 'ThemeGraphic') { $listBoxItem.Control.Width = 150 }

            $listBoxItem.Control.Add_SelectionChanged({
                if ($this.Tag -eq 'ThemeGraphic') {
                    if ($script:restoringDefaults -or !$_.AddedItems.Count) { return }
                    $selection = [string]$_.AddedItems[0].Tag
                    $script:atomSettings.ThemeGraphic.Value = $selection
                    Set-AtomThemeGraphic -Window $window -Theme $themes[$script:atomSettings.Theme.Value] -Selection $selection
                    Save-AtomSettings
                    return
                }
                if ($null -eq $this.SelectedValue) { return }

                if ($this.Tag -eq 'PluginEditor' -and $this.SelectedValue -eq '__choose__') {
                    $previousEditor = $script:atomSettings.PluginEditor.Value
                    $editorDialog = New-Object Microsoft.Win32.OpenFileDialog
                    $editorDialog.Title = 'Choose a plugin editor'
                    $editorDialog.Filter = 'Applications (*.exe)|*.exe'
                    $editorDialog.CheckFileExists = $true
                    $editorDialog.Multiselect = $false

                    if ($editorDialog.ShowDialog($window)) {
                        $customItems = @($this.Items | Where-Object {
                            $_.Content -notin 'Notepad', 'Visual Studio Code', 'Notepad++', 'Choose application...'
                        })
                        foreach ($customItem in $customItems) { $this.Items.Remove($customItem) }

                        $existingEditor = @($this.Items | Where-Object Tag -eq $editorDialog.FileName)[0]
                        if (!$existingEditor) {
                            $editorItem = New-Object System.Windows.Controls.ComboBoxItem
                            $editorItem.Content = [IO.Path]::GetFileNameWithoutExtension($editorDialog.FileName)
                            $editorItem.Tag = $editorDialog.FileName
                            $this.Items.Insert($this.Items.Count - 1, $editorItem)
                        }
                        $this.SelectedValue = $editorDialog.FileName
                    } else {
                        $this.SelectedValue = $previousEditor
                    }
                    return
                }

                $script:atomSettings.($this.Tag).Value = $this.SelectedValue
                if ($this.Tag -eq 'PluginClicks') { $script:pluginListDirty = $true }
                if ($this.Tag -eq 'StartupColumns') { Set-AtomPluginColumnCount -ColumnCount $this.SelectedValue }
                if ($this.Tag -eq 'QuipTone') { Set-AtomQuip }
                if (!$script:restoringDefaults) { Save-AtomSettings }
            })
        }
    }

    $listBoxItem.MinHeight = $settingsRowMinHeight
    $listBoxItem.VerticalContentAlignment = 'Center'
    $settingsPanel = $settingsPanels[$setting.Category]
    if (!$settingsPanel) { throw "Unknown settings category '$($setting.Category)' for '$settingName'." }
        $settingsPanel.Children.Add($listBoxItem) | Out-Null
        $section = switch ($setting.Category) { General { 'general' } Plugins { 'plugin' } Quips { 'quip' } Appearance { 'appearance' } }
        Add-AtomSettingSearchEntry -Element $listBoxItem -Name $setting.Name -Description $setting.Description -Section $section
    }

    $resetMetadataButton = [Windows.Controls.Button]::new()
    $resetMetadataButton.Content = 'Reset plugin metadata'
    $resetMetadataButton.Margin = '5'
    $resetMetadataButton.Style = $window.FindResource('RoundedButton')
    $resetMetadataButton.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
    $resetMetadataButton.Background = [Windows.Media.Brushes]::Transparent
    $resetMetadataButton.ToolTip = 'Restore default plugin categories, favorites, visibility, and other metadata'
    $resetMetadataButton.Add_Click({ Reset-AtomPluginMetadata })
    [void]$settingsPanels.Plugins.Children.Add($resetMetadataButton)
    Add-AtomSettingSearchEntry -Element $resetMetadataButton -Name 'Reset plugin metadata' -Description 'Restore default categories, favorites, visibility, and other plugin metadata. Downloaded files and program download settings are kept.' -Section plugin
    Add-AtomSettingSearchEntry -Element ($window.FindName('uiScalingSettingRow')) -Name 'UI scaling' -Description $atomSettings.UIScaling.Description -Section appearance
    Add-AtomSettingSearchEntry -Element ($window.FindName('themeSettingRow')) -Name 'Theme' -Description $atomSettings.Theme.Description -Section appearance
    Add-AtomSettingSearchEntry -Element ($window.FindName('defaultSwitchButton')) -Name 'Restore Defaults' -Description 'Reset ATOM preferences to their default values. The update channel and plugin metadata are kept.' -Section reset
    Add-AtomSettingSearchEntry -Element ($window.FindName('pathButton').Parent) -Name 'ATOM folder and repository' -Description 'Open the local ATOM folder or visit its source repository.' -Section atom
    $window.FindName('settingsSearchTextBox').Add_TextChanged({ Update-AtomSettingsSearch })
    $window.FindName('settingsSearchClearButton').Add_Click({ $window.FindName('settingsSearchTextBox').Clear() })
    $window.FindName('settingsDescriptionButton').Add_Click({
        $script:atomSettings.ShowSettingsDescriptions.Value = !$script:atomSettings.ShowSettingsDescriptions.Value
        Save-AtomSettings
    })
    Set-VectorIcon -Window $window -ResourceMappings @{ settingsSearchClearButton = 'BackspaceIcon'; settingsSearchImage = 'SearchIcon' }
    $script:settingsStatusTimer = [Windows.Threading.DispatcherTimer]::new()
    $script:settingsStatusTimer.Interval = [TimeSpan]::FromSeconds(6)
    $script:settingsStatusTimer.Add_Tick({
        $script:settingsStatusTimer.Stop()
        Set-AtomQuip -Target ($window.FindName('settingsStatusText')) -ReuseCurrent
        $window.FindName('settingsStatusText').ToolTip = $window.FindName('settingsStatusText').Text
    })
    $window.Add_Closed({ $script:settingsStatusTimer.Stop() })
    $script:settingsControlsInitialized = $true
    Update-AtomSettingsSearch
    Set-AtomQuip -Target ($window.FindName('settingsStatusText')) -ReuseCurrent
}

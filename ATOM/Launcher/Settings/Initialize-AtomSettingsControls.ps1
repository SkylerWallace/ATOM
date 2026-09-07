function Initialize-AtomSettingsControls {
    if ($script:settingsControlsInitialized) { return }

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
            if ($settingName -eq 'PluginEditor') { $controlOptions = Get-AtomPluginEditorOptions }

            $comboBoxStyle = $window.FindResource('CustomComboBox')
            $listBoxItem = New-ListBoxControlItem -ControlType ComboBox -ControlAlignment Right -ControlOptions $controlOptions -SelectedValue $setting.Value -ControlStyle $comboBoxStyle -ControlWidth 110 -Text $setting.Name -Tag $settingName -ToolTip $setting.ToolTip
            $listBoxItem.Text.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')

            $listBoxItem.Control.Add_SelectionChanged({
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
    }

    $script:settingsControlsInitialized = $true
}

function Initialize-AtomUpdatesPage {
    if ($script:updatesPageInitialized) { return }

    $script:installedVersionText = $window.FindName('installedVersionText')
    $updateChannelPanel = $window.FindName('updateChannelPanel')
    $updateChannelSelectorStyle = $window.FindResource('CustomComboBox')
    $updateChannelItem = New-ListBoxControlItem -ControlType ComboBox -ControlAlignment Right -ControlOptions ([ordered]@{
        'Stable' = 'main'
        'Development' = 'dev'
    }) -SelectedValue $script:atomSettings['UpdateChannel']['Value'] -ControlStyle $updateChannelSelectorStyle -ControlWidth 144 -Text 'Update channel' -Tag 'UpdateChannel' -ToolTip 'Choose the GitHub branch used for ATOM updates'
    $updateChannelItem.MinHeight = 28
    $updateChannelItem.VerticalContentAlignment = 'Center'
    $updateChannelItem.Text.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
    $updateChannelPanel.Children.Add($updateChannelItem) | Out-Null
    $script:updateChannelSelector = $updateChannelItem.Control
    $script:updateActionButton = $window.FindName('updateActionButton')
    $script:updateActionText = $window.FindName('updateActionText')
    $script:updateActionImage = $window.FindName('updateActionImage')
    $script:healthCheckButton = $window.FindName('healthCheckButton')
    $script:healthCheckText = $window.FindName('healthCheckText')
    $script:updateStatePath = Join-Path $configPath 'UpdateState.json'

    $script:updateText = $window.FindName('updateText')
    $script:lastCheckedPath = Join-Path $configPath "time.txt"
    if (Test-Path $lastCheckedPath) { $lastCheckedContent = Get-Content -Path $lastCheckedPath }
    $updateText.Text = if ($lastCheckedContent) { "Last checked $lastCheckedContent" } else { 'Not checked' }

    $script:updateActionStates = @{
        Check      = @{ Text = 'Check for Updates'; Icon = 'DownloadIcon'; Enabled = $true; ToolTip = 'Check the selected channel for ATOM updates' }
        Checking   = @{ Text = 'Checking...'; Icon = 'RefreshIcon'; Enabled = $false; ToolTip = 'Checking the selected channel for ATOM updates' }
        CheckAgain = @{ Text = 'Check Again'; Icon = 'RefreshIcon'; Enabled = $true; ToolTip = 'Check the selected channel again' }
        Update     = @{ Text = 'Update ATOM'; Icon = 'UpdateIcon'; Enabled = $true; ToolTip = 'Install the available ATOM update' }
        Synchronize = @{ Text = 'Synchronize ATOM'; Icon = 'UpdateIcon'; Enabled = $true; ToolTip = 'Synchronize this source copy with the selected ATOM channel' }
        Repair     = @{ Text = 'Repair ATOM'; Icon = 'ResetWrenchIcon'; Enabled = $true; ToolTip = 'Replace missing or modified ATOM-owned files' }
        Retry      = @{ Text = 'Retry Update Check'; Icon = 'RefreshIcon'; Enabled = $true; ToolTip = 'Retry checking the selected channel for updates' }
    }
    $script:setUpdateAction = {
        param ([Parameter(Mandatory)][String]$State)

        $actionState = $updateActionStates[$State]
        if (!$actionState) { throw "Unknown update action state '$State'." }

        $statusColor = switch ($State) {
            CheckAgain { 'successText' }
            { $_ -in 'Update', 'Synchronize', 'Repair' } { 'warningText' }
            Retry { 'errorText' }
            default { 'surfaceText' }
        }
        $updateText.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, $statusColor)
        $updateActionButton.Tag = $State
        $updateActionButton.IsEnabled = $actionState.Enabled
        $updateActionButton.Opacity = if ($actionState.Enabled) { 1.0 } else { 0.44 }
        $updateActionButton.ToolTip = $actionState.ToolTip
        $updateActionText.Text = $actionState.Text
        $updateActionImage.Content = $window.FindResource($actionState.Icon)
    }
    & $setUpdateAction 'Check'

    Update-AtomUpdateContext
    $updateChannelSelector.SelectedValue = $script:atomSettings['UpdateChannel']['Value']

    $updateActionButton.Add_Click({
        switch ($this.Tag) {
            { $_ -in 'Check', 'CheckAgain', 'Retry' } { Test-AtomUpdate }
            { $_ -in 'Update', 'Synchronize', 'Repair' } { Start-AtomUpdate }
        }
    })

    $healthCheckButton.Add_Click({ Test-AtomInstallationHealth })

    $updateChannelSelector.Add_SelectionChanged({
        if (!$this.SelectedValue) { return }

        $script:atomSettings['UpdateChannel']['Value'] = [String]$this.SelectedValue
        Update-AtomUpdateContext
        & $setUpdateAction 'Check'
        $updateText.Text = "Not checked for '$($script:updateBranch)'"
        $healthCheckText.Text = ''
        $healthCheckText.Visibility = 'Collapsed'

        if (!$script:restoringDefaults) { Save-AtomSettings }
    })
    $script:updatesPageInitialized = $true
}

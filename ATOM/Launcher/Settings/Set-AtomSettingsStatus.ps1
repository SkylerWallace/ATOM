function Set-AtomSettingsStatus {
    param([String]$Message)
    if (!$script:settingsControlsInitialized) { return }
    $window.FindName('settingsStatusText').Text = $Message
    $window.FindName('settingsStatusText').ToolTip = $Message
    $script:settingsStatusTimer.Stop()
    $script:settingsStatusTimer.Start()
}

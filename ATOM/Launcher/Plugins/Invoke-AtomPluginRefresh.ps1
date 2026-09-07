function Invoke-AtomPluginRefresh {
    if (!$refreshButton.IsEnabled) { return }

    Start-ButtonSpin $refreshButton
    Set-AtomQuip
    Update-AtomPluginList -Reload
    $window.SizeToContent = "Height"
}

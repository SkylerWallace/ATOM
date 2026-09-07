function Clear-AtomPluginSelection {
    foreach ($selectedPlugin in @(Get-AtomPluginItems | Where-Object IsSelected)) {
        $selectedPlugin.IsSelected = $false
    }
}

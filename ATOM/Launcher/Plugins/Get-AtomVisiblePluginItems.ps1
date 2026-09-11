function Get-AtomVisiblePluginItems {
    @(Get-AtomPluginItems | Where-Object { $_.IsVisible -and $_.IsEnabled })
}

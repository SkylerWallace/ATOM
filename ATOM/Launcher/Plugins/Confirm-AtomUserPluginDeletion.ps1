function Confirm-AtomUserPluginDeletion {
    param([Parameter(Mandatory)]$Plugin)
    if (!$Plugin.UserPluginId) { return }
    if ([Windows.MessageBox]::Show($window, "Delete user plugin '$($Plugin.Name)'?", 'Delete plugin', 'YesNo', 'Question', 'No') -ne 'Yes') { return }
    if ([Windows.MessageBox]::Show($window, "This will send the plugin folder, including its script, metadata, and copied icons, to the Recycle Bin. The original files you imported are kept. Are you sure?", 'Confirm plugin deletion', 'YesNo', 'Warning', 'No') -ne 'Yes') { return }
    try {
        Remove-AtomUserPlugin -RootPath (Join-Path (Split-Path $atomPath) 'UserPlugins') -Id $Plugin.UserPluginId
        Update-AtomPluginList -Reload
        Update-AtomCatalogFilter
        $statusBarStatus.Text = "Removed $($Plugin.Name)"
    } catch { [void][Windows.MessageBox]::Show($window, $_.Exception.Message, 'Unable to delete plugin', 'OK', 'Error') }
}

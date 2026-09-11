function Confirm-AtomUserPluginDeletion {
    param([Parameter(Mandatory)]$Plugin)
    if (!$Plugin.IsUserOwned) { return }
    if ([Windows.MessageBox]::Show($window, "Delete user plugin '$($Plugin.Name)'?", 'Delete plugin', 'YesNo', 'Question', 'No') -ne 'Yes') { return }
    if ([Windows.MessageBox]::Show($window, "This will recycle the plugin script and any exclusively owned icon, then remove its metadata. A metadata backup is kept in ATOM's Backups folder. Shared icons and original imported files are kept. Are you sure?", 'Confirm plugin deletion', 'YesNo', 'Warning', 'No') -ne 'Yes') { return }
    try {
        Remove-AtomUserPlugin -RootPath $atomPath -Id $Plugin.UserPluginId
        Update-AtomPluginList -Reload
        Update-AtomCatalogFilter
        $statusBarStatus.Text = "Removed $($Plugin.Name)"
    } catch { [void][Windows.MessageBox]::Show($window, $_.Exception.Message, 'Unable to delete plugin', 'OK', 'Error') }
}

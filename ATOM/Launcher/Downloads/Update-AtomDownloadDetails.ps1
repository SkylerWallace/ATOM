function Update-AtomDownloadDetails {
    if (!$script:downloadMode) { return }
    foreach ($name in @($script:downloadRows.Keys)) {
        $row = $script:downloadRows[$name]
        $result = $script:downloadResults[$name]
        $record = $script:downloadRecords[$name]
        $update = $script:downloadVersions[$name]
        $state = $script:downloadTransferState
        $active = $state -and $state.Program -eq $name -and !$pluginsButton.IsEnabled -and $result.Status -eq 'Running'
        $status = if ($result.Status -in 'Failed', 'Blocked', 'Queued', 'Checking', 'Running') { $result.Status } elseif ($script:availableProgramUpdates -contains $name) { 'Update available' } elseif ($result -and $row.Downloaded) { $result.Status } elseif ($row.Downloaded) { 'Downloaded' } else { 'Not downloaded' }
        $lines = [Collections.Generic.List[String]]::new()
        if ($active) {
            $progressText = if ($null -ne $state.PercentComplete) { ' - {0:0}%' -f [Math]::Max(0, [Math]::Min(100, $state.PercentComplete)) } else { '' }
            $lines.Add([String]$state.Status + $progressText)
        } else { $lines.Add($status) }
        $installed = if ($row.Downloaded -and $record.Version) { $record.Version } elseif ($row.Downloaded) { 'Unknown' } else { 'None' }
        $latest = if ($update.LatestVersion) { $update.LatestVersion } else { 'Unknown' }
        $lines.Add("Installed: $installed | Available: $latest")
        if ($active -and $null -ne $state.TotalBytes) {
            $lines.Add('Transfer: ' + (Format-AtomDownloadSize $state.TotalBytes))
        } elseif ($null -ne $record.DownloadBytes) {
            $lines.Add('Last transfer: ' + (Format-AtomDownloadSize $record.DownloadBytes))
        } else { $lines.Add('Download size: Unknown') }
        if ($active -and $state.BytesPerSecond -gt 0) {
            $lines.Add('Speed: ' + (Format-AtomDownloadSize $state.BytesPerSecond) + '/s')
        }
        $diskSize = if ($script:downloadStorage -and $script:downloadStorage.Sizes.ContainsKey($name)) { Format-AtomDownloadSize $script:downloadStorage.Sizes[$name] } else { 'Not measured' }
        $partial = if ($script:downloadStorage.Partial) { ' (partial scan)' } else { '' }
        $lines.Add("On disk: $diskSize$partial")
        $dependencies = @($programs[$name].Dependencies | Where-Object { $_ })
        if ($dependencies.Count) { $lines.Add('Requires: ' + ($dependencies -join ', ')) }
        if ($result.Error) { $lines.Add($result.Error) }
        $row.Details.Text = $lines -join [Environment]::NewLine
        $row.Details.ToolTip = $row.Details.Text
        $row.Progress.Visibility = if ($active) { 'Visible' } else { 'Collapsed' }
        $row.Progress.IsIndeterminate = $active -and $null -eq $state.PercentComplete
        $row.Progress.Value = if ($active -and $null -ne $state.PercentComplete) { [Math]::Max(0, [Math]::Min(100, $state.PercentComplete)) } else { 0 }
        $row.Item.Control.IsEnabled = $pluginsButton.IsEnabled
    }
    if ($script:downloadStorage -and !$script:downloadStorageScan) {
        $suffix = if ($script:downloadStorage.Partial) { ' (partial; some paths skipped)' } else { '' }
        $downloadStorageText.Text = 'Toolkit: ' + (Format-AtomDownloadSize $script:downloadStorage.TotalBytes) + ' | Drive free: ' + (Format-AtomDownloadSize $script:downloadStorage.FreeBytes) + $suffix
    }
}

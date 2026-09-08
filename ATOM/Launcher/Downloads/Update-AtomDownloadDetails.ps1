function Update-AtomDownloadDetails {
    if (!$script:downloadMode) { return }
    foreach ($name in @($script:downloadRows.Keys)) {
        $row = $script:downloadRows[$name]
        $result = $script:downloadResults[$name]
        if ($result.Status -eq 'Completed') {
            $row.Downloaded = $true
            if ($result.Record) { $script:downloadRecords[$name] = $result.Record }
        }
        $record = $script:downloadRecords[$name]
        $update = $script:downloadVersions[$name]
        $state = $script:downloadTransferState
        $active = $state -and $state.Program -eq $name -and !$pluginsButton.IsEnabled -and $result.Status -eq 'Running'
        $status = if ($result.Status -in 'Failed', 'Blocked', 'Queued', 'Checking', 'Running') { $result.Status } elseif ($result.Status -eq 'Completed') { 'Downloaded' } elseif ($script:availableProgramUpdates -contains $name) { 'Update available' } elseif ($result -and $row.Downloaded) { $result.Status } elseif ($row.Downloaded) { 'Downloaded' } else { 'Not downloaded' }
        $lines = [Collections.Generic.List[String]]::new()
        if ($active) {
            $progressText = if ($null -ne $state.PercentComplete) { ' - {0:0}%' -f [Math]::Max(0, [Math]::Min(100, $state.PercentComplete)) } else { '' }
            $lines.Add([String]$state.Status + $progressText)
        } elseif ($status -in 'Failed', 'Blocked', 'Queued', 'Checking', 'Running', 'Update available') { $lines.Add($status) }
        $installed = if ($row.Downloaded -and $record.Version) { $record.Version } elseif ($row.Downloaded) { 'Unknown' } else { 'None' }
        $versionText = "Installed: $installed"
        if ($update.LatestVersion -and $update.LatestVersion -ne $record.Version) { $versionText += " | Available: $($update.LatestVersion)" }
        $lines.Add($versionText)
        if ($active -and $null -ne $state.TotalBytes) {
            $sizeText = 'Transfer: ' + (Format-AtomDownloadSize $state.TotalBytes)
            if ($state.BytesPerSecond -gt 0) { $sizeText += ' | ' + (Format-AtomDownloadSize $state.BytesPerSecond) + '/s' }
            $lines.Add($sizeText)
        } elseif (!$active -and $row.Downloaded -and $script:downloadStorage -and $script:downloadStorage.Sizes.ContainsKey($name)) {
            $partial = if ($script:downloadStorage.Partial) { ' (partial scan)' } else { '' }
            $lines.Add('On disk: ' + (Format-AtomDownloadSize $script:downloadStorage.Sizes[$name]) + $partial)
        } elseif (!$active -and $null -ne $record.DownloadBytes) {
            $lines.Add('Last transfer: ' + (Format-AtomDownloadSize $record.DownloadBytes))
        } elseif ($active -and $state.BytesPerSecond -gt 0) {
            $lines.Add('Speed: ' + (Format-AtomDownloadSize $state.BytesPerSecond) + '/s')
        }
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

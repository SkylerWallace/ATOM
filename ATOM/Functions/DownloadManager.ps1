function Format-AtomDownloadSize {
    param ($Bytes)
    if ($null -eq $Bytes) { return 'Unknown' }
    if ($Bytes -ge 1GB) { return ('{0:0.##} GB' -f ($Bytes / 1GB)) }
    if ($Bytes -ge 1MB) { return ('{0:0.##} MB' -f ($Bytes / 1MB)) }
    if ($Bytes -ge 1KB) { return ('{0:0.##} KB' -f ($Bytes / 1KB)) }
    return "$Bytes B"
}

function Test-AtomDownloadFilter {
    param ([String]$Filter, [Bool]$Downloaded, [Bool]$UpdateAvailable, [String]$Status)
    switch ($Filter) {
        'Downloaded' { return $Downloaded }
        'Not downloaded' { return !$Downloaded }
        'Updates available' { return $UpdateAvailable }
        'Failed' { return $Status -in 'Failed', 'Blocked' }
        default { return $true }
    }
}

function Get-AtomDownloadStorage {
    <#
    .SYNOPSIS
        Measures toolkit files without following junctions or symbolic links.
    #>
    param ([String]$Root, [Hashtable]$Destinations)
    $rootPath = [IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    $prefixes = @{}
    $sizes = @{}
    foreach ($name in $Destinations.Keys) {
        try {
            $destination = [IO.Path]::GetFullPath($Destinations[$name]).TrimEnd('\', '/')
            if ($destination.StartsWith($rootPath + '\', [StringComparison]::OrdinalIgnoreCase)) {
                $prefixes[$name] = $destination + '\'
                $sizes[$name] = [long]0
            }
        } catch { }
    }
    $total = [long]0
    $partial = $false
    $pending = [Collections.Generic.Stack[String]]::new()
    if ([IO.Directory]::Exists($rootPath)) { $pending.Push($rootPath) }
    while ($pending.Count) {
        $directory = $pending.Pop()
        try {
            $directoryInfo = Get-Item -LiteralPath $directory -Force -ErrorAction Stop
            if ($directoryInfo.Attributes -band [IO.FileAttributes]::ReparsePoint) { $partial = $true; continue }
            foreach ($entry in Get-ChildItem -LiteralPath $directory -Force -ErrorAction Stop) {
                if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { $partial = $true; continue }
                if ($entry.PSIsContainer) { $pending.Push($entry.FullName); continue }
                $total += $entry.Length
                foreach ($name in $prefixes.Keys) {
                    if ($entry.FullName.StartsWith($prefixes[$name], [StringComparison]::OrdinalIgnoreCase)) {
                        $sizes[$name] += $entry.Length
                    }
                }
            }
        } catch { $partial = $true }
    }
    $free = $null
    try { $free = [IO.DriveInfo]::new([IO.Path]::GetPathRoot($rootPath)).AvailableFreeSpace } catch { }
    [PSCustomObject]@{ TotalBytes = $total; FreeBytes = $free; Sizes = $sizes; Partial = $partial }
}

function Add-AtomDownloadDetails {
    param ($Item, $ProgramState)
    $panel = [Windows.Controls.StackPanel]::new()
    $existingContent = $Item.Content
    $Item.Content = $null
    [void]$panel.Children.Add($existingContent)
    $details = [Windows.Controls.TextBlock]::new()
    $details.FontSize = 10
    $details.TextWrapping = 'Wrap'
    $details.Margin = '7,2,7,5'
    $details.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
    [void]$panel.Children.Add($details)
    $progress = [Windows.Controls.ProgressBar]::new()
    $progress.Height = 3
    $progress.Margin = '7,0,7,6'
    $progress.Maximum = 100
    $progress.Visibility = 'Collapsed'
    $progress.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'controlBrush')
    [void]$panel.Children.Add($progress)
    $Item.Content = $panel
    $script:downloadRows[$Item.Tag.Name] = @{
        Item = $Item; Details = $details; Progress = $progress; Downloaded = [bool]$ProgramState.IsAvailable
    }
}

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

function Update-AtomDownloadActionEmphasis {
    param ([Int]$SelectedCount)

    $primaryAction = if ($SelectedCount -gt 0) { $downloadSelectedButton } else { $programUpdateButton }
    $secondaryAction = if ($SelectedCount -gt 0) { $programUpdateButton } else { $downloadSelectedButton }
    $primaryAction.SetResourceReference([Windows.Controls.Control]::BackgroundProperty, 'controlBrush')
    $primaryAction.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'controlText')
    $secondaryAction.SetResourceReference([Windows.Controls.Control]::BackgroundProperty, 'accentBrush')
    $secondaryAction.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'accentText')
}

function Update-AtomCatalogFilter {
    $searchText = [String]$searchTextBox.Text
    $filter = if ($downloadFilter.SelectedItem) { [String]$downloadFilter.SelectedItem.Content } else { 'All' }
    $visibleCount = 0
    foreach ($categoryGrid in $pluginWrapPanel.Children) {
        $listBox = $categoryGrid.Children.Child
        $anyVisible = $false
        foreach ($item in $listBox.Items) {
            $visible = ([String]$item.DataContext).IndexOf($searchText, [StringComparison]::OrdinalIgnoreCase) -ge 0
            if ($script:downloadMode) {
                $name = $item.Tag.Name
                $row = $script:downloadRows[$name]
                $visible = $visible -and (Test-AtomDownloadFilter -Filter $filter -Downloaded $row.Downloaded -UpdateAvailable ($script:availableProgramUpdates -contains $name) -Status $script:downloadResults[$name].Status)
            }
            $item.Visibility = if ($visible) { 'Visible' } else { 'Collapsed' }
            if ($visible) { $visibleCount++; $anyVisible = $true }
        }
        $categoryGrid.Visibility = if ($anyVisible) { 'Visible' } else { 'Collapsed' }
        if ($script:downloadMode -and $categoryGrid.Tag -is [Windows.Controls.CheckBox]) {
            $previousSelectionGuard = $window.Tag.UpdatingDownloadSelection
            $window.Tag.UpdatingDownloadSelection = $true
            try {
                $visibleItems = @($listBox.Items | Where-Object { $_.Visibility -eq 'Visible' -and $_.IsEnabled })
                $categoryGrid.Tag.IsEnabled = $pluginsButton.IsEnabled -and $visibleItems.Count -gt 0
                $categoryGrid.Tag.IsChecked = $visibleItems.Count -gt 0 -and @($visibleItems | Where-Object { !$_.Control.IsChecked }).Count -eq 0
            } finally { $window.Tag.UpdatingDownloadSelection = $previousSelectionGuard }
        }
    }
    if ($script:downloadMode) {
        $selected = @(Get-AtomDownloadItem | Where-Object { $_.Control.IsChecked })
        Update-AtomDownloadActionEmphasis -SelectedCount $selected.Count
        $hiddenSelected = @($selected | Where-Object { $_.Visibility -eq 'Collapsed' }).Count
        $downloadSummaryText.Text = "$visibleCount shown | $($selected.Count) selected ($hiddenSelected hidden)"
        if (!$visibleCount) { $downloadSummaryText.Text += ' | No matching downloads' }
        Update-AtomDownloadDetails
    }
}

function Start-AtomDownloadStorageScan {
    if ($script:downloadStorageScan -and !$script:downloadStorageScan.Done) { return }
    $script:downloadStorageScan = [Hashtable]::Synchronized(@{ Done = $false; Result = $null; Error = $null })
    $destinations = @{}
    foreach ($name in $programs.Keys) {
        if ($programs[$name].ProgramInfo.DestinationPath) { $destinations[$name] = [String]$programs[$name].ProgramInfo.DestinationPath }
    }
    $downloadStorageText.Text = 'Measuring toolkit storage...'
    try {
        Invoke-Runspace -Isolated -InputVariables @{
            Scan = $script:downloadStorageScan; Root = $programsPath; Destinations = $destinations
            ManagerPath = (Join-Path $functionsPath 'DownloadManager.ps1')
        } -ScriptBlock {
            try {
                . $ManagerPath
                $Scan.Result = Get-AtomDownloadStorage -Root $Root -Destinations $Destinations
            } catch { $Scan.Error = $_.Exception.Message }
            finally { $Scan.Done = $true }
        }
        $downloadManagerTimer.Start()
    } catch {
        $script:downloadStorageScan.Done = $true
        $downloadStorageText.Text = 'Unable to measure storage: ' + $_.Exception.Message
    }
}

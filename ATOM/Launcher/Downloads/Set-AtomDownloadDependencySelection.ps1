function Set-AtomDownloadDependencySelection {
    param ([String]$Name, [Bool]$Selected)

    if ($script:updatingDownloadDependencies) { return }
    $script:updatingDownloadDependencies = $true
    try {
        $items = @{}
        foreach ($item in @(Get-AtomDownloadItem)) { $items[[String]$item.Control.Tag] = $item }
        $pending = [Collections.Generic.Queue[String]]::new()
        $visited = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
        $pending.Enqueue($Name)
        while ($pending.Count) {
            $current = $pending.Dequeue()
            if (!$visited.Add($current)) { continue }
            if ($items.ContainsKey($current) -and $items[$current].IsEnabled) {
                $items[$current].Control.IsChecked = $Selected
            }
            if ($Selected) {
                foreach ($dependency in @($programs[$current].Dependencies | Where-Object { $_ })) {
                    $pending.Enqueue($dependency)
                }
            } else {
                foreach ($candidate in $programs.Keys) {
                    if ($programs[$candidate].Dependencies -contains $current) { $pending.Enqueue($candidate) }
                }
            }
        }
    } finally {
        $script:updatingDownloadDependencies = $false
    }
    Update-AtomDownloadSelectionState
}

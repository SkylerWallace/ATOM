function Move-AtomPluginFocus {
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Left', 'Right', 'Up', 'Down', 'Home', 'End')]
        [String]$Direction
    )

    $items = @(Get-AtomVisiblePluginItems)
    if (!$items.Count) { return }

    $current = Get-AtomFocusedPluginItem
    if ($Direction -eq 'Home' -or !$current) { Set-AtomFocusedPluginItem -Item $items[0]; return }
    if ($Direction -eq 'End') { Set-AtomFocusedPluginItem -Item $items[-1]; return }

    $origin = $current.TranslatePoint(
        [Windows.Point]::new($current.ActualWidth / 2, $current.ActualHeight / 2),
        $pluginWrapPanel
    )
    $candidate = $items | Where-Object { $_ -ne $current } | ForEach-Object {
        $point = $_.TranslatePoint([Windows.Point]::new($_.ActualWidth / 2, $_.ActualHeight / 2), $pluginWrapPanel)
        $horizontal = $point.X - $origin.X
        $vertical = $point.Y - $origin.Y
        $isCandidate = switch ($Direction) {
            Left  { $horizontal -lt -1 }
            Right { $horizontal -gt 1 }
            Up    { $vertical -lt -1 }
            Down  { $vertical -gt 1 }
        }
        if ($isCandidate) {
            $primary = if ($Direction -in 'Left', 'Right') { [Math]::Abs($horizontal) } else { [Math]::Abs($vertical) }
            $secondary = if ($Direction -in 'Left', 'Right') { [Math]::Abs($vertical) } else { [Math]::Abs($horizontal) }
            [PSCustomObject]@{ Item = $_; Score = $primary + (2 * $secondary) }
        }
    } | Sort-Object Score | Select-Object -First 1

    if ($candidate) { Set-AtomFocusedPluginItem -Item $candidate.Item }
}

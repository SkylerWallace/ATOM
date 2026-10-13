function Update-AtomDownloadActionEmphasis {
    param ([Int]$SelectedCount)

    $primaryAction = if ($SelectedCount -gt 0) { $downloadSelectedButton } else { $programUpdateButton }
    $secondaryAction = if ($SelectedCount -gt 0) { $programUpdateButton } else { $downloadSelectedButton }
    $primaryAction.SetResourceReference([Windows.Controls.Control]::BackgroundProperty, 'controlBrush')
    $primaryAction.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'controlText')
    $secondaryAction.SetResourceReference([Windows.Controls.Control]::BackgroundProperty, 'accentBrush')
    $secondaryAction.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'accentText')
    foreach ($button in $primaryAction, $secondaryAction) {
        if (!$button.IsEnabled) {
            $button.SetResourceReference([Windows.Controls.Control]::BackgroundProperty, 'surfaceBrush')
            $button.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
        }
    }
}

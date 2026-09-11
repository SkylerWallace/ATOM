function Set-AtomQuip {
    param($Target = $statusBarStatus, [Switch]$ReuseCurrent)
    if (!$atomSettings.ShowQuips.Value) {
        $script:currentQuip = ''
    } elseif (!$ReuseCurrent -or !$script:currentQuip) {
        $eligibleQuips = @(switch ($atomSettings.QuipTone.Value) {
            'Gentle'  { $quips | Where-Object { !$_.Tone -or $_.Tone -eq 'Gentle' } }
            'Playful' { $quips | Where-Object { $_.Tone -ne 'Snarky' } }
            'Snarky'  { $quips | Where-Object { $_.Tone -eq 'Snarky' } }
            default   { $quips }
        })

        $commonQuips = @($eligibleQuips | Where-Object { !$_.IsRare })
        $rareQuips = @($eligibleQuips | Where-Object { $_.IsRare })
        $useRarePool = (Get-Random -Minimum 0 -Maximum 8) -eq 0
        if ($atomSettings.InvertQuipRarity.Value) { $useRarePool = !$useRarePool }

        $quipPool = if ($useRarePool) { $rareQuips } else { $commonQuips }
        if (!$quipPool.Count) { $quipPool = if ($useRarePool) { $commonQuips } else { $rareQuips } }

        $script:currentQuip = (Get-Random -InputObject $quipPool).Text
    }

    $Target.Text = $script:currentQuip
    if ($script:settingsControlsInitialized -and !$script:settingsStatusTimer.IsEnabled) {
        $settingsStatus = $window.FindName('settingsStatusText')
        $settingsStatus.Text = $script:currentQuip
        $settingsStatus.ToolTip = $script:currentQuip
    }
}

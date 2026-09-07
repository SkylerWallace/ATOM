function Set-AtomQuip {
    if (!$atomSettings.ShowQuips.Value) {
        $statusBarStatus.Text = ''
        return
    }

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

    $statusBarStatus.Text = (Get-Random -InputObject $quipPool).Text
}

function Start-AtomUpdate {
    if (!$script:atomUpdateContext.LocalHash) {
        $channelName = if ($script:atomUpdateContext.Branch -eq 'dev') { 'Development' } else { 'Stable' }
        $confirmationText = @"
This source copy is not linked to an ATOM release or development snapshot.

Synchronizing will replace ATOM-owned files with the latest $channelName channel files. User-added files will be preserved, and replaced files will be backed up.

Continue?
"@
        $confirmation = [Windows.MessageBox]::Show(
            $window,
            $confirmationText,
            'Synchronize ATOM',
            [Windows.MessageBoxButton]::YesNo,
            [Windows.MessageBoxImage]::Warning
        )
        if ($confirmation -ne [Windows.MessageBoxResult]::Yes) { return }
    }

    $updateAtomPath = "$dependenciesPath\Update-ATOM.ps1"
    $updateArguments = "-NoProfile -ExecutionPolicy Bypass -File `"$updateAtomPath`" -Branch $($script:atomUpdateContext.Branch)"
    Start-Process powershell -ArgumentList $updateArguments
}

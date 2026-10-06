function Start-AtomUpdate {
    $confirmedReplacement = $false
    if ($script:atomUpdateContext.IsGitCheckout -or !$script:atomUpdateContext.LocalHash) {
        $channelName = if ($script:atomUpdateContext.Branch -eq 'dev') { 'Development' } else { 'Stable' }
        $confirmationText = @"
This copy does not have a reliable installed-release reference.

Synchronizing will install the latest $channelName channel files. Unknown files and user settings will be preserved. Files replaced by the package will be backed up.

Continue?
"@
        if ($script:atomUpdateContext.IsGitCheckout) {
            $confirmationText = "This is a Git checkout. Synchronizing with the $channelName channel can overwrite tracked files and local edits. Replaced files will be backed up, and Git history, unknown files, and user settings will be preserved.`n`nContinue?"
        }
        $confirmation = [Windows.MessageBox]::Show(
            $window,
            $confirmationText,
            'Synchronize ATOM',
            [Windows.MessageBoxButton]::YesNo,
            [Windows.MessageBoxImage]::Warning
        )
        if ($confirmation -ne [Windows.MessageBoxResult]::Yes) { return }
        $confirmedReplacement = $true
    }

    $updateAtomPath = "$dependenciesPath\Update-ATOM.ps1"
    $updateArguments = "-NoProfile -ExecutionPolicy Bypass -File `"$updateAtomPath`" -Branch $($script:atomUpdateContext.Branch)"
    if ($confirmedReplacement) { $updateArguments += ' -AllowSourceReplacement' }
    Start-Process powershell -ArgumentList $updateArguments
}

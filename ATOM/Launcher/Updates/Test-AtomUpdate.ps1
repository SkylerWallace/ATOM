function Test-AtomUpdate {
    & $setUpdateAction 'Checking'
    $updateText.Text = 'Checking for updates...'

    Invoke-Runspace -ScriptBlock {
        try {
            . (Join-Path $functionsPath 'Import-Atom.ps1') -Function Get-AtomChannelState
            $latestCommitHash = (Get-AtomChannelState -Channel $updateBranch).CommitSha
            $requiresSynchronization = !$localCommitHash
            $updateAvailable = $localCommitHash -ne $latestCommitHash
            $checkedText = Get-Date -Format 'MM/dd/yy h:mmtt'
            [IO.File]::WriteAllText($lastCheckedPath, $checkedText)

            Invoke-Ui {
                if ($requiresSynchronization) {
                    & $setUpdateAction 'Synchronize'
                    $updateText.Text = "Synchronization required for '$updateBranch'"
                } elseif ($updateAvailable) {
                    & $setUpdateAction 'Update'
                    $updateText.Text = "Update available on '$updateBranch'"
                } else {
                    & $setUpdateAction 'CheckAgain'
                    $updateText.Text = "Up to date ($checkedText)"
                }
            }
        } catch {
            $errorMessage = $_.Exception.Message
            Invoke-Ui {
                $updateText.Text = "Unable to check for updates: $errorMessage"
                & $setUpdateAction 'Retry'
            }
        }
    }
}

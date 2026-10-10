function Test-AtomUpdate {
    & $setUpdateAction 'Checking'
    $updateText.Text = 'Checking for updates...'

    $isGitCheckout = $script:atomUpdateContext.IsGitCheckout
    $checkoutRoot = Split-Path $atomPath
    Invoke-Runspace -InputVariables @{ isGitCheckout=$isGitCheckout; checkoutRoot=$checkoutRoot } -ScriptBlock {
        try {
            . (Join-Path $functionsPath 'Import-Atom.ps1') -Function Get-AtomChannelState
            $latestCommitHash = (Get-AtomChannelState -Channel $updateBranch).CommitSha
            if ($isGitCheckout) {
                $localCommitHash = $null
                $git = (Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1).Source
                if ($git) {
                    $localCommitHash = & $git -C $checkoutRoot rev-parse --verify HEAD 2>&1
                    if ($LASTEXITCODE -ne 0 -or $localCommitHash -notmatch '^[0-9a-f]{40}$') { $localCommitHash = $null }
                }
            }
            $requiresSynchronization = !$localCommitHash
            $updateAvailable = $localCommitHash -ne $latestCommitHash
            $checkedText = Get-Date -Format 'MM/dd/yy h:mmtt'
            [IO.File]::WriteAllText($lastCheckedPath, $checkedText)

            Invoke-Ui {
                if ($isGitCheckout) {
                    & $setUpdateAction 'Synchronize'
                    $updateText.Text = if ($localCommitHash -and !$updateAvailable) { "Checkout matches '$updateBranch'; synchronization available." } else { "Synchronize checkout with '$updateBranch'." }
                } elseif ($requiresSynchronization) {
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

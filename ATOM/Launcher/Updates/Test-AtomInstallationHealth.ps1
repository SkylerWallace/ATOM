function Test-AtomInstallationHealth {
    $healthCheckButton.IsEnabled = $false
    $healthCheckText.Visibility = 'Visible'
    $healthCheckText.Text = 'Verifying ATOM files...'
    $installedCommit = $script:atomUpdateContext.LocalHash
    $installedFiles = @($script:atomUpdateContext.UpdateState.Files)
    $healthBranch = $script:atomUpdateContext.Branch
    $installedRoot = Split-Path $atomPath

    $healthCheckInputs = @{
        installedCommit = $installedCommit
        installedFiles = $installedFiles
        healthBranch  = $healthBranch
        installedRoot = $installedRoot
    }
    Invoke-Runspace -InputVariables $healthCheckInputs -ScriptBlock {
        try {
            . (Join-Path $functionsPath 'Import-Atom.ps1') -Function Get-AtomChannelState,Get-AtomFileHash,Test-AtomFileManifest

            $integrity = Test-AtomFileManifest -RootPath $installedRoot -Files $installedFiles
            $referenceCommit = if ($installedCommit) { $installedCommit } else { 'Unmanaged source copy' }
            try {
                $latestCommit = (Get-AtomChannelState -Channel $healthBranch).CommitSha
                $updateAvailable = $installedCommit -ne $latestCommit
            } catch {
                $channelCheckError = $_.Exception.Message
                $updateAvailable = $false
            }

            $summary = if ($integrity.IsHealthy) {
                "All $($integrity.CheckedCount) ATOM files verified successfully."
            } else {
                "$($integrity.MissingFiles.Count) missing, $($integrity.ModifiedFiles.Count) modified, and $($integrity.UnverifiableFiles.Count) unverifiable file(s)."
            }

            $details = [Collections.Generic.List[String]]::new()
            $details.Add("ATOM HEALTH CHECK")
            $details.Add("Installed commit: $(if ($installedCommit) { $installedCommit } else { 'Unmanaged source copy' })")
            $details.Add("Reference commit: $referenceCommit")
            $details.Add("Selected channel: $healthBranch")
            $details.Add("Files checked: $($integrity.CheckedCount)")
            $details.Add("Files verified: $($integrity.VerifiedCount)")
            $details.Add('')
            $details.Add($summary)

            foreach ($fileGroup in @(
                @{ Label = 'MISSING'; Files = $integrity.MissingFiles }
                @{ Label = 'MODIFIED'; Files = $integrity.ModifiedFiles }
                @{ Label = 'UNVERIFIABLE'; Files = $integrity.UnverifiableFiles }
            )) {
                if (!$fileGroup.Files.Count) { continue }
                $details.Add('')
                $details.Add($fileGroup.Label)
                foreach ($file in @($fileGroup.Files | Select-Object -First 15)) { $details.Add("- $file") }
                if ($fileGroup.Files.Count -gt 15) {
                    $details.Add("...and $($fileGroup.Files.Count - 15) more")
                }
            }

            if ($updateAvailable) {
                $details.Add('')
                $details.Add("A newer commit is available on '$healthBranch'.")
            } elseif ($channelCheckError) {
                $details.Add('')
                $details.Add("Update availability could not be checked: $channelCheckError")
            }

            $detailText = $details -join [Environment]::NewLine
            Invoke-Ui {
                $healthCheckText.Text = $summary
                if (!$installedCommit) {
                    & $setUpdateAction 'Synchronize'
                    $updateText.Text = "Synchronization required for '$healthBranch'"
                } elseif (!$integrity.IsHealthy) {
                    & $setUpdateAction 'Repair'
                    $updateText.Text = 'Repair available'
                } elseif ($updateAvailable) {
                    & $setUpdateAction 'Update'
                    $updateText.Text = "Update available on '$healthBranch'"
                } elseif ($channelCheckError) {
                    & $setUpdateAction 'Retry'
                    $updateText.Text = 'Files verified; update check unavailable'
                } else {
                    & $setUpdateAction 'CheckAgain'
                    $updateText.Text = 'Files verified; ATOM is up to date'
                }
                $healthCheckButton.IsEnabled = $true
                [void][Windows.MessageBox]::Show($window, $detailText, 'ATOM Health Check', 'OK', $(if ($integrity.IsHealthy) { 'Information' } else { 'Warning' }))
            }
        } catch {
            $errorMessage = $_.Exception.Message
            Invoke-Ui {
                $healthCheckText.Text = "Unable to verify ATOM files: $errorMessage"
                $healthCheckButton.IsEnabled = $true
            }
        }
    }
}

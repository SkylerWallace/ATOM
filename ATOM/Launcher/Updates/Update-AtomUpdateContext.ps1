function Update-AtomUpdateContext {
    $updateChannel = [String]$script:atomSettings['UpdateChannel']['Value']
    if ($updateChannel -notin 'main', 'dev') {
        $updateChannel = 'main'
        $script:atomSettings['UpdateChannel']['Value'] = $updateChannel
    }
    $script:atomUpdateContext = Get-AtomUpdateContext -StatePath $updateStatePath -UpdateChannel $updateChannel
    $script:localCommitHash = $script:atomUpdateContext.LocalHash
    $script:updateBranch = $script:atomUpdateContext.Branch
    $installedVersionText.Text = if ($script:atomUpdateContext.IsGitCheckout) {
        "$version (Git checkout)"
    } elseif ($script:localCommitHash) {
        "$version ($($script:localCommitHash.Substring(0, 7)))"
    } else {
        "$version (Unmanaged)"
    }
}

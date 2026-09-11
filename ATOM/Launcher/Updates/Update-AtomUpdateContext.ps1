function Update-AtomUpdateContext {
    $requiresBootstrap = !(Test-Path -LiteralPath $updateStatePath -PathType Leaf)
    if (!$requiresBootstrap) {
        try { $requiresBootstrap = (Get-AtomUpdateState -Path $updateStatePath).SchemaVersion -ne 2 }
        catch { $requiresBootstrap = $true }
    }

    if ($requiresBootstrap) {
        $sourceRootName = Split-Path (Split-Path $atomPath) -Leaf
        $detectedChannel = if ($sourceRootName -eq 'ATOM-dev') { 'dev' } else { 'main' }
        if ($script:atomSettings['UpdateChannel']['Value'] -ne $detectedChannel) {
            $script:atomSettings['UpdateChannel']['Value'] = $detectedChannel
            Write-AtomSettingsFile -Path "$configPath\SettingsUser.ps1" -Settings $script:atomSettings
        }

        $bootstrapExclusions = @(
            '.git/*'
            '.github/*'
            '.gitignore'
            'LICENSE'
            'README.md'
            'Programs/*'
            'UserPlugins/*'
            'ATOM/Backups/*'
            'ATOM/Resources/Icons/User Icons/*'
            'ATOM/Logs/*'
            'ATOM/Config/files.txt'
            'ATOM/Config/hash.txt'
            'ATOM/Config/PluginsUser.ps1'
            'ATOM/Config/PluginsParamsUser.ps1'
            'ATOM/Config/ProgramsParamsUser.ps1'
            'ATOM/Config/SavedTheme.ps1'
            'ATOM/Config/SettingsUser.ps1'
            'ATOM/Config/time.txt'
            'ATOM/Config/UpdateState.json'
        )
        $bootstrapExclusions += @(Get-AtomUserPlugin -RootPath $atomPath | ForEach-Object {
            [Management.Automation.WildcardPattern]::Escape('ATOM/Plugins/' + [IO.Path]::GetFileName($_.FullName))
            [Management.Automation.WildcardPattern]::Escape('ATOM/Resources/Icons/Program Icons/' + $_.Name + '.png')
        })
        $bootstrapFiles = New-AtomFileManifest -RootPath (Split-Path $atomPath) -Exclude $bootstrapExclusions
        Write-AtomUpdateState -Path $updateStatePath -Channel $detectedChannel -Files $bootstrapFiles
    }

    $updateChannel = [String]$script:atomSettings['UpdateChannel']['Value']
    if ($updateChannel -notin 'main', 'dev') {
        $updateChannel = 'main'
        $script:atomSettings['UpdateChannel']['Value'] = $updateChannel
    }
    $script:atomUpdateContext = Get-AtomUpdateContext -StatePath $updateStatePath -UpdateChannel $updateChannel
    $script:localCommitHash = $script:atomUpdateContext.LocalHash
    $script:updateBranch = $script:atomUpdateContext.Branch
    $installedVersionText.Text = if ($script:localCommitHash) {
        "$version ($($script:localCommitHash.Substring(0, 7)))"
    } else {
        "$version (Unmanaged)"
    }
}

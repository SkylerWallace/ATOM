# Explicit function paths and dependencies. Keep alphabetized; see README.md.
@{
    Groups = @{
        Runtime = @(
            'Clear-AtomPluginMetadata'
            'ConvertTo-AtomPowerShellLiteral'
            'Copy-ProgramItem'
            'Copy-WebItem'
            'Dismount-RegistryHive'
            'Expand-With7z'
            'Format-AtomDownloadSize'
            'Format-DownloadManifestJson'
            'Get-App'
            'Get-AtomChannelState'
            'Get-AtomDownloadStorage'
            'Get-AtomFileHash'
            'Get-AtomUpdateContext'
            'Get-AtomUpdateState'
            'Get-DownloadManifest'
            'Get-ProgramUpdates'
            'Get-ShadowCopies'
            'Install-Choco'
            'Install-Program'
            'Install-Scoop'
            'Install-Winget'
            'Invoke-Runspace'
            'Mount-RegistryHive'
            'New-AtomFileManifest'
            'Remove-App'
            'Remove-DownloadRecord'
            'Remove-ThingProperty'
            'Resolve-ScoopDownload'
            'Set-AtomPluginOverride'
            'Set-DownloadRecord'
            'Set-ThingProperty'
            'Set-WindowStyle'
            'Start-Program'
            'Sync-DownloadManifest'
            'Test-AtomDownloadFilter'
            'Test-AtomFileManifest'
            'Update-AtomEnvironmentPath'
            'Write-AtomFileAtomic'
            'Write-AtomSettingsFile'
            'Write-AtomUpdateState'
            'Write-DownloadManifest'
        )
        Wpf = @(
            'Add-AtomScrollViewerBehavior'
            'Get-AtomThemeShadowResources'
            'Get-CachedImage'
            'Get-VectorIconGeometry'
            'New-AtomWindow'
            'New-ListBoxControlItem'
            'New-VectorIcon'
            'Set-AtomThemeGradient'
            'Set-VectorIcon'
            'Set-WindowSize'
            'Start-ButtonSpin'
        )
        Launcher = @(
            'Add-AtomDownloadDetails'
            'Add-AtomPluginDescription'
            'Add-AtomSettingSearchEntry'
            'Clear-AtomPluginSelection'
            'Clear-AtomSearchTextBox'
            'Focus-AtomSearch'
            'Get-AtomDownloadItem'
            'Get-AtomFocusedPluginItem'
            'Get-AtomManagedProgramState'
            'Get-AtomPluginEditorOptions'
            'Get-AtomPluginItems'
            'Get-AtomVisiblePluginItems'
            'Initialize-AtomChangelog'
            'Initialize-AtomSettingsControls'
            'Invoke-AtomEscapeAction'
            'Invoke-AtomPlugin'
            'Invoke-AtomPluginRefresh'
            'Invoke-AtomSingleSearchResult'
            'Move-AtomPluginFocus'
            'New-AtomSearchBarXaml'
            'Open-AtomAddPluginMenu'
            'Open-AtomFileInEditor'
            'Open-AtomPluginContextMenu'
            'Open-AtomPluginFileLocation'
            'Open-AtomPluginInEditor'
            'Remove-AtomOfflineDownload'
            'Reset-AtomPluginMetadata'
            'Save-AtomSettings'
            'Select-AllAtomDownloads'
            'Set-AtomChangelogExpanded'
            'Set-AtomConsoleVisibility'
            'Set-AtomDownloadDependencySelection'
            'Set-AtomDownloadMode'
            'Set-AtomFocusedPluginItem'
            'Set-AtomPage'
            'Set-AtomPluginCategory'
            'Set-AtomPluginColumnCount'
            'Set-AtomPluginFavorite'
            'Set-AtomPluginPreference'
            'Set-AtomPluginSortLayout'
            'Set-AtomPluginVisibility'
            'Set-AtomQuip'
            'Set-AtomSettingsStatus'
            'Set-AtomThemeSelectorExpanded'
            'Set-AtomUiScaling'
            'Show-AtomPluginProperties'
            'Start-AtomDownloadStorageScan'
            'Start-AtomUpdate'
            'Test-AtomInstallationHealth'
            'Test-AtomUpdate'
            'Toggle-AtomFocusedPlugin'
            'Update-AtomCatalogFilter'
            'Update-AtomDownloadActionEmphasis'
            'Update-AtomDownloadDetails'
            'Update-AtomDownloadSelectionState'
            'Update-AtomPluginList'
            'Update-AtomSettingsSearch'
            'Update-AtomThemeSelector'
            'Update-AtomUpdateContext'
            'Update-AtomVisibilityButton'
        )
    }
    Functions = @{
        'Add-AtomDownloadDetails' = @{
            Path = '../Launcher/Downloads/Add-AtomDownloadDetails.ps1'
            DependsOn = @()
        }
        'Add-AtomPluginDescription' = @{
            Path = '../Launcher/Plugins/Add-AtomPluginDescription.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Add-AtomPluginPropertyField' = @{
            Path = '../Launcher/Plugins/Add-AtomPluginPropertyField.ps1'
            DependsOn = @('New-ListBoxControlItem')
            Wpf = $true
        }
        'Add-AtomScrollViewerBehavior' = @{
            Path = 'WPF/Add-AtomScrollViewerBehavior.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Add-AtomSettingSearchEntry' = @{
            Path = '../Launcher/Settings/Add-AtomSettingSearchEntry.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Clear-AtomPluginMetadata' = @{
            Path = 'Configuration/Clear-AtomPluginMetadata.ps1'
            DependsOn = @('ConvertTo-AtomPowerShellLiteral', 'Write-AtomFileAtomic')
        }
        'Clear-AtomPluginSelection' = @{
            Path = '../Launcher/Plugins/Clear-AtomPluginSelection.ps1'
            DependsOn = @('Get-AtomPluginItems')
            Wpf = $true
        }
        'Clear-AtomSearchTextBox' = @{
            Path = '../Launcher/Plugins/Clear-AtomSearchTextBox.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Confirm-AtomUserPluginDeletion' = @{
            Path = '../Launcher/Plugins/Confirm-AtomUserPluginDeletion.ps1'
            DependsOn = @('Remove-AtomUserPlugin', 'Update-AtomPluginList', 'Update-AtomCatalogFilter')
            Wpf = $true
        }
        'ConvertTo-AtomPowerShellLiteral' = @{
            Path = 'Configuration/ConvertTo-AtomPowerShellLiteral.ps1'
            DependsOn = @()
        }
        'Copy-ProgramItem' = @{
            Path = 'Downloads/Copy-ProgramItem.ps1'
            DependsOn = @('Copy-WebItem', 'Resolve-ScoopDownload')
        }
        'Copy-WebItem' = @{
            Path = 'Downloads/Copy-WebItem.ps1'
            DependsOn = @()
        }
        'Dismount-RegistryHive' = @{
            Path = 'Windows/Dismount-RegistryHive.ps1'
            DependsOn = @()
        }
        'Expand-With7z' = @{
            Path = 'Files/Expand-With7z.ps1'
            DependsOn = @()
        }
        'Focus-AtomSearch' = @{
            Path = '../Launcher/Plugins/Focus-AtomSearch.ps1'
            DependsOn = @('Set-AtomPage')
            Wpf = $true
        }
        'Format-AtomDownloadSize' = @{
            Path = 'Downloads/Format-AtomDownloadSize.ps1'
            DependsOn = @()
        }
        'Format-DownloadManifestJson' = @{
            Path = 'Downloads/Format-DownloadManifestJson.ps1'
            DependsOn = @()
        }
        'Get-App' = @{
            Path = 'Applications/Get-App.ps1'
            DependsOn = @()
        }
        'Get-AtomChannelState' = @{
            Path = 'Updates/Get-AtomChannelState.ps1'
            DependsOn = @()
        }
        'Get-AtomDownloadItem' = @{
            Path = '../Launcher/Downloads/Get-AtomDownloadItem.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Get-AtomDownloadStorage' = @{
            Path = 'Downloads/Get-AtomDownloadStorage.ps1'
            DependsOn = @()
        }
        'Get-AtomFileHash' = @{
            Path = 'Updates/Get-AtomFileHash.ps1'
            DependsOn = @()
        }
        'Get-AtomFocusedPluginItem' = @{
            Path = '../Launcher/Plugins/Get-AtomFocusedPluginItem.ps1'
            DependsOn = @('Get-AtomVisiblePluginItems')
            Wpf = $true
        }
        'Get-AtomManagedProgramState' = @{
            Path = '../Launcher/Navigation/Get-AtomManagedProgramState.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Get-AtomPluginEditorOptions' = @{
            Path = '../Launcher/Plugins/Get-AtomPluginEditorOptions.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Get-AtomPluginItems' = @{
            Path = '../Launcher/Plugins/Get-AtomPluginItems.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Get-AtomThemeShadowResources' = @{
            Path = 'WPF/Get-AtomThemeShadowResources.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Get-AtomUpdateContext' = @{
            Path = 'Updates/Get-AtomUpdateContext.ps1'
            DependsOn = @('Get-AtomUpdateState')
        }
        'Get-AtomUpdateState' = @{
            Path = 'Updates/Get-AtomUpdateState.ps1'
            DependsOn = @()
        }
        'Get-AtomUserPlugin' = @{
            Path = 'Configuration/Get-AtomUserPlugin.ps1'
            DependsOn = @()
        }
        'Get-AtomVisiblePluginItems' = @{
            Path = '../Launcher/Plugins/Get-AtomVisiblePluginItems.ps1'
            DependsOn = @('Get-AtomPluginItems')
            Wpf = $true
        }
        'Get-CachedImage' = @{
            Path = 'WPF/Get-CachedImage.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Get-DownloadManifest' = @{
            Path = 'Downloads/Get-DownloadManifest.ps1'
            DependsOn = @()
        }
        'Get-ProgramUpdates' = @{
            Path = 'Downloads/Get-ProgramUpdates.ps1'
            DependsOn = @('Get-DownloadManifest', 'Resolve-ScoopDownload')
        }
        'Get-ShadowCopies' = @{
            Path = 'Windows/Get-ShadowCopies.ps1'
            DependsOn = @()
        }
        'Get-VectorIconGeometry' = @{
            Path = 'WPF/Get-VectorIconGeometry.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Initialize-AtomChangelog' = @{
            Path = '../Launcher/Updates/Initialize-AtomChangelog.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Initialize-AtomSettingsControls' = @{
            Path = '../Launcher/Settings/Initialize-AtomSettingsControls.ps1'
            DependsOn = @('Add-AtomSettingSearchEntry', 'Get-AtomPluginEditorOptions', 'New-ListBoxControlItem', 'Reset-AtomPluginMetadata', 'Save-AtomSettings', 'Set-AtomConsoleVisibility', 'Set-AtomPluginColumnCount', 'Set-AtomQuip', 'Set-VectorIcon', 'Update-AtomSettingsSearch')
            Wpf = $true
        }
        'Install-Choco' = @{
            Path = 'Applications/Install-Choco.ps1'
            DependsOn = @('Update-AtomEnvironmentPath')
        }
        'Install-Program' = @{
            Path = 'Applications/Install-Program.ps1'
            DependsOn = @('Copy-WebItem')
        }
        'Install-Scoop' = @{
            Path = 'Applications/Install-Scoop.ps1'
            DependsOn = @('Update-AtomEnvironmentPath')
        }
        'Install-Winget' = @{
            Path = 'Applications/Install-Winget.ps1'
            DependsOn = @('Copy-WebItem')
        }
        'Invoke-AtomEscapeAction' = @{
            Path = '../Launcher/Navigation/Invoke-AtomEscapeAction.ps1'
            DependsOn = @('Clear-AtomPluginSelection', 'Clear-AtomSearchTextBox', 'Get-AtomPluginItems', 'Set-AtomPage')
            Wpf = $true
        }
        'Invoke-AtomPlugin' = @{
            Path = '../Launcher/Plugins/Invoke-AtomPlugin.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Invoke-AtomPluginRefresh' = @{
            Path = '../Launcher/Plugins/Invoke-AtomPluginRefresh.ps1'
            DependsOn = @('Set-AtomQuip', 'Start-ButtonSpin', 'Update-AtomPluginList')
            Wpf = $true
        }
        'Invoke-AtomSingleSearchResult' = @{
            Path = '../Launcher/Plugins/Invoke-AtomSingleSearchResult.ps1'
            DependsOn = @('Get-AtomVisiblePluginItems', 'Invoke-AtomPlugin')
            Wpf = $true
        }
        'Invoke-Runspace' = @{
            Path = 'Core/Invoke-Runspace.ps1'
            DependsOn = @()
        }
        'Mount-RegistryHive' = @{
            Path = 'Windows/Mount-RegistryHive.ps1'
            DependsOn = @()
        }
        'Move-AtomPluginFocus' = @{
            Path = '../Launcher/Plugins/Move-AtomPluginFocus.ps1'
            DependsOn = @('Get-AtomFocusedPluginItem', 'Get-AtomVisiblePluginItems', 'Set-AtomFocusedPluginItem')
            Wpf = $true
        }
        'New-AtomFileManifest' = @{
            Path = 'Updates/New-AtomFileManifest.ps1'
            DependsOn = @('Get-AtomFileHash')
        }
        'New-AtomPluginPropertiesWindow' = @{
            Path = '../Launcher/Plugins/New-AtomPluginPropertiesWindow.ps1'
            DependsOn = @('Add-AtomPluginPropertyField')
            Wpf = $true
        }
        'New-AtomSearchBarXaml' = @{
            Path = '../Launcher/Navigation/New-AtomSearchBarXaml.ps1'
            DependsOn = @()
        }
        'New-AtomWindow' = @{
            Path = 'WPF/New-AtomWindow.ps1'
            DependsOn = @('Set-AtomThemeGradient', 'Set-VectorIcon')
            Wpf = $true
        }
        'New-ListBoxControlItem' = @{
            Path = 'WPF/New-ListBoxControlItem.ps1'
            DependsOn = @('Get-CachedImage')
            Wpf = $true
        }
        'New-VectorIcon' = @{
            Path = 'WPF/New-VectorIcon.ps1'
            DependsOn = @('Get-VectorIconGeometry')
            Wpf = $true
        }
        'Open-AtomAddPluginMenu' = @{
            Path = '../Launcher/Plugins/Open-AtomAddPluginMenu.ps1'
            DependsOn = @('Show-AtomPluginProperties')
            Wpf = $true
        }
        'Open-AtomFileInEditor' = @{
            Path = '../Launcher/Navigation/Open-AtomFileInEditor.ps1'
            DependsOn = @()
        }
        'Open-AtomPluginContextMenu' = @{
            Path = '../Launcher/Plugins/Open-AtomPluginContextMenu.ps1'
            DependsOn = @('Get-AtomFocusedPluginItem')
            Wpf = $true
        }
        'Open-AtomPluginFileLocation' = @{
            Path = '../Launcher/Plugins/Open-AtomPluginFileLocation.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Open-AtomPluginInEditor' = @{
            Path = '../Launcher/Plugins/Open-AtomPluginInEditor.ps1'
            DependsOn = @('Open-AtomFileInEditor')
            Wpf = $true
        }
        'Remove-App' = @{
            Path = 'Applications/Remove-App.ps1'
            DependsOn = @()
        }
        'Remove-AtomOfflineDownload' = @{
            Path = '../Launcher/Downloads/Remove-AtomOfflineDownload.ps1'
            DependsOn = @('Get-AtomManagedProgramState', 'Remove-DownloadRecord', 'Update-AtomPluginList')
            Wpf = $true
        }
        'Remove-AtomUserPlugin' = @{
            Path = 'Configuration/Remove-AtomUserPlugin.ps1'
            DependsOn = @('Get-AtomUserPlugin')
        }
        'Remove-DownloadRecord' = @{
            Path = 'Downloads/Remove-DownloadRecord.ps1'
            DependsOn = @('Get-DownloadManifest', 'Write-DownloadManifest')
        }
        'Remove-ThingProperty' = @{
            Path = 'Windows/Remove-ThingProperty.ps1'
            DependsOn = @('Dismount-RegistryHive', 'Mount-RegistryHive')
        }
        'Reset-AtomPluginMetadata' = @{
            Path = '../Launcher/Settings/Reset-AtomPluginMetadata.ps1'
            DependsOn = @('Clear-AtomPluginMetadata', 'Set-AtomSettingsStatus', 'Update-AtomPluginList', 'Update-AtomCatalogFilter')
            Wpf = $true
        }
        'Resolve-ScoopDownload' = @{
            Path = 'Downloads/Resolve-ScoopDownload.ps1'
            DependsOn = @()
        }
        'Save-AtomSettings' = @{
            Path = '../Launcher/Settings/Save-AtomSettings.ps1'
            DependsOn = @('Set-AtomSettingsStatus', 'Update-AtomSettingsSearch', 'Write-AtomSettingsFile')
            Wpf = $true
        }
        'Save-AtomUserPlugin' = @{
            Path = 'Configuration/Save-AtomUserPlugin.ps1'
            DependsOn = @('Get-AtomUserPlugin', 'Write-AtomFileAtomic')
        }
        'Select-AllAtomDownloads' = @{
            Path = '../Launcher/Downloads/Select-AllAtomDownloads.ps1'
            DependsOn = @('Get-AtomPluginItems', 'Update-AtomDownloadSelectionState')
            Wpf = $true
        }
        'Set-AtomChangelogExpanded' = @{
            Path = '../Launcher/Updates/Set-AtomChangelogExpanded.ps1'
            DependsOn = @('Initialize-AtomChangelog', 'Set-VectorIcon')
            Wpf = $true
        }
        'Set-AtomConsoleVisibility' = @{
            Path = '../Launcher/Navigation/Set-AtomConsoleVisibility.ps1'
            DependsOn = @('Set-WindowStyle')
            Wpf = $true
        }
        'Set-AtomDownloadDependencySelection' = @{
            Path = '../Launcher/Downloads/Set-AtomDownloadDependencySelection.ps1'
            DependsOn = @('Get-AtomDownloadItem', 'Update-AtomDownloadSelectionState')
            Wpf = $true
        }
        'Set-AtomDownloadMode' = @{
            Path = '../Launcher/Downloads/Set-AtomDownloadMode.ps1'
            DependsOn = @('Clear-AtomSearchTextBox', 'Set-AtomQuip', 'Update-AtomPluginList')
            Wpf = $true
        }
        'Set-AtomFocusedPluginItem' = @{
            Path = '../Launcher/Plugins/Set-AtomFocusedPluginItem.ps1'
            DependsOn = @('Clear-AtomPluginSelection')
            Wpf = $true
        }
        'Set-AtomPage' = @{
            Path = '../Launcher/Navigation/Set-AtomPage.ps1'
            DependsOn = @('Initialize-AtomSettingsControls', 'Set-AtomDownloadMode', 'Start-AtomDownloadStorageScan', 'Update-AtomPluginList')
            Wpf = $true
        }
        'Set-AtomPluginCategory' = @{
            Path = '../Launcher/Plugins/Set-AtomPluginCategory.ps1'
            DependsOn = @('Set-AtomPluginPreference', 'Update-AtomPluginList')
            Wpf = $true
        }
        'Set-AtomPluginColumnCount' = @{
            Path = '../Launcher/Plugins/Set-AtomPluginColumnCount.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Set-AtomPluginFavorite' = @{
            Path = '../Launcher/Plugins/Set-AtomPluginFavorite.ps1'
            DependsOn = @('New-VectorIcon', 'Set-AtomPluginPreference')
            Wpf = $true
        }
        'Set-AtomPluginOverride' = @{
            Path = 'Configuration/Set-AtomPluginOverride.ps1'
            DependsOn = @('ConvertTo-AtomPowerShellLiteral', 'Write-AtomFileAtomic')
        }
        'Set-AtomPluginPreference' = @{
            Path = '../Launcher/Plugins/Set-AtomPluginPreference.ps1'
            DependsOn = @('Save-AtomUserPlugin', 'Set-AtomPluginOverride')
            Wpf = $true
        }
        'Set-AtomPluginSortLayout' = @{
            Path = '../Launcher/Plugins/Set-AtomPluginSortLayout.ps1'
            DependsOn = @('Set-AtomPluginCategory', 'Update-AtomPluginList')
            Wpf = $true
        }
        'Set-AtomPluginVisibility' = @{
            Path = '../Launcher/Plugins/Set-AtomPluginVisibility.ps1'
            DependsOn = @('Set-AtomPluginPreference', 'Update-AtomPluginList')
            Wpf = $true
        }
        'Set-AtomQuip' = @{
            Path = '../Launcher/Navigation/Set-AtomQuip.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Set-AtomSettingsStatus' = @{
            Path = '../Launcher/Settings/Set-AtomSettingsStatus.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Set-AtomThemeGradient' = @{
            Path = 'WPF/Set-AtomThemeGradient.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Set-AtomThemeSelectorExpanded' = @{
            Path = '../Launcher/Settings/Set-AtomThemeSelectorExpanded.ps1'
            DependsOn = @('Set-VectorIcon')
            Wpf = $true
        }
        'Set-AtomUiScaling' = @{
            Path = '../Launcher/Settings/Set-AtomUiScaling.ps1'
            DependsOn = @('Set-AtomPluginColumnCount')
            Wpf = $true
        }
        'Set-DownloadRecord' = @{
            Path = 'Downloads/Set-DownloadRecord.ps1'
            DependsOn = @('Get-DownloadManifest', 'Write-DownloadManifest')
        }
        'Set-ThingProperty' = @{
            Path = 'Windows/Set-ThingProperty.ps1'
            DependsOn = @('Dismount-RegistryHive', 'Mount-RegistryHive')
        }
        'Set-VectorIcon' = @{
            Path = 'WPF/Set-VectorIcon.ps1'
            DependsOn = @('Get-VectorIconGeometry', 'New-VectorIcon')
            Wpf = $true
        }
        'Set-WindowSize' = @{
            Path = 'WPF/Set-WindowSize.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Set-WindowStyle' = @{
            Path = 'Windows/Set-WindowStyle.ps1'
            DependsOn = @()
        }
        'Show-AtomPluginProperties' = @{
            Path = '../Launcher/Plugins/Show-AtomPluginProperties.ps1'
            DependsOn = @('Get-CachedImage', 'New-AtomPluginPropertiesWindow', 'Save-AtomUserPlugin', 'Update-AtomCatalogFilter', 'Update-AtomPluginList')
            Wpf = $true
        }
        'Start-AtomDownloadStorageScan' = @{
            Path = '../Launcher/Downloads/Start-AtomDownloadStorageScan.ps1'
            DependsOn = @('Get-AtomDownloadStorage', 'Invoke-Runspace')
        }
        'Start-AtomUpdate' = @{
            Path = '../Launcher/Updates/Start-AtomUpdate.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Start-ButtonSpin' = @{
            Path = 'WPF/Start-ButtonSpin.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Start-Program' = @{
            Path = 'Applications/Start-Program.ps1'
            DependsOn = @('Copy-ProgramItem', 'Copy-WebItem', 'Expand-With7z', 'Resolve-ScoopDownload')
        }
        'Sync-DownloadManifest' = @{
            Path = 'Downloads/Sync-DownloadManifest.ps1'
            DependsOn = @('Get-DownloadManifest', 'Write-DownloadManifest')
        }
        'Test-AtomDownloadFilter' = @{
            Path = 'Downloads/Test-AtomDownloadFilter.ps1'
            DependsOn = @()
        }
        'Test-AtomFileManifest' = @{
            Path = 'Updates/Test-AtomFileManifest.ps1'
            DependsOn = @('Get-AtomFileHash')
        }
        'Test-AtomInstallationHealth' = @{
            Path = '../Launcher/Updates/Test-AtomInstallationHealth.ps1'
            DependsOn = @('Get-AtomChannelState', 'Invoke-Runspace', 'Test-AtomFileManifest')
            Wpf = $true
        }
        'Test-AtomUpdate' = @{
            Path = '../Launcher/Updates/Test-AtomUpdate.ps1'
            DependsOn = @('Get-AtomChannelState', 'Invoke-Runspace')
            Wpf = $true
        }
        'Toggle-AtomFocusedPlugin' = @{
            Path = '../Launcher/Plugins/Toggle-AtomFocusedPlugin.ps1'
            DependsOn = @('Get-AtomFocusedPluginItem', 'Set-AtomPluginFavorite')
            Wpf = $true
        }
        'Update-AtomCatalogFilter' = @{
            Path = '../Launcher/Downloads/Update-AtomCatalogFilter.ps1'
            DependsOn = @('Get-AtomDownloadItem', 'Test-AtomDownloadFilter', 'Update-AtomDownloadActionEmphasis', 'Update-AtomDownloadDetails')
        }
        'Update-AtomDownloadActionEmphasis' = @{
            Path = '../Launcher/Downloads/Update-AtomDownloadActionEmphasis.ps1'
            DependsOn = @()
        }
        'Update-AtomDownloadDetails' = @{
            Path = '../Launcher/Downloads/Update-AtomDownloadDetails.ps1'
            DependsOn = @('Format-AtomDownloadSize')
        }
        'Update-AtomDownloadSelectionState' = @{
            Path = '../Launcher/Downloads/Update-AtomDownloadSelectionState.ps1'
            DependsOn = @('Get-AtomDownloadItem', 'Update-AtomCatalogFilter')
            Wpf = $true
        }
        'Update-AtomEnvironmentPath' = @{
            Path = 'Windows/Update-AtomEnvironmentPath.ps1'
            DependsOn = @()
        }
        'Update-AtomPluginList' = @{
            Path = '../Launcher/Plugins/Update-AtomPluginList.ps1'
            DependsOn = @('Add-AtomDownloadDetails', 'Add-AtomPluginDescription', 'Confirm-AtomUserPluginDeletion', 'Get-AtomDownloadItem', 'Get-AtomManagedProgramState', 'Get-AtomUserPlugin', 'Get-CachedImage', 'Get-DownloadManifest', 'Invoke-AtomPlugin', 'Invoke-Runspace', 'New-ListBoxControlItem', 'New-VectorIcon', 'Open-AtomPluginFileLocation', 'Open-AtomPluginInEditor', 'Remove-AtomOfflineDownload', 'Set-AtomDownloadDependencySelection', 'Set-AtomPluginCategory', 'Set-AtomPluginFavorite', 'Set-AtomPluginVisibility', 'Set-VectorIcon', 'Show-AtomPluginProperties', 'Update-AtomCatalogFilter', 'Update-AtomDownloadSelectionState', 'Update-AtomVisibilityButton')
            Wpf = $true
        }
        'Update-AtomSettingsSearch' = @{
            Path = '../Launcher/Settings/Update-AtomSettingsSearch.ps1'
            DependsOn = @('Set-VectorIcon')
            Wpf = $true
        }
        'Update-AtomThemeSelector' = @{
            Path = '../Launcher/Settings/Update-AtomThemeSelector.ps1'
            DependsOn = @()
            Wpf = $true
        }
        'Update-AtomUpdateContext' = @{
            Path = '../Launcher/Updates/Update-AtomUpdateContext.ps1'
            DependsOn = @('Get-AtomUpdateContext', 'Get-AtomUpdateState', 'New-AtomFileManifest', 'Write-AtomSettingsFile', 'Write-AtomUpdateState')
            Wpf = $true
        }
        'Update-AtomVisibilityButton' = @{
            Path = '../Launcher/Updates/Update-AtomVisibilityButton.ps1'
            DependsOn = @('Set-VectorIcon')
            Wpf = $true
        }
        'Write-AtomFileAtomic' = @{
            Path = 'Files/Write-AtomFileAtomic.ps1'
            DependsOn = @()
        }
        'Write-AtomSettingsFile' = @{
            Path = 'Configuration/Write-AtomSettingsFile.ps1'
            DependsOn = @('Write-AtomFileAtomic')
        }
        'Write-AtomUpdateState' = @{
            Path = 'Updates/Write-AtomUpdateState.ps1'
            DependsOn = @('Write-AtomFileAtomic')
        }
        'Write-DownloadManifest' = @{
            Path = 'Downloads/Write-DownloadManifest.ps1'
            DependsOn = @('Format-DownloadManifestJson', 'Write-AtomFileAtomic')
        }
    }
}

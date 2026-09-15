@{
    SchemaVersion = 1
    Actions = @{
        WindowsGentleCleanup = @{
            Name          = 'Gentle cleanup'
            Description   = 'Clean Windows update files, Defender files, upgrade logs, obsolete drivers, reports, and temporary caches while keeping the Recycle Bin intact.'
            Source        = 'Temp Cleanup'
            Kind          = 'Plugin'
            PluginFile    = 'Temp Cleanup.ps1'
            WorksInPE     = $false
            RequiresAdmin = $true
            Parameters    = @{
                MinimumAgeDays = 7
                Categories     = @(
                    'WindowsUpdateCleanup'
                    'DefenderAntivirus'
                    'WindowsUpgradeLogs'
                    'DownloadedProgramFiles'
                    'InternetCache'
                    'ErrorReports'
                    'DeliveryOptimization'
                    'TemporaryFiles'
                    'DeviceDriverPackages'
                )
                NonInteractive = $true
            }
        }

        WindowsDeepCleanup = @{
            Name          = 'Deep cleanup'
            Description   = 'Run gentle cleanup, clear DirectX and thumbnail caches, and permanently empty the current account''s Recycle Bin.'
            Source        = 'Temp Cleanup'
            Kind          = 'Plugin'
            PluginFile    = 'Temp Cleanup.ps1'
            WorksInPE     = $false
            RequiresAdmin = $true
            Parameters    = @{
                MinimumAgeDays = 7
                Categories     = @(
                    'WindowsUpdateCleanup'
                    'DefenderAntivirus'
                    'WindowsUpgradeLogs'
                    'DownloadedProgramFiles'
                    'InternetCache'
                    'ErrorReports'
                    'DeliveryOptimization'
                    'TemporaryFiles'
                    'DeviceDriverPackages'
                    'DirectXShaderCache'
                    'RecycleBin'
                    'Thumbnails'
                )
                NonInteractive = $true
            }
        }

        WindowsRestoreDefaultServices = @{
            Name          = 'Restore default service startup states'
            Description   = 'Restore supported Windows services to their default startup settings; restart Windows to apply changes.'
            Source        = 'Reset Default Services'
            Kind          = 'Plugin'
            PluginFile    = 'Reset Default Services.ps1'
            WorksInPE     = $true
            RequiresAdmin = $true
            Parameters    = @{
                Action         = 'RestoreDefaultStartupStates'
                NonInteractive = $true
            }
        }

        WindowsSystemInformation = @{
            Name          = 'Windows system information'
            Description   = 'Collect Windows version and memory details.'
            Source        = 'Built-in command'
            Kind          = 'SystemInformation'
            WorksInPE     = $false
            RequiresAdmin = $false
            Parameters    = @{}
        }

        TrifectaVerifySystemFiles = @{
            Name          = 'Verify Windows system files'
            Description   = 'Verify system files with Trifecta without repairs.'
            Source        = 'Trifecta'
            Kind          = 'Plugin'
            PluginFile    = 'Trifecta.ps1'
            WorksInPE     = $false
            RequiresAdmin = $true
            Parameters    = @{
                Action         = 'VerifySystemFiles'
                NonInteractive = $true
            }
        }
    }
}

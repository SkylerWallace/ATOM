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

        WindowsRecommendedOptimizations = @{
            Name          = 'Recommended optimizations'
            Description   = 'Disable selected scheduled tasks, setup reminders, startup entries, and telemetry, and remove bundled online-service shortcuts.'
            Source        = 'Windows Debloat & Tune'
            Kind          = 'Plugin'
            PluginFile    = 'Windows Debloat & Tune.ps1'
            WorksInPE     = $false
            RequiresAdmin = $true
            Parameters    = @{
                Optimizations = @(
                    'DisableScheduledTasks'
                    'DisableSCOOBE'
                    'DisableStartups'
                    'DisableTelemetry'
                    'RemoveOnlineServices'
                )
                NonInteractive = $true
            }
        }

        WindowsRemoveMalware = @{
            Name          = 'Remove malware'
            Description   = 'Launch interactive malware uninstallers first, then remove programs that support silent uninstall.'
            MayRequireUserInput = $true
            Source        = 'Windows Debloat & Tune'
            Kind          = 'Plugin'
            PluginFile    = 'Windows Debloat & Tune.ps1'
            WorksInPE     = $false
            RequiresAdmin = $true
            Parameters    = @{
                ProgramCategories = @('Malware')
                AllowInteractiveUninstall = $true
                NonInteractive    = $true
            }
        }

        WindowsRemoveBloatware = @{
            Name          = 'Remove bloatware & unused AppX packages'
            Description   = 'Uninstall detected Bloatware catalog programs and eligible current-user AppX packages with no detected user data.'
            Source        = 'Windows Debloat & Tune'
            Kind          = 'Plugin'
            PluginFile    = 'Windows Debloat & Tune.ps1'
            WorksInPE     = $false
            RequiresAdmin = $true
            Parameters    = @{
                ProgramCategories = @('Bloatware')
                UnusedAppx        = $true
                NonInteractive    = $true
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

        TrifectaStoreUpdates = @{
            Name          = 'Start Microsoft Store updates'
            Description   = 'Open Microsoft Store and request app updates; reports request submission, not update completion.'
            Source        = 'Trifecta'
            Kind          = 'Plugin'
            PluginFile    = 'Trifecta.ps1'
            WorksInPE     = $false
            RequiresAdmin = $true
            MayRequireUserInput = $true
            Parameters    = @{
                Action         = 'StoreUpdates'
                NonInteractive = $true
            }
        }

        TrifectaWindowsUpdates = @{
            Name          = 'Start Windows updates'
            Description   = 'Open Windows Update and request an update scan; reports request submission, not update completion.'
            Source        = 'Trifecta'
            Kind          = 'Plugin'
            PluginFile    = 'Trifecta.ps1'
            WorksInPE     = $false
            RequiresAdmin = $true
            MayRequireUserInput = $true
            Parameters    = @{
                Action         = 'WindowsUpdates'
                NonInteractive = $true
            }
        }

        TrifectaScanSystemFiles = @{
            Name          = 'Scan and repair Windows system files'
            Description   = 'Run SFC with repairs enabled and retain its output for review.'
            Source        = 'Trifecta'
            Kind          = 'Plugin'
            PluginFile    = 'Trifecta.ps1'
            WorksInPE     = $false
            RequiresAdmin = $true
            Parameters    = @{
                Action         = 'ScanSystemFiles'
                NonInteractive = $true
            }
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

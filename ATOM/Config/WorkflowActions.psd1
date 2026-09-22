@{
    SchemaVersion = 1
    Actions = @{
        ClamAVQuickScan = @{
            Name          = 'ClamAV quick scan'
            Description   = 'Scan the Windows folder with local definitions and quarantine detected files.'
            Source        = 'ClamAV'
            Kind          = 'Plugin'
            PluginFile    = 'ClamAV.ps1'
            WorksInPE     = $true
            RequiresAdmin = $true
            WorkflowLogs  = $true
            SupportsCancellation = $true
            Parameters    = @{
                ScanType   = 'Quick'
                Quarantine = $true
            }
        }
        ClamAVDeepScan = @{
            Name          = 'ClamAV deep scan'
            Description   = 'Scan the Windows drive with local definitions and quarantine detected files.'
            Source        = 'ClamAV'
            Kind          = 'Plugin'
            PluginFile    = 'ClamAV.ps1'
            WorksInPE     = $true
            RequiresAdmin = $true
            WorkflowLogs  = $true
            SupportsCancellation = $true
            Parameters    = @{
                ScanType   = 'Deep'
                Quarantine = $true
            }
        }
        EmsisoftQuickScan = @{
            Name          = 'Emsisoft quick scan'
            Description   = 'Scan common malware locations and quarantine detections; in PE, scan the mounted Windows folder.'
            Source        = 'Emsisoft Emergency Kit'
            Kind          = 'Plugin'
            PluginFile    = 'Emsisoft Emergency Kit.ps1'
            WorksInPE     = $true
            RequiresAdmin = $true
            WorkflowLogs  = $true
            SupportsCancellation = $true
            Parameters    = @{
                ScanType = 'Quick'
            }
        }
        EmsisoftDeepScan = @{
            Name          = 'Emsisoft deep scan'
            Description   = 'Scan the Windows drive and quarantine detections.'
            Source        = 'Emsisoft Emergency Kit'
            Kind          = 'Plugin'
            PluginFile    = 'Emsisoft Emergency Kit.ps1'
            WorksInPE     = $true
            RequiresAdmin = $true
            WorkflowLogs  = $true
            SupportsCancellation = $true
            Parameters    = @{
                ScanType = 'Deep'
            }
        }
        StingerQuickScan = @{
            Name          = 'Stinger quick scan'
            Description   = 'Scan common malware locations and repair detected threats; in PE, scan the mounted Windows folder.'
            Source        = 'McAfee Stinger'
            Kind          = 'Plugin'
            PluginFile    = 'McAfee Stinger.ps1'
            WorksInPE     = $true
            RequiresAdmin = $true
            WorkflowLogs  = $true
            SupportsCancellation = $true
            Parameters    = @{
                ScanType = 'Quick'
            }
        }
        StingerDeepScan = @{
            Name          = 'Stinger deep scan'
            Description   = 'Scan the Windows drive and repair detected threats.'
            Source        = 'McAfee Stinger'
            Kind          = 'Plugin'
            PluginFile    = 'McAfee Stinger.ps1'
            WorksInPE     = $true
            RequiresAdmin = $true
            WorkflowLogs  = $true
            SupportsCancellation = $true
            Parameters    = @{
                ScanType = 'Deep'
            }
        }

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

    }
}

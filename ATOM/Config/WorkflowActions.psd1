@{
    SchemaVersion = 1
    Actions = @{
        ClamAVScan = @{
            Name          = 'ClamAV scan'
            Description   = 'Scan Windows with local definitions and quarantine detected files.'
            Source        = 'ClamAV'
            Kind          = 'Plugin'
            PluginFile    = 'ClamAV.ps1'
            WorksInPE     = $true
            RequiresAdmin = $true
            WorkflowLogs  = $true
            SupportsCancellation = $true
            Parameters    = @{
                Quarantine = $true
            }
            Option = @{
                Label   = 'Scan depth'
                Default = 'Quick'
                Choices = @(
                    @{
                        Id         = 'Quick'
                        Name       = 'Quick'
                        Parameters = @{ ScanType = 'Quick' }
                    }
                    @{
                        Id         = 'Deep'
                        Name       = 'Deep'
                        Parameters = @{ ScanType = 'Deep' }
                    }
                )
            }
        }
        EmsisoftScan = @{
            Name          = 'Emsisoft scan'
            Description   = 'Scan for malware and quarantine detections using the selected scan depth.'
            Source        = 'Emsisoft Emergency Kit'
            Kind          = 'Plugin'
            PluginFile    = 'Emsisoft Emergency Kit.ps1'
            WorksInPE     = $true
            RequiresAdmin = $true
            WorkflowLogs  = $true
            SupportsCancellation = $true
            Parameters    = @{}
            Option = @{
                Label   = 'Scan depth'
                Default = 'Quick'
                Choices = @(
                    @{
                        Id         = 'Quick'
                        Name       = 'Quick'
                        Parameters = @{ ScanType = 'Quick' }
                    }
                    @{
                        Id         = 'Deep'
                        Name       = 'Deep'
                        Parameters = @{ ScanType = 'Deep' }
                    }
                )
            }
        }
        StingerScan = @{
            Name          = 'Stinger scan'
            Description   = 'Scan for malware and repair detected threats using the selected scan depth.'
            Source        = 'Trellix Stinger'
            Kind          = 'Plugin'
            PluginFile    = 'Trellix Stinger.ps1'
            WorksInPE     = $true
            RequiresAdmin = $true
            WorkflowLogs  = $true
            SupportsCancellation = $true
            Parameters    = @{}
            Option = @{
                Label   = 'Scan depth'
                Default = 'Quick'
                Choices = @(
                    @{
                        Id         = 'Quick'
                        Name       = 'Quick'
                        Parameters = @{ ScanType = 'Quick' }
                    }
                    @{
                        Id         = 'Deep'
                        Name       = 'Deep'
                        Parameters = @{ ScanType = 'Deep' }
                    }
                )
            }
        }
        WindowsCleanup = @{
            Name          = 'Windows cleanup'
            Description   = 'Clear junk files; Deep also clears graphics caches and permanently empties the Recycle Bin.'
            Source        = 'Temp Cleanup'
            Kind          = 'Plugin'
            PluginFile    = 'Temp Cleanup.ps1'
            WorksInPE     = $false
            RequiresAdmin = $true
            Parameters    = @{
                MinimumAgeDays = 7
                NonInteractive = $true
            }
            Option = @{
                Label   = 'Cleanup level'
                Default = 'Gentle'
                Choices = @(
                    @{
                        Id   = 'Gentle'
                        Name = 'Gentle'
                        Parameters = @{
                            Categories = @(
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
                        }
                    }
                    @{
                        Id   = 'Deep'
                        Name = 'Deep'
                        Parameters = @{
                            Categories = @(
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
                        }
                    }
                )
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

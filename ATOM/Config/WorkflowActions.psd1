@{
    SchemaVersion = 1
    Actions = @{

        ClamAVScan = @{
            Results = @{
                Reports = @('scan.log', 'scan-output.txt')
                Metrics = @(
                    @{ Label = 'files scanned'; Pattern = '^Scanned files:\s*([\d,]+)\s*$' }
                    @{ Label = 'infections detected'; Pattern = '^Infected files:\s*([\d,]+)\s*$' }
                    @{ Label = 'infections quarantined'; Pattern = '^(.+): moved to\s+.+$'; Aggregation = 'UniqueCount'; ZeroWhen = 'infections detected' }
                )
            }
            Name          = 'ClamAV scan'
            Description   = 'Scan Windows with local definitions and quarantine detected files. Warning: scans can take 12+ hours.'
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
            Results = @{
                Reports = @('scan.log', 'scan-output.txt')
                Metrics = @(
                    @{ Label = 'files scanned'; Pattern = '^Scanned\s*:?\s+([\d,]+)\s*$' }
                    @{ Label = 'infections detected'; Pattern = '^(?:Found|Detected)(?: (?:traces|objects|files))?\s*:?\s+([\d,]+)\s*$' }
                    @{ Label = 'infections removed/quarantined'; Pattern = '^(?:Removed|Deleted)(?: (?:traces|objects|files))?\s*:?\s+([\d,]+)\s*$' }
                )
            }
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
        MicrosoftSafetyScanner = @{
            Results = @{
                Reports = @('msert.log')
                Metrics = @(
                    @{ Label = 'files scanned'; Pattern = '^(?:Number of files scanned|Number of scanned files|Scanned files):\s*([\d,]+)\s*$' }
                    @{ Label = 'infections detected'; Pattern = '^Number of (?:infected files|infections):\s*([\d,]+)\s*$' }
                    @{ Label = 'infections removed'; Pattern = '^Number of (?:cleaned files|removed infections):\s*([\d,]+)\s*$' }
                )
                Note = 'Counts are unavailable when the report includes earlier scans.'
            }
            Name          = 'Microsoft Safety Scanner'
            Description   = 'Scan Windows and clean detected threats using Microsoft''s scanner.'
            Source        = 'Microsoft Safety Scanner'
            Kind          = 'Plugin'
            PluginFile    = 'Microsoft Safety Scanner.ps1'
            WorksInPE     = $false
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
            Results = @{
                Reports = @('Stinger*.html', 'scan-output.txt')
                Metrics = @(
                    @{ Label = 'files scanned'; Pattern = '^TotalFiles:\.*\s*([\d,]+)\s*$' }
                    @{ Label = 'infections detected'; Pattern = '^(?:Possibly Infected|Number of infected files|Infected files|Total threats detected):\.*\s*([\d,]+)\s*$' }
                    @{ Label = 'infections removed/quarantined'; Pattern = '^(?:Files deleted|Deleted files|Deleted|Quarantined):\.*\s*([\d,]+)\s*$'; ZeroWhen = 'infections detected' }
                    @{ Label = 'files repaired'; Pattern = '^(?:Files repaired|Repaired files):\.*\s*([\d,]+)\s*$'; Optional = $true }
                )
            }
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
            Results = @{
                Metrics = @(
                    @{ Label = 'files removed'; Property = 'DeletedFiles' }
                    @{ Label = 'bytes reclaimed'; Property = 'BytesRemoved' }
                    @{ Label = 'cleanup tasks completed'; Property = 'PassedTasks' }
                )
                Note = 'File and byte totals exclude Windows handler and Recycle Bin cleanup.'
            }
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
            Results = @{
                Metrics = @(
                    @{ Label = 'services detected'; Property = 'DetectedServices' }
                    @{ Label = 'services restored'; Property = 'ChangedServices' }
                    @{ Label = 'service checks passed'; Property = 'PassedTasks' }
                )
                Note = 'Restart Windows to apply changed startup settings.'
            }
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
            Results = @{
                Metrics = @(
                    @{ Label = 'tasks completed'; Property = 'PassedTasks' }
                    @{ Label = 'tasks needing attention'; Property = 'AttentionTasks' }
                    @{ Label = 'tasks skipped'; Property = 'SkippedTasks' }
                )
            }
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
            Results = @{
                Metrics = @(
                    @{ Label = 'tasks completed'; Property = 'PassedTasks' }
                    @{ Label = 'tasks needing attention'; Property = 'AttentionTasks' }
                    @{ Label = 'tasks skipped'; Property = 'SkippedTasks' }
                )
            }
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
            Results = @{
                Metrics = @(
                    @{ Label = 'tasks completed'; Property = 'PassedTasks' }
                    @{ Label = 'tasks needing attention'; Property = 'AttentionTasks' }
                    @{ Label = 'tasks skipped'; Property = 'SkippedTasks' }
                )
            }
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
            Results = @{
                Metrics = @(
                    @{ Label = 'update requests submitted'; Property = 'UpdateRequestSubmitted' }
                )
                Note = 'Update installation is not verified.'
            }
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
            Results = @{
                Metrics = @(
                    @{ Label = 'update requests submitted'; Property = 'UpdateRequestSubmitted' }
                )
                Note = 'Update installation is not verified.'
            }
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
            Results = @{
                Metrics = @(
                    @{ Label = 'SFC outcome'; Property = 'Outcome'; Format = 'SFC: {0}' }
                )
            }
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

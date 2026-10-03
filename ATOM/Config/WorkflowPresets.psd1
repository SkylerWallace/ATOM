@{
    SchemaVersion = 1
    Presets = @(
        @{
            Id          = 'AntivirusScan'
            Name        = 'AV scan'
            Description = 'Scan with Emsisoft and Stinger; Tinfoil adds ClamAV, which can take 12+ hours. Continue through findings or failures and review each scanner''s results.'
            ContinueOnFailure = $true
            Actions = @(
                @{ ActionId = 'EmsisoftScan'; OptionId = 'Quick' }
                @{ ActionId = 'StingerScan'; OptionId = 'Quick' }
            )
            Option = @{
                Label   = 'Scan coverage'
                Default = 'Quick'
                Choices = @(
                    @{
                        Id   = 'Quick'
                        Name = 'Quick'
                        Actions = @(
                            @{ ActionId = 'EmsisoftScan'; OptionId = 'Quick' }
                            @{ ActionId = 'StingerScan'; OptionId = 'Quick' }
                        )
                    }
                    @{
                        Id   = 'Deep'
                        Name = 'Deep'
                        Actions = @(
                            @{ ActionId = 'EmsisoftScan'; OptionId = 'Deep' }
                            @{ ActionId = 'StingerScan'; OptionId = 'Deep' }
                        )
                    }
                    @{
                        Id   = 'Tinfoil'
                        Name = 'Tinfoil'
                        Actions = @(
                            @{ ActionId = 'EmsisoftScan'; OptionId = 'Deep' }
                            @{ ActionId = 'StingerScan'; OptionId = 'Deep' }
                            @{ ActionId = 'ClamAVScan'; OptionId = 'Deep' }
                        )
                    }
                )
            }
        }
        @{
            Id          = 'WindowsTuneup'
            Name        = 'Tuneup & cleanup'
            Description = 'Remove unwanted apps, optimize Windows, clear junk files, start updates, and repair system files. Deep cleanup also empties the Recycle Bin.'
            Option = @{
                Label   = 'Cleanup level'
                Default = 'Deep'
                Choices = @(
                    @{
                        Id   = 'Gentle'
                        Name = 'Gentle'
                        Actions = @(
                            'WindowsRemoveMalware'
                            'WindowsRemoveBloatware'
                            'WindowsRestoreDefaultServices'
                            'WindowsRecommendedOptimizations'
                            @{ ActionId = 'WindowsCleanup'; OptionId = 'Gentle' }
                            'TrifectaStoreUpdates'
                            'TrifectaWindowsUpdates'
                            'TrifectaScanSystemFiles'
                        )
                    }
                    @{
                        Id   = 'Deep'
                        Name = 'Deep'
                        Actions = @(
                            'WindowsRemoveMalware'
                            'WindowsRemoveBloatware'
                            'WindowsRestoreDefaultServices'
                            'WindowsRecommendedOptimizations'
                            @{ ActionId = 'WindowsCleanup'; OptionId = 'Deep' }
                            'TrifectaStoreUpdates'
                            'TrifectaWindowsUpdates'
                            'TrifectaScanSystemFiles'
                        )
                    }
                )
            }
            Actions     = @(
                'WindowsRemoveMalware'
                'WindowsRemoveBloatware'
                'WindowsRestoreDefaultServices'
                'WindowsRecommendedOptimizations'
                @{ ActionId = 'WindowsCleanup'; OptionId = 'Deep' }
                'TrifectaStoreUpdates'
                'TrifectaWindowsUpdates'
                'TrifectaScanSystemFiles'
            )
        }
    )
}

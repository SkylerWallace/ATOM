@{
    SchemaVersion = 1
    Presets = @(
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

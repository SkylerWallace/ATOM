@{
    SchemaVersion = 1
    Presets = @(
        @{
            Id          = 'WindowsTuneup'
            Name        = 'Tuneup & cleanup'
            Description = 'Remove unwanted apps, restore service defaults, optimize Windows, and clear junk files, including the Recycle Bin. Start updates and repair system files.'
            Actions     = @(
                'WindowsRemoveMalware'
                'WindowsRemoveBloatware'
                'WindowsRestoreDefaultServices'
                'WindowsRecommendedOptimizations'
                'WindowsDeepCleanup'
                'TrifectaStoreUpdates'
                'TrifectaWindowsUpdates'
                'TrifectaScanSystemFiles'
            )
        }
    )
}

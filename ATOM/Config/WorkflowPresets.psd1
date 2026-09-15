@{
    SchemaVersion = 1
    Presets = @(
        @{
            Id          = 'WindowsDiagnostics'
            Name        = 'Windows diagnostics'
            Description = 'Collect Windows information, then verify protected system files without repairing them.'
            Actions     = @(
                'WindowsSystemInformation'
                'TrifectaVerifySystemFiles'
            )
        }
    )
}

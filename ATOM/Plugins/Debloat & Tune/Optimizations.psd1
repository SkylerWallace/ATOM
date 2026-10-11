@{
    DisableEncryption = @{
        Name = 'Disable Encryption'
        ToolTip = 'Decrypt the Windows drive.'
        Description = 'Remove Windows drive encryption for data recovery or OS repair.'
        ScriptFile = 'Disable Encryption.ps1'
        DetectionScriptFile = 'Test device encryption.ps1'
    }
    DisableScheduledTasks = @{
        Name = 'Disable scheduled tasks'
        ToolTip = 'Disable selected telemetry tasks.'
        Description = 'Disable selected scheduled tasks, primarily related to telemetry.'
        ScriptFile = 'Disable scheduled tasks.ps1'
    }
    DisableSCOOBE = @{
        Name = 'Disable SCOOBE'
        ToolTip = 'Hide Windows setup reminders.'
        Description = 'Disable reminders to finish setting up Windows after feature updates.'
        ScriptFile = 'Disable SCOOBE.ps1'
    }
    DisableStartups = @{
        Name = 'Disable startups'
        ToolTip = 'Disable selected startup programs.'
        Description = 'Disable selected startup entries from common programs.'
        ScriptFile = 'Disable startups.ps1'
    }
    DisableWindowsSuggestions = @{
        Name = 'Disable Windows suggestions'
        ToolTip = 'Turn off Windows tips and promotional prompts.'
        Description = 'Hide Windows tips, app suggestions, and account or backup prompts.'
        ScriptFile = 'Disable Windows suggestions.ps1'
    }
    DisableSysMain = @{
        Name = 'Disable SysMain (Superfetch)'
        Caution = 'Disabling SysMain may slow app startup on some PCs.'
        ToolTip = 'SysMain preloads apps to speed startup. Disabling it may reduce heavy disk activity but slow app launches.'
        Description = 'SysMain preloads frequently used apps for faster startup. Disabling it can reduce heavy disk activity on some PCs, but may slow app launches.'
        ScriptFile = 'Disable SysMain (Superfetch).ps1'
    }
    DisableTelemetry = @{
        Name = 'Reduce telemetry'
        ToolTip = 'Reduce Windows diagnostic data and tracking.'
        Description = 'Reduce optional diagnostics and tracking; required data may remain.'
        ScriptFile = 'Disable telemetry.ps1'
    }
    RemoveOnlineServices = @{
        Name = 'Remove online services'
        ToolTip = 'Remove OEM online-service shortcuts.'
        Description = 'Remove bundled OEM online-service shortcuts.'
        ScriptFile = 'Remove online services.ps1'
    }
    SetManualServices = @{
        Name = 'Set manual services'
        ToolTip = 'Adjust selected service startup states.'
        Description = 'Set selected services to manual or disabled startup states.'
        ScriptFile = 'Set manual services.ps1'
    }
}

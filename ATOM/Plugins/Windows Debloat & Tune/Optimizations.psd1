@{
    DisableScheduledTasks = @{
        Name = 'Disable scheduled tasks'
        Description = 'Disable selected scheduled tasks, primarily related to telemetry.'
        ScriptFile = 'Disable scheduled tasks.ps1'
    }
    DisableSCOOBE = @{
        Name = 'Disable SCOOBE'
        Description = 'Disable reminders to finish setting up Windows after feature updates.'
        ScriptFile = 'Disable SCOOBE.ps1'
    }
    DisableStartups = @{
        Name = 'Disable startups'
        Description = 'Disable selected startup entries from common programs.'
        ScriptFile = 'Disable startups.ps1'
    }
    DisableSysMain = @{
        Name = 'Disable SysMain (Superfetch)'
        Description = 'Stop and disable SysMain, which can contribute to heavy disk usage on older PCs.'
        ScriptFile = 'Disable SysMain (Superfetch).ps1'
    }
    DisableTelemetry = @{
        Name = 'Disable telemetry'
        Description = 'Apply the configured Windows privacy and telemetry settings.'
        ScriptFile = 'Disable telemetry.ps1'
    }
    RemoveOnlineServices = @{
        Name = 'Remove online services'
        Description = 'Remove bundled OEM online-service shortcuts.'
        ScriptFile = 'Remove online services.ps1'
    }
    SetManualServices = @{
        Name = 'Set manual services'
        Description = 'Set selected services to manual or disabled startup states.'
        ScriptFile = 'Set manual services.ps1'
    }
}

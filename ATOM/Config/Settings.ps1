# Default settings
$atomSettings = [ordered]@{
    Theme = @{
        Value   = "Atomic"
    }
    SaveEncryptionKeys = @{
        Name    = 'Save encryption keys'
        ToolTip = "Save computer's encryption key to $logsPath"
        Value   = $true
    }
    LaunchOnRestart = @{
        Name    = 'Launch on restart'
        ToolTip = "Start ATOM when computer reboots"
        Value   = $true
    }
    ShowToolTips = @{
        Name    = 'Show tooltips'
        ToolTip = "Show tooltips when hovering over plugins"
        Value   = $true
    }
    ShowAdditionalPlugins = @{
        Name    = 'Show additional plugins'
        ToolTip = "Show the Additional plugins category"
        Value   = $false
    }
    ShowHiddenPlugins = @{
        Name    = 'Show hidden plugins'
        ToolTip = "Show hidden plugins for each plugin category"
        Value   = $false
    }
    EnableDebugMode = @{
        Name    = 'Enable debug mode'
        ToolTip = "Disable silent launch of plugins"
        Value   = $false
    }
    StartupColumns = @{
        Name    = 'Startup columns'
        ToolTip = "Amount of plugin category columns displayed when starting ATOM"
        Value   = 2
    }
}
# Default settings
$atomSettings = [ordered]@{
    Theme = @{
        Value   = "Atomic"
    }
    SortPlugins = @{
        Value = "Category"
    }
    SaveEncryptionKeys = @{
        Name    = 'Save encryption keys'
        ToolTip = "Save computer's encryption key to $logsPath"
        Value   = $true
        ControlType = 'ToggleButton'
    }
    LaunchOnRestart = @{
        Name    = 'Launch on restart'
        ToolTip = "Start ATOM when computer reboots"
        Value   = $true
        ControlType = 'ToggleButton'
    }
    ShowToolTips = @{
        Name    = 'Show tooltips'
        ToolTip = "Show tooltips when hovering over plugins"
        Value   = $true
        ControlType = 'ToggleButton'
    }
    ShowAdditionalPlugins = @{
        Name    = 'Show additional plugins'
        ToolTip = "Show the Additional plugins category"
        Value   = $false
        ControlType = 'ToggleButton'
    }
    ShowHiddenPlugins = @{
        Name    = 'Show hidden plugins'
        ToolTip = "Show hidden plugins for each plugin category"
        Value   = $false
        ControlType = 'ToggleButton'
    }
    EnableDebugMode = @{
        Name    = 'Enable debug mode'
        ToolTip = "Disable silent launch of plugins"
        Value   = $false
        ControlType = 'ToggleButton'
    }
    PluginClicks = @{
        Name    = 'Clicks to launch plugins'
        ToolTip = 'Single-click or double-click required to launch a plugin'
        Value   = 1
        ControlType = 'RadioButton'
        Options = [ordered]@{
            "Single" = 1
            "Double" = 2
        }
    }
    StartupColumns = @{
        Name    = 'Startup columns'
        ToolTip = "Amount of plugin category columns displayed when starting ATOM"
        Value   = 2
        ControlType = 'RadioButton'
        Options = [ordered]@{
            "1" = 1
            "2" = 2
            "3" = 3
        }
    }
}
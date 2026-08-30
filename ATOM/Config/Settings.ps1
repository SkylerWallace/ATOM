# Default settings
$atomSettings = [ordered]@{
    Theme = @{
        Value   = "Atomic"
    }
    UIScaling = @{
        Value = 1.0
    }
    UpdateChannel = @{
        Value = 'main'
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
    SearchPluginTags = @{
        Name    = 'Search plugin tags'
        ToolTip = 'Include plugin tags when searching'
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
    ShowQuips = @{
        Name    = 'Show quips'
        ToolTip = 'Show quips in the ATOM status bar'
        Value   = $true
        ControlType = 'ToggleButton'
    }
    QuipTone = @{
        Name    = 'Quip tone'
        ToolTip = 'Choose which styles of quips ATOM can show'
        Value   = 'Full'
        ControlType = 'ComboBox'
        Options = [ordered]@{
            'Gentle only' = 'Gentle'
            'Up to playful' = 'Playful'
            'Snarky only' = 'Snarky'
            'Full range' = 'Full'
        }
    }
    InvertQuipRarity = @{
        Name    = 'Invert quip rarity'
        ToolTip = 'Make rare quips common and common quips rare. IWHBYD.'
        Value   = $false
        ControlType = 'ToggleButton'
    }
    PluginEditor = @{
        Name    = 'Plugin editor'
        ToolTip = 'Choose the application used to edit PowerShell and command-script plugins'
        Value   = 'notepad.exe'
        ControlType = 'ComboBox'
        Options = [ordered]@{
            'Notepad' = 'notepad.exe'
            'Choose application...' = '__choose__'
        }
    }
    PluginClicks = @{
        Name    = 'Clicks to launch plugins'
        ToolTip = 'Single-click or double-click required to launch a plugin'
        Value   = 1
        ControlType = 'ComboBox'
        Options = [ordered]@{
            "Single" = 1
            "Double" = 2
        }
    }
    StartupColumns = @{
        Name    = 'Startup columns'
        ToolTip = "Amount of plugin category columns displayed when starting ATOM"
        Value   = 2
        ControlType = 'ComboBox'
        Options = [ordered]@{
            "1" = 1
            "2" = 2
            "3" = 3
        }
    }
}

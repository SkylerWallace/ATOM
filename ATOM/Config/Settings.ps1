# Default settings
$atomSettings = [ordered]@{
    Theme = @{
        Description = 'Choose the colors used throughout the interface.'
        Name = 'Theme'
        Value   = "Atomic"
    }
    UIScaling = @{
        Description = 'Adjust the size of the entire interface from 100% to 200%.'
        Name = 'UI scaling'
        Value = 1.0
    }
    ThemeGraphic = @{
        Name = 'Title-bar graphic'
        Description = 'Use the theme''s default artwork, choose a graphic for all themes, or disable it.'
        Category = 'Appearance'
        ToolTip = 'Choose title-bar artwork'
        Value = 'Automatic'
        ControlType = 'ComboBox'
        Options = [ordered]@{ 'Disabled' = 'Disabled'; 'Automatic' = 'Automatic' }
    }
    UpdateChannel = @{
        Value = 'main'
        RestoreDefault = $false
    }
    SortPlugins = @{
        Value = "Category"
    }
    ShowPluginDescriptions = @{
        Value = $false
    }
    ShowSettingsDescriptions = @{
        Name = 'Settings descriptions'
        Value = $false
    }
    StartupPosition = @{
        Description = 'Open ATOM at the top-left of the screen or centered on the next launch.'
        Name = 'Startup position'
        Category = 'General'
        ToolTip = 'Where ATOM opens on its next launch'
        Value = 'TopLeft'
        ControlType = 'ComboBox'
        Options = [ordered]@{ 'Top-left' = 'TopLeft'; 'Center' = 'Center' }
    }
    SaveEncryptionKeys = @{
        Description = 'Save the computer''s encryption recovery key in the logs folder for later reference.'
        Name    = 'Save encryption keys'
        Category = 'General'
        ToolTip = "Save computer's encryption key to $logsPath"
        Value   = $true
        ControlType = 'ToggleButton'
    }
    LaunchOnRestart = @{
        Description = 'Start ATOM automatically when the computer restarts.'
        Name    = 'Launch on restart'
        Category = 'General'
        ToolTip = "Start ATOM when computer reboots"
        Value   = $true
        ControlType = 'ToggleButton'
    }
    ShowToolTips = @{
        Description = 'Show a brief explanation when hovering over a plugin.'
        Name    = 'Show tooltips'
        Category = 'Plugins'
        ToolTip = "Show tooltips when hovering over plugins"
        Value   = $true
        ControlType = 'ToggleButton'
    }
    SearchPluginTags = @{
        Description = 'Include plugin tags when searching the Plugins page, alongside plugin names.'
        Name    = 'Search plugin tags'
        Category = 'Plugins'
        ToolTip = 'Include plugin tags when searching'
        Value   = $false
        ControlType = 'ToggleButton'
    }
    ShowHiddenPlugins = @{
        Description = 'Include hidden plugins in the Plugins page so they can be accessed or made visible again.'
        Name    = 'Show hidden plugins'
        Category = 'Plugins'
        ToolTip = "Show hidden plugins for each plugin category"
        Value   = $false
        ControlType = 'ToggleButton'
    }
    EnableDebugMode = @{
        Description = 'Show the console and launch plugins without suppressing their console output to help troubleshoot problems.'
        Name    = 'Enable debug mode'
        Category = 'General'
        ToolTip = "Disable silent launch of plugins"
        Value   = $false
        ControlType = 'ToggleButton'
    }
    ShowQuips = @{
        Description = 'Display quips in status bars when there is no recent activity to report.'
        Name    = 'Show quips'
        Category = 'Quips'
        ToolTip = 'Show quips in the ATOM status bar'
        Value   = $true
        ControlType = 'ToggleButton'
    }
    QuipTone = @{
        Description = 'Choose which tones of humor can appear in status bar quips.'
        Name    = 'Quip tone'
        Category = 'Quips'
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
        Description = 'Show normally rare quips more often, and common quips less often.'
        Name    = 'Invert quip rarity'
        Category = 'Quips'
        ToolTip = 'Make rare quips common and common quips rare. IWHBYD.'
        Value   = $false
        ControlType = 'ToggleButton'
    }
    PluginEditor = @{
        Description = 'Choose the application used to edit script plugins and open the changelog.'
        Name    = 'Plugin editor'
        Category = 'Plugins'
        ToolTip = 'Choose the application used to edit PowerShell and command-script plugins'
        Value   = 'notepad.exe'
        ControlType = 'ComboBox'
        Options = [ordered]@{
            'Notepad' = 'notepad.exe'
            'Choose application...' = '__choose__'
        }
    }
    PluginClicks = @{
        Description = 'Choose whether launching a plugin requires a single click or a double click.'
        Name    = 'Clicks to launch plugins'
        Category = 'Plugins'
        ToolTip = 'Single-click or double-click required to launch a plugin'
        Value   = 1
        ControlType = 'ComboBox'
        Options = [ordered]@{
            "Single" = 1
            "Double" = 2
        }
    }
    StartupColumns = @{
        Description = 'Set the number of plugin category columns shown when ATOM starts.'
        Name    = 'Startup columns'
        Category = 'Plugins'
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

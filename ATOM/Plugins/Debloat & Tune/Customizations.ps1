$customizations = [ordered]@{
    'Dark Mode' = @{
        Description = 'Use dark colors for Windows and apps.'
        ToolTip = 'Use dark colors for Windows and apps.'
        Refresh = 'ThemeSimple'
        MinimumWindowsBuild = 18282
        Settings = @(
            @{
                Path = 'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
                Name = 'AppsUseLightTheme'
                OnValue = 0
                OffValue = 1
                DefaultValue = 1
            }
            @{
                Path = 'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
                Name = 'SystemUsesLightTheme'
                OnValue = 0
                OffValue = 1
                DefaultValue = 1
            }
        )
    }
    'Mouse Acceleration' = @{
        Description = 'Adjust pointer speed based on mouse movement. Sign out to apply.'
        ToolTip = 'Enable enhanced pointer precision.'
        Settings = @(
            @{
                Path = 'Control Panel\Mouse'
                Name = 'MouseSpeed'
                OnValue = '1'
                OffValue = '0'
                DefaultValue = '1'
                Type = 'String'
            }
            @{
                Path = 'Control Panel\Mouse'
                Name = 'MouseThreshold1'
                OnValue = '6'
                OffValue = '0'
                DefaultValue = '6'
                Type = 'String'
            }
            @{
                Path = 'Control Panel\Mouse'
                Name = 'MouseThreshold2'
                OnValue = '10'
                OffValue = '0'
                DefaultValue = '10'
                Type = 'String'
            }
        )
    }
    'Notifications' = @{
        Description = 'Allow app alerts, including Windows Security notifications.'
        ToolTip = 'Allow Windows toast notifications.'
        MinimumWindowsBuild = 14328
        Settings = @(@{
            Path = 'Software\Microsoft\Windows\CurrentVersion\PushNotifications'
            Name = 'ToastEnabled'
            OnValue = 1
            OffValue = 0
            DefaultValue = 1
        })
    }
    'Explorer - Sync Provider Ads' = @{
        Description = 'Show sync-provider ads without changing file syncing.'
        ToolTip = 'Reopen Explorer or sign out to apply.'
        Settings = @(@{
            Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            Name = 'ShowSyncProviderNotifications'
            OnValue = 1
            OffValue = 0
            DefaultValue = 1
        })
    }
    'Explorer - Show File Extensions' = @{
        Description = 'Show file types such as .exe and .pdf after each filename.'
        ToolTip = 'Reopen Explorer or sign out to apply.'
        Settings = @(@{
            Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            Name = 'HideFileExt'
            OnValue = 0
            OffValue = 1
            DefaultValue = 1
        })
    }
    'Taskbar - Chat' = @{
        Description = 'Show the Chat shortcut on supported Windows 11 versions.'
        ToolTip = 'Show the legacy Chat button.'
        MinimumWindowsBuild = 22000
        MaximumWindowsBuild = 22621
        Settings = @(@{
            Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            Name = 'TaskbarMn'
            OnValue = 1
            OffValue = 0
            DefaultValue = 1
        })
    }
    'Taskbar - Copilot' = @{
        Description = 'Show the legacy taskbar shortcut, separate from the Copilot app.'
        ToolTip = 'Show the legacy Copilot button.'
        MinimumWindowsBuild = 22621
        MaximumWindowsBuild = 22631
        Settings = @(@{
            Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            Name = 'ShowCopilotButton'
            OnValue = 1
            OffValue = 0
            DefaultValue = 0
        })
    }
    'Taskbar - Search' = @{
        Description = 'Switch between a search icon and no taskbar search button.'
        ToolTip = 'Other search layouts appear as a mixed state.'
        Refresh = 'Taskbar'
        Settings = @(@{
            Path = 'Software\Microsoft\Windows\CurrentVersion\Search'
            Name = 'SearchboxTaskbarMode'
            OnValue = 1
            OffValue = 0
            DefaultValue = 2
        })
    }
    'Taskbar - Task View' = @{
        Description = 'Show a shortcut to open windows and virtual desktops.'
        ToolTip = 'Show the Task View button.'
        Refresh = 'Taskbar'
        Settings = @(@{
            Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            Name = 'ShowTaskViewButton'
            OnValue = 1
            OffValue = 0
            DefaultValue = 1
        })
    }
    'Taskbar - Widgets' = @{
        Description = 'Show a shortcut to the Windows 11 Widgets panel.'
        ToolTip = 'Show the Widgets button.'
        MinimumWindowsBuild = 22000
        Settings = @(@{
            Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            Name = 'TaskbarDa'
            OnValue = 1
            OffValue = 0
            DefaultValue = 1
        })
    }
    'Taskbar - Left Align' = @{
        Description = 'Align taskbar icons to the left when on, or center when off.'
        ToolTip = 'Align taskbar icons to the left.'
        Refresh = 'Taskbar'
        MinimumWindowsBuild = 22000
        Settings = @(@{
            Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            Name = 'TaskbarAl'
            OnValue = 0
            OffValue = 1
            DefaultValue = 1
        })
    }
}

function Get-DebloatCustomizationState {
    param([Collections.IDictionary]$Definition)
    $states = @(foreach ($setting in $Definition.Settings) {
        $value = [Microsoft.Win32.Registry]::GetValue(('HKEY_CURRENT_USER\' + $setting.Path), $setting.Name, $setting.DefaultValue)
        if ($value -eq $setting.OnValue) { $true } elseif ($value -eq $setting.OffValue) { $false } else { $null }
    })
    if (@($states | Where-Object { $_ -ne $true }).Count -eq 0) { return $true }
    if (@($states | Where-Object { $_ -ne $false }).Count -eq 0) { return $false }
    return $null
}

function Update-DebloatShell {
    param([ValidateSet('Taskbar', 'ThemeSimple')][string]$Mode)
    if (-not ('Atom.DebloatAppearanceRefresh' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Threading;
namespace Atom {
    public static class DebloatAppearanceRefresh {
        private static readonly object refreshLock = new object();
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        private static extern IntPtr SendMessageTimeout(IntPtr hwnd, uint message,
            IntPtr wParam, string lParam, uint flags, uint timeout, out IntPtr result);
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        private static extern bool SendNotifyMessage(IntPtr hwnd, uint message, IntPtr wParam, IntPtr lParam);
        public static void Refresh(string mode) {
            // Serialize broadcasts off the UI thread so slow apps cannot stall toggles.
            ThreadPool.QueueUserWorkItem(delegate {
                lock (refreshLock) {
                    IntPtr result;
                    IntPtr broadcast = new IntPtr(0xffff);
                    string area = mode == "ThemeSimple" ? "ImmersiveColorSet" : "TraySettings";
                    if (mode == "ThemeSimple")
                        SendNotifyMessage(broadcast, 0x031a, IntPtr.Zero, IntPtr.Zero);
                    SendMessageTimeout(broadcast, 0x001a, IntPtr.Zero, area, 2,
                        mode == "ThemeSimple" ? 100u : 2000u, out result);
                }
            });
        }
    }
}
'@
    }
    [Atom.DebloatAppearanceRefresh]::Refresh($Mode)
}

function Set-DebloatCustomizationState {
    param([Collections.IDictionary]$Definition, [bool]$Enabled)
    foreach ($setting in $Definition.Settings) {
        $value = if ($Enabled) { $setting.OnValue } else { $setting.OffValue }
        $type = if ($setting.Type) { $setting.Type } else { 'DWord' }
        Set-ThingProperty -Path ('HKCU:\' + $setting.Path) -Name $setting.Name -Type $type -Value $value -ErrorAction Stop
    }
    if ($Definition.Refresh) { Update-DebloatShell -Mode $Definition.Refresh }
}

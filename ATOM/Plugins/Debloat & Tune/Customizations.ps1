$customizations = [ordered]@{
    'Dark Mode' = @{
        ToolTip               = 'Use the dark Windows color theme'
        MinimumWindowsVersion = 10
        MinimumWindowsBuild   = 18282
        ShowIf                = { [Microsoft.Win32.Registry]::GetValue('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize', 'SystemUsesLightTheme', $null) -ne 0 }
        Action                = {
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -Type DWord -Value 0
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Type DWord -Value 0
            Stop-Process -Name explorer
            Write-Host '- Enabled Dark Mode'
        }
    }

    'Disable Encryption' = @{
        ToolTip   = "Recommended on personal devices for`neasier data recovery and OS repair"
        ShowIf    = {
            (Get-CimInstance -Namespace 'Root\CIMv2\Security\MicrosoftVolumeEncryption' -ClassName Win32_EncryptableVolume |
                Where-Object DriveLetter -EQ $env:SystemDrive |
                Select-Object -ExpandProperty IsVolumeInitializedForProtection) -eq 'True'
        }
        Action    = {
            manage-bde $env:SystemDrive -Off
            if ($LASTEXITCODE -ne 0) { throw "manage-bde failed with exit code $LASTEXITCODE" }
            Write-Host '- Disabling Device Encryption'
        }
    }

    'Disable Mouse Acceleration' = @{
        ToolTip   = 'Important tweak for some gamers'
        ShowIf    = { [Microsoft.Win32.Registry]::GetValue('HKEY_CURRENT_USER\Control Panel\Mouse', 'MouseSpeed', $null) -ne 0 }
        Action    = {
            Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSpeed' -Type String -Value 0
            Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold1' -Type String -Value 0
            Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold2' -Type String -Value 0
            Write-Host '- Disabled Mouse Acceleration'
        }
    }

    'Disable Notifications' = @{
        ToolTip               = 'This is system-wide and will also disable Windows Security notifications'
        MinimumWindowsVersion = 10
        MinimumWindowsBuild   = 14328
        ShowIf                = { [Microsoft.Win32.Registry]::GetValue('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications', 'ToastEnabled', $null) -ne 0 }
        Action                = {
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications' -Name 'ToastEnabled' -Type DWord -Value 0
            Write-Host '- Disabled Notifications'
        }
    }

    'Taskbar - Disable Chat' = @{
        ToolTip               = 'Disable Chat icon in taskbar'
        MinimumWindowsVersion = 11
        MinimumWindowsBuild   = 22000
        ShowIf                = { [Microsoft.Win32.Registry]::GetValue('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarMn', $null) -ne 0 }
        Action                = {
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarMn' -Type DWord -Value 0
            Write-Host '- Disabled Chat button'
        }
    }

    'Taskbar - Disable Copilot' = @{
        ToolTip               = 'Disable Copilot icon in taskbar'
        MinimumWindowsVersion = 11
        ShowIf                = { [Microsoft.Win32.Registry]::GetValue('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'ShowCopilotButton', $null) -ne 0 }
        Action                = {
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowCopilotButton' -Type DWord -Value 0
            Write-Host '- Disabled Copilot button'
        }
    }

    'Taskbar - Disable Search' = @{
        ToolTip               = 'Hide the search box in the taskbar'
        MinimumWindowsVersion = 10
        ShowIf                = { [Microsoft.Win32.Registry]::GetValue('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search', 'SearchboxTaskbarMode', $null) -ne 0 }
        Action                = {
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Type DWord -Value 0
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarModeCache' -Type DWord -Value 1
            Write-Host '- Disabled Search Box'
        }
    }

    'Taskbar - Disable Task View' = @{
        ToolTip               = 'Disable Task View icon in taskbar'
        MinimumWindowsVersion = 10
        ShowIf                = { [Microsoft.Win32.Registry]::GetValue('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'ShowTaskViewButton', $null) -ne 0 }
        Action                = {
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Type DWord -Value 0
            Write-Host '- Disabled Task View button'
        }
    }

    'Taskbar - Disable Widgets' = @{
        ToolTip               = 'Disable Widgets icon in taskbar'
        MinimumWindowsVersion = 11
        MinimumWindowsBuild   = 22000
        ShowIf                = { [Microsoft.Win32.Registry]::GetValue('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarDa', $null) -ne 0 }
        Action                = {
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Type DWord -Value 0
            Write-Host '- Disabled Widgets'
        }
    }

    'Taskbar - Left Align' = @{
        ToolTip               = 'Left-align taskbar icons in Windows 11'
        MinimumWindowsVersion = 11
        MinimumWindowsBuild   = 22000
        ShowIf                = { [Microsoft.Win32.Registry]::GetValue('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarAl', $null) -ne 0 }
        Action                = {
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAl' -Type DWord -Value 0
            Write-Host '- Taskbar left-aligned'
        }
    }

    'Update Apps' = @{
        ToolTip               = "Update all eligible apps with 'winget upgrade --all'"
        MinimumWindowsVersion = 10
        MinimumWindowsBuild   = 17763
        ShowIf                = { [bool](Get-Command winget -ErrorAction SilentlyContinue) }
        Action                = {
            $result = Start-Process winget -ArgumentList 'upgrade --all --accept-package-agreements --accept-source-agreements --force --silent' -Wait -PassThru -ErrorAction Stop
            if ($result.ExitCode -ne 0) { throw "WinGet did not complete successfully (exit code $($result.ExitCode))" }
            Write-Host '- Installed Microsoft Store app updates'
        }
    }
}

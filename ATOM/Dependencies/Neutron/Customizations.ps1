function Test-Predicate {
    param (
        [string]$path,
        [string]$name,
        [int]$value,
        [int]$minWinVer = 0,
        [int]$minWinBuild = 0
    )
    
    try {
        (Get-ItemPropertyValue -Path $path -Name $name) -ne $value
    } catch {
        ($winVer -ge $minWinVer) -and ($winBuild -ge $minWinBuild)
    }
}

$customizations = [ordered]@{
    "Dark Mode" = @{
        Tooltip     = "Yes"
        Predicate   = { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -MinWinVer 10 -MinWinBuild 18282 }
        Scriptblock = {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type "DWord" -Value "0"
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type "DWord" -Value "0"

            # Restarting explorer.exe to apply taskbar theming
            Stop-Process -Name explorer

            Write-Host "- Enabled Dark Mode"
        }
    }
    
    "Disable Encryption" = @{
        ToolTip     = "Recommended on personal devices for`neasier data recovery and OS repair"
        Predicate   = {
            (Get-CimInstance -Namespace "Root\CIMv2\Security\MicrosoftVolumeEncryption" -ClassName Win32_EncryptableVolume | Where-Object { $_.DriveLetter -eq $env:SystemDrive } | Select-Object -ExpandProperty IsVolumeInitializedForProtection) -eq "True"
        }
        ScriptBlock = {
            manage-bde $env:SystemDrive -Off
            Write-Host "- Disabling Device Encryption"
        }
    }
    
    "Disable Mouse Acceleration" = @{
        ToolTip     = "Important tweak for some gamers"
        Predicate   = { Test-Predicate -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 }
        ScriptBlock = {
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type "String" -Value "0"
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type "String" -Value "0"
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type "String" -Value "0"
            Write-Host "- Disabled Mouse Acceleration"
        }
    }
    
    "Disable Notifications" = @{
        ToolTip     = "This is system-wide, will also disable Windows Security notifs"
        Predicate   = { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Value 0 -MinWinVer 10 -MinWinBuild 14328 }
        ScriptBlock = {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type "DWord" -Value "0"
            Write-Host "- Disabled Notifications"
        }
    }
    
    "Taskbar - Disable Chat" = @{
        ToolTip     = "Disable Chat icon in taskbar"
        Predicate   = { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -MinWinVer 11 -MinWinBuild 22000 }
        ScriptBlock = {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type "DWord" -Value "0"
            Write-Host "- Disabled Chat button"
        }
    }
    
    "Taskbar - Disable Copilot" = @{
        ToolTip     = "Disable Copilot icon in taskbar"
        Predicate   = { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0 -MinWinVer 11 }
        ScriptBlock = {
            # Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type "DWord" -Value "1"
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type "DWord" -Value "0"
            Write-Host "- Disabled Copilot button"
        }
    }
    
    "Taskbar - Disable Search" = @{
        ToolTip     = "Set search bar to hidden in taskbar"
        Predicate   = { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -MinWinVer 10 }
        ScriptBlock = {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type "DWord" -Value "0"
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarModeCache" -Type "DWord" -Value "1"
            Write-Host "- Disabled Search Box"
        }
    }
    
    "Taskbar - Disable Task View" = @{
        ToolTip     = "Disable Task View icon in taskbar"
        Predicate   = { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -MinWinVer 10 }
        ScriptBlock = {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type "DWord" -Value "0"
            Write-Host "- Disabled Task View button"
        }
    }
    
    "Taskbar - Disable Widgets" = @{
        ToolTip     = "Disable Widgets icon in taskbar"
        Predicate   = { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -MinWinVer 11 -MinWinBuild 22000 }
        ScriptBlock = {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type "DWord" -Value "0"
            Write-Host "- Disabled Widgets"
        }
    }
    
    "Taskbar - Left Align" = @{
        ToolTip     = "Left-align taskbar icons in Windows 11"
        Predicate   = { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -MinWinVer 11 -MinWinBuild 22000 }
        ScriptBlock = {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type "DWord" -Value "0"
            Write-Host "- Taskbar left-aligned"
        }
    }
    
    "Update Apps" = @{
        ToolTip     = "Update all eligible apps with 'winget upgrade --all'"
        Predicate   = { Test-Predicate -MinWinVer 10 -MinWinBuild 17763 }
        ScriptBlock = {
            Start-Process winget -ArgumentList "upgrade --all --accept-package-agreements --accept-source-agreements --force --silent" -Wait
            Write-Host "- Installed Microsoft Store app updates"
        }
    }
}
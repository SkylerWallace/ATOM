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
		tooltip = "Yes"
		predicate = { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -MinWinVer 10 -MinWinBuild 18282 }
		scriptblock = {
			Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type "DWord" -Value "0"
			Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type "DWord" -Value "0"

			# Restarting explorer.exe to apply taskbar theming
			taskkill /f /im explorer.exe
			start explorer.exe

			Write-OutputBox "- Enabled Dark Mode"
		}
	}
	
	"Disable Encryption" = @{
		tooltip		= "Recommended on personal devices for`neasier data recovery and OS repair"
		predicate	= {
			(Get-CimInstance -Namespace "Root\CIMv2\Security\MicrosoftVolumeEncryption" -ClassName Win32_EncryptableVolume | Where-Object { $_.DriveLetter -eq $env:SystemDrive } | Select-Object -ExpandProperty ProtectionStatus) -ne 0
		}
		scriptblock	= {
			manage-bde $env:SystemDrive -Off
			Write-OutputBox "- Disabling Device Encryption"
		}
	}
	
	"Disable Mouse Acceleration" = @{
		tooltip		= "Important tweak for some gamers"
		predicate	= { Test-Predicate -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 }
		scriptblock	= {
			Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type "String" -Value "0"
			Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type "String" -Value "0"
			Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type "String" -Value "0"
			Write-OutputBox "- Disabled Mouse Acceleration"
		}
	}
	
	"Disable Notifications" = @{
		tooltip		= "This is system-wide, will also disable Windows Security notifs"
		predicate	= { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Value 0 -MinWinVer 10 -MinWinBuild 14328 }
		scriptblock	= {
			Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type "DWord" -Value "0"
			Write-OutputBox "- Disabled Notifications"
		}
	}
	
	"Taskbar - Disable Chat" = @{
		tooltip		= "Disable Chat icon in taskbar"
		predicate	= { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -MinWinVer 11 -MinWinBuild 22000 }
		scriptblock	= {
			Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type "DWord" -Value "0"
			Write-OutputBox "- Disabled Chat button"
		}
	}
	
	"Taskbar - Disable Copilot" = @{
		tooltip		= "Disable Copilot icon in taskbar"
		predicate	= { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0 -MinWinVer 11 }
		scriptblock	= {
			# Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type "DWord" -Value "1"
			Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type "DWord" -Value "0"
			Write-OutputBox "- Disabled Copilot button"
		}
	}
	
	"Taskbar - Disable Search" = @{
		tooltip		= "Set search bar to hidden in taskbar"
		predicate	= { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -MinWinVer 10 }
		scriptblock	= {
			Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type "DWord" -Value "0"
			Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarModeCache" -Type "DWord" -Value "1"
			Write-OutputBox "- Disabled Search Box"
		}
	}
	
	"Taskbar - Disable Task View" = @{
		tooltip		= "Disable Task View icon in taskbar"
		predicate	= { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -MinWinVer 10 }
		scriptblock	= {
			Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type "DWord" -Value "0"
			Write-OutputBox "- Disabled Task View button"
		}
	}
	
	"Taskbar - Disable Widgets" = @{
		tooltip		= "Disable Widgets icon in taskbar"
		predicate	= { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -MinWinVer 11 -MinWinBuild 22000 }
		scriptblock	= {
			Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type "DWord" -Value "0"
			Write-OutputBox "- Disabled Widgets"
		}
	}
	
	"Taskbar - Left Align" = @{
		tooltip		= "Left-align taskbar icons in Windows 11"
		predicate	= { Test-Predicate -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -MinWinVer 11 -MinWinBuild 22000 }
		scriptblock	= {
			Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type "DWord" -Value "0"
			Write-OutputBox "- Taskbar left-aligned"
		}
	}
	
	"Update Apps" = @{
		tooltip		= "Update all eligible apps with 'winget upgrade --all'"
		predicate	= { Test-Predicate -MinWinVer 10 -MinWinBuild 17763 }
		scriptblock	= {
			winget upgrade --all --accept-package-agreements --accept-source-agreements --force --silent
			Write-OutputBox "- Installed Microsoft Store app updates"
		}
	}
}
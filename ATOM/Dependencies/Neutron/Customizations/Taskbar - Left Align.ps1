Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAI" -Type "DWord" -Value "0"

Write-OutputBox "Taskbar left-aligned."
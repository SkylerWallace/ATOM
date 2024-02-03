Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type "DWord" -Value "0"

Write-OutputBox "- Disabled Widgets"
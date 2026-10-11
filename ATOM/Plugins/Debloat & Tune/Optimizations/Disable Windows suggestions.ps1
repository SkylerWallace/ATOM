. (Join-Path $functionsPath 'Import-Atom.ps1') -Function Set-ThingProperty

$settings = @(
    @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SoftLandingEnabled' }
    @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested'; Name = 'Enabled' }
    @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Mobility'; Name = 'OptedIn' }
    @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_AccountNotifications' }
    @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackupReminder'; Name = 'Enabled' }
)
foreach ($setting in $settings) {
    Set-ThingProperty @setting -Type DWord -Value 0
    Write-Host "- Disabled $($setting.Name) at $($setting.Path)"
}

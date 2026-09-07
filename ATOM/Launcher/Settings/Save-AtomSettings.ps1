function Save-AtomSettings {
    Write-AtomSettingsFile -Path "$configPath\SettingsUser.ps1" -Settings $script:atomSettings
}

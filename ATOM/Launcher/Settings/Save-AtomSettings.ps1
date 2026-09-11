function Save-AtomSettings {
    Write-AtomSettingsFile -Path "$configPath\SettingsUser.ps1" -Settings $script:atomSettings
    $changes = @()
    foreach ($entry in $script:atomSettings.GetEnumerator()) {
        if ($script:settingsStatusValues[$entry.Key] -ne $entry.Value.Value) {
            $label = if ($entry.Value.Name) { $entry.Value.Name } else { $entry.Key }
            $value = $entry.Value.Value
            if ($value -is [bool]) { $value = if ($value) { 'On' } else { 'Off' } }
            if ($entry.Value.Options) {
                $option = $entry.Value.Options.GetEnumerator() | Where-Object Value -eq $entry.Value.Value | Select-Object -First 1
                if ($option) { $value = $option.Key }
            }
            $changes += "${label}: $value"
        }
        $script:settingsStatusValues[$entry.Key] = $entry.Value.Value
    }
    if ($changes.Count) { Set-AtomSettingsStatus -Message ($changes -join '; ') }
    Update-AtomSettingsSearch
}

$tooltip = "Disables second OOBE after feature updates`n(forcing Microsoft Account & explaining new Windows features)"

Write-Host "Disabling SCOOBE"

# All registry values for disabling Privacy & Security settings
$settings = [ordered]@{
	'New feature pestering' = @{
		Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
		Name = 'SubscribedContent-310093Enabled'
		Type = 'DWord'
		Value = 0
	}
	'Forcing Microsoft Account' = @{
		Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement'
		Name = 'ScoobeSystemSettingEnabled'
		Type = 'DWord'
		Value = 0
	}
}

# Import function
'Set-ThingProperty' | ForEach-Object {
	. "$functionsPath\$_.ps1"
}

$settings.GetEnumerator() | ForEach-Object {
    $value = $_.Value
    if ($value -is [System.Collections.Specialized.OrderedDictionary]) {
        $value.GetEnumerator() | ForEach-Object { 
            $splat = $_.Value
            Set-ThingProperty @splat
        }
    } else {
        $splat = $value
        Set-ThingProperty @splat
    }

	Write-Host "- $($_.Name) > Disabled"
}

Write-Host ""
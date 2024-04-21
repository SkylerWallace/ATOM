$tooltip = "Disables second OOBE after feature updates`n(forcing Microsoft Account & explaining new Windows features)"

Write-OutputBox "Disabling SCOOBE"

# All registry values for disabling Privacy & Security settings
$settings = [ordered]@{
	'New feature pestering' = @{
		path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
		name = "SubscribedContent-310093Enabled"
		type = "DWord"
		value = 0
	}
	'Forcing Microsoft Account' = @{
		path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement"
		name = "ScoobeSystemSettingEnabled"
		type = "DWord"
		value = 0
	}
}

function Modify-RegistryKey {
	param (
		[string]$path,
		[string]$name,
		[string]$type,
		[object]$value
	)
	
	$script:modified = $false # Flag for script output
	$keyValue = (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue).$name # Existing value
	
	if ($keyValue -eq $null) {
		# Create parent key if not detected & add registry entry
		if (!(Test-Path $path)) { New-Item -Path $path -Force }
		New-ItemProperty -Path $path -Name $name -Type $type -Value $value -Force | Out-Null
		$script:modified = $true
	} elseif ($keyValue -ne $value) {
		# Modify registry value
		Set-ItemProperty -Path $path -Name $name -Type $type -Value $value
		$script:modified = $true
	}
}

foreach ($setting in $settings.Keys) {
	# If hashtable key is nested/ordered
	if ($settings[$setting] -is [System.Collections.Specialized.OrderedDictionary]) {
		# Run Modify-RegistryKey function for all subkeys
		foreach ($subKey in $settings[$setting].Keys) {
			$path = $settings[$setting][$subKey]["path"]
			$name = $settings[$setting][$subKey]["name"]
			$type = $settings[$setting][$subKey]["type"]
			$value = $settings[$setting][$subKey]["value"]
			
			Modify-RegistryKey -Path $path -Name $name -Type $type -Value $value
		}
	# If hashtable key is not nested
	} else {
		$path = $settings[$setting]["path"]
		$name = $settings[$setting]["name"]
		$type = $settings[$setting]["type"]
		$value = $settings[$setting]["value"]
		
		Modify-RegistryKey -Path $path -Name $name -Type $type -Value $value
	}
	
	# Output based on $modified variable from Modify-RegistryKey function
	if ($modified) {
		Write-OutputBox "- $setting > Disabled"
	} else {
		Write-OutputBox "- $setting > Unchanged"
	}
}

Write-OutputBox ""
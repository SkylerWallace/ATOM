function Perform-Optimization {
	$counter = 0
	$balancedCounter = 0
	$aggressiveCounter = 0
	foreach ($registrySetting in $registrySettings) {
		$registryPath = $registrySetting[0]
		$registryName = $registrySetting[1]
		$registryType = $registrySetting[2]
		$registryValue = $registrySetting[3]
		$createOrDelete = $registrySetting[4]
		$debloatModeThreshold = $registrySetting[5]
		if (Test-Path -Path $registryPath) {
			if ((Get-ItemProperty -Path $registryPath).PSObject.Properties.Name -Contains $registryName)
			{
				if (((Get-ItemProperty -Path $registryPath -Name $registryName).$registryName -ne $registryValue) -And
				($debloatMode -ge $debloatModeThreshold) -And
				($createOrDelete -ne 2))
				{
					Set-ItemProperty -Path $registryPath -Name $registryName -Type $registryType -Value $registryValue 
					$counter++
					if ($debloatModeThreshold -eq 2) {
						$balancedCounter++
					}
					if ($debloatModeThreshold -eq 3) {
						$aggressiveCounter++
					}
				}
				elseif ($createOrDelete -eq 2)
				{
				Remove-ItemProperty -Path $registryPath -Name $registryName -Force | Out-Null
				$counter++
					if ($debloatModeThreshold -eq 2) {
						$balancedCounter++
					}
					if ($debloatModeThreshold -eq 3) {
						$aggressiveCounter++
					}
				}
			}
			elseif ($createOrDelete -eq 1)
			{
				New-ItemProperty -Path $registryPath -Name $registryName -Type $registryType -Value $registryValue -Force | Out-Null
				$counter++
				if ($debloatModeThreshold -eq 2) {
					$balancedCounter++
				}
				if ($debloatModeThreshold -eq 3) {
					$aggressiveCounter++
				}
			}

		}
	}
	if ($counter -ge 1)
	{
		Write-Host "Disabled $($counter) $($settingsGroup)." -ForegroundColor Cyan
		if ($debloatMode -eq 2 -And $balancedCounter -ge 1)
		{
			Write-Host "- $balancedCounter / $counter disabled due to Balanced Mode." -ForegroundColor Green
		}
		elseif ($debloatMode -eq 3 -And $aggressiveCounter -ge 1 -Or $balancedCounter -ge 1)
		{
			$aggressiveCounter = $aggressiveCounter + $balancedCounter
			Write-Host "- $aggressiveCounter / $counter disabled due to Aggressive Mode." -ForegroundColor Magenta
		}
	}
	else {
		Write-Host "All $($settingsGroup) already set to current Debloat Mode setting." -ForegroundColor DarkGray
	}
}
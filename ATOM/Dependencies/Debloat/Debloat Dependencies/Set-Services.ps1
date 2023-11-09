function Set-Services {
	$counter = 0
	$balancedCounter = 0
	$aggressiveCounter = 0
	foreach ($service in $services) {
		$serviceName = $service[0]
		$serviceValue = $service[1]
		$debloatModeThreshold = $service[2]
		if ((Get-Service -Name $serviceName -ErrorAction SilentlyContinue) -ne $null) {
			if (($debloatMode -ge $debloatModeThreshold) -And
				((Get-Service -Name $serviceName).StartType -ne $serviceValue))
			{
				if ($serviceValue -ne "Manual") {
					Stop-Service "$serviceName" -ErrorAction SilentlyContinue
				}
				Set-Service "$serviceName" -StartupType $serviceValue -ErrorAction SilentlyContinue
				$counter++
				if ($debloatModeThreshold -eq 2){
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
		Write-Host "Adjusted $($counter) services." -ForegroundColor Cyan
		if ($debloatMode -eq 2 -And $balancedCounter -ge 1)
		{
			Write-Host "- $balancedCounter / $counter adjusted due to Balanced Mode." -ForegroundColor Green
		}
		elseif ($debloatMode -eq 3 -And $aggressiveCounter -ge 1 -Or $balancedCounter -ge 1)
		{
			$aggressiveCounter = $aggressiveCounter + $balancedCounter
			Write-Host "- $aggressiveCounter / $counter adjusted due to Aggressive Mode." -ForegroundColor Magenta
		}
	}
	else {
		Write-Host "All $($settingsGroup) already set to current Debloat Mode setting." -ForegroundColor DarkGray
	}
}
$inPE = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
if ($inPE) {
	# Get all system partitions (typically EFI partitions for BCD access)
	$systemPartitions = Get-Disk | Where-Object { $_.OperationalStatus -eq 'Online' } | Get-Partition | Where-Object { $_.Type -eq 'System' }
	$systemMount = "Z"
	
	foreach ($partition in $systemPartitions) {
		$partition | Set-Partition -NewDriveLetter $systemMount
		
		# Delete RAMdisk
		bcdedit /store "${systemMount}:\EFI\Microsoft\Boot\BCD" /delete "{ramdiskoptions}" /f
		
		# Delete ATOM boot entry
		$lines = bcdedit /store "${systemMount}:\EFI\Microsoft\Boot\BCD" /enum | Out-String -Stream
		$guid = $null
		foreach ($line in $lines) {
			if ($line -match 'identifier\s+{([\w\-]+)}') {
				$guid = $matches[1]
			} elseif ($guid -and ($line -match 'description\s+ATOM PE')) {
				bcdedit /store "${systemMount}:\EFI\Microsoft\Boot\BCD" /delete "{$guid}"
				break
			}
		}

		# Dismount the partition
		Get-Partition -DriveLetter $systemMount | Remove-PartitionAccessPath -AccessPath "${systemMount}:\"

	}
} else {
	# Delete RAMdisk
	bcdedit /delete "{ramdiskoptions}" /f
	
	# Delete ATOM boot entry
	$lines = bcdedit /enum all | Out-String -Stream
	$guid = $null
	foreach ($line in $lines) {
		if ($line -match 'identifier\s+{([\w\-]+)}') {
			$guid = $matches[1]
		} elseif ($guid -and ($line -match 'description\s+ATOM PE')) {
			bcdedit /delete "{$guid}"
			break
		}
	}
	
	# Launch ClearBCD on reboot (cleanup after reboot from PE)
	$scriptPath = $MyInvocation.MyCommand.Path	
	$registryValue = "cmd /c `"start /b powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`"`""
	$runOncePath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
	New-ItemProperty -Path $runOncePath -Name "ClearBCD" -Value $registryValue -Force | Out-Null
}
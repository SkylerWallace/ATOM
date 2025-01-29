function Invoke-Runspace {
	param (
		[scriptblock]$scriptBlock,
		[switch]$wait
	)
	
	$runspace = [runspacefactory]::CreateRunspace()
	$runspace.ApartmentState = "STA"
	$runspace.ThreadOptions = "ReuseThread"
	$runspace.Open()
	
	# Import all script's variables into runspace
	Get-Variable | Where-Object {$_.Options -eq 'None'} | ForEach-Object {
		$runspace.SessionStateProxy.SetVariable($_.Name, $_.Value)
	}
	
	# Create scriptblock for Write-OutputBox and Invoke-Ui functions
	$additionalScriptBlock = {
		function Invoke-Ui {
			param([scriptblock]$action, [switch]$getValue)
			if ($getValue) { return $window.Dispatcher.Invoke([Func[object]] $action)}
			$window.Dispatcher.Invoke([action]$action, "Render")
		}

		function Write-Host {
			param([string]$object)

			Microsoft.PowerShell.Utility\Write-Output $object
			Invoke-Ui { $outputBox.Text += "$object`r`n"; $scrollToEnd }
		}
	}
	
	# Modify scriptblock parameter to include Write-OutputBox function
	$scriptBlock = [scriptblock]::Create([string]$additionalScriptBlock + "`n" + [string]$scriptBlock)
	
	# Add scriptblock
	$powershell = [powershell]::Create().AddScript($scriptBlock)
	
	# Start runspace
	$powershell.Runspace = $runspace

	if ($wait) {
		$handle = $powershell.BeginInvoke()
		$powershell.EndInvoke($handle)
		$result = $powershell.Streams.Output
		$powershell.Dispose()
		[GC]::Collect()
		return $result
	} else {
		$null = $powershell.BeginInvoke()
	}
}
function Create-Runspace {
	param ([scriptblock]$scriptBlock)
	
	$runspace = [runspacefactory]::CreateRunspace()
	$runspace.ApartmentState = "STA"
	$runspace.ThreadOptions = "ReuseThread"
	$runspace.Open()
	
	# Import all script's variables into runspace
	Get-Variable | Where-Object { $initialVariables -notcontains $_.Name } | ForEach-Object {
		$runspace.SessionStateProxy.SetVariable($_.Name, $_.Value)
	}
	
	# Create scriptblock for Write-OutputBox and Invoke-Ui functions
	$additionalScriptBlock = {
		function Invoke-Ui {
			param([scriptblock]$action, [switch]$getValue)
			if ($getValue) { return $window.Dispatcher.Invoke([Func[object]] $action)}
			$window.Dispatcher.Invoke([action]$action, "Render")
		}
		
		function Write-OutputBox {
			param([string]$text)
			Invoke-Ui { $outputBox.Text += "$text`r`n"; $scrollToEnd }
		}
	}
	
	# Modify scriptblock parameter to include Write-OutputBox function
	$scriptBlock = [scriptblock]::Create([string]$additionalScriptBlock + "`n" + [string]$scriptBlock)
	
	# Add scriptblock
	$powershell = [powershell]::Create().AddScript($scriptBlock)
	
	# Start runspace
	$powershell.Runspace = $runspace
	$null = $powershell.BeginInvoke()
}
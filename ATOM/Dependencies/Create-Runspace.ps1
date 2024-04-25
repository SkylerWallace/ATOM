function Create-Runspace {
    param (
        [scriptblock]$scriptBlock
    )
    
    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.ApartmentState = "STA"
    $runspace.ThreadOptions = "ReuseThread"
    $runspace.Open()
    
    # Import all script's variables into runspace
    Get-Variable | Where-Object { $initialVariables -notcontains $_.Name } | ForEach-Object {
        $runspace.SessionStateProxy.SetVariable($_.Name, $_.Value)
    }
	
	# Create scriptblock for Write-OutputBox function
	$outputBoxScriptBlock = {
		function Write-OutputBox {
			param([string]$text)
			
			$outputBox.Dispatcher.Invoke([action]{
				$outputBox.Text += "$Text`r`n"
				$scrollToEnd
			}, "Render")
		}
	}
	
	# Modify scriptblock parameter to include Write-OutputBox function
	$scriptBlock = [scriptblock]::Create([string]$outputBoxScriptBlock + "`n" + [string]$scriptBlock)
    
	# Add scriptblock
    $powershell = [powershell]::Create().AddScript($scriptBlock)
    
	# Start runspace
    $powershell.Runspace = $runspace
	$null = $powershell.BeginInvoke()
}
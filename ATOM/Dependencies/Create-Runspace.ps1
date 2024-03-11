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
    
	# Add scriptblock
    $powershell = [powershell]::Create().AddScript($scriptBlock)
    
	# Start runspace
    $powershell.Runspace = $runspace
	$null = $powershell.BeginInvoke()
}
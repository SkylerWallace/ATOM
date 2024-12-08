function New-LogFile {
	param([string]$name)
	
	$outputText = Invoke-Ui -GetValue { $outputBox.Text }
	$dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
	$logPath = Join-Path $atomTemp "${name}-$dateTime.txt"
	$outputText | Out-File -FilePath $logPath
	Write-OutputBox "Log saved to $logPath"
}
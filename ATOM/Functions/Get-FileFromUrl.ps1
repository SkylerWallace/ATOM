function Get-FileFromUrl {
	<#
	.SYNOPSIS
	Downloads a file from a specified URL and displays a progress bar.

	.DESCRIPTION
	The `Get-FileFromUrl` function downloads a file from a specified URL to a target file path.
	It utilizes background jobs to ensure the download does not slow down due to progress reporting, 
	unlike in PowerShell 5.x where `$ProgressPreference` might impact performance. A progress bar 
	is displayed to give feedback on the download progress.

	.PARAMETER Uri
	Specifies the URL to download the file. Alias: 'Url'.

	.PARAMETER OutFile
	Specifies the path where the downloaded file will be saved. If not specified, the file will be saved in the system's TEMP directory with a name derived from the URL. Optional.

	.PARAMETER TempPath
	Specifies the directory where files will be downloaded to if the OutFile parameter is not specified. Optional.

	.PARAMETER Headers
	Specifies a hashtable of custom headers to include in the HTTP request. Useful for providing authentication tokens or other headers required by the server. Optional.

	.PARAMETER AssignVariable
	Specifies the name of a variable to which the downloaded file's path will be assigned upon completion of the download. Optional.

	.EXAMPLE
	Get-FileFromUrl -Uri "https://example.com/file.zip" -OutFile "C:\Users\Owner\Downloads\file.zip"
	Downloads the file from the specified URL and saves it to `C:\Users\Owner\Downloads\file.zip`.

	.EXAMPLE
	Get-FileFromUrl -Uri "https://example.com/file.zip" -TempPath "C:\Temp"
	Downloads the file from the specified URL and saves it to `C:\Temp\file.zip`.

	.EXAMPLE
	Get-FileFromUrl -Uri "https://example.com/file.zip" -AssignVariable "downloadedFile"
	Downloads the file from the specified URL and saves it to the TEMP directory with its original name. The full path to the downloaded file is assigned to the variable `$downloadedFile`.

	.EXAMPLE
	Get-FileFromUrl -Uri "https://example.com/file.zip" -Headers @{ Authorization = "Bearer token123" }
	Downloads the file from the specified URL, including a custom Authorization header in the HTTP request.

	.INPUTS
	[string] The URL to download the file from.

	[string] The file path where the file will be saved.

	[hashtable] Custom headers for the HTTP request.

	.OUTPUTS
	[string] If `AssignVariable` is specified, the function returns the file path of the downloaded file by setting the specified variable.
	
	.NOTES
	Author: Skyler Wallace
	Requires: Internet connection to download files.
	#>

	param (
		[Parameter(Mandatory)]
		[alias('Url')]
		[string]$uri,
		[string]$outfile = $null,
		[string]$tempPath = $null,
		[hashtable]$headers = $null,
		[string]$assignVariable = $null
	)
	
	# Get file size of download
	$fileSizeBytes = (Invoke-WebRequest -Uri $uri -Headers $headers -Method Head -UseBasicParsing).Headers.'Content-Length'
	$fileSizeMb = [math]::Round($fileSizeBytes / 1MB, 2)
	
	# Provide file path for downloaded file
	$outfile = if ($outfile) { $outfile }
	elseif (!$outfile -and $tempPath) { Join-Path $tempPath (Split-Path $uri -Leaf) }
	else { Join-Path (Get-Item $env:TEMP).FullName (Split-Path $uri -Leaf) }

	$name = (Split-Path $outfile -Leaf)

	# Download file as job
	$downloadJob = Start-Job {
		param($uri, $outfile)
		Invoke-WebRequest -Uri $uri -Headers $headers -OutFile $outfile -UseBasicParsing
	} -ArgumentList $uri, $outfile
	
	# Output to progress bar as job runs
	while ($downloadJob.State -eq 'Running') {
		if (!(Test-Path $outfile)) { continue }
		$downloadedBytes = (Get-Item $outfile).Length
		$downloadedMb = [math]::Round($downloadedBytes / 1MB, 2)
		$percentComplete = [math]::Round(($downloadedBytes / $fileSizeBytes) * 100, 2)
		Write-Progress $name 'Downloading...' -PercentComplete $percentComplete -CurrentOperation "$uri : $downloadedMb MB / $fileSizeMb MB"
	}
	
	Wait-Job $downloadJob | Remove-Job | Out-Null
	Write-Progress $name 'Downloading...' -Completed

	if ($assignVariable) {
		Set-Variable -Name $assignVariable -Value $outfile -Scope 1 -Force
	}
}
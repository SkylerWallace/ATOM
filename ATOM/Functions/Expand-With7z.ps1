function Expand-With7z {
	<#
	.SYNOPSIS
	Extracts files from an archive using the 7-Zip utility.

	.DESCRIPTION
	The `Expand-With7z` function extracts files from an archive using the 7-Zip utility, either by downloading and using the console version (`7zr.exe`) or the full executable version of 7-Zip. 
	It supports running a custom script block after extraction and performs cleanup of temporary files after execution.

	This function can work in two modes:
	- **Console Extraction**: Uses the lightweight `7zr.exe` for extraction.
	- **Full 7-Zip Extraction**: Downloads and extracts the full version of 7-Zip for more advanced capabilities.

	.PARAMETER ConsoleExtract
	When specified, forces the function to use the console version of 7-Zip (`7zr.exe`) to extract the archive. Optional.

	.PARAMETER ScriptBlock
	Specifies a custom script block to be executed after the extraction is completed. Optional.

	.EXAMPLE
	Expand-With7z -ConsoleExtract
	Extracts the archive using the console version of 7-Zip.

	.EXAMPLE
	Expand-With7z -ScriptBlock { Write-Host "Extraction complete!" }
	Extracts the archive and then runs the specified script block.

	.INPUTS
	None. This function does not accept any pipeline input.

	.OUTPUTS
	None. This function does not produce output to the pipeline.

	.NOTES
	Author: Skyler Wallace
	
	.LINK
	For more information on 7-Zip command line switches, visit:
	https://web.mit.edu/outland/arch/i386_rhel4/build/p7zip-current/DOCS/MANUAL/
	#>
	
	param (
		[switch]$consoleExtract,
		[scriptblock]$scriptBlock
	)
	
	function Remove-7z {
		$7zConsolePath, $7zInstallerPath, $7zPortablePath, $appPath | ForEach-Object {
			if ($_ -ne $null) { Remove-Item $_ -Recurse -Force }
		}
	}
	
	# Download app
	$url = $programsInfo.$program.DownloadUrl
	$appPath = Join-Path $env:TEMP (Split-Path $programsInfo.$program.ExeName -Leaf)
	Invoke-WebRequest $url -OutFile $appPath -UserAgent "wget"
	
	# Download 7-Zip console version
	$7zConsoleUrl = "https://www.7-zip.org/a/7zr.exe"
	$7zConsolePath = Join-Path $env:TEMP "7zr.exe"
	Invoke-WebRequest $7zConsoleUrl -OutFile $7zConsolePath
	
	# Extract app with console version if -ConsoleExtract switch used
	if ($consoleExtract) {
		$extractArgs = "`"$7zConsolePath`" x `"$appPath`" -o`"$extractionPath`" -y"
		Start-Process cmd.exe -ArgumentList "/c `"$extractArgs`"" -Wait
		Remove-7z
		return
	}
	
	# Download 7-Zip exe version
	$7zInstallerUrl = $programsInfo['7-Zip'].DownloadUrl
	$7zInstallerPath = Join-Path $env:TEMP "7-Zip.exe"
	Invoke-WebRequest $7zInstallerUrl -OutFile $7zInstallerPath
	
	# Use 7z console to extract 7z exe version
	$7zPortablePath = Join-Path $env:TEMP "7-Zip"
	$extractArgs = "`"$7zConsolePath`" x `"$7zInstallerPath`" -o`"$7zPortablePath`" -y"
	Start-Process cmd.exe -ArgumentList "/c `"$extractArgs`"" -Wait
	
	# Extract app using 7z exe
	$7zExe = Join-Path $7zPortablePath "7z.exe"
	$extractArgs = "`"$7zExe`" x `"$appPath`" -o`"$extractionPath`" -y"
	Start-Process cmd.exe -ArgumentList "/c `"$extractArgs`"" -Wait
	
	# Run scriptblock if -ScriptBlock parameter is defined
	if ($scriptBlock) { Invoke-Command -ScriptBlock $scriptBlock -NoNewScope }
	
	# Cleanup
	Remove-7z
}
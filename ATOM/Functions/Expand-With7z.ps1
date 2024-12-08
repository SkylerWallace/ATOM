function Expand-With7z {
	param ([switch]$consoleExtract, [scriptblock]$scriptBlock)
	
	function Remove-7z {
		$7zConsolePath, $7zInstallerPath, $7zPortablePath, $appPath | ForEach {
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
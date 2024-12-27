function Install-Winget {
	<#
	.SYNOPSIS
	Installs or updates Winget (Windows Package Manager) on the system.

	.DESCRIPTION
	The Install-Winget function checks if Winget is installed on the system.
	If not installed or if an update is available, it downloads and installs Winget along with its dependencies.
	The function can run under both user and system context, adapting its behavior accordingly.

	.PARAMETER None
	This function does not accept parameters.

	.EXAMPLE
	Install-Winget
	Installs or updates Winget on the local system if not already present or if an update is available.

	.INPUTS
	None. This function does not accept any pipeline input.

	.OUTPUTS
	None. The function outputs status messages to the console.

	.NOTES
	Author: Skyler Wallace
	Requires: 
	- The custom function `Get-FileFromUrl` to download files from URLs.
	- Requires administrative privileges to install or update Winget.
	- Internet connectivity is required for downloading Winget and its dependencies.

	.LINK
	For more information about installing Winget, visit:
	https://docs.microsoft.com/en-us/windows/package-manager/winget/
	#>

	# Check if function is being ran in System context, adjust function as necessary
	$runningAsSystem = [Security.Principal.WindowsIdentity]::GetCurrent().Name -eq 'NT AUTHORITY\SYSTEM'

	$tempPath = if (!$runningAsSystem) { (Get-Item $env:TEMP).FullName }
	else {
		$sid = (New-Object Security.Principal.NTAccount((Get-WmiObject Win32_ComputerSystem).UserName.Split('\')[1])).Translate([Security.Principal.SecurityIdentifier]).Value
		([string](Get-ItemProperty "Registry::HKEY_USERS\$sid\Volatile Environment").USERPROFILE + "\AppData\Local\Temp").Trim()
	}

    $vccInstalled = if ($runningAsSystem) {
        Get-ChildItem 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall' | ForEach-Object {
            (Get-ItemProperty -LiteralPath $_.PsPath).DisplayName | Where-Object { $_ -like 'Microsoft Visual C++ 2015-2022 Redistributable (x64)*' }
        }
    }

	if ($runningAsSystem -and !$vccInstalled) {
		Write-Host "Installing Visual C++ 2015-2022"
		
		try {
			Get-FileFromUrl -Url 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -TempPath $tempPath -AssignVariable 'vccOutfile'
			Start-Process $vccOutfile -ArgumentList '/q /norestart' -Wait
			Write-Host "- Installed" -Fore Green
		} catch {
			Write-Host "- Failed to install Visual C++ 2015-2022" -Fore Red
			Write-Host "- Script may not work properly" -Fore Red
		} finally {
			if (Test-Path $vccOutfile) {
				Remove-Item $vccOutfile -Force
			}
		}
	}

	# Get winget path, method compatible with running PowerShell as System
	$wingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"

	if (!$wingetPath) {
		Write-Host "Winget not detected"
	} else {
		$wingetPath	= $wingetPath[-1].Path
		$wingetApi	= 'https://api.github.com/repos/microsoft/Winget-cli/releases/latest'
		[version]$currentWingetVersion = (cmd /c $wingetPath --version).Trim('v')
		[version]$latestWingetVersion = (Invoke-RestMethod -Uri $wingetApi -Method Get -UseBasicParsing).tag_name.Trim('v')
		Write-Host "Winget v$currentWingetVersion"
	}

	if (!$wingetPath -or ($currentWingetVersion -lt $latestWingetVersion)) {
		try {
			$errorActionPreference = 'Stop' # Force any error to throw to catch block

			# Download required dependencies
			Write-Host "- Downloading Winget dependencies"
			$dependenciesUrl = 'https://github.com/microsoft/winget-cli/releases/latest/download/DesktopAppInstaller_Dependencies.zip'
			Get-FileFromUrl -Url $dependenciesUrl -TempPath $tempPath -AssignVariable 'dependenciesZip'

			# Extracting dependencies
			$extractedDependencies = Join-Path (Get-Item $dependenciesZip).DirectoryName (Get-Item $dependenciesZip).BaseName
			Expand-Archive $dependenciesZip -DestinationPath $extractedDependencies -Force

			$architecture = [System.Runtime.InteropServices.RuntimeInformation,mscorlib]::OSArchitecture.ToString().ToLower()

			# Get Winget dependency info from GitHub
			$versionsUrl = 'https://github.com/microsoft/winget-cli/releases/download/v1.9.25200/DesktopAppInstaller_Dependencies.json'
			$dependencyFiles = Invoke-WebRequest -Uri $versionsUrl -UseBasicParsing | ConvertFrom-Json | Select-Object -Expand Dependencies | ForEach-Object {
				Get-ChildItem $extractedDependencies\$architecture\$_*.appx
			}

			# Download license file
			$apiUrl = 'https://api.github.com/repos/microsoft/Winget-cli/releases/latest'
			$response = Invoke-RestMethod -Uri $apiUrl -Method Get -ErrorAction Stop
			$licenseUrl = $response.assets.browser_download_url | Where-Object {$_ -like "*License1.xml"} # Index value for License file.
			Get-FileFromUrl -Url $licenseUrl -TempPath $tempPath -AssignVariable 'licenseFile'

			# Download Winget
			$wingetUrl = 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
			Get-FileFromUrl -Url $wingetUrl -TempPath $tempPath -AssignVariable 'wingetFile'

			# Install Winget
			Write-Host "- Installing Winget v$latestWingetVersion"
			Add-AppxProvisionedPackage -Online -PackagePath $wingetFile -DependencyPackagePath $dependencyFiles -LicensePath $licenseFile | Out-Null

			# Seems some installs of Winget don't add the repo source, this should makes sure that it's installed every time
			$sourceUrl = 'https://cdn.winget.microsoft.com/cache/source.msix'
			Get-FileFromUrl -Url $sourceUrl -TempPath $tempPath -AssignVariable 'sourceFile'

			if (!$runningAsSystem) {
				$errorActionPreference = 'SilentlyContinue' # Allow this one to error out
				Add-AppxPackage $sourceFile
			} else {
				$batFile = $sourceFile + '.bat'
				Set-Content $batFile -Value "
					powershell -Command ^
					Add-AppxPackage $sourceFile; ^
					Remove-Item $batFile -Force
				"

				Start-Process explorer -ArgumentList $batFile

				do { Start-Sleep -Milliseconds 200 }
				until (!(Test-Path $batFile))
			}

			# Refresh system variables
			$env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

			Write-Host "- Winget installed"
		} catch {
			Write-Host "- Failed to install Winget"
		}

		# Remove downloadeded files
		$dependenciesZip, $extractedDependencies, $licenseFile, $wingetFile | ForEach-Object {
			if ($_ -and (Test-Path $_)) {
				Remove-Item $_ -Force -Recurse
			}
		}
	}; Write-Host ""
}
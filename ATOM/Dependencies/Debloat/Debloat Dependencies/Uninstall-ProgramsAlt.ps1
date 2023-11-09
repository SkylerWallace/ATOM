function Uninstall-ProgramsAlt {
	foreach ($program in $programs) {
		$programName = $program[0]
		$programRegPath = $program[1]
		$uninstallScript = $program[2]
		$programUserDataPath = $program[3]
		if ((Test-Path -Path $programRegPath) -And !(Test-Path -Path $programUserDataPath)) {
			cmd /c $uninstallScript
			if (!(Test-Path -Path $programRegPath)) {
				Write-Host "$programName uninstalled." -ForegroundColor Green
			}
			else {
				Write-Host "$programName uninstaller manually aborted." -ForegroundColor Red
			}
		}
		elseif  ((Test-Path -Path $programRegPath) -And (Test-Path -Path $programUserDataPath)){
			Write-Host "$programName has user data, aborting uninstall." -ForegroundColor Red
		}
		else {
			Write-Host "$programName not detected." -ForegroundColor DarkGray
		}
	}
}
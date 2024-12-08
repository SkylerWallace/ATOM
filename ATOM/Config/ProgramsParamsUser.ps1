## Add programs for custom plugins and the ATOM Store here.
## The update feature in ATOM will remove Programs-Hashtable.ps1
## but will not remove Programs-Hashtable (Custom).ps1 making
## this .ps1 safe from updates.

<#
- ProgramFolder
	Name of programs folder within ATOM's Programs folder.
	If ProgramFolder = 'ExampleProgram', the location is 
	in './Programs/ExampleProgram'.
- ExeName
	Name of the executable within ProgramFolder.
	If ExeName = 'ExampleExe.exe', the location is
	'./Programs/ExampleProgram/ExampleExe.exe'.
- AltPath
	If Start-PortablePrograms does not detect the defined
	ProgramFolder path, it will check the AltPath. Does
	not need to be defined.
- AltExeName
	Name of the executable in AltPath if AltPath is
	defined.
- DownloadUrl
	URL to download program.
	Ex: 'DownloadUrl' = 'https://www.website.net/download.zip'
- Override
	If defined, will override default downloading procedures
	in Start-PortablePrograms & Install-PortablePrograms.
	Ex: 'Override' = { iwr -url $url -outFile $downloadPath }
	IMPORTANT: preAtomPath, programsPath, exePath, extractionPath,
	and exePath variables are inherited.
- Credential
	If download URL requires a username and/or password, this
	parameter must be defined and set to $true.
	Ex: 'Credential' = $true
- UserName
	If Credential is defined and set to $true, this will
	auto-fill the username. If undefined, username will
	not be auto-filled.
	Ex: 'UserName' = abc123
- ArgumentList
	If defined, will arguments with the program's exe if
	called by Start-PortablePrograms.
	Ex: 'ArgumentList' = '/silent'
- PostInstall
	If defined, will run the contents of PostInstall after
	program has been installed.
	Ex: 'PostInstall' = { Remove-Item -Path $removeMe }
#>

$customProgramsInfo = [ordered]@{
	<#
	'Example'			= @{
		'ProgramFolder'	= $null
		'ExeName'		= $null
		'DownloadUrl'	= $null
		'Override'		= $null
	#>
}
# Variables
$atomTemp           = Join-Path (Get-Item $env:TEMP).FullName "AtomTemp"
$atomPath			= $psScriptRoot | Split-Path
$drivePath			= $atomPath | Split-Path -Qualifier
$dependenciesPath	= "$atomPath\Dependencies"
$functionsPath		= "$atomPath\Functions"
$logsPath			= "$atomPath\Logs"
$pluginsPath		= "$atomPath\Plugins"
$resourcesPath		= "$atomPath\Resources"
$settingsPath		= "$atomPath\Settings"
$programsPath       = "$atomPath\..\Programs"

# Import functions
Get-ChildItem $psScriptRoot -Include *.ps1 -Recurse | ForEach-Object {
	. $_.FullName
}

# Create ATOM temp directory and set as working directory
if (!(Test-Path $atomTemp)) {
	New-Item -Path $atomTemp -ItemType Directory -Force
}

if ((Get-Location).Path -ne $atomTemp) {
	Set-Location $atomTemp
}

Export-ModuleMember -Variable *
Export-ModuleMember -Function *
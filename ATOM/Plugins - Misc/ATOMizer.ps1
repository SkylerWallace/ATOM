# Launch: Hidden

# Create ATOM temp directory if not detected
$atomTemp = Join-Path $env:TEMP "ATOM Temp"
if (!(Test-Path $atomTemp)) {
	New-Item -Path $atomTemp -ItemType Directory -Force
}

$atomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
$fontsPath = Join-Path $dependenciesPath "Fonts"
$iconsPath = Join-Path $dependenciesPath "Icons"
$settingsPath = Join-Path $dependenciesPath "Settings"
$scriptPath = Join-Path $dependenciesPath "ATOMizer.ps1"
$dictionaryPath = Join-Path $dependenciesPath "ResourceDictionary.ps1"
$runspacePath = Join-Path $dependenciesPath "Create-Runspace.ps1"
$themesPath = Join-Path $settingsPath "Themes.ps1"
$savedThemePath = Join-Path $settingsPath "SavedTheme.ps1"

$atomizerCopyPath = Join-Path $atomTemp "ATOMizer"
$dependenciesCopyPath = Join-Path $atomizerCopyPath "Dependencies"
$fontsCopyPath = Join-Path $dependenciesCopyPath "Fonts"
$iconsCopyPath = Join-Path $dependenciesCopyPath "Icons"
$settingsCopyPath = Join-Path $dependenciesCopyPath "Settings"

New-Item -ItemType Directory -Path $atomizerCopyPath | Out-Null
New-Item -ItemType Directory -Path $dependenciesCopyPath | Out-Null
New-Item -ItemType Directory -Path $fontsCopyPath | Out-Null
New-Item -ItemType Directory -Path $iconsCopyPath | Out-Null
New-Item -ItemType Directory -Path $settingsCopyPath | Out-Null
New-Item -ItemType Directory -Path "$iconsCopyPath\Plugins" | Out-Null

Copy-Item $scriptPath -Destination $atomizerCopyPath
Copy-Item $dictionaryPath -Destination $dependenciesCopyPath
Copy-Item $runspacePath -Destination $dependenciesCopyPath
Copy-Item $themesPath -Destination $settingsCopyPath
Copy-Item $savedThemePath -Destination $settingsCopyPath
Copy-Item "$fontsPath\OpenSans-Regular.ttf" -Destination $fontsCopyPath
Copy-Item "$iconsPath\Plugins\ATOMizer.png" -Destination "$iconsCopyPath\Plugins\ATOMizer.png"
Copy-Item "$iconsPath\Minimize (Light).png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Minimize (Dark).png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Refresh (Light).png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Refresh (Dark).png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Close (Light).png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Close (Dark).png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Download (Light).png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Download (Dark).png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Browse (Light).png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Browse (Dark).png" -Destination $iconsCopyPath

$scriptPath = Join-Path $atomizerCopyPath "ATOMizer.ps1"
Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" -AtomPath `"$atomPath`" -AtomTemp `"$atomTemp`"" -Wait
Remove-Item $atomizerCopyPath -Recurse -Force
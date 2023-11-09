# Launch: Hidden

$atomPath = Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent
$atomParentPath = Split-Path $atomPath -Parent
$dependenciesPath = Join-Path $atomPath "Dependencies"
$fontsPath = Join-Path $dependenciesPath "Fonts"
$iconsPath = Join-Path $dependenciesPath "Icons"
$scriptPath = Join-Path $dependenciesPath "ATOMizer.ps1"

$atomizerCopyPath = Join-Path $atomParentPath "ATOMizer"
$dependenciesCopyPath = Join-Path $atomizerCopyPath "Dependencies"
$fontsCopyPath = Join-Path $dependenciesCopyPath "Fonts"
$iconsCopyPath = Join-Path $dependenciesCopyPath "Icons"

New-Item -ItemType Directory -Path $atomizerCopyPath | Out-Null
New-Item -ItemType Directory -Path $dependenciesCopyPath | Out-Null
New-Item -ItemType Directory -Path $fontsCopyPath | Out-Null
New-Item -ItemType Directory -Path $iconsCopyPath | Out-Null
New-Item -ItemType Directory -Path "$iconsCopyPath\Plugins" | Out-Null

Copy-Item $scriptPath -Destination $atomizerCopyPath
Copy-Item "$fontsPath\OpenSans-Regular.ttf" -Destination $fontsCopyPath
Copy-Item "$iconsPath\Plugins\ATOMizer.png" -Destination "$iconsCopyPath\Plugins\ATOMizer.png"
Copy-Item "$iconsPath\Minimize.png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Refresh.png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Close.png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Download.png" -Destination $iconsCopyPath
Copy-Item "$iconsPath\Browse.png" -Destination $iconsCopyPath

$scriptPath = Join-Path $atomizerCopyPath "ATOMizer.ps1"
Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Wait
Remove-Item $atomizerCopyPath -Recurse -Force
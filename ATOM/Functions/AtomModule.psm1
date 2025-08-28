# Variables
$atomTemp         = Join-Path (Get-Item $env:TEMP).FullName "AtomTemp"
$atomPath         = $psScriptRoot | Split-Path
$drivePath        = $atomPath | Split-Path -Qualifier
$configPath       = "$atomPath\Config"
$dependenciesPath = "$atomPath\Dependencies"
$functionsPath    = "$atomPath\Functions"
$logsPath         = "$atomPath\Logs"
$pluginsPath      = "$atomPath\Plugins"
$resourcesPath    = "$atomPath\Resources"
$programsPath     = (Split-Path $atomPath)+"\Programs"# "$atomPath\..\Programs"

# Import Plugins.ps1
if (Test-Path $configPath\Plugins.ps1) {
    . $configPath\Plugins.ps1
}

# Import functions
$moduleArguments = Get-PsCallStack | Where-Object { $_.Command -eq 'Import-Module'} | Select-Object -Expand Arguments
if ($moduleArguments -match '(?<=Function=)(.*?)(?=,)') {
    $functions = $matches[0] -split '\s+'
    $functions | ForEach-Object {
        . $psScriptRoot\$_.ps1
    }
} else {
    Get-ChildItem $psScriptRoot -Include *.ps1 -Recurse | ForEach-Object {
        . $_.FullName
    }
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
# Explicit ATOM path setup. Creates the toolkit's scratch directory, not a catalog.
# Bootstrap scripts are dot-sourced by Import-Atom.ps1 into the caller's scope.
$atomPath         = Split-Path (Split-Path $PSScriptRoot)
$atomTemp         = Join-Path ([IO.Path]::GetTempPath()) 'AtomTemp'
$drivePath        = [IO.Path]::GetPathRoot($atomPath).TrimEnd('\', '/')
$configPath       = Join-Path $atomPath 'Config'
$dependenciesPath = Join-Path $atomPath 'Dependencies'
$functionsPath    = Join-Path $atomPath 'Functions'
$logsPath         = Join-Path $atomPath 'Logs'
$pluginsPath      = Join-Path $atomPath 'Plugins'
$resourcesPath    = Join-Path $atomPath 'Resources'
$programsPath     = Join-Path (Split-Path $atomPath) 'Programs'
if (![IO.Directory]::Exists($atomTemp)) { [void][IO.Directory]::CreateDirectory($atomTemp) }

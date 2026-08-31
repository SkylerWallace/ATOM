param (
    # Explicitly limits function loading for startup-sensitive callers. Existing
    # callers may omit this while they migrate from legacy -Function discovery.
    [String[]]$FunctionName
)

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

$moduleSourcePaths = @()
$pluginsConfigPath = Join-Path $configPath 'Plugins.ps1'
if (Test-Path -LiteralPath $pluginsConfigPath -PathType Leaf) {
    $moduleSourcePaths += $pluginsConfigPath
}

# Import only explicitly requested functions when the caller uses the module API.
if ($FunctionName) {
    $functions = @($FunctionName | Select-Object -Unique)
} else {
    # Backward compatibility for plugins that still rely on Import-Module's
    # -Function argument to determine which implementation files are loaded.
    $moduleArguments = Get-PsCallStack | Where-Object { $_.Command -eq 'Import-Module'} | Select-Object -Expand Arguments
    if ($moduleArguments -match '(?<=Function=)(.*?)(?=,)') {
        $functions = @($matches[0] -split '\s+')
    } else {
        $functionPaths = @(Get-ChildItem $psScriptRoot -Include *.ps1 -Recurse | Select-Object -ExpandProperty FullName)
    }
}

if (!$functionPaths) {
    $functionPaths = foreach ($function in $functions) {
        if ($function -notmatch '^[A-Za-z][A-Za-z0-9-]*$') { throw "Invalid ATOM function name '$function'." }
        $functionPath = Join-Path $psScriptRoot "$function.ps1"
        if (!(Test-Path -LiteralPath $functionPath -PathType Leaf)) { throw "ATOM function '$function' was not found at '$functionPath'." }
        $functionPath
    }
}

# Parse configuration and selected implementations as one source unit. They remain
# in individual files for ownership and review, while module startup pays the
# parser setup cost once instead of once per file.
$functionSource = [Text.StringBuilder]::new()
foreach ($sourcePath in @($moduleSourcePaths) + @($functionPaths)) {
    [void]$functionSource.AppendLine([IO.File]::ReadAllText($sourcePath))
}
. ([ScriptBlock]::Create($functionSource.ToString()))

# Create ATOM temp directory
if (!(Test-Path $atomTemp)) {
    New-Item -Path $atomTemp -ItemType Directory -Force
}

Export-ModuleMember -Variable *
Export-ModuleMember -Function $(if ($FunctionName) { $functions } else { '*' })

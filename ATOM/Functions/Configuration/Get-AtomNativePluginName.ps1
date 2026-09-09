function Get-AtomNativePluginName {
    param([Parameter(Mandatory)][String]$RootPath)
    $catalogPath = Join-Path $RootPath 'Config/Plugins.ps1'
    $names = @(& {
        param($CatalogPath)
        $programDefaults = @{}
        . $CatalogPath
        $programDefaults.Keys
    } $catalogPath)
    $statePath = Join-Path $RootPath 'Config/UpdateState.json'
    if (Test-Path -LiteralPath $statePath) {
        $state = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($state.CommitSha) {
            $names += @($state.Files | Where-Object { $_.Path.Replace('\', '/') -match '^ATOM/Plugins/[^/]+$' } | ForEach-Object { [IO.Path]::GetFileNameWithoutExtension($_.Path) })
        }
    }
    $names | Sort-Object -Unique
}

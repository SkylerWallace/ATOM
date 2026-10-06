function Get-AtomWorkflowHistory {
    <# .SYNOPSIS
        Lists persisted workflow runs without evaluating log content as code.
    #>
    param([Parameter(Mandatory)][string]$Root, [hashtable]$Cache = @{})
    if (!(Test-Path -LiteralPath $Root)) { return }
    $paths = @(Get-ChildItem -LiteralPath $Root -Directory -ErrorAction Stop | Where-Object { !($_.Attributes -band [IO.FileAttributes]::ReparsePoint) } | ForEach-Object { Join-Path $_.FullName 'results.json' })
    $plainPaths = $paths
    $paths = @(Get-ChildItem -LiteralPath $Root -File -Filter '*.zip' -ErrorAction Stop | Where-Object {
        $_.BaseName -match '^(?:[0-9a-f]{32}|\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}_[a-z0-9]{4})$'
    } | Select-Object -ExpandProperty FullName)
    $paths += $plainPaths
    $seen = @{}
    foreach ($path in $paths) {
        if (!(Test-Path -LiteralPath $path)) { continue }
        $file = Get-Item -LiteralPath $path -ErrorAction Stop
        if ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
        $runName = if ($file.Extension -eq '.zip') { $file.BaseName } else { Split-Path $file.DirectoryName -Leaf }
        if ($seen[$runName]) { continue }
        if (!$Cache.ContainsKey($path)) {
            $created = $file.CreationTimeUtc
            $name = 'Custom workflow'
            try {
                $run = Read-AtomWorkflowLog -Path $path
                if ($run.StartedUtc) { $created = ([datetime]$run.StartedUtc).ToUniversalTime() }
                if ($run.PresetName) { $name = [string]$run.PresetName }
            }
            catch { continue }
            $Cache[$path] = [pscustomobject]@{
                Path = $path
                Label = '{0:MMMM dd, yyyy h:mm tt} - {1}' -f $created.ToLocalTime(), $name
                Created = $created
            }
        }
        $seen[$runName] = $true
        $Cache[$path]
    }
}

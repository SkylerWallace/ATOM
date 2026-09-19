function Get-AtomWorkflowHistory {
    <# .SYNOPSIS
        Lists persisted workflow runs without evaluating log content as code.
    #>
    param([Parameter(Mandatory)][string]$Root, [hashtable]$Cache = @{})
    if (!(Test-Path -LiteralPath $Root)) { return }
    foreach ($directory in Get-ChildItem -LiteralPath $Root -Directory -ErrorAction Stop) {
        if ($directory.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
        $path = Join-Path $directory.FullName 'results.json'
        if (!(Test-Path -LiteralPath $path)) { continue }
        $file = Get-Item -LiteralPath $path -ErrorAction Stop
        if ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
        if (!$Cache.ContainsKey($path)) {
            $created = $directory.CreationTimeUtc
            $name = 'Custom workflow'
            try {
                $run = [IO.File]::ReadAllText($path) | ConvertFrom-Json -ErrorAction Stop
                if ($run.StartedUtc) { $created = [datetime]::Parse($run.StartedUtc).ToUniversalTime() }
                if ($run.PresetName) { $name = [string]$run.PresetName }
            }
            catch { continue }
            $Cache[$path] = [pscustomobject]@{
                Path = $path
                Label = '{0:MMMM dd, yyyy h:mm tt} - {1}' -f $created.ToLocalTime(), $name
                Created = $created
            }
        }
        $Cache[$path]
    }
}

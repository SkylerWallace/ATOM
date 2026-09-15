function Invoke-DebloatQueue {
    <# .SYNOPSIS
        Executes selected debloat actions and returns per-action results.
    #>
    param(
        [Parameter(Mandatory)][object[]]$Queue,
        [Parameter(Mandatory)][string]$DependenciesPath,
        [Parameter(Mandatory)][string]$FunctionsPath,
        [switch]$Preview
    )

    $catalog = Import-PowerShellDataFile (Join-Path $DependenciesPath 'Optimizations.psd1')
    foreach ($action in $Queue) {
        if ($action.Kind -notin 'Optimization','Customization','Program','AppX') { throw "Unknown action type: $($action.Kind)" }
        if ($action.Kind -eq 'Optimization') {
            if (!$catalog.ContainsKey($action.Id)) { throw "Unknown optimization: $($action.Id)" }
            $file = $catalog[$action.Id].ScriptFile
            if ([IO.Path]::GetFileName($file) -ne $file -or !(Test-Path -LiteralPath (Join-Path "$DependenciesPath/Optimizations" $file))) { throw "Invalid optimization file: $file" }
        }
    }

    $tasks = [Collections.Generic.List[object]]::new()
    foreach ($action in $Queue) {
        $task = [ordered]@{
            Id          = $action.Id
            Name        = $action.Name
            Kind        = $action.Kind
            Status      = 'Succeeded'
            StartedUtc  = [datetime]::UtcNow.ToString('o')
            FinishedUtc = $null
            Summary     = ''
        }
        try {
            if ($Preview) { $task.Summary = 'Preview: selected; no changes made.' }
            else {
                & {
                    $ErrorActionPreference = 'Stop'
                    switch ($action.Kind) {
                        Optimization { & (Join-Path "$DependenciesPath/Optimizations" $catalog[$action.Id].ScriptFile) }
                        Customization { & ([scriptblock]::Create($action.Script)) }
                        Program {
                            if ($action.Script) { & ([scriptblock]::Create($action.Script)) $action.Target }
                            else { Remove-App -App $action.Target -ErrorAction Stop }
                        }
                        AppX {
                            $packages = @(Get-AppxPackage -Name $action.PackageName -ErrorAction Stop)
                            if (!$packages.Count) { Write-Host '  Already absent'; break }
                            $packages | Remove-AppxPackage -ErrorAction Stop
                            if (Get-AppxPackage -Name $action.PackageName -ErrorAction Stop) { throw 'App package is still installed.' }
                        }
                    }
                } | ForEach-Object { Write-Host ([string]$_) }
                $task.Summary = 'Completed.'
            }
        }
        catch {
            $task.Status = 'NeedsAttention'
            $task.Summary = $_.Exception.Message
        }
        $task.FinishedUtc = [datetime]::UtcNow.ToString('o')
        $tasks.Add([pscustomobject]$task)
    }
    $failed = @($tasks | Where-Object Status -eq 'NeedsAttention').Count
    [pscustomobject]@{
        Status = $(if ($failed) { 'NeedsAttention' } else { 'Succeeded' })
        ExitCode = $null
        Summary = $(if ($Preview) { "Preview: $($tasks.Count) actions selected; no changes made." } else { "$($tasks.Count - $failed) of $($tasks.Count) actions completed; $failed need attention." })
        Output = [pscustomobject]@{
            Preview        = [bool]$Preview
            TotalTasks     = $tasks.Count
            PassedTasks    = $tasks.Count - $failed
            AttentionTasks = $failed
            Tasks          = $tasks.ToArray()
        }
    }
}

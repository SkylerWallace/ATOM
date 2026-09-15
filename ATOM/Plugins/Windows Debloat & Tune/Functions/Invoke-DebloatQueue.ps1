function Invoke-DebloatQueue {
    <# .SYNOPSIS
        Executes selected debloat actions and returns per-action results.
    #>
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Queue,
        [Parameter(Mandatory)][string]$DependenciesPath,
        [Parameter(Mandatory)][string]$FunctionsPath,
        [switch]$Preview
    )

    . (Join-Path $DependenciesPath 'Functions/Debloat-Removals.ps1')
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
            if ($action.SkipReason) {
                $task.Status = 'Skipped'
                $task.Summary = $action.SkipReason
                continue
            }
            if ($action.Kind -eq 'Program' -and $action.Unattended) {
                $null = Get-DebloatQuietUninstall -App $action.Target
            }
            if ($Preview) { $task.Summary = 'Preview: selected; no changes made.' }
            else {
                & {
                    $ErrorActionPreference = 'Stop'
                    switch ($action.Kind) {
                        Optimization { & (Join-Path "$DependenciesPath/Optimizations" $catalog[$action.Id].ScriptFile) }
                        Customization { & ([scriptblock]::Create($action.Script)) }
                        Program {
                            if ($action.Unattended) { Remove-DebloatProgram -App $action.Target }
                            elseif ($action.Script) { & ([scriptblock]::Create($action.Script)) $action.Target }
                            else { Remove-App -App $action.Target -ErrorAction Stop }
                        }
                        AppX {
                            $packages = @(Get-AppxPackage -Name $action.PackageName -ErrorAction Stop)
                            if ($action.UnusedOnly) {
                                $packages = @($packages | Where-Object { $_.PackageFullName -eq $action.PackageFullName })
                                foreach ($package in $packages) {
                                    if (!(Test-DebloatUnusedAppx -Package $package -Definition $action.Definition)) { throw 'App eligibility changed since the scan; no removal attempted.' }
                                }
                            }
                            if (!$packages.Count) { Write-Host '  Already absent'; break }
                            $packages | Remove-AppxPackage -ErrorAction Stop
                            $remaining = @(Get-AppxPackage -Name $action.PackageName -ErrorAction Stop)
                            if ($action.UnusedOnly) { $remaining = @($remaining | Where-Object { $_.PackageFullName -eq $action.PackageFullName }) }
                            if ($remaining.Count) { throw 'App package is still installed.' }
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
        finally {
            $task.FinishedUtc = [datetime]::UtcNow.ToString('o')
            $tasks.Add([pscustomobject]$task)
        }
    }
    $failed = @($tasks | Where-Object Status -eq 'NeedsAttention').Count
    $skipped = @($tasks | Where-Object Status -eq 'Skipped').Count
    [pscustomobject]@{
        Status = $(if ($failed) { 'NeedsAttention' } else { 'Succeeded' })
        ExitCode = $null
        Summary = $(if ($Preview) { "Preview: $($tasks.Count) actions; $skipped skipped; $failed need attention; no changes made." } else { "$($tasks.Count - $failed - $skipped) actions completed; $skipped skipped; $failed need attention." })
        Output = [pscustomobject]@{
            Preview        = [bool]$Preview
            TotalTasks     = $tasks.Count
            PassedTasks    = $tasks.Count - $failed - $skipped
            SkippedTasks   = $skipped
            AttentionTasks = $failed
            Tasks          = $tasks.ToArray()
        }
    }
}

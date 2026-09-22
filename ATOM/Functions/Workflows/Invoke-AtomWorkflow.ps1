function Invoke-AtomWorkflow {
    <# .SYNOPSIS
        Executes a validated, sequential workflow and saves checkpoints.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory, ParameterSetName='Ids')][string[]]$ActionIds,
          [Parameter(Mandatory, ParameterSetName='Entries')][object[]]$Entries,
          [Parameter(Mandatory)][hashtable]$State,
          [Parameter(Mandatory)][string]$ResultPath,
          [Parameter(Mandatory)][string]$AtomRoot,
          [string]$PresetName)
    $ErrorActionPreference = 'Stop'
    $catalog=(Import-PowerShellDataFile "$AtomRoot/Config/WorkflowActions.psd1").Actions
    if ($PSCmdlet.ParameterSetName -eq 'Ids') { $Entries = @($ActionIds | ForEach-Object { @{ActionId=$_} }) }
    if (!$Entries.Count) { throw 'Queue is empty.' }
    $resolvedActions = @($Entries | ForEach-Object {
        if (!$catalog.ContainsKey($_.ActionId)) { throw "Unknown action: $($_.ActionId)" }
        Resolve-AtomWorkflowSelection -Definition $catalog[$_.ActionId] -OptionId $_.OptionId
    })
    $inPE=(Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT') -or (Test-Path (Join-Path $env:SystemRoot 'System32\wpeutil.exe'))
    $principal=[Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
    $steps = @(for ($i=0; $i -lt $Entries.Count; $i++) {
        $action=$resolvedActions[$i]
        [pscustomobject]@{ ActionId=$Entries[$i].ActionId; OptionId=$action.OptionId; Name=$action.Name; Parameters=$action.Parameters; Status='Pending'; StartedUtc=$null; FinishedUtc=$null; Summary=''; Data=$null }
    })
    $run = [pscustomobject]@{ SchemaVersion=1; PresetName=$PresetName; ComputerName=$env:COMPUTERNAME; UserName=[Security.Principal.WindowsIdentity]::GetCurrent().Name; Error=$null; Status='Running'; StartedUtc=[datetime]::UtcNow.ToString('o'); FinishedUtc=$null; Steps=$steps }
    try {
        Write-AtomFileAtomic -Path $ResultPath -Content ($run | ConvertTo-Json -Depth 20)
        foreach ($action in $resolvedActions) {
            if ($inPE -and !$action.WorksInPE) { throw "$($action.Name) does not support Windows PE." }
            if ($action.RequiresAdmin -and !$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw "$($action.Name) requires administrator privileges. Nothing was run." }
            if ($action.Kind -eq 'Plugin' -and !(Test-Path -LiteralPath (Join-Path "$AtomRoot/Plugins" $action.PluginFile))) { throw "Plugin missing: $($action.PluginFile)" }
        }
        foreach ($step in $steps) {
            if ($State.StopRequested -or $run.Status -in 'Failed','NeedsAttention') { $step.Status='Skipped'; continue }
            $step.Status='Running'
            $step.StartedUtc=[datetime]::UtcNow.ToString('o')
            $State.Summary = ($steps | ForEach-Object { "$($_.Status) - $($_.Name)" }) -join "`r`n"
            Write-AtomFileAtomic -Path $ResultPath -Content ($run | ConvertTo-Json -Depth 20)
            try {
                $actionLogDirectory = Join-Path (Split-Path $ResultPath) ([guid]::NewGuid().ToString('N'))
                $result=Invoke-AtomWorkflowAction -Action $resolvedActions[[array]::IndexOf($steps, $step)] -AtomRoot $AtomRoot -LogDirectory $actionLogDirectory -State $State
                $step.Data=$result
                $step.Summary=$result.Summary
                $step.Status=$result.Status
                if ($result.Status -in 'Failed','NeedsAttention') { $run.Status=$result.Status }
            } catch {
                $step.Status='Failed'; $step.Summary=$_.Exception.Message; $run.Status='Failed'
            }
            $step.FinishedUtc=[datetime]::UtcNow.ToString('o')
            Write-AtomFileAtomic -Path $ResultPath -Content ($run | ConvertTo-Json -Depth 20)
        }
        if ($run.Status -notin 'Failed','NeedsAttention') { $run.Status=if (@($steps | Where-Object Status -eq 'Skipped').Count) {'Stopped'} else {'Succeeded'} }
    } catch {
        $run.Status = 'Failed'
        $run.Error = $_.Exception.Message
        foreach ($step in $steps) {
            if ($step.Status -eq 'Running') { $step.Status='Failed'; $step.Summary=$_.Exception.Message; $step.FinishedUtc=[datetime]::UtcNow.ToString('o') }
            elseif ($step.Status -eq 'Pending') { $step.Status='Skipped' }
        }
        throw
    } finally {
        $run.FinishedUtc=[datetime]::UtcNow.ToString('o')
        $State.Summary = ($steps | ForEach-Object { "$($_.Status) - $($_.Name)`r`n$($_.Summary)" }) -join "`r`n"
        Write-AtomFileAtomic -Path $ResultPath -Content ($run | ConvertTo-Json -Depth 20)
    }
    $run.Status
}

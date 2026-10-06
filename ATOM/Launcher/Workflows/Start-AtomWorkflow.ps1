function Start-AtomWorkflow {
    <# .SYNOPSIS
        Starts a workflow worker and observes completion without blocking WPF.
    #>
    if ($script:workflowWorker -or !$script:workflowQueue.Count) { return }
    $script:workflowState = [hashtable]::Synchronized(@{ StopRequested=$false; CanStopScan=$false; Summary='Starting...' })
    try {
        $root = Get-AtomWorkflowLogRoot
        do {
            $suffix = -join (1..4 | ForEach-Object { 'abcdefghijklmnopqrstuvwxyz0123456789'[(Get-Random -Maximum 36)] })
            $name = '{0:yyyy-MM-dd_HH-mm-ss}_{1}' -f [datetime]::UtcNow, $suffix
            $directory = Join-Path $root $name
        } while ((Test-Path -LiteralPath $directory) -or (Test-Path -LiteralPath ($directory + '.zip')))
        $script:workflowResultPath = Join-Path $directory 'results.json'
    }
    catch { $window.FindName('workflowStatus').Text=$_.Exception.Message; return }
    $script:workflowWorker = [powershell]::Create()
    $null = $script:workflowWorker.AddScript({
        param($loader,$ids,$state,$resultPath,$root,$presetName,$continueOnFailure)
        $ErrorActionPreference='Stop'
        . $loader -Function Invoke-AtomWorkflow
        Invoke-AtomWorkflow -Entries $ids -State $state -ResultPath $resultPath -AtomRoot $root -PresetName $presetName -ContinueOnFailure:$continueOnFailure
    }).AddArgument("$atomPath/Functions/Import-Atom.ps1").AddArgument([object[]]@($script:workflowQueue | ForEach-Object { @{ActionId=$_.ActionId;OptionId=$_.OptionId} })).AddArgument($script:workflowState).AddArgument($script:workflowResultPath).AddArgument($atomPath).AddArgument($script:workflowPresetName).AddArgument([bool]$script:workflowContinueOnFailure)
    try { $script:workflowHandle = $script:workflowWorker.BeginInvoke() }
    catch { $script:workflowWorker.Dispose(); $script:workflowWorker=$null; $window.FindName('workflowStatus').Text=$_.Exception.Message; return }
    foreach ($name in 'workflowLibrary','workflowEdit','workflowRun','workflowClear') { $window.FindName($name).IsEnabled=$false }
    $script:workflowTimer = [Windows.Threading.DispatcherTimer]::new()
    $script:workflowTimer.Interval = [timespan]::FromMilliseconds(200)
    $script:workflowTimer.Add_Tick({
        $stopButton = $window.FindName('workflowStopScan')
        $stopButton.Visibility = if ($script:workflowState.CanStopScan) { 'Visible' } else { 'Collapsed' }
        $stopButton.IsEnabled = $script:workflowState.CanStopScan -and !$script:workflowState.StopRequested
        if (!$script:workflowHandle.IsCompleted) { return }
        $script:workflowTimer.Stop()
        try {
            $outcome = $script:workflowWorker.EndInvoke($script:workflowHandle)
            if ($script:workflowWorker.HadErrors) { throw $script:workflowWorker.Streams.Error[0] }
            $window.FindName('workflowStatus').Text = "$outcome - see Workflow logs for results."
        } catch { $window.FindName('workflowStatus').Text = "Workflow failed: $($_.Exception.Message)" }
        finally {
            $window.FindName('workflowStopScan').Visibility='Collapsed'
            $script:workflowWorker.Dispose(); $script:workflowWorker=$null
            foreach ($name in 'workflowLibrary','workflowEdit','workflowRun','workflowClear') { $window.FindName($name).IsEnabled=$true }
        }
    })
    $window.FindName('workflowStatus').Text='Running...'
    $script:workflowTimer.Start()
    Show-AtomWorkflowLogWindow -SelectPath $script:workflowResultPath
}

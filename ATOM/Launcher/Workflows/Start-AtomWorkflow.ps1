function Start-AtomWorkflow {
    <# .SYNOPSIS
        Starts a workflow worker and observes completion without blocking WPF.
    #>
    if ($script:workflowWorker -or !$script:workflowQueue.Count) { return }
    $script:workflowState = [hashtable]::Synchronized(@{ StopRequested=$false; Summary='Starting...' })
    $script:workflowResultPath = Join-Path $logsPath ("Workflows/{0}/results.json" -f [guid]::NewGuid().ToString('N'))
    $script:workflowWorker = [powershell]::Create()
    $null = $script:workflowWorker.AddScript({
        param($loader,$ids,$state,$resultPath,$root)
        $ErrorActionPreference='Stop'
        . $loader -Function Invoke-AtomWorkflow
        Invoke-AtomWorkflow -ActionIds $ids -State $state -ResultPath $resultPath -AtomRoot $root
    }).AddArgument("$atomPath/Functions/Import-Atom.ps1").AddArgument([string[]]@($script:workflowQueue | ForEach-Object {$_.ActionId})).AddArgument($script:workflowState).AddArgument($script:workflowResultPath).AddArgument($atomPath)
    try { $script:workflowHandle = $script:workflowWorker.BeginInvoke() }
    catch { $script:workflowWorker.Dispose(); $script:workflowWorker=$null; $window.FindName('workflowStatus').Text=$_.Exception.Message; return }
    foreach ($name in 'workflowLibrary','workflowEdit','workflowRun','workflowClear') { $window.FindName($name).IsEnabled=$false }
    $script:workflowTimer = [Windows.Threading.DispatcherTimer]::new()
    $script:workflowTimer.Interval = [timespan]::FromMilliseconds(200)
    $script:workflowTimer.Add_Tick({
        $window.FindName('workflowResults').Text = $script:workflowState.Summary
        if (!$script:workflowHandle.IsCompleted) { return }
        $script:workflowTimer.Stop()
        try {
            $outcome = $script:workflowWorker.EndInvoke($script:workflowHandle)
            if ($script:workflowWorker.HadErrors) { throw $script:workflowWorker.Streams.Error[0] }
            $window.FindName('workflowStatus').Text = "$outcome - Results: $script:workflowResultPath"
        } catch { $window.FindName('workflowStatus').Text = "Workflow failed: $($_.Exception.Message)" }
        finally {
            $script:workflowWorker.Dispose(); $script:workflowWorker=$null
            foreach ($name in 'workflowLibrary','workflowEdit','workflowRun','workflowClear') { $window.FindName($name).IsEnabled=$true }
        }
    })
    $window.FindName('workflowStatus').Text='Running...'
    $script:workflowTimer.Start()
}

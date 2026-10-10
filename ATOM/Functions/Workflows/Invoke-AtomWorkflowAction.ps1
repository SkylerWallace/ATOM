function Invoke-AtomWorkflowAction {
    <# .SYNOPSIS
        Executes a action using its plugin parameters or built-in command.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][hashtable]$Action, [Parameter(Mandatory)][string]$AtomRoot, [string]$LogDirectory, [hashtable]$State)
    if ($Action.Kind -eq 'Plugin') {
        $parameters=@{} + $Action.Parameters
        if ($Action.SupportsCancellation) { $parameters.ScanState=$State }
        if ($Action.WorkflowLogs) { $parameters.LogDirectory=$LogDirectory }
        $result= & (Join-Path "$AtomRoot/Plugins" $Action.PluginFile) @parameters
        if (!$result -or $result.Status -notin 'Succeeded','Failed','NeedsAttention') { throw 'Plugin did not return a supported workflow result.' }
        return $result
    }
    if ($Action.Kind -ne 'SystemInformation') { throw 'Unsupported action kind.' }
    $os=Get-CimInstance Win32_OperatingSystem -OperationTimeoutSec 30 -ErrorAction Stop
    [pscustomobject]@{Status='Succeeded';ExitCode=$null;Summary="$($os.Caption), build $($os.BuildNumber), $($os.OSArchitecture)";Output=[ordered]@{ComputerName=$os.CSName;Windows=$os.Caption;Version=$os.Version;Build=$os.BuildNumber;Architecture=$os.OSArchitecture;FreeMemoryKB=$os.FreePhysicalMemory}}
}

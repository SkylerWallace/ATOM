function Invoke-AtomAntivirusScan {
    <#
    .SYNOPSIS
        Runs a portable scanner and retains its reports with the workflow result.
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('Emsisoft', 'Stinger')][string]$Scanner,
        [ValidateSet('Quick', 'Deep')][string]$ScanType,
        [string]$Executable,
        [Parameter(Mandatory)][string]$LogDirectory,
        [hashtable]$ScanState
    )

    $ErrorActionPreference = 'Stop'
    if (!$ScanState) { $ScanState = @{ StopRequested=$false } }
    $waitForScanner = {
        param($child)
        $ScanState.CanStopScan = $true
        try {
            while (!$child.WaitForExit(200)) {
                if ($ScanState.StopRequested) {
                    if (!$child.HasExited) { $child.Kill() }
                    $child.WaitForExit()
                    throw [OperationCanceledException]::new('AV scan stopped by the user. Results may be incomplete; review any quarantine changes already made.')
                }
            }
            if ($ScanState.StopRequested) { throw [OperationCanceledException]::new('AV scan stopped by the user.') }
        }
        finally { $ScanState.CanStopScan = $false }
    }
    $result = [ordered]@{
        Status = 'Failed'
        ExitCode = $null
        Summary = ''
        Output = [ordered]@{
            Scanner = $Scanner
            ScanType = $ScanType
            ReportDirectory = $LogDirectory
            QuarantineDirectory = $null
            StartedUtc = [datetime]::UtcNow.ToString('o')
            FinishedUtc = $null
        }
    }

    try {
        if ($ScanState.StopRequested) { throw [OperationCanceledException]::new('AV scan stopped before launch.') }
        $inPE = (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT') -or (Test-Path (Join-Path $env:SystemRoot 'System32\wpeutil.exe'))
        $logRoot = Get-AtomWorkflowLogRoot
        if (!(Test-Path -LiteralPath $Executable -PathType Leaf)) { throw "Scanner missing: $Executable. Download or update it from ATOM's Downloads page first." }
        [void][IO.Directory]::CreateDirectory($LogDirectory)
        $target = [IO.Path]::GetPathRoot($env:SystemRoot)
        if ($inPE) {
            $mounted = (Get-ItemProperty 'HKLM:\SOFTWARE\ATOM' -Name MountedDrive -ErrorAction Stop).MountedDrive
            $target = $mounted + '\'
            if ($ScanType -eq 'Quick') {
                $offlineWindows = (Get-ItemProperty 'HKLM:\RemoteOS-HKLM-SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name SystemRoot -ErrorAction Stop).SystemRoot
                $target = $mounted + $offlineWindows.Substring(2).TrimEnd('\') + '\'
            }
            if (!(Test-Path -LiteralPath $target -PathType Container)) { throw 'Mounted scan target is unavailable.' }
        }
        $result.Output.Target = if ($inPE -or $ScanType -eq 'Deep') { $target } else { 'Live Windows quick scan' }
        $result.Output.Offline = $inPE
        $report = Join-Path $LogDirectory 'scan.log'

        if ($Scanner -eq 'Emsisoft') {
            $update = Start-Process -FilePath $Executable -ArgumentList '/update' -WorkingDirectory (Split-Path $Executable) -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $LogDirectory 'update-output.txt') -RedirectStandardError (Join-Path $LogDirectory 'update-errors.txt')
            try {
                & $waitForScanner $update
                $result.Output.UpdateExitCode = $update.ExitCode
                if ($update.ExitCode -ne 0) {
                    $result.Output.UpdateWarning = "Signature update failed (exit code $($update.ExitCode)); continuing with available definitions. Their freshness could not be verified."
                }
            }
            finally { $update.Dispose() }

            $quarantine = Join-Path (Split-Path (Split-Path $logRoot)) 'Quarantine\Emsisoft'
            [void][IO.Directory]::CreateDirectory($quarantine)
            $result.Output.QuarantineDirectory = $quarantine
            $exclusions = Join-Path $LogDirectory 'exclusions.txt'
            [IO.File]::WriteAllText($exclusions, $quarantine + [Environment]::NewLine)
            [string[]]$arguments = if ($inPE) { @(('/files="{0}."' -f $target), '/archive', '/ntfs') } elseif ($ScanType -eq 'Quick') { @('/quick') } else { @(('/files="{0}."' -f $target), '/memory', '/traces', '/archive', '/ntfs') }
            $arguments += @(('/quarantine="{0}"' -f $quarantine), ('/log="{0}"' -f $report), ('/whitelist="{0}"' -f $exclusions))
        }
        else {
            $result.Output.RemediationMode = 'Repair'
            $arguments = @('--GO', '--SILENT', '--REPAIR', ('--REPORTPATH="{0}"' -f $LogDirectory))
            if ($inPE) { $arguments += @(('--SCANPATH="{0}."' -f $target), '--NOPROCESS', '--NOREGISTRY', '--NOBOOT', '--NOROOTKIT', '--NOWMI') }
            elseif ($ScanType -eq 'Deep') { $arguments += @(('--SCANPATH="{0}."' -f $target), '--ROOTKIT', '--WMI') }
        }

        $process = Start-Process -FilePath $Executable -ArgumentList ($arguments -join ' ') -WorkingDirectory (Split-Path $Executable) -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $LogDirectory 'scan-output.txt') -RedirectStandardError (Join-Path $LogDirectory 'scan-errors.txt')
        try { & $waitForScanner $process; $result.ExitCode = $process.ExitCode }
        finally { $process.Dispose() }

        if ($Scanner -eq 'Emsisoft') {
            if ($result.ExitCode -notin 0,1) { throw "Emsisoft scan failed (exit code $($result.ExitCode)). Review scanner output." }
            if (!(Test-Path -LiteralPath $report -PathType Leaf)) { throw 'Emsisoft did not produce the requested scan report. Review scanner output.' }
            $result.Status = if ($result.ExitCode -eq 0) { 'Succeeded' } else { 'NeedsAttention' }
            $result.Summary = if ($result.ExitCode -eq 0) { 'Scan completed with no infections reported.' } else { 'Detections reported; quarantine was requested. Review the scan report to confirm remediation.' }
        }
        else {
            $result.Status = 'NeedsAttention'
            $result.Summary = "Stinger exited with code $($result.ExitCode). Repair was requested. Review its reports for scan completion, detections, and repair or quarantine results."
        }
    }
    catch [OperationCanceledException] { $result.Status='NeedsAttention'; $result.Output.Cancelled=$true; $result.Summary=$_.Exception.Message }
    catch { $result.Summary = $_.Exception.Message }
    finally {
        $result.Output.FinishedUtc = [datetime]::UtcNow.ToString('o')
        if ($result.Output.UpdateWarning) { $result.Summary += " $($result.Output.UpdateWarning)" }
    }
    [pscustomobject]$result
}

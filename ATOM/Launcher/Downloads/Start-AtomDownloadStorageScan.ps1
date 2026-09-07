function Start-AtomDownloadStorageScan {
    if ($script:downloadStorageScan -and !$script:downloadStorageScan.Done) { return }
    $script:downloadStorageScan = [Hashtable]::Synchronized(@{ Done = $false; Result = $null; Error = $null })
    $destinations = @{}
    foreach ($name in $programs.Keys) {
        if ($programs[$name].ProgramInfo.DestinationPath) { $destinations[$name] = [String]$programs[$name].ProgramInfo.DestinationPath }
    }
    $downloadStorageText.Text = 'Measuring toolkit storage...'
    try {
        Invoke-Runspace -Isolated -InputVariables @{
            Scan = $script:downloadStorageScan; Root = $programsPath; Destinations = $destinations
            FunctionLoader = (Join-Path $functionsPath 'Import-Atom.ps1')
        } -ScriptBlock {
            try {
                . $FunctionLoader -Function Get-AtomDownloadStorage
                $Scan.Result = Get-AtomDownloadStorage -Root $Root -Destinations $Destinations
            } catch { $Scan.Error = $_.Exception.Message }
            finally { $Scan.Done = $true }
        }
        $downloadManagerTimer.Start()
    } catch {
        $script:downloadStorageScan.Done = $true
        $downloadStorageText.Text = 'Unable to measure storage: ' + $_.Exception.Message
    }
}

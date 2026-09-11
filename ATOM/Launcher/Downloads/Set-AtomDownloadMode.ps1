function Set-AtomDownloadMode {
    param (
        [Parameter(Mandatory)]
        [Boolean]$Enabled
    )

    if ($script:downloadMode -eq $Enabled) { return }

    $script:downloadMode = $Enabled
    Clear-AtomSearchTextBox

    if (!$script:downloadMode) { Set-AtomQuip }

    $modeSwitchWatch = [Diagnostics.Stopwatch]::StartNew()
    Update-AtomPluginList
    Write-Verbose ('Download Mode rebuild: {0:N1} ms' -f $modeSwitchWatch.Elapsed.TotalMilliseconds)
}

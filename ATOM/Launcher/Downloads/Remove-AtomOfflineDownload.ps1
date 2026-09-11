function Remove-AtomOfflineDownload {
    param (
        [Parameter(Mandatory)]
        [Object]$Plugin
    )

    if ($script:downloadMode -and !$pluginsButton.IsEnabled) { return }
    $programState = Get-AtomManagedProgramState -Plugin $Plugin
    if (!$programState -or !$programState.IsAvailable) {
        $statusBarStatus.Text = "$($Plugin.Name) is not available offline"
        return
    }

    $confirmation = [Windows.MessageBox]::Show(
        $window,
        "Remove the offline download for $($Plugin.Name)?`n`nThis deletes its portable program files but keeps the ATOM plugin.",
        'Remove Offline Download',
        [Windows.MessageBoxButton]::YesNo,
        [Windows.MessageBoxImage]::Warning
    )
    if ($confirmation -ne [Windows.MessageBoxResult]::Yes) { return }

    try {
        $programDirectory = Get-Item -LiteralPath $programState.DestinationPath -ErrorAction Stop
        if (!$programDirectory.PSIsContainer -or ($programDirectory.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw 'The managed program path is not a removable directory.'
        }

        Remove-Item -LiteralPath $programDirectory.FullName -Recurse -Force -ErrorAction Stop

        try {
            if (!(Get-Command Remove-DownloadRecord -CommandType Function -ErrorAction SilentlyContinue)) {
                . (Join-Path $functionsPath 'Import-Atom.ps1') -Function Remove-DownloadRecord
            }
            Remove-DownloadRecord -Name $Plugin.Name -ErrorAction Stop | Out-Null
        } catch {
            $manifestWarning = "The offline files were removed, but downloads.json could not be updated: $($_.Exception.Message)"
        }

        Update-AtomPluginList
        if ($manifestWarning) {
            $statusBarStatus.Text = 'Offline files removed; download record cleanup failed'
            [void][Windows.MessageBox]::Show($window, $manifestWarning, 'Remove Offline Download', 'OK', 'Warning')
        } else {
            $statusBarStatus.Text = "Removed offline download for $($Plugin.Name)"
        }
    } catch {
        $message = "Unable to remove the offline download for $($Plugin.Name): $($_.Exception.Message)"
        $statusBarStatus.Text = $message
        [void][Windows.MessageBox]::Show($window, $message, 'Remove Offline Download', 'OK', 'Error')
    }
}

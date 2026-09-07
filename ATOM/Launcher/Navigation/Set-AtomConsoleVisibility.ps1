function Set-AtomConsoleVisibility {
    param (
        [Boolean]$Visible
    )

    $windowStyle = if ($Visible) { 'Normal' } else { 'Hidden' }
    $processIds = @($PID) + @(Get-CimInstance Win32_Process -Filter "ParentProcessId = $PID" |
        Where-Object Name -in 'powershell.exe', 'pwsh.exe', 'cmd.exe' |
        Select-Object -ExpandProperty ProcessId)

    $processIds | Set-WindowStyle -WindowStyle $windowStyle
}

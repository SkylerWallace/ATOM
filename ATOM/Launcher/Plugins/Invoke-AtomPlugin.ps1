function Invoke-AtomPlugin {
    param (
        [Parameter(Mandatory)]
        [Object]$Plugin
    )

    $launchParams = @{}
    foreach ($parameter in $Plugin.LaunchParams.GetEnumerator()) {
        $launchParams[$parameter.Key] = $parameter.Value
    }
    $launchParams.WindowStyle =
        if ($programs[$Plugin.Name].Silent -and !$atomSettings.EnableDebugMode.Value) { 'Hidden' }
        else { 'Normal' }

    $isAdministrator = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($Plugin.Config.RequiresAdmin -ne $false -and !$isAdministrator) { $launchParams.Verb = 'RunAs' }
    try {
        Start-Process @launchParams -ErrorAction Stop
        $statusBarStatus.Text = "Running $($Plugin.Name)"
    } catch {
        $statusBarStatus.Text = "Unable to launch $($Plugin.Name): $($_.Exception.Message)"
    }
}

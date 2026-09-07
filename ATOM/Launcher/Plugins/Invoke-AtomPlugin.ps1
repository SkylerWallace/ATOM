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

    Start-Process @launchParams
    $statusBarStatus.Text = "Running $($Plugin.Name)"
}

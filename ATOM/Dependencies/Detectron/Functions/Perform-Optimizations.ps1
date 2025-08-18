function Perform-Optimizations {
    $scriptPaths = $selectedScripts -split ";"
    foreach ($scriptPath in $scriptPaths) {
        if ([string]::IsNullOrWhiteSpace($scriptPath)) { continue }
        . $scriptPath
    }
}
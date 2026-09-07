function Test-AtomDownloadFilter {
    param ([String]$Filter, [Bool]$Downloaded, [Bool]$UpdateAvailable, [String]$Status)
    switch ($Filter) {
        'Downloaded' { return $Downloaded }
        'Not downloaded' { return !$Downloaded }
        'Updates available' { return $UpdateAvailable }
        'Failed' { return $Status -in 'Failed', 'Blocked' }
        default { return $true }
    }
}

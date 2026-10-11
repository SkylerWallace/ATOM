function Set-WindowSize {
    $effectiveVertRes = [Windows.SystemParameters]::PrimaryScreenHeight
    if ($effectiveVertRes -le (1.0 * $window.MaxHeight)) {
        $window.MinHeight = 0.6 * $effectiveVertRes
        $window.MaxHeight = 0.9 * $effectiveVertRes
    }
}

function Get-VectorIconGeometry {
    <#
    .SYNOPSIS
        Resolves an icon's artwork variant from the window's resources.
    .DESCRIPTION
        Filled icons prefer the filled optical-size variant, then filled artwork,
        then outline artwork. Outline icons prefer the requested optical-size
        variant before the base icon. Missing variants fall back; missing icons throw.
    .PARAMETER TargetWindow
        Window supplying Icons/Common.xaml resources. Window is an alias; when
        omitted, the caller's $window is used.
    #>
    param (
        [Alias('Window')]
        [System.Windows.Window]$TargetWindow,

        [Parameter(Mandatory)]
        [String]$Icon,

        [ValidateSet(20, 24)]
        [Int]$OpticalSize = 24,

        [Switch]$Filled
    )

    if (!$TargetWindow) { $TargetWindow = $window }
    if (!$TargetWindow) { throw 'A WPF Window must be supplied with -Window.' }

    $resourceKeys = if ($Filled) {
        if ($OpticalSize -eq 20) {
            @(($Icon + '20Filled'), ($Icon + 'Filled'), ($Icon + '20'), $Icon)
        } else {
            @(($Icon + 'Filled'), $Icon)
        }
    } elseif ($OpticalSize -eq 20) {
        @(($Icon + '20'), $Icon)
    } else {
        @($Icon)
    }

    foreach ($resourceKey in $resourceKeys) {
        $geometry = $TargetWindow.Resources[$resourceKey]
        if ($geometry -is [System.Windows.Media.Geometry]) { return $geometry }
    }

    throw "Vector icon '$($resourceKeys[0])' was not found."
}

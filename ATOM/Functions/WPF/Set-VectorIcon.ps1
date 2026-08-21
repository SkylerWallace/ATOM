function Get-VectorIconGeometry {
    param (
        [Alias('Window')][System.Windows.Window]$TargetWindow,
        [Parameter(Mandatory)][String]$Icon,
        [ValidateSet(20, 24)][Int]$OpticalSize = 24,
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

function New-VectorIcon {
    param (
        [Alias('Window')][System.Windows.Window]$TargetWindow,
        [Parameter(Mandatory)][String]$Icon,
        [String]$ForegroundResource = 'surfaceText',
        [Double]$Size = 16,
        [ValidateSet(20, 24)][Int]$OpticalSize = 24,
        [Switch]$Filled
    )

    if (!$TargetWindow) { $TargetWindow = $window }
    if (!$TargetWindow) { throw 'A WPF Window must be supplied with -Window.' }

    $control = [System.Windows.Controls.ContentControl]::new()
    $control.Width = $Size
    $control.Height = $Size
    $control.Style = $TargetWindow.Resources['VectorIconStyle']
    $control.Content = Get-VectorIconGeometry -Window $TargetWindow -Icon $Icon -OpticalSize $OpticalSize -Filled:$Filled
    $control.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, $ForegroundResource)
    return $control
}

function Set-VectorIcon {
    param (
        [Alias('Window')][System.Windows.Window]$TargetWindow,
        [String]$ForegroundResource = 'surfaceText',
        [Parameter(Mandatory)][Hashtable]$ResourceMappings,
        [ValidateSet(20, 24)][Int]$OpticalSize = 24,
        [Switch]$Filled
    )

    if (!$TargetWindow) { $TargetWindow = $window }
    if (!$TargetWindow) { throw 'A WPF Window must be supplied with -Window.' }

    foreach ($entry in $ResourceMappings.GetEnumerator()) {
        $resource = $TargetWindow.FindName($entry.Key)
        if (!$resource) { throw "Vector icon target '$($entry.Key)' was not found." }

        if ($resource -is [System.Windows.Controls.Button]) {
            $icon = $resource.Content
            if ($icon -isnot [System.Windows.Controls.ContentControl]) {
                $resource.Content = New-VectorIcon -Window $TargetWindow -Icon $entry.Value -ForegroundResource $ForegroundResource -OpticalSize $OpticalSize -Filled:$Filled
                continue
            }
        } elseif ($resource -is [System.Windows.Controls.ContentControl]) {
            $icon = $resource
        } else {
            throw "'$($entry.Key)' does not support vector icon content."
        }

        $icon.Style = $TargetWindow.Resources['VectorIconStyle']
        $icon.Content = Get-VectorIconGeometry -Window $TargetWindow -Icon $entry.Value -OpticalSize $OpticalSize -Filled:$Filled
        $icon.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, $ForegroundResource)
    }
}

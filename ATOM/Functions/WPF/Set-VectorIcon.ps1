function Get-VectorIconGeometry {
    param (
        [Parameter(Mandatory)][String]$Icon,
        [ValidateSet(20, 24)][Int]$OpticalSize = 24,
        [Switch]$Filled
    )

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
        $geometry = $window.Resources[$resourceKey]
        if ($geometry -is [System.Windows.Media.Geometry]) { return $geometry }
    }

    throw "Vector icon '$($resourceKeys[0])' was not found."
}

function New-VectorIcon {
    param (
        [Parameter(Mandatory)][String]$Icon,
        [String]$ForegroundResource = 'surfaceText',
        [Double]$Size = 16,
        [ValidateSet(20, 24)][Int]$OpticalSize = 24,
        [Switch]$Filled
    )

    $control = [System.Windows.Controls.ContentControl]::new()
    $control.Width = $Size
    $control.Height = $Size
    $control.Style = $window.Resources['VectorIconStyle']
    $control.Content = Get-VectorIconGeometry -Icon $Icon -OpticalSize $OpticalSize -Filled:$Filled
    $control.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, $ForegroundResource)
    return $control
}

function Set-VectorIcon {
    param (
        [String]$ForegroundResource = 'surfaceText',
        [Parameter(Mandatory)][Hashtable]$ResourceMappings,
        [ValidateSet(20, 24)][Int]$OpticalSize = 24,
        [Switch]$Filled
    )

    foreach ($entry in $ResourceMappings.GetEnumerator()) {
        $resource = $window.FindName($entry.Key)
        if (!$resource) { throw "Vector icon target '$($entry.Key)' was not found." }

        if ($resource -is [System.Windows.Controls.Button]) {
            $icon = $resource.Content
            if ($icon -isnot [System.Windows.Controls.ContentControl]) {
                $resource.Content = New-VectorIcon -Icon $entry.Value -ForegroundResource $ForegroundResource -OpticalSize $OpticalSize -Filled:$Filled
                continue
            }
        } elseif ($resource -is [System.Windows.Controls.ContentControl]) {
            $icon = $resource
        } else {
            throw "'$($entry.Key)' does not support vector icon content."
        }

        $icon.Style = $window.Resources['VectorIconStyle']
        $icon.Content = Get-VectorIconGeometry -Icon $entry.Value -OpticalSize $OpticalSize -Filled:$Filled
        $icon.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, $ForegroundResource)
    }
}
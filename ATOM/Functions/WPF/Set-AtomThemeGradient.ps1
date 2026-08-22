function Set-AtomThemeGradient {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Windows.Window]$Window,

        [Parameter(Mandatory)]
        [Collections.IDictionary]$Theme,

        [Parameter(Mandatory)]
        [Collections.IDictionary]$Defaults
    )

    $getSetting = {
        param ([String]$Name)

        if ($Theme.Contains($Name)) { $Theme[$Name] }
        else { $Defaults[$Name] }
    }

    $style = [String](& $getSetting 'gradientStyle')
    if ($style -notin 'Radial', 'Linear', 'None') {
        throw "Unsupported theme gradientStyle '$style'. Use Radial, Linear, or None."
    }
    $interpolation = [String](& $getSetting 'gradientInterpolation')
    if ($interpolation -notin 'ScRgb', 'SRgb') {
        throw "Unsupported theme gradientInterpolation '$interpolation'. Use ScRgb or SRgb."
    }

    $surfaceStart = [Windows.Media.Color]$Window.FindResource('surfaceGrad0')
    $surfaceMiddle = [Windows.Media.Color]$Window.FindResource('surfaceColor')
    $surfaceEnd = [Windows.Media.Color]$Window.FindResource('surfaceGrad1')
    $themeStrength = [Double]$Theme.gradientStrength

    $newBrush = {
        param ([ValidateSet('panel', 'list')][String]$Area)

        if ($style -eq 'None') {
            return $Window.FindResource('surfaceBrush')
        }

        $midpoint = [Double](& $getSetting ($Area + 'GradientMidpoint'))
        if ($midpoint -lt 0 -or $midpoint -gt 1) {
            throw "$Area gradient midpoint must be between 0 and 1."
        }

        if ($style -eq 'Linear') {
            $brush = [Windows.Media.LinearGradientBrush]::new()
            $brush.StartPoint = [Windows.Point]::Parse([String](& $getSetting 'linearGradientStart'))
            $brush.EndPoint = [Windows.Point]::Parse([String](& $getSetting 'linearGradientEnd'))
        } else {
            $radiusX = & $getSetting ($Area + 'GradientRadiusX')
            $radiusY = & $getSetting ($Area + 'GradientRadiusY')
            if ($null -eq $radiusX) { $radiusX = $themeStrength }
            if ($null -eq $radiusY) { $radiusY = $themeStrength }

            $brush = [Windows.Media.RadialGradientBrush]::new()
            $brush.Center = [Windows.Point]::Parse([String](& $getSetting ($Area + 'GradientCenter')))
            $brush.GradientOrigin = [Windows.Point]::Parse([String](& $getSetting ($Area + 'GradientOrigin')))
            $brush.RadiusX = [Double]$radiusX
            $brush.RadiusY = [Double]$radiusY
        }

        $interpolationMode = $interpolation + 'LinearInterpolation'
        $brush.ColorInterpolationMode = [Enum]::Parse([Windows.Media.ColorInterpolationMode], $interpolationMode)
        $brush.GradientStops.Add([Windows.Media.GradientStop]::new($surfaceStart, 0))
        if ($midpoint -gt 0 -and $midpoint -lt 1) {
            $brush.GradientStops.Add([Windows.Media.GradientStop]::new($surfaceMiddle, $midpoint))
        }
        $brush.GradientStops.Add([Windows.Media.GradientStop]::new($surfaceEnd, 1))
        return $brush
    }

    $Window.Resources['surfacePanelBrush'] = & $newBrush panel
    $Window.Resources['surfaceListBrush'] = & $newBrush list
}
function Set-AtomThemeGraphic {
    <#
    .SYNOPSIS
        Applies optional, static title-bar artwork without affecting layout or input.
    .DESCRIPTION
        Themes opt in with titleBarGraphic, titleBarGraphicColor and titleBarGraphicOpacity.
        Artwork lives in Resources/ThemeGraphics.psd1, loaded on first use. The selected
        geometry is parsed once per window; brushes are frozen. Missing
        or unknown graphics clear the decoration when switching themes.
    #>
    param (
        [Parameter(Mandatory)][System.Windows.Window]$Window,
        [Collections.IDictionary]$Theme,
        [bool]$Enabled = $true,
        [string]$Selection = 'Automatic'
    )

    $hostBorder = $Window.FindName('atomTitleBarGraphic')
    if (!$hostBorder) { return }
    $hostBorder.Background = $null
    $hostBorder.Visibility = 'Collapsed'
    if (!$Enabled -or !$Theme -or $Selection -eq 'Disabled') { return }
    $graphicName = if (!$Selection -or $Selection -eq 'Automatic') { $Theme['titleBarGraphic'] } else { $Selection }
    if (!$graphicName) { return }

    $libraryKey = 'Atom.TitleBarGraphic.Library'
    $library = $Window.Resources[$libraryKey]
    if (!$library) {
        $library = Import-PowerShellDataFile -LiteralPath (Join-Path $resourcesPath 'ThemeGraphics.psd1')
        $Window.Resources[$libraryKey] = $library
    }
    $graphic = $library[$graphicName]
    if (!$graphic) { return }

    $geometryKey = 'Atom.{0}Graphic.Geometry' -f $graphicName
    $geometry = $Window.Resources[$geometryKey]
    if (!$geometry) {
        $geometry = [Windows.Media.Geometry]::Parse($graphic.Geometry)
        $geometry.Freeze()
        $Window.Resources[$geometryKey] = $geometry
    }
    $color = if ($Theme.Contains('titleBarGraphicColor')) { $Theme['titleBarGraphicColor'] } else { $Theme['primaryText'] }
    $ink = [Windows.Media.SolidColorBrush]::new([Windows.Media.ColorConverter]::ConvertFromString($color))
    $pen = [Windows.Media.Pen]::new($ink, [double]$graphic.StrokeThickness)
    $drawing = [Windows.Media.DrawingGroup]::new()
    # Transparent bounds keep the artwork at its authored size, including empty space.
    $bounds = [Windows.Media.RectangleGeometry]::new([Windows.Rect]::new(0, 0, $graphic.Width, $graphic.Height))
    # Crop oversized artwork to its authored canvas instead of letting its bounds
    # recenter the brush. This supports intentionally off-frame compositions.
    $drawing.ClipGeometry = $bounds
    $drawing.Children.Add([Windows.Media.GeometryDrawing]::new([Windows.Media.Brushes]::Transparent, $null, $bounds))
    $drawing.Children.Add([Windows.Media.GeometryDrawing]::new($null, $pen, $geometry))
    $brush = [Windows.Media.DrawingBrush]::new($drawing)
    $brush.Stretch = 'None'
    $brush.AlignmentX = 'Right'
    $brush.AlignmentY = 'Center'
    $brush.Freeze()
    $hostBorder.Background = $brush
    $hostBorder.Opacity = if ($Theme.Contains('titleBarGraphicOpacity')) { [Math]::Max(0.0, [Math]::Min(1.0, [double]$Theme['titleBarGraphicOpacity'])) } else { 0.20 }
    $hostBorder.Visibility = 'Visible'
}

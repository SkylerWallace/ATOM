function New-VectorIcon {
    <#
    .SYNOPSIS
        Creates a themed ContentControl containing a vector icon.
    .PARAMETER TargetWindow
        Window supplying icon and theme resources. Window is an alias; when
        omitted, the caller's $window is used.
    .PARAMETER Size
        Rendered width and height in WPF units, independent of OpticalSize.
    .PARAMETER OpticalSize
        Preferred artwork variant. Get-VectorIconGeometry resolves fallbacks.
    .PARAMETER ForegroundResource
        Theme brush resource used for the icon's color.
    #>
    param (
        [Alias('Window')]
        [System.Windows.Window]$TargetWindow,

        [Parameter(Mandatory)]
        [String]$Icon,

        [String]$ForegroundResource = 'surfaceText',

        [Double]$Size = 16,

        [ValidateSet(20, 24)]
        [Int]$OpticalSize = 24,

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

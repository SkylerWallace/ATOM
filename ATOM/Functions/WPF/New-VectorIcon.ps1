function New-VectorIcon {
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

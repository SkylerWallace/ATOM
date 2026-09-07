function Set-VectorIcon {
    param (
        [Alias('Window')]
        [System.Windows.Window]$TargetWindow,

        [String]$ForegroundResource = 'surfaceText',

        [Parameter(Mandatory)]
        [Hashtable]$ResourceMappings,

        [ValidateSet(20, 24)]
        [Int]$OpticalSize = 24,

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

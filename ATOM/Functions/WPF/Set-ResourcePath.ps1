function Set-ResourcePath {
    param (
        [String]$path = "$psScriptRoot\..\..\Resources\Icons\Common",
        [String]$colorRole,
        [Hashtable]$resourceMappings
    )

    $colorMode = switch ($colorRole) {
        "Primary"    { $primaryIcons }
        "Background" { $backgroundIcons }
        "Surface"    { $surfaceIcons }
        "Accent"     { $accentIcons }
        default      { $surfaceIcons }
    }

    $resourceMappings.Keys | ForEach-Object {
        $name = $_
        $resource = $window.FindName($_)

        $uri = New-Object System.Uri "$path\$($resourceMappings.$_) ($colorMode).png"
        $img = New-Object System.Windows.Media.Imaging.BitmapImage $uri

        switch ($resource) {
            {$resource -is [System.Windows.Controls.Button]} { $resource.Content = New-Object System.Windows.Controls.Image -Property @{ Source = $img } }
            {$resource -is [System.Windows.Controls.Image]} { $resource.Source = $img }
            default { $window.Resources.Add($name , $img) }
        }
    }
}
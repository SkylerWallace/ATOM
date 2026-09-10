function Set-AtomTheme {
    param([Collections.IDictionary]$Theme)
        # Update variables
        foreach ($key in $Theme.Keys) {
            New-Variable -Name $key -Value $Theme.$key -Scope Script -Force
        }
        $controlBrush = if ($Theme.Contains('controlBrush')) { $Theme.controlBrush } else { $Theme.primaryBrush }
        New-Variable -Name controlBrush -Value $controlBrush -Scope Script -Force
        $controlText = if ($Theme.Contains('controlText')) { $Theme.controlText } else { $Theme.primaryText }
        New-Variable -Name controlText -Value $controlText -Scope Script -Force
        Get-AtomThemeShadowResources -Theme $Theme -Defaults $themeShadowDefaults | ForEach-Object {
            $_.GetEnumerator() | ForEach-Object {
                New-Variable -Name $_.Key -Value $_.Value -Scope Script -Force
            }
        }

        # Update resources dynamically based on their type
        foreach ($resName in $window.Resources.Keys) {
            # Check if the resource key matches a global variable
            if (Get-Variable -Name $resName -Scope Script -ErrorAction SilentlyContinue) {
                $globalValue = (Get-Variable -Name $resName -Scope Script).Value

                # Determine the type of the resource and update accordingly
                $resource = $window.Resources[$resName]
                if ($resource -is [System.Windows.Media.SolidColorBrush]) {
                    $window.Resources[$resName] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString($globalValue))
                } elseif ($resource -is [System.Windows.Media.Color]) {
                    $window.Resources[$resName] = [System.Windows.Media.ColorConverter]::ConvertFromString($globalValue)
                } elseif ($resource -is [Double]) {
                    $window.Resources[$resName] = [Double]$globalValue
                }
            }
        }

        $window.Resources["gradientStrength"] = $gradientStrength
        Set-AtomThemeGradient -Window $window -Theme $Theme -Defaults $themeGradientDefaults
        Set-AtomThemeGraphic -Window $window -Theme $Theme -Selection $script:atomSettings.ThemeGraphic.Value

        Update-AtomThemeSelector
}

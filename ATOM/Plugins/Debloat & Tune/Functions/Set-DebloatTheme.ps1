function Set-DebloatTheme {
    param([bool]$Dark)

    function Set-ThemeValue {
        param([string]$Text, [string]$Section, [string]$Name, [string]$Value)
        $lines = [Collections.Generic.List[string]]::new()
        $lines.AddRange([string[]]($Text -split '\r?\n'))
        $start = -1
        $end = $lines.Count
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i].Trim() -ieq "[$Section]") { $start = $i; continue }
            if ($start -ge 0 -and $lines[$i].Trim().StartsWith('[')) { $end = $i; break }
        }
        if ($start -lt 0) { $lines.Add("[$Section]"); $lines.Add("$Name=$Value") }
        else {
            $found = $false
            for ($i = $end - 1; $i -gt $start; $i--) {
                if ($lines[$i] -match ('^\s*' + [regex]::Escape($Name) + '\s*=')) {
                    if (!$found) { $lines[$i] = "$Name=$Value"; $found = $true }
                    else { $lines.RemoveAt($i) }
                }
            }
            if (!$found) { $lines.Insert($end, "$Name=$Value") }
        }
        [string]::Join([Environment]::NewLine, $lines)
    }

    if ([Windows.SystemParameters]::HighContrast) { throw 'Turn off high contrast before changing light/dark mode.' }
    $sourcePath = [Microsoft.Win32.Registry]::GetValue('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes', 'CurrentTheme', $null)
    if (!$sourcePath -or !(Test-Path -LiteralPath $sourcePath)) { throw 'The current Windows theme file could not be found.' }
    $text = [IO.File]::ReadAllText($sourcePath, [Text.Encoding]::Default)
    $mode = if ($Dark) { 'Dark' } else { 'Light' }
    $text = Set-ThemeValue $text 'VisualStyles' 'SystemMode' $mode
    $text = Set-ThemeValue $text 'VisualStyles' 'AppMode' $mode
    $text = Set-ThemeValue $text 'Theme' 'DisplayName' 'ATOM appearance'
    $text = Set-ThemeValue $text 'Theme' 'ThemeId' ([Guid]::NewGuid().ToString('B'))

    # The saved theme can lag behind live accent preferences.
    $dwmPath = 'HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM'
    $accent = [Microsoft.Win32.Registry]::GetValue($dwmPath, 'ColorizationColor', $null)
    if ($null -ne $accent) {
        $color = [BitConverter]::ToUInt32([BitConverter]::GetBytes([int]$accent), 0)
        $text = Set-ThemeValue $text 'VisualStyles' 'ColorizationColor' ('0x{0:X8}' -f $color)
    }
    $automaticAccent = [Microsoft.Win32.Registry]::GetValue($dwmPath, 'AutoColorization', $null)
    if ($null -ne $automaticAccent) { $text = Set-ThemeValue $text 'VisualStyles' 'AutoColorization' ([string]$automaticAccent) }

    if (-not ('Atom.DebloatThemeManager' -as [type])) { Add-Type -Path (Join-Path $PSScriptRoot 'DebloatThemeManager.cs') -ErrorAction Stop }
    $themeDirectory = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Microsoft\Windows\Themes'
    [void][IO.Directory]::CreateDirectory($themeDirectory)
    $themePath = Join-Path $themeDirectory 'ATOM-appearance.theme'
    [IO.File]::WriteAllText($themePath, $text, [Text.Encoding]::Unicode)
    [Atom.DebloatThemeManager]::Apply($themePath)
}

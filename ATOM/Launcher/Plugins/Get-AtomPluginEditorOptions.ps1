function Get-AtomPluginEditorOptions {
    $options = [ordered]@{ 'Notepad' = 'notepad.exe' }
    $editorCandidates = [ordered]@{
        'Visual Studio Code' = @(
            "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
            "$env:ProgramFiles\Microsoft VS Code\Code.exe"
            "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
        )
        'Notepad++' = @(
            "$env:ProgramFiles\Notepad++\notepad++.exe"
            "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe"
        )
    }

    $pathDirectories = @($env:PATH -split [IO.Path]::PathSeparator | Where-Object { ![String]::IsNullOrWhiteSpace($_) })
    foreach ($editor in $editorCandidates.GetEnumerator()) {
        $editorPath = @($editor.Value | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } | Select-Object -First 1)[0]
        if (!$editorPath) {
            # Exact executable probes avoid slow PowerShell command discovery.
            $fileName = [IO.Path]::GetFileName($editor.Value[0])
            foreach ($directory in $pathDirectories) {
                $candidate = [IO.Path]::Combine([Environment]::ExpandEnvironmentVariables($directory.Trim().Trim('"')), $fileName)
                if (![IO.Path]::IsPathRooted($candidate)) { $candidate = [IO.Path]::Combine($PWD.ProviderPath, $candidate) }
                if ([IO.File]::Exists($candidate)) { $editorPath = [IO.Path]::GetFullPath($candidate); break }
            }
        }
        if ($editorPath) { $options[$editor.Key] = $editorPath }
    }

    $configuredEditor = [String]$script:atomSettings.PluginEditor.Value
    if ($configuredEditor -ne 'notepad.exe' -and $options.Values -notcontains $configuredEditor) {
        $options[[IO.Path]::GetFileNameWithoutExtension($configuredEditor)] = $configuredEditor
    }
    $options['Choose application...'] = '__choose__'

    return $options
}

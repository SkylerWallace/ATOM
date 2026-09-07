function Get-AtomPluginEditorOptions {
    $options = [ordered]@{ 'Notepad' = 'notepad.exe' }
    $editorCandidates = [ordered]@{
        'Visual Studio Code' = @(
            "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
            "$env:ProgramFiles\Microsoft VS Code\Code.exe"
            "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
            (Get-Command 'code.exe' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source)
        )
        'Notepad++' = @(
            "$env:ProgramFiles\Notepad++\notepad++.exe"
            "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe"
            (Get-Command 'notepad++.exe' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source)
        )
    }

    foreach ($editor in $editorCandidates.GetEnumerator()) {
        $editorPath = @($editor.Value | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } | Select-Object -First 1)[0]
        if ($editorPath) { $options[$editor.Key] = $editorPath }
    }

    $configuredEditor = [String]$script:atomSettings.PluginEditor.Value
    if ($configuredEditor -ne 'notepad.exe' -and $options.Values -notcontains $configuredEditor) {
        $options[[IO.Path]::GetFileNameWithoutExtension($configuredEditor)] = $configuredEditor
    }
    $options['Choose application...'] = '__choose__'

    return $options
}

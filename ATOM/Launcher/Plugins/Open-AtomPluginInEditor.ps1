function Open-AtomPluginInEditor {
    param (
        [Parameter(Mandatory)]
        [Object]$Plugin
    )

    if (!$Plugin.FullName -or [IO.Path]::GetExtension($Plugin.FullName) -notin '.ps1', '.bat', '.cmd') { return }

    $configuredEditor = [String]$script:atomSettings.PluginEditor.Value
    $editorPath = if (
        $configuredEditor -eq 'notepad.exe' -or
        (Test-Path -LiteralPath $configuredEditor -PathType Leaf)
    ) { $configuredEditor } else { 'notepad.exe' }

    Start-Process -FilePath $editorPath -ArgumentList ('"{0}"' -f $Plugin.FullName)
}

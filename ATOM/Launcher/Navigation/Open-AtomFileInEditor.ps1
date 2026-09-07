function Open-AtomFileInEditor {
    <#
    .SYNOPSIS
        Opens a local file using the configured plugin editor.
    #>
    param ([Parameter(Mandatory)][String]$Path)

    $configuredEditor = [String]$script:atomSettings.PluginEditor.Value
    $editorPath = if (
        $configuredEditor -eq 'notepad.exe' -or
        (Test-Path -LiteralPath $configuredEditor -PathType Leaf)
    ) { $configuredEditor } else { 'notepad.exe' }

    Start-Process -FilePath $editorPath -ArgumentList ('"{0}"' -f $Path)
}

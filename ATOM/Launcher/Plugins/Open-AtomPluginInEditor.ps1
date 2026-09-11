function Open-AtomPluginInEditor {
    param (
        [Parameter(Mandatory)]
        [Object]$Plugin
    )

    if (!$Plugin.FullName -or [IO.Path]::GetExtension($Plugin.FullName) -notin '.ps1', '.bat', '.cmd') { return }

    Open-AtomFileInEditor -Path $Plugin.FullName
}

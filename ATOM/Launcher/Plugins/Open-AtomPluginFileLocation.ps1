function Open-AtomPluginFileLocation {
    param (
        [Parameter(Mandatory)]
        [Object]$Plugin
    )

    if (!$Plugin.FullName -or !(Test-Path -LiteralPath $Plugin.FullName -PathType Leaf)) { return }

    $explorerArguments = '/select,"{0}"' -f $Plugin.FullName
    Start-Process -FilePath 'explorer.exe' -ArgumentList $explorerArguments
}

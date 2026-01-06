$userPrograms = [ordered]@{
<#
'Example' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = $null
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\Example"
        RelativePath    = "example.exe"
        Uri             = "https://example.com/file.zip"
    }
}
#>
}
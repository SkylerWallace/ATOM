$configPath = "$psScriptRoot\..\Config"
$pluginFile = "$configPath\PluginsParams.ps1"
$programFile = "$configPath\ProgramsParams.ps1"
$outputFile = "$configPath\Plugins.ps1"

# Load the pluginInfo hashtable
. $pluginFile
if (!$pluginInfo) {
    Write-Error "Failed to load pluginInfo from $pluginFile"
    exit
}

# Load the programsInfo hashtable
. $programFile
if (!$programsInfo) {
    Write-Error "Failed to load programsInfo from $programFile"
    exit
}

# Merge data for each program
$programs = [ordered]@{}
foreach ($program in $pluginInfo.Keys) {
    # Create ProgramInfo with transformed keys
    $programInfo = [ordered]@{}
    if ($programsInfo.$program.ProgramFolder) { $programInfo.DestinationPath = "`$programsPath\$($programsInfo.$program.ProgramFolder)" }
    if ($programsInfo.$program.ExeName) { $programInfo.RelativePath = "$($programsInfo.$program.ExeName)" }
    if ($programsInfo.$program.DownloadUrl) { $programInfo.Uri = "$($programsInfo.$program.DownloadUrl)" }
    if ($programsInfo.$program.Credential) { $programInfo.Credential = $($programsInfo.$program.Credential) }
    if ($programsInfo.$program.Override) { $programInfo.ScriptBlock = $programsInfo.$program.Override }

    # Create merged entry
    $programs[$program] = [ordered]@{}
    if ($script:pluginInfo[$program]) { $programs[$program].PluginInfo = $script:pluginInfo[$program] }
    if ($programsInfo[$program]) { $programs[$program].ProgramInfo = $programInfo }
    else {$programs[$program].ProgramInfo = $null}
}

# Create formatted output file
$outputContent = @'
$programs = [ordered]@{
'@

foreach ($program in $programs.Keys) {
    $outputContent += "`n'$program' = @{`n"

    # Build PluginInfo lines if it exists
    if ($programs[$program].PluginInfo) {
        $pluginInfoLines = $programs[$program].PluginInfo.GetEnumerator() | ForEach-Object {
            if ($_.Value -is [bool]) {
                "        $($_.Key) = `$$($_.Value.ToString().ToLower())"
            } else {
                "        $($_.Key) = `"$($_.Value)`""
            }
        }
        $pluginInfoText = $pluginInfoLines -join "`n"
        $outputContent += @"
    PluginInfo = @{
$pluginInfoText
    }
"@
    }

    # Build ProgramInfo lines if it exists
    if ($programs[$program].ProgramInfo) {
        $programInfoLines = $programs[$program].ProgramInfo.GetEnumerator() | ForEach-Object {
            if ($_.Key -eq 'ScriptBlock' -and $_.Value) {
                $scriptBlockText = $_.Value.ToString().Trim() -replace '^    ','            '
                "        ScriptBlock = {"
                "            $scriptBlockText"
                "        }"
            } else {
                "        $($_.Key) = `"$($_.Value)`""
            }
        }
        $programInfoText = $programInfoLines -join "`n"
        if ($programs[$program].PluginInfo) {
            $outputContent += "`n    ProgramInfo = {`n$programInfoText`n    }"
        } else {
            $outputContent += "`n    ProgramInfo = {`n$programInfoText`n    }"
        }
    }

    $outputContent += "`n}"
}

$outputContent += @"
}
"@

# Create merged file
$outputContent | Out-File -FilePath $outputFile -Encoding UTF8
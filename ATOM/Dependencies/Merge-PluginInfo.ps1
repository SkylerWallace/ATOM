$configPath = "$psScriptRoot\..\Config"
$dependenciesPath = "$psScriptRoot\..\Dependencies"

# Load legacy hashtables
$legacyFiles = @(
    "$dependenciesPath\Plugins-Hashtable (Custom).ps1",
    "$dependenciesPath\Programs-Hashtable (Custom).ps1",
    "$configPath\PluginsParamsUser.ps1",
    "$configPath\ProgramsParamsUser.ps1"
)

$legacyFiles | ForEach-Object {
    if (Test-Path $_) {
        . $_
        [System.Collections.ArrayList]$detectedLegacyFiles.Add($_)
    }
}

#if ($customPluginInfo -or $customProgramsInfo) {  }

# Create empty dictionary, get all plugins/programs
$userProgramInfo = [ordered]@{}
$plugins = $customPluginInfo.Keys + $customProgramsInfo.Keys | Sort-Object -Unique

# Merge dictionaries
foreach ($plugin in $plugins) {
    # Create empty key for plugin
    $userProgramInfo.$plugin = @{}

    # Import plugin info hashtable into new key
    if ($customPluginInfo.$plugin) { $userProgramInfo.$plugin.PluginInfo = $customPluginInfo.$plugin }

    # Convert program info hashtable keys
    if ($customProgramsInfo.$plugin) { $userProgramInfo.$plugin.ProgramInfo = @{} }
    if ($customProgramsInfo.$plugin.ProgramFolder) { $userProgramInfo.$plugin.ProgramInfo.DestinationPath = "`$programsPath\$($customProgramsInfo.$plugin.ProgramFolder)" }
    if ($customProgramsInfo.$plugin.ExeName) { $userProgramInfo.$plugin.ProgramInfo.RelativePath = "$($customProgramsInfo.$plugin.ExeName)" }
    if ($customProgramsInfo.$plugin.DownloadUrl) { $userProgramInfo.$plugin.ProgramInfo.Uri = "$($customProgramsInfo.$plugin.DownloadUrl)" }
    if ($customProgramsInfo.$plugin.Credential) { $userProgramInfo.$plugin.ProgramInfo.Credential = "$($customProgramsInfo.$plugin.Credential)" }
    if ($customProgramsInfo.$plugin.Override) { $userProgramInfo.$plugin.ProgramInfo.ScriptBlock = $customProgramsInfo.$plugin.Override }
}

# Create formatted output file
$outputContent = @'
$userProgramInfo = [ordered]@{
'@

foreach ($program in $userProgramInfo.Keys) {
    $outputContent += "`n'$program' = @{`n"

    # Build PluginInfo lines if it exists
    if ($userProgramInfo[$program].PluginInfo) {
        $pluginInfoLines = $userProgramInfo[$program].PluginInfo.GetEnumerator() | ForEach-Object {
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
    if ($userProgramInfo[$program].ProgramInfo) {
        $programInfoLines = $userProgramInfo[$program].ProgramInfo.GetEnumerator() | ForEach-Object {
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
        if ($userProgramInfo[$program].PluginInfo) {
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
$outputFile = "$configPath\PluginsUser.ps1"
$outputContent | Set-Content -Path $outputFile -Encoding UTF8 -NoNewLine
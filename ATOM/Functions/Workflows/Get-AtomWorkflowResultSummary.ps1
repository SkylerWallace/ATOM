function Get-AtomWorkflowResultSummary {
    <# .SYNOPSIS
        Formats catalog-defined report matches and structured output properties.
    #>
    param([string]$ActionId, [Parameter(Mandatory)]$Result, [hashtable]$Definition)

    if (!$Definition) {
        $catalogPath = if ($atomPath) { Join-Path $atomPath 'Config/WorkflowActions.psd1' }
        elseif ($__atomLibraryIndex.Path) { Join-Path (Split-Path (Split-Path $__atomLibraryIndex.Path)) 'Config/WorkflowActions.psd1' }
        else { Join-Path $PSScriptRoot '../../Config/WorkflowActions.psd1' }
        $stamp = [IO.File]::GetLastWriteTimeUtc($catalogPath)
        if (!$script:workflowResultCatalog -or $script:workflowResultCatalogStamp -ne $stamp) {
            $script:workflowResultCatalog = (Import-PowerShellDataFile -LiteralPath $catalogPath).Actions
            $script:workflowResultCatalogStamp = $stamp
        }
        $Definition = $script:workflowResultCatalog[$ActionId]
    }
    $rules = $Definition.Results
    if (!$rules -or !$Result.Output) { return $Result.Summary }
    $metrics = @($rules.Metrics)
    $values = @{}
    $unique = @{}
    foreach ($metric in $metrics) {
        if ($metric.Property) {
            $value = $Result.Output
            foreach ($part in $metric.Property.Split('.')) { if ($null -ne $value) { $value = $value.$part } }
            if ($null -ne $value -and $value -is [bool]) { $value = [int]$value }
            $values[$metric.Label] = $value
        }
        if ($metric.Aggregation -eq 'UniqueCount') { $unique[$metric.Label] = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase) }
    }
    if ($rules.Reports -and !$Result.Output.ReportMayIncludeEarlierScans -and (Test-Path -LiteralPath $Result.Output.ReportDirectory -PathType Container)) {
        $reports = @(Get-ChildItem -LiteralPath $Result.Output.ReportDirectory -File | Where-Object {
            $name = $_.Name
            @($rules.Reports | Where-Object { $name -like $_ }).Count -gt 0
        })
        foreach ($report in $reports) {
            $reader = [IO.StreamReader]::new($report.FullName, $true)
            try {
                while (!$reader.EndOfStream) {
                    $line = $reader.ReadLine().Replace([string][char]0, '')
                    if ($report.Extension -in '.html','.htm') { $line = [Net.WebUtility]::HtmlDecode(($line -replace '<[^>]+>', ' ')) }
                    foreach ($metric in $metrics) {
                        if ($metric.Pattern -and $line.Trim() -match $metric.Pattern) {
                            if ($metric.Aggregation -eq 'UniqueCount') { [void]$unique[$metric.Label].Add($matches[1]); $values[$metric.Label] = $unique[$metric.Label].Count }
                            else { $values[$metric.Label] = [long]($matches[1] -replace ',', '') }
                        }
                    }
                }
            }
            finally { $reader.Dispose() }
        }
    }
    $lines = @($metrics | ForEach-Object {
        $value = $values[$_.Label]
        if ($null -eq $value -and $_.ZeroWhen -and $null -ne $values[$_.ZeroWhen] -and $values[$_.ZeroWhen] -eq 0 -and !$Result.Output.Cancelled -and $Result.ExitCode -eq 0) { $value = 0 }
        if ($null -ne $value) {
            if ($_.Format) { $_.Format -f $value }
            else { "$value $($_.Label)" }
        }
        elseif (!$_.Optional) { "$($_.Label): Not reported" }
    })
    if ($rules.Note) { $lines += $rules.Note }
    if ($rules.IncludeSummary -or $Result.Status -ne 'Succeeded' -or $Result.Output.UpdateWarning) { $lines += $Result.Summary }
    return $lines -join "`n"
}

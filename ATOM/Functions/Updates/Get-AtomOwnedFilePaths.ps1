function Get-AtomOwnedFilePaths {
    <#
    .SYNOPSIS
        Recovers ATOM file ownership independently of file integrity.
    #>
    param ([Parameter(Mandatory)][String]$RootPath)

    $paths = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($name in 'UpdateState.json', 'OwnershipState.json') {
        try {
            $state = Get-AtomUpdateState -Path (Join-Path $RootPath "ATOM/Config/$name")
            foreach ($file in $state.Files) { [void]$paths.Add($file.Path) }
        } catch { }
    }

    # Older source copies may have no manifest. Their native plugin catalog
    # still identifies first-party scripts without evaluating script content.
    $catalogs = @(Join-Path $RootPath 'ATOM/Config/Plugins.ps1')
    $backups = Join-Path $RootPath 'ATOM/Backups/Updates'
    if (Test-Path -LiteralPath $backups) {
        $catalogs += @(Get-ChildItem -LiteralPath $backups -Directory | ForEach-Object {
            Join-Path $_.FullName 'ATOM/Config/Plugins.ps1'
        })
    }
    foreach ($catalog in $catalogs) {
        if (!(Test-Path -LiteralPath $catalog -PathType Leaf)) { continue }
        $errors = $null
        $ast = [Management.Automation.Language.Parser]::ParseFile($catalog, [ref]$null, [ref]$errors)
        if ($errors) { continue }
        $assignment = $ast.Find({ param($node)
            $node -is [Management.Automation.Language.AssignmentStatementAst] -and $node.Left.Extent.Text -eq '$programs'
        }, $true)
        if (!$assignment) { continue }
        $table = $assignment.Right.Find({ param($node) $node -is [Management.Automation.Language.HashtableAst] }, $true)
        foreach ($entry in $table.KeyValuePairs) {
            if ($entry.Item1 -isnot [Management.Automation.Language.StringConstantExpressionAst]) { continue }
            $name = $entry.Item1.Value
            if ($name.IndexOfAny([IO.Path]::GetInvalidFileNameChars()) -ge 0) { continue }
            [void]$paths.Add("ATOM/Plugins/$name.ps1")
        }
    }
    $paths | Sort-Object
}

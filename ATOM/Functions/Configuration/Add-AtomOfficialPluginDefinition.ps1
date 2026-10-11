function Add-AtomOfficialPluginDefinition {
    <# .SYNOPSIS
        Inserts a static official plugin definition without rewriting existing catalog code.
    #>
    param(
        [Parameter(Mandatory)][String]$Path,
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][Collections.IDictionary]$Metadata
    )
    foreach ($target in $Path, (Split-Path -Parent $Path)) {
        if ((Get-Item -LiteralPath $target -ErrorAction Stop).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'The official catalog cannot be a linked file or directory.' }
    }
    $source = [IO.File]::ReadAllText($Path)
    $tokens = $null
    $parseErrors = $null
    $ast = [Management.Automation.Language.Parser]::ParseInput($source, [ref]$tokens, [ref]$parseErrors)
    if ($parseErrors.Count) { throw 'The plugin catalog contains syntax errors. Fix them before adding a plugin.' }
    $assignments = @($ast.EndBlock.Statements | Where-Object {
        $_ -is [Management.Automation.Language.AssignmentStatementAst] -and
        $_.Left -is [Management.Automation.Language.VariableExpressionAst] -and $_.Left.VariablePath.UserPath -eq 'programs'
    })
    if ($assignments.Count -ne 1) { throw 'Expected one top-level programs hashtable in the plugin catalog.' }
    $table = $assignments[0].Right.Find({ param($node) $node -is [Management.Automation.Language.HashtableAst] }, $false)
    if (!$table) { throw 'The plugin catalog must define programs using a literal hashtable.' }
    foreach ($entry in $table.KeyValuePairs) {
        if ($entry.Item1.SafeGetValue() -eq $Name) { throw "A plugin named '$Name' already exists." }
    }
    $newline = if ($source.Contains("`r`n")) { "`r`n" } else { "`n" }
    $literal = ConvertTo-AtomPowerShellLiteral -Value $Metadata
    $definition = "'$($Name.Replace("'", "''"))' = $literal" -replace '\r?\n', $newline
    $updated = $source.Insert($table.Extent.EndOffset - 1, "$newline$definition$newline$newline")
    [void][Management.Automation.Language.Parser]::ParseInput($updated, [ref]$tokens, [ref]$parseErrors)
    if ($parseErrors.Count) { throw 'The new plugin definition is invalid; the catalog was not changed.' }
    Write-AtomFileAtomic -Path $Path -Content $updated -Encoding ([Text.UTF8Encoding]::new($false))
}

function ConvertTo-AtomPowerShellLiteral {
    param (
        [AllowNull()]
        [Object]$Value,

        [Int]$Indent = 0
    )

    $padding = ' ' * $Indent

    if ($null -eq $Value) { return '$null' }
    if ($Value -is [Boolean]) {
        if ($Value) { return '$true' }
        return '$false'
    }
    if ($Value -is [String] -or $Value -is [Char]) {
        $escapedValue = ([String]$Value).Replace("'", "''")
        return "'$escapedValue'"
    }
    if ($Value -is [ScriptBlock]) {
        $lines = @('{')
        $lines += @([String]$Value -split '\r?\n' | ForEach-Object { "$(' ' * ($Indent + 4))$_" })
        $lines += "$padding}"
        return $lines -join [Environment]::NewLine
    }
    if ($Value -is [System.Collections.IDictionary]) {
        $lines = @('[ordered]@{')
        foreach ($entry in $Value.GetEnumerator()) {
            $escapedKey = ([String]$entry.Key).Replace("'", "''")
            $key = if ($Indent -gt 0 -and $entry.Key -match '^[A-Za-z_][A-Za-z0-9_]*$') { [String]$entry.Key } else { "'$escapedKey'" }
            $literal = ConvertTo-AtomPowerShellLiteral -Value $entry.Value -Indent ($Indent + 4)
            $literalLines = @($literal -split '\r?\n')
            $lines += "$(' ' * ($Indent + 4))$key = $($literalLines[0])"
            if ($literalLines.Count -gt 1) { $lines += $literalLines[1..($literalLines.Count - 1)] }
        }
        $lines += "$padding}"
        return $lines -join [Environment]::NewLine
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        $lines = @('@(')
        foreach ($item in $Value) {
            $literal = ConvertTo-AtomPowerShellLiteral -Value $item -Indent ($Indent + 4)
            $literalLines = @($literal -split '\r?\n')
            $lines += "$(' ' * ($Indent + 4))$($literalLines[0])"
            if ($literalLines.Count -gt 1) { $lines += $literalLines[1..($literalLines.Count - 1)] }
        }
        $lines += "$padding)"
        return $lines -join [Environment]::NewLine
    }
    if (
        $Value -is [Byte] -or $Value -is [Int16] -or $Value -is [Int32] -or
        $Value -is [Int64] -or $Value -is [Single] -or $Value -is [Double] -or
        $Value -is [Decimal]
    ) {
        return [Convert]::ToString($Value, [Globalization.CultureInfo]::InvariantCulture)
    }

    throw "Unsupported PluginsUser value type: $($Value.GetType().FullName)"
}

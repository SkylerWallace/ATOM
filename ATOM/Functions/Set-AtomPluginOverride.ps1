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

function Set-AtomPluginOverride {
    <#
    .SYNOPSIS
        Persists one user-defined plugin property override.

    .DESCRIPTION
        Updates the canonical userPrograms hashtable and removes properties that
        match their built-in defaults. Entries are sorted before being written.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Path,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Defaults,

        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [ValidateSet('Category', 'Hidden', 'Favorite')]
        [String]$Property,

        [Parameter(Mandatory)]
        [Object]$Value
    )

    if ([String]::IsNullOrWhiteSpace($Name)) { throw 'Plugin name is required.' }

    $userPrograms = [ordered]@{}
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        . $Path
        if ($userPrograms -isnot [System.Collections.IDictionary]) {
            throw 'PluginsUser.ps1 must define $userPrograms as a hashtable.'
        }
    }

    if (!$userPrograms.Contains($Name)) { $userPrograms[$Name] = [ordered]@{} }
    if ($userPrograms[$Name] -isnot [System.Collections.IDictionary]) {
        throw "The userPrograms entry for '$Name' must be a hashtable."
    }

    $defaultConfig = $Defaults[$Name]
    $matchesDefault =
        if (!$defaultConfig) { $false }
        elseif ($Property -eq 'Category') { [String]$Value -eq [String]$defaultConfig.Category }
        else { [Boolean]$Value -eq [Boolean]$defaultConfig[$Property] }

    if ($matchesDefault) {
        [void]$userPrograms[$Name].Remove($Property)
        if ($userPrograms[$Name].Count -eq 0) { [void]$userPrograms.Remove($Name) }
    } else {
        $userPrograms[$Name][$Property] = $Value
    }

    $sortedPrograms = [ordered]@{}
    $userPrograms.GetEnumerator() | Sort-Object Key | ForEach-Object {
        $sortedPrograms[$_.Key] = $_.Value
    }

    if (!(Get-Command Write-AtomFileAtomic -CommandType Function -ErrorAction SilentlyContinue)) {
        $functionRoot = if ($functionsPath) { $functionsPath } else { $PSScriptRoot }
        . (Join-Path $functionRoot 'Write-AtomFileAtomic.ps1')
    }

    $literal = ConvertTo-AtomPowerShellLiteral -Value $sortedPrograms
    $content = ([Char]36) + "userPrograms = $literal$([Environment]::NewLine)"
    Write-AtomFileAtomic -Path $Path -Content $content
}

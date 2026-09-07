function Format-DownloadManifestJson {
    param (
        [Parameter(Mandatory)]
        [String]$Json
    )

    # Windows PowerShell unnecessarily HTML-escapes these JSON-safe characters.
    $Json = $Json.Replace('\u0026', '&').Replace('\u0027', "'").Replace('\u003c', '<').Replace('\u003e', '>')

    $output = [Text.StringBuilder]::new()
    $indent = 0
    $inString = $false
    $escaped = $false

    foreach ($character in $Json.ToCharArray()) {
        if ($inString) {
            [void]$output.Append($character)
            if ($escaped) { $escaped = $false }
            elseif ($character -eq '\') { $escaped = $true }
            elseif ($character -eq '"') { $inString = $false }
            continue
        }

        switch ($character) {
            '"' {
                $inString = $true
                [void]$output.Append($character)
            }
            { $_ -eq '{' -or $_ -eq '[' } {
                [void]$output.Append($character).AppendLine()
                $indent++
                [void]$output.Append(' ' * ($indent * 2))
            }
            { $_ -eq '}' -or $_ -eq ']' } {
                $indent--
                [void]$output.AppendLine().Append(' ' * ($indent * 2)).Append($character)
            }
            ',' {
                [void]$output.Append($character).AppendLine().Append(' ' * ($indent * 2))
            }
            ':' {
                [void]$output.Append(': ')
            }
            default {
                if (![Char]::IsWhiteSpace($character)) { [void]$output.Append($character) }
            }
        }
    }

    $output.ToString()
}

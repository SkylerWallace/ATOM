function Write-AtomSettingsFile {
    <#
    .SYNOPSIS
        Writes the current ATOM settings to SettingsUser.ps1.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Path,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Settings
    )

    $settingsContent = @(
        '$userAtomSettings = [ordered]@{'
        foreach ($setting in $Settings.GetEnumerator()) {
            "    $($setting.Name) = @{"

            $value = $setting.Value.Value
            if ($value -is [Boolean]) {
                "        Value = `$$($value.ToString().ToLowerInvariant())"
            } elseif ($value -is [String]) {
                $escapedValue = $value.Replace("'", "''")
                "        Value = '$escapedValue'"
            } elseif (
                $value -is [Byte] -or $value -is [Int16] -or $value -is [Int32] -or
                $value -is [Int64] -or $value -is [Single] -or $value -is [Double] -or
                $value -is [Decimal]
            ) {
                "        Value = $([Convert]::ToString($value, [Globalization.CultureInfo]::InvariantCulture))"
            } else {
                $typeName = if ($null -eq $value) { 'null' } else { $value.GetType().FullName }
                throw "Unsupported ATOM setting value type for '$($setting.Name)': $typeName"
            }

            '    }'
        }
        '}'
    ) -join [Environment]::NewLine

    if (!(Get-Command Write-AtomFileAtomic -CommandType Function -ErrorAction SilentlyContinue)) {
        . (Join-Path $PSScriptRoot 'Write-AtomFileAtomic.ps1')
    }

    Write-AtomFileAtomic -Path $Path -Content "$settingsContent$([Environment]::NewLine)"
}

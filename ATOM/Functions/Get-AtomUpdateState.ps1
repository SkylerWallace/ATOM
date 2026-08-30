function Get-AtomUpdateState {
    <#
    .SYNOPSIS
        Reads and validates ATOM's local v2 update state.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$Path
    )

    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        try {
            $state = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        } catch {
            throw "Unable to read ATOM update state '$Path': $($_.Exception.Message)"
        }

        if (
            $state.SchemaVersion -ne 2 -or
            $state.Channel -notin 'main', 'dev' -or
            ($state.CommitSha -and $state.CommitSha -notmatch '^[0-9a-f]{40}$')
        ) {
            throw "ATOM update state '$Path' is invalid."
        }

        $manifestPaths = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
        foreach ($file in @($state.Files)) {
            $manifestPath = ([String]$file.Path).Replace('\', '/').TrimStart('/')
            if (
                !$manifestPath -or
                [IO.Path]::IsPathRooted([String]$file.Path) -or
                $manifestPath.Split('/') -contains '..' -or
                !$manifestPaths.Add($manifestPath) -or
                $file.Sha256 -notmatch '^[0-9A-Fa-f]{64}$'
            ) {
                throw "ATOM update state '$Path' contains an invalid file manifest."
            }
            $file.Path = $manifestPath
        }
        return $state
    }
}

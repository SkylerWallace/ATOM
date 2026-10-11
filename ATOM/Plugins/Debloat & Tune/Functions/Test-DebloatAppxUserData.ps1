function Test-DebloatAppxUserData {
    <# .SYNOPSIS
        Conservatively detects potential app data without maintaining per-app file names.
    .DESCRIPTION
        Checks standard persistent/cache folders and stops at their first entry.
        Empty installation folders do not count. Data may be created automatically;
        absence is a heuristic, not proof that an app has never been used.
        Unreadable data is treated as present to exclude the app from select-all.
    #>
    param([Parameter(Mandatory)][string]$Path)
    foreach ($folder in 'LocalState','LocalCache','RoamingState','AC','SystemAppData') {
        $entries = $null
        try {
            $entries = [IO.Directory]::EnumerateFileSystemEntries([IO.Path]::Combine($Path, $folder)).GetEnumerator()
            if ($entries.MoveNext()) { return $true }
        } catch [IO.DirectoryNotFoundException] {
            continue
        } catch {
            return $true
        } finally { if ($entries -is [IDisposable]) { $entries.Dispose() } }
    }
    return $false
}

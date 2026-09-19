function Get-AtomWorkflowLogRoot {
    <# .SYNOPSIS
        Resolves workflow storage on this computer, or its mounted Windows installation in PE.
    #>
    if (!(Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT')) {
        $programData = [Environment]::GetFolderPath('CommonApplicationData')
        if (!$programData) { throw 'Windows ProgramData is unavailable.' }
        return Join-Path $programData 'ATOM\Logs\Workflows'
    }

    $mounted = (Get-ItemProperty 'HKLM:\SOFTWARE\ATOM' -Name MountedDrive -ErrorAction Stop).MountedDrive
    $software = 'HKLM:\RemoteOS-HKLM-SOFTWARE'
    if ($mounted -notmatch '^[A-Za-z]:$' -or !(Test-Path $software) -or !(Test-Path 'HKLM:\RemoteOS-HKLM-SYSTEM')) {
        throw 'Use MountOS before running workflows in PE so their logs can be saved on the computer.'
    }
    $systemRoot = (Get-ItemProperty "$software\Microsoft\Windows NT\CurrentVersion" -Name SystemRoot -ErrorAction Stop).SystemRoot
    if ($systemRoot -notmatch '^[A-Za-z]:\\') { throw 'Mounted Windows has an unsupported SystemRoot.' }
    $originalDrive = $systemRoot.Substring(0,2)
    $profile = Get-ItemProperty "$software\Microsoft\Windows NT\CurrentVersion\ProfileList" -ErrorAction Stop
    $programData = if ($profile.ProgramData) { [string]$profile.ProgramData } else { "$originalDrive\ProgramData" }
    $programData = $programData.Replace('%SystemDrive%', $originalDrive)
    if (!$programData.StartsWith($originalDrive + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Cannot map the mounted Windows ProgramData location.' }
    $target = [IO.Path]::GetFullPath($mounted + $programData.Substring(2))
    if (!$target.StartsWith($mounted + '\', [StringComparison]::OrdinalIgnoreCase) -or $mounted -eq [IO.Path]::GetPathRoot($env:SystemRoot).TrimEnd('\')) { throw 'Invalid persistent workflow log location.' }
    if (!(Test-Path -LiteralPath ($mounted + $systemRoot.Substring(2) + '\System32\config\SYSTEM'))) { throw 'The mounted Windows installation is no longer available.' }
    Join-Path $target 'ATOM\Logs\Workflows'
}

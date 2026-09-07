function Update-AtomEnvironmentPath {
    [CmdletBinding()]
    param (

    )

    $pathSegments = @(
        [Environment]::GetEnvironmentVariable('Path', 'Machine')
        [Environment]::GetEnvironmentVariable('Path', 'User')
    ) | Where-Object { $_ }

    $env:Path = $pathSegments -join ';'
}

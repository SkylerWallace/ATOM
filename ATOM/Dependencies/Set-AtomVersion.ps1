[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory, Position = 0)]
    [ValidatePattern('^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$')]
    [string]$Version
)

$versionPath = Join-Path (Split-Path $PSScriptRoot) 'Config\Version.psd1'
if ($PSCmdlet.ShouldProcess($versionPath, "Set ATOM version to $Version")) {
    $content = "@{`r`n    # Semantic version: MAJOR.MINOR.PATCH. Keep the display prefix out of this value.`r`n    Version = '$Version'`r`n}`r`n"
    [IO.File]::WriteAllText($versionPath, $content, [Text.UTF8Encoding]::new($false))
    Write-Host "ATOM version set to $Version"
}

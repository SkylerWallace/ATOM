function Set-AtomPluginPreference {
    param (
        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [ValidateSet('Category', 'Hidden', 'Favorite')]
        [String]$Property,

        [Parameter(Mandatory)]
        [Object]$Value
    )

    $overridePath = Join-Path $configPath 'PluginsUser.ps1'
    Set-AtomPluginOverride -Path $overridePath -Defaults $script:programDefaults -Name $Name -Property $Property -Value $Value
}

function Set-AtomPluginVisibility {
    param (
        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [Boolean]$Hidden
    )

    Set-AtomPluginPreference -Name $Name -Property Hidden -Value $Hidden
    Update-AtomPluginList -Reload
    $statusBarStatus.Text = if ($Hidden) { "Hid $Name" } else { "Unhid $Name" }
}

function Set-AtomPluginCategory {
    param (
        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [String]$Category
    )

    Set-AtomPluginPreference -Name $Name -Property Category -Value $Category
    Update-AtomPluginList -Reload
    $statusBarStatus.Text = "Moved $Name to $Category"
}

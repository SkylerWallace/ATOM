function Confirm-AtomOfficialPlugin {
    <# .SYNOPSIS
        Confirms creation of a first-party plugin that changes project source files.
    #>
    param([Parameter(Mandatory)][Windows.Window]$Owner)
    $message = @'
TL;DR, SELECT 'NO' IF YOU DON'T KNOW WHAT YOU'RE DOING.

This creates a built-in ATOM plugin and changes Config/Plugins.ps1, plus its script and any selected icon in Plugins.

It will be read-only in Properties and cannot be deleted through ATOM. Review and commit the files to include the plugin in a release. Updates or repairs may replace catalog changes that have not shipped.

Are you sure?
'@
    return [Windows.MessageBox]::Show($Owner, $message, 'Create official ATOM plugin', 'YesNo', 'Warning', 'No') -eq [Windows.MessageBoxResult]::Yes
}

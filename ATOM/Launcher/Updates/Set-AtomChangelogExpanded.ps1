function Set-AtomChangelogExpanded {
    <#
    .SYNOPSIS
        Expands the changelog and initializes its cached contents on demand.
    #>
    param ([Boolean]$Expanded)

    if ($Expanded) { Initialize-AtomChangelog }
    $window.FindName('changelogPanel').Visibility = if ($Expanded) { 'Visible' } else { 'Collapsed' }
    $window.FindName('changelogToggleButton').ToolTip = if ($Expanded) { 'Hide changelog' } else { 'Show changelog' }
    Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{
        changelogIndicator = $(if ($Expanded) { 'ArrowDropUpIcon' } else { 'ArrowDropDownIcon' })
    }
}

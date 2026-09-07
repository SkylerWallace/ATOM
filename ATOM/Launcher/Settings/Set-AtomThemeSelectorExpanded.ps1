function Set-AtomThemeSelectorExpanded {
    param (
        [Boolean]$Expanded
    )

    $themePanel.Visibility = if ($Expanded) { 'Visible' } else { 'Collapsed' }
    Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'themeSelectorIndicator' = $(if ($Expanded) { 'ArrowDropUpIcon' } else { 'ArrowDropDownIcon' }) }
    $themeSelectorButton.ToolTip = if ($Expanded) { 'Hide theme options' } else { 'Show theme options' }
}

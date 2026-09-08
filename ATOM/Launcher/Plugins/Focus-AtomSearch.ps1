function Focus-AtomSearch {
    if ($script:activePage -eq 'Settings') {
        [void]$window.FindName('settingsSearchTextBox').Focus()
        $window.FindName('settingsSearchTextBox').SelectAll()
        return
    }
    if ($script:activePage -notin 'Plugins', 'Downloads') {
        Set-AtomPage -Page $(if ($script:downloadMode) { 'Downloads' } else { 'Plugins' })
    }
    $searchTextBox.Focus() | Out-Null
    $searchTextBox.SelectAll()
}

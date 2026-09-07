function Focus-AtomSearch {
    if ($script:activePage -notin 'Plugins', 'Downloads') {
        Set-AtomPage -Page $(if ($script:downloadMode) { 'Downloads' } else { 'Plugins' })
    }
    $searchTextBox.Focus() | Out-Null
    $searchTextBox.SelectAll()
}

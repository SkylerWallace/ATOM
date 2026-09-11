function Clear-AtomSearchTextBox {
    $searchTextBox.Clear()
    $searchTextBox.Focus() | Out-Null
    $backspaceButton.Focus() | Out-Null
}

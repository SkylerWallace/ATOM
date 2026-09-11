function Get-AtomPluginItems {
    foreach ($categoryGrid in $pluginWrapPanel.Children) {
        $listBox = $categoryGrid.Children.Child
        foreach ($item in $listBox.Items) { $item }
    }
}

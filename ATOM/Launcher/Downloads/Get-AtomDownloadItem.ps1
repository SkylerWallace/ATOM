function Get-AtomDownloadItem {
    foreach ($categoryGrid in $pluginWrapPanel.Children) {
        $border = $categoryGrid.Children | Where-Object { $_ -is [System.Windows.Controls.Border] } | Select-Object -First 1
        if (!$border) { continue }

        foreach ($item in $border.Child.Items) {
            if ($item.Control -is [System.Windows.Controls.CheckBox]) { $item }
        }
    }
}

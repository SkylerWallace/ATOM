function Add-AtomPluginDescription {
    <#
    .SYNOPSIS
        Adds wrapped description text beneath a plugin row's existing content.
    #>
    param (
        [Parameter(Mandatory)]
        [Windows.Controls.ListBoxItem]$Item,
        [Parameter(Mandatory)]
        [String]$Description
    )

    $panel = [Windows.Controls.StackPanel]::new()
    $header = $Item.Content
    $Item.Content = $null
    [void]$panel.Children.Add($header)
    $details = [Windows.Controls.TextBlock]::new()
    $details.Text = $Description
    $details.FontSize = 10
    $details.TextWrapping = 'Wrap'
    $details.Margin = '7,2,7,5'
    $details.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
    [void]$panel.Children.Add($details)
    $Item.Content = $panel
}

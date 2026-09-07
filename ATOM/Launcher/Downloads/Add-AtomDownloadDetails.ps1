function Add-AtomDownloadDetails {
    param ($Item, $ProgramState)
    $panel = [Windows.Controls.StackPanel]::new()
    $existingContent = $Item.Content
    $Item.Content = $null
    [void]$panel.Children.Add($existingContent)
    $details = [Windows.Controls.TextBlock]::new()
    $details.FontSize = 10
    $details.TextWrapping = 'Wrap'
    $details.Margin = '7,2,7,5'
    $details.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
    [void]$panel.Children.Add($details)
    $progress = [Windows.Controls.ProgressBar]::new()
    $progress.Height = 3
    $progress.Margin = '7,0,7,6'
    $progress.Maximum = 100
    $progress.Visibility = 'Collapsed'
    $progress.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'controlBrush')
    [void]$panel.Children.Add($progress)
    $Item.Content = $panel
    $script:downloadRows[$Item.Tag.Name] = @{
        Item = $Item; Details = $details; Progress = $progress; Downloaded = [bool]$ProgramState.IsAvailable
    }
}

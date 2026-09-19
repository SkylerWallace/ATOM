function Update-AtomWorkflowLogView {
    <# .SYNOPSIS
        Refreshes history on demand and renders changed checkpoints from the selected run.
    #>
    param([hashtable]$View)
    if ($View.Updating) { return }
    $View.Updating = $true
    try {
        if ($View.SelectPath -or ([datetime]::UtcNow - $View.LastHistory).TotalSeconds -ge 5) {
            $history = @(Get-AtomWorkflowHistory -Root $View.Root -Cache $View.HistoryCache | Sort-Object Created -Descending)
            $key = ($history.Path -join '|')
            if ($key -ne $View.HistoryKey) {
                $selected = $View.Runs.SelectedItem.Tag
                $View.Runs.Items.Clear()
                foreach ($entry in $history) {
                    $item = [Windows.Controls.ComboBoxItem]::new()
                    $item.Content = $entry.Label
                    $item.Tag = $entry.Path
                    [void]$View.Runs.Items.Add($item)
                }
                $View.HistoryKey = $key
                $View.Runs.SelectedIndex = -1; for ($i=0; $i -lt $history.Count; $i++) { if ($history[$i].Path -eq $selected) { $View.Runs.SelectedIndex=$i; break } }
                if (!$View.Runs.SelectedItem -and $history.Count) { $View.Runs.SelectedIndex=0 }
            }
            if ($View.SelectPath -and $View.SelectPath -in $history.Path) {
                for ($i=0; $i -lt $history.Count; $i++) { if ($history[$i].Path -eq $View.SelectPath) { $View.Runs.SelectedIndex=$i; break } }
                $View.SelectPath=$null
            }
            $View.LastHistory=[datetime]::UtcNow
        }
        $path = [string]$View.Runs.SelectedItem.Tag
        if (!$path) { $View.Summary.Text='No workflow logs on this computer yet.'; $View.Steps.Children.Clear(); return }
        $stamp = [IO.File]::GetLastWriteTimeUtc($path).Ticks
        if ($path -eq $View.SelectedPath -and $stamp -eq $View.Stamp) { return }
        $run = [IO.File]::ReadAllText($path) | ConvertFrom-Json -ErrorAction Stop
        if ($run.SchemaVersion -ne 1 -or !$run.PSObject.Properties['Steps']) { throw 'Unsupported workflow log format.' }
        $formatTimestamp = {
            param($timestamp)
            if (!$timestamp) { return 'Pending' }
            try { ([datetime]$timestamp).ToLocalTime().ToString('MMMM dd, yyyy h:mm:ss tt') }
            catch { 'Unavailable' }
        }
        $passed = @($run.Steps | Where-Object Status -eq 'Succeeded').Count
        $View.Summary.Text = "$($run.Status) - $passed of $(@($run.Steps).Count) actions passed`nStarted: $(& $formatTimestamp $run.StartedUtc)    Finished: $(& $formatTimestamp $run.FinishedUtc)`nComputer: $($run.ComputerName)"
        if ($run.Error) { $View.Summary.Text += "`n$($run.Error)" }
        if ($run.Status -eq 'Running') { $View.Summary.Text += "`nLast saved state; a run left open by a previous session may be unfinished." }
        $expanded = @($View.Steps.Children | Where-Object { $_.Child.Children[-1].IsExpanded } | ForEach-Object { $_.Tag })
        $View.Steps.Children.Clear()
        $index=0
        foreach ($step in $run.Steps) {
            $card=[Windows.Controls.Border]::new()
            $card.SetResourceReference([Windows.FrameworkElement]::StyleProperty,'CustomBorder')
            $card.Margin='0,4,0,10'; $card.Padding='12'; $card.Tag=$index
            $stack=[Windows.Controls.StackPanel]::new(); $card.Child=$stack
            foreach ($text in @("$($step.Status) - $($step.Name)", "Started: $(& $formatTimestamp $step.StartedUtc)    Finished: $(& $formatTimestamp $step.FinishedUtc)", $step.Summary)) {
                if (!$text) { continue }
                $label=[Windows.Controls.TextBlock]::new(); $label.Text=$text; $label.TextWrapping='Wrap'; $label.Margin='0,0,0,6'
                $label.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty,'surfaceText')
                [void]$stack.Children.Add($label)
            }
            $details=[Windows.Controls.Expander]::new(); $details.Header='Result details'; $details.IsExpanded=$index -in $expanded
            $details.SetResourceReference([Windows.Controls.Control]::ForegroundProperty,'surfaceText')
            $body=[Windows.Controls.TextBox]::new(); $body.IsReadOnly=$true; $body.TextWrapping='Wrap'; $body.BorderThickness=0; $body.Background=[Windows.Media.Brushes]::Transparent
            $body.SetResourceReference([Windows.Controls.Control]::ForegroundProperty,'surfaceText')
            $body.Text=if ($step.Data) { $step.Data | ConvertTo-Json -Depth 20 } else { 'No result data yet.' }
            $details.Content=$body; [void]$stack.Children.Add($details); [void]$View.Steps.Children.Add($card)
            $index++
        }
        $View.SelectedPath=$path; $View.Stamp=$stamp
    }
    catch { $View.Steps.Children.Clear(); $View.Summary.Text="Unable to read workflow log: $($_.Exception.Message)" }
    finally { $View.Updating=$false }
}

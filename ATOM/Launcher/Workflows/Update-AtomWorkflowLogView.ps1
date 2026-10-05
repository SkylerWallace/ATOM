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
        $completed = @($run.Steps | Where-Object { $_.FinishedUtc -and $_.Status -ne 'Skipped' }).Count
        $resultLabel = {
            param($status)
            switch ($status) {
                Succeeded { 'Completed' }
                Failed { 'Failed' }
                NeedsAttention { 'Needs review' }
                default { $status }
            }
        }
        $View.Summary.Text = "$(& $resultLabel $run.Status) - $completed of $(@($run.Steps).Count) actions finished`nStarted: $(& $formatTimestamp $run.StartedUtc)    Finished: $(& $formatTimestamp $run.FinishedUtc)`nComputer: $($run.ComputerName)"
        if ($run.Error) { $View.Summary.Text += "`n$($run.Error)" }
        if ($run.Status -eq 'Running') { $View.Summary.Text += "`nLast saved state; a run left open by a previous session may be unfinished." }
        $View.Steps.Children.Clear()
        $index=0
        foreach ($step in $run.Steps) {
            $summary = $step.Summary
            if ($step.Data) {
                try { $summary = Get-AtomWorkflowResultSummary -ActionId $step.ActionId -Result $step.Data }
                catch { }
            }
            $card=[Windows.Controls.Border]::new()
            $card.SetResourceReference([Windows.FrameworkElement]::StyleProperty,'CustomBorder')
            $card.Margin='0,4,0,10'; $card.Padding='12'; $card.Tag=$index
            $stack=[Windows.Controls.StackPanel]::new(); $card.Child=$stack
            $status = if ($step.Data.Output.Cancelled) { 'Stopped' } else { & $resultLabel $step.Status }
            foreach ($text in @("$status - $($step.Name)", "Started: $(& $formatTimestamp $step.StartedUtc)    Finished: $(& $formatTimestamp $step.FinishedUtc)", $summary)) {
                if (!$text) { continue }
                $label=[Windows.Controls.TextBlock]::new(); $label.Text=$text; $label.TextWrapping='Wrap'; $label.Margin='0,0,0,6'
                $label.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty,'surfaceText')
                [void]$stack.Children.Add($label)
            }
            $buttons = [Windows.Controls.WrapPanel]::new()
            $logPaths = [ordered]@{}
            $detailsPath = if ($step.DetailsPath -and (Test-Path -LiteralPath $step.DetailsPath -PathType Leaf)) { $step.DetailsPath } else { $path }
            $logPaths['Open result log'] = $detailsPath
            $reportDirectory = $step.Data.Output.ReportDirectory
            if ($reportDirectory -and (Test-Path -LiteralPath $reportDirectory -PathType Container)) {
                $report = Get-ChildItem -LiteralPath $reportDirectory -File | Where-Object {
                    $_.Name -in 'scan.log','msert.log' -or $_.Extension -in '.html','.htm'
                } | Sort-Object Name | Select-Object -First 1
                if ($report) { $logPaths['Open scan report'] = $report.FullName }
            }
            foreach ($entry in $logPaths.GetEnumerator()) {
                $button = [Windows.Controls.Button]::new()
                $caption = [Windows.Controls.TextBlock]::new()
                $caption.Text = $entry.Key; $caption.Padding = '12,5'
                $button.Content = $caption; $button.Tag = $entry.Value
                $button.SetResourceReference([Windows.FrameworkElement]::StyleProperty, 'RoundedButton')
                $button.SetResourceReference([Windows.Controls.Control]::BackgroundProperty, 'accentBrush')
                $button.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'accentText')
                $button.Padding = '14,7'; $button.Margin = '0,0,6,0'; $button.MinHeight = 30
                $button.Add_Click({
                    try { Open-AtomFileInEditor -Path $this.Tag }
                    catch { [void][Windows.MessageBox]::Show("Unable to open log: $($_.Exception.Message)", 'Workflow logs', 'OK', 'Error') }
                })
                [void]$buttons.Children.Add($button)
            }
            [void]$stack.Children.Add($buttons); [void]$View.Steps.Children.Add($card)
            $index++
        }
        $View.SelectedPath=$path; $View.Stamp=$stamp
    }
    catch { $View.Steps.Children.Clear(); $View.Summary.Text="Unable to read workflow log: $($_.Exception.Message)" }
    finally { $View.Updating=$false }
}

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
        $View.WorkflowLog.Tag = $path
        $View.WorkflowLog.IsEnabled = $path -and (Test-Path -LiteralPath $path -PathType Leaf)
        if (!$path) { foreach ($field in 'RunStatus','Started','Finished','Computer','RunError') { if ($View[$field]) { $View[$field].Text='' } }; if ($View.Duration) { $View.Duration.Text='' }; $View.Summary.Text='No workflow logs on this computer yet.'; $View.Steps.Children.Clear(); return }
        $stamp = [IO.File]::GetLastWriteTimeUtc($path).Ticks
        $liveRun = $path -eq $script:workflowResultPath -and $script:workflowHandle -and !$script:workflowHandle.IsCompleted
        $updateDuration = {
            $targets = @(@{ Control=$View.Duration; Started=$View.RunStartedUtc; Finished=$View.RunFinishedUtc; Active=$liveRun }) + @($View.ActionDurations)
            foreach ($target in $targets) {
                if (!$target.Control) { continue }
                $target.Control.Text = ''
                if (!$target.Started) { $target.Control.Text = 'Time elapsed: Pending'; continue }
                try {
                    $start = ([datetime]$target.Started).ToUniversalTime()
                    $end = if ($target.Finished) { ([datetime]$target.Finished).ToUniversalTime() } elseif ($target.Active -and $liveRun) { [datetime]::UtcNow } else { $null }
                    if (!$end) { $target.Control.Text = 'Time elapsed: Unavailable'; continue }
                    $seconds = [Math]::Max(0, [Math]::Floor(($end - $start).TotalSeconds))
                    $duration = [timespan]::FromSeconds($seconds)
                    $target.Control.Text = "Time elapsed: $([int][Math]::Floor($duration.TotalHours))h $($duration.Minutes)m $($duration.Seconds)s"
                }
                catch { $target.Control.Text = 'Duration: Unavailable' }
            }
        }
        if ($path -eq $View.SelectedPath -and $stamp -eq $View.Stamp -and $liveRun -eq $View.LiveRun) { & $updateDuration; return }
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
        $View.RunStartedUtc = $run.StartedUtc; $View.RunFinishedUtc = $run.FinishedUtc
        $View.RunStatus.Inlines.Clear()
        $name = if ([string]::IsNullOrWhiteSpace($run.PresetName)) { 'Custom workflow' } else { $run.PresetName }
        $View.Summary.Text = $name
        $successful = @($run.Steps | Where-Object Status -eq 'Succeeded').Count
        $statusText = switch ($run.Status) {
            Succeeded { 'Completed successfully' }
            Failed { if ($successful) { 'Partial success / failure' } else { 'Failed' } }
            NeedsAttention { 'Needs attention' }
            Stopped { 'Stopped' }
            Running { if ($liveRun) { 'Running' } else { 'Last recorded: Running (not verified)' } }
            default { $run.Status }
        }
        $iconKey = switch ($run.Status) { Succeeded { 'WorkflowCompletedIcon' } Failed { 'WorkflowErrorIcon' } NeedsAttention { 'WorkflowWarningIcon' } Stopped { 'WorkflowWarningIcon' } }
        if ($iconKey -or $liveRun) {
            $icon = [Windows.Shapes.Path]::new(); $icon.Width = 18; $icon.Height = 18; $icon.Stretch = 'Uniform'; $icon.Margin = '0,0,8,0'
            if ($liveRun) {
                $icon.Data = [Windows.Media.Geometry]::Parse('M12,2 A10,10 0 1 1 2,12'); $icon.StrokeThickness = 2
                $icon.SetResourceReference([Windows.Shapes.Shape]::StrokeProperty, 'backgroundText')
                $icon.RenderTransformOrigin = '0.5,0.5'; $rotation = [Windows.Media.RotateTransform]::new(); $icon.RenderTransform = $rotation
                $spin = [Windows.Media.Animation.DoubleAnimation]::new(0,360,[Windows.Duration]::new([timespan]::FromSeconds(1))); $spin.RepeatBehavior = [Windows.Media.Animation.RepeatBehavior]::Forever
                $rotation.BeginAnimation([Windows.Media.RotateTransform]::AngleProperty,$spin)
                $icon.Add_Unloaded({ $this.RenderTransform.BeginAnimation([Windows.Media.RotateTransform]::AngleProperty,$null) })
            }
            else {
                $icon.SetResourceReference([Windows.Shapes.Path]::DataProperty,$iconKey)
                $icon.SetResourceReference([Windows.Shapes.Shape]::FillProperty,'backgroundText')
            }
            $inline = [Windows.Documents.InlineUIContainer]::new($icon); $inline.BaselineAlignment = 'Center'
            [void]$View.RunStatus.Inlines.Add($inline)
        }
        [void]$View.RunStatus.Inlines.Add([Windows.Documents.Run]::new("$statusText - $completed of $(@($run.Steps).Count) actions finished"))
        $View.Started.Text = "Started: $(& $formatTimestamp $run.StartedUtc)"
        $View.Finished.Text = "Finished: $(& $formatTimestamp $run.FinishedUtc)"
        $View.Computer.Text = "Computer: $($run.ComputerName)"
        $View.RunError.Text = $run.Error
        $View.RunError.Visibility = if ([string]::IsNullOrWhiteSpace($run.Error)) { 'Collapsed' } else { 'Visible' }
        & $updateDuration
        $View.Steps.Children.Clear()
        $View.ActionDurations = [Collections.Generic.List[object]]::new()
        foreach ($step in $run.Steps) {
            $summary = $step.Summary
            if ($step.Data) {
                try { $summary = Get-AtomWorkflowResultSummary -ActionId $step.ActionId -Result $step.Data }
                catch { }
            }
            $card=[Windows.Controls.Border]::new()
            $card.SetResourceReference([Windows.FrameworkElement]::StyleProperty,'CustomBorder')
            $card.Margin='0,4,0,10'; $card.Padding='12'
            $stack=[Windows.Controls.StackPanel]::new(); $card.Child=$stack
            $status = if ($step.Data.Output.Cancelled) { 'Stopped' } else { & $resultLabel $step.Status }
            $heading = [Windows.Controls.StackPanel]::new(); $heading.Margin = '0,0,0,8'
            [void]$stack.Children.Add($heading)
            $title = [Windows.Controls.TextBlock]::new()
            $title.Text = $step.Name; $title.FontWeight = 'Bold'; $title.TextWrapping = 'Wrap'; $title.Margin = '0,0,0,8'
            $title.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
            [void]$heading.Children.Add($title)
            $active = $step.Status -eq 'Running' -and $liveRun
            if ($active) { $status = 'Running' }
            elseif ($step.Status -eq 'Running') { $status = 'Last recorded: Running (not verified)' }
            $statusRow = [Windows.Controls.StackPanel]::new(); $statusRow.Orientation = 'Horizontal'
            $iconKey = switch ($step.Status) { Succeeded { 'WorkflowCompletedIcon' } NeedsAttention { 'WorkflowWarningIcon' } Failed { 'WorkflowErrorIcon' } }
            if ($active -or $iconKey) {
                $icon = [Windows.Shapes.Path]::new()
                $icon.Width = 18; $icon.Height = 18; $icon.Stretch = 'Uniform'; $icon.Margin = '0,0,8,0'; $icon.VerticalAlignment = 'Center'
                if ($active) {
                    $icon.Data = [Windows.Media.Geometry]::Parse('M12,2 A10,10 0 1 1 2,12')
                    $icon.StrokeThickness = 2
                    $icon.SetResourceReference([Windows.Shapes.Shape]::StrokeProperty, 'surfaceText')
                    $icon.RenderTransformOrigin = '0.5,0.5'
                    $rotation = [Windows.Media.RotateTransform]::new(); $icon.RenderTransform = $rotation
                    $spin = [Windows.Media.Animation.DoubleAnimation]::new(0, 360, [Windows.Duration]::new([timespan]::FromSeconds(1)))
                    $spin.RepeatBehavior = [Windows.Media.Animation.RepeatBehavior]::Forever
                    $rotation.BeginAnimation([Windows.Media.RotateTransform]::AngleProperty, $spin)
                    $icon.Add_Unloaded({ $this.RenderTransform.BeginAnimation([Windows.Media.RotateTransform]::AngleProperty, $null) })
                }
                else {
                    $icon.SetResourceReference([Windows.Shapes.Path]::DataProperty, $iconKey)
                    $icon.SetResourceReference([Windows.Shapes.Shape]::FillProperty, 'surfaceText')
                }
                [void]$statusRow.Children.Add($icon)
            }
            $statusLabel = [Windows.Controls.TextBlock]::new(); $statusLabel.Text = $status; $statusLabel.VerticalAlignment = 'Center'
            if ($active) { $statusLabel.FontWeight = 'Bold' }
            $statusLabel.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
            [void]$statusRow.Children.Add($statusLabel); [void]$heading.Children.Add($statusRow)
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
                $caption = [Windows.Shapes.Path]::new()
                $caption.Width = 18; $caption.Height = 18; $caption.Stretch = 'Uniform'
                $caption.SetResourceReference([Windows.Shapes.Path]::DataProperty, $(if ($entry.Key -eq 'Open result log') { 'DescriptionIcon' } else { 'ArticleIcon' }))
                $caption.SetResourceReference([Windows.Shapes.Shape]::FillProperty, 'accentText')
                $button.Content = $caption; $button.Tag = $entry.Value
                $button.ToolTip = $entry.Key
                [Windows.Automation.AutomationProperties]::SetName($button, $entry.Key)
                $button.SetResourceReference([Windows.FrameworkElement]::StyleProperty, 'CircularActionButton')
                $button.SetResourceReference([Windows.Controls.Control]::BackgroundProperty, 'accentBrush')
                $button.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'accentText')
                $button.Margin = '8,0,0,0'
                $button.Add_Click({
                    try { Open-AtomFileInEditor -Path $this.Tag }
                    catch { [void][Windows.MessageBox]::Show("Unable to open log: $($_.Exception.Message)", 'Workflow logs', 'OK', 'Error') }
                })
                [void]$buttons.Children.Add($button)
            }
            $buttons.VerticalAlignment = 'Bottom'; $buttons.HorizontalAlignment = 'Right'
            $timestamps = [Windows.Controls.StackPanel]::new()
            foreach ($text in @("Started: $(& $formatTimestamp $step.StartedUtc)", "Finished: $(& $formatTimestamp $step.FinishedUtc)")) {
                $label = [Windows.Controls.TextBlock]::new(); $label.Text = $text; $label.TextWrapping = 'Wrap'
                if ($timestamps.Children.Count) { $label.Margin = '0,4,0,0' }
                $label.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
                [void]$timestamps.Children.Add($label)
            }
            $durationLabel = [Windows.Controls.TextBlock]::new()
            $durationLabel.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
            $timestamps.Children.Insert(0, $durationLabel)
            $timestamps.Children[1].Margin = '0,4,0,0'
            $View.ActionDurations.Add(@{ Control=$durationLabel; Started=$step.StartedUtc; Finished=$step.FinishedUtc; Active=$active })
            [void]$stack.Children.Add($timestamps)
            $results = [Windows.Controls.Grid]::new(); $results.Margin = '0,12,0,0'
            $column = [Windows.Controls.ColumnDefinition]::new(); $column.Width = '*'; [void]$results.ColumnDefinitions.Add($column)
            $column = [Windows.Controls.ColumnDefinition]::new(); $column.Width = 'Auto'; [void]$results.ColumnDefinitions.Add($column)
            if ($summary) {
                $summaryLines = [Windows.Controls.StackPanel]::new()
                foreach ($line in ($summary -split '\r?\n' | Where-Object { $_.Trim() })) {
                    $label = [Windows.Controls.TextBlock]::new(); $label.Text = $line; $label.TextWrapping = 'Wrap'
                    if ($summaryLines.Children.Count) { $label.Margin = '0,4,0,0' }
                    $label.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
                    [void]$summaryLines.Children.Add($label)
                }
                [void]$results.Children.Add($summaryLines)
            }
            [Windows.Controls.Grid]::SetColumn($buttons, 1)
            [void]$results.Children.Add($buttons); [void]$stack.Children.Add($results)
            [void]$View.Steps.Children.Add($card)
        }
        & $updateDuration
        $View.SelectedPath=$path; $View.Stamp=$stamp; $View.LiveRun=$liveRun
    }
    catch { foreach ($field in 'RunStatus','Started','Finished','Computer','RunError') { if ($View[$field]) { $View[$field].Text='' } }; if ($View.Duration) { $View.Duration.Text='' }; $View.Steps.Children.Clear(); $View.Summary.Text="Unable to read workflow log: $($_.Exception.Message)" }
    finally { $View.Updating=$false }
}

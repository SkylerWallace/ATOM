function New-AtomWorkflowQueueEntry {
    param([string]$ActionId, [string]$OptionId)

    if (!$script:workflowCatalog.ContainsKey($ActionId)) { throw "Unknown action: $ActionId" }
    $action = Resolve-AtomWorkflowSelection -Definition $script:workflowCatalog[$ActionId] -OptionId $OptionId
    [pscustomobject]@{
        EntryId  = [guid]::NewGuid().ToString()
        ActionId = $ActionId
        OptionId = $action.OptionId
        Name     = $action.Name
    }
}

function Initialize-AtomWorkflows {
    <# .SYNOPSIS
        Builds preset/action cards and a persistent editable queue on first use.
    #>
    if ($null -ne $script:workflowQueue) { return }
    foreach ($section in 'Presets','Actions') {
        $indicator=$window.FindName("workflow${section}Indicator")
        $indicator.Content=New-VectorIcon -Window $window -Icon $(if ($section -eq 'Actions') {'ArrowDropDownIcon'} else {'ArrowDropUpIcon'}) -ForegroundResource backgroundText
        $window.FindName("workflow${section}Toggle").Add_Click({
            param($sender,$e)
            $section=$sender.Tag
            $panel=$window.FindName("workflow${section}Section")
            $expanded=$panel.Visibility -ne [Windows.Visibility]::Visible
            $panel.Visibility=if($expanded){'Visible'}else{'Collapsed'}
            $window.FindName("workflow${section}Indicator").Content=New-VectorIcon -Window $window -Icon $(if($expanded){'ArrowDropUpIcon'}else{'ArrowDropDownIcon'}) -ForegroundResource backgroundText
            $sender.ToolTip=if($expanded){"Hide $($section.ToLower())"}else{"Show $($section.ToLower())"}
        })
    }
    $script:workflowCatalog=(Import-PowerShellDataFile "$atomPath/Config/WorkflowActions.psd1").Actions
    $presets=(Import-PowerShellDataFile "$atomPath/Config/WorkflowPresets.psd1").Presets
    $script:workflowQueue=[Collections.ObjectModel.ObservableCollection[object]]::new()
    $list=$window.FindName('workflowQueue')
    $list.ItemsSource=$script:workflowQueue
    $script:workflowQueue.add_CollectionChanged({ $script:workflowPresetName=$null; $window.FindName('workflowRun').IsEnabled=(!$script:workflowWorker -and $script:workflowQueue.Count -gt 0) })
    foreach ($definition in @($presets)+@($script:workflowCatalog.GetEnumerator() | Sort-Object Name | ForEach-Object { $_.Value + @{Id=$_.Key} })) {
        $preset=$definition.ContainsKey('Actions')
        $card=[Windows.Controls.Border]::new()
        if ($preset) { $card.Style=$window.Resources['CustomBorder'] }; $card.Margin='5'; $card.Padding=if($preset){'12'}else{'3'}; $card.HorizontalAlignment='Stretch'
        $stack=[Windows.Controls.StackPanel]::new(); $card.Child=$stack
        $texts = @($definition.Name, $definition.Description)
        if ($definition.MayRequireUserInput) { $texts += 'May require user input' }
        foreach ($text in $texts) {
            $label=[Windows.Controls.TextBlock]::new(); $label.Text=$text; $label.TextWrapping='Wrap'; $label.Margin=if($preset){'0,0,0,8'}else{'0,0,0,3'}; $label.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty,'surfaceText'); if ($text -eq $definition.Name) { $label.FontWeight='SemiBold'; $label.FontSize=if($preset){16}else{12} }; $null=$stack.Children.Add($label)
        }
        $selector = $null
        if ($definition.Option) {
            $optionsRow = [Windows.Controls.StackPanel]::new()
            $optionsRow.Orientation = 'Horizontal'
            $optionsRow.Margin = '0,3,0,6'
            $caption = [Windows.Controls.TextBlock]::new()
            $caption.Text = $definition.Option.Label
            $caption.VerticalAlignment = 'Center'
            $caption.Margin = '0,0,8,0'
            $caption.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
            $selector = [Windows.Controls.ComboBox]::new()
            $selector.Style = $window.FindResource('CustomComboBox')
            $selector.MinWidth = 110
            [Windows.Automation.AutomationProperties]::SetName($selector, "$($definition.Name): $($definition.Option.Label)")
            foreach ($choice in $definition.Option.Choices) {
                $item = [Windows.Controls.ComboBoxItem]::new()
                $item.Content = $choice.Name
                $item.Tag = $choice.Id
                $null = $selector.Items.Add($item)
                if ($choice.Id -eq $definition.Option.Default) { $selector.SelectedItem = $item }
            }
            $null = $optionsRow.Children.Add($caption)
            $null = $optionsRow.Children.Add($selector)
            $null = $stack.Children.Add($optionsRow)
        }
        $button=[Windows.Controls.Button]::new(); $button.Content=if($preset){'Use preset'}else{'Add to queue'}; $button.Style=$window.Resources['RoundedButton']; $button.Height=if($preset){28}else{23}; $button.MinWidth=105; $button.SetResourceReference([Windows.Controls.Control]::BackgroundProperty,'controlBrush'); $button.SetResourceReference([Windows.Controls.Control]::ForegroundProperty,'controlText'); $button.Padding='10,5'; $button.HorizontalAlignment='Left'; $button.Tag=@{Definition=$definition; Selector=$selector}
        $button.Add_Click({
            param($sender,$eventArgs)
            if ($script:workflowWorker) { return }
            $optionId=if($sender.Tag.Selector){[string]$sender.Tag.Selector.SelectedItem.Tag}else{$null}; $d=Resolve-AtomWorkflowSelection -Definition $sender.Tag.Definition -OptionId $optionId
            if ($d.ContainsKey('Actions')) {
                if ($script:workflowQueue.Count -and [Windows.MessageBox]::Show($window,'Replace the current queue with this preset?','Workflows','YesNo','Question') -ne 'Yes') { return }
                $script:workflowQueue.Clear(); $ids=$d.Actions
            } else { $ids=@(@{ActionId=$d.Id; OptionId=$d.OptionId}) }
            foreach ($id in $ids) { if ($id -is [string]) { $entry=New-AtomWorkflowQueueEntry -ActionId $id } else { $entry=New-AtomWorkflowQueueEntry -ActionId $id.ActionId -OptionId $id.OptionId }; $script:workflowQueue.Add($entry) }
            if ($d.ContainsKey('Actions')) { $script:workflowPresetName=$d.Name }
        })
        if($preset){
            $null=$stack.Children.Add($button)
        }else{
            $button.Content=New-VectorIcon -Window $window -Icon 'AddIcon' -ForegroundResource surfaceText -Size 20
            $button.Style=$window.Resources['RoundHoverButtonStyle']
            $button.SetResourceReference([Windows.Controls.Control]::BackgroundProperty,'surfaceHighlight')
            $button.ToolTip='Add to queue'
            [Windows.Automation.AutomationProperties]::SetName($button, "Add $($definition.Name) to queue")
            $button.MinWidth=0; $button.Width=26; $button.Height=26; $button.FontSize=18
            $button.VerticalAlignment='Center'; $button.Margin='8,0,0,0'
            $row=[Windows.Controls.DockPanel]::new()
            $card.Child=$null
            [Windows.Controls.DockPanel]::SetDock($button,'Right')
            $null=$row.Children.Add($button)
            $null=$row.Children.Add($stack)
            $card.Child=$row
        }
        if (!$preset) {
            $card.Tag=$button.Tag
            $card.Add_PreviewMouseLeftButtonDown({
                param($sender,$e)
                $script:workflowDragPoint=$null
                $hit=$e.OriginalSource
                while ($hit -and $hit -ne $sender) {
                    if ($hit -is [Windows.Controls.Primitives.ButtonBase] -or $hit -is [Windows.Controls.ComboBox]) { return }
                    $hit=[Windows.Media.VisualTreeHelper]::GetParent($hit)
                }
                $script:workflowDragPoint=$e.GetPosition($sender)
            })
            $card.Add_MouseMove({
                param($sender,$e)
                if ($script:workflowWorker -or $e.LeftButton -ne 'Pressed' -or !$script:workflowDragPoint) { return }
                $point=$e.GetPosition($sender)
                if ([math]::Abs($point.X-$script:workflowDragPoint.X)+[math]::Abs($point.Y-$script:workflowDragPoint.Y) -lt 8) { return }
                $optionId=if($sender.Tag.Selector){[string]$sender.Tag.Selector.SelectedItem.Tag}else{$null}
                $selection=@{ActionId=$sender.Tag.Definition.Id;OptionId=$optionId} | ConvertTo-Json -Compress
                $data=[Windows.DataObject]::new('ATOM.Action',$selection)
                $script:workflowDragPoint=$null
                [Windows.DragDrop]::DoDragDrop($sender,$data,[Windows.DragDropEffects]::Copy) | Out-Null
            })
        }
        $panel=if($preset){'workflowPresets'}else{'workflowActions'}
        $null=$window.FindName($panel).Children.Add($card)
    }
    $window.FindName('workflowClear').Add_Click({ if(!$script:workflowWorker){$script:workflowQueue.Clear()} })
    $list.AddHandler([Windows.Controls.Button]::ClickEvent,[Windows.RoutedEventHandler]{
        param($sender,$e)
        if($script:workflowWorker){return}
        $button=$e.OriginalSource
        while($button -and $button -isnot [Windows.Controls.Button]){$button=[Windows.Media.VisualTreeHelper]::GetParent($button)}
        if(!$button){return}
        $entry=$button.DataContext
        $i=$script:workflowQueue.IndexOf($entry)
        if($i -lt 0){return}
        switch($button.Tag){
            'Up' {if($i -gt 0){$script:workflowQueue.Move($i,$i-1)}}
            'Down' {if($i -lt $script:workflowQueue.Count-1){$script:workflowQueue.Move($i,$i+1)}}
            'Remove' {$script:workflowQueue.RemoveAt($i)}
        }
        $e.Handled=$true
    })
    $list.Add_PreviewMouseLeftButtonDown({
        param($sender,$e)
        $script:workflowDragEntry=$null
        $hit=$e.OriginalSource
        while($hit -and $hit -isnot [Windows.Controls.Button]){$hit=[Windows.Media.VisualTreeHelper]::GetParent($hit)}
        if($hit -and $hit.Tag -eq 'Drag'){
            $script:workflowDragPoint=$e.GetPosition($sender)
            $script:workflowDragEntry=$hit.DataContext
        }
    })
    $list.Add_PreviewMouseMove({
        param($sender,$e)
        if($script:workflowWorker -or $e.LeftButton -ne 'Pressed' -or !$script:workflowDragEntry){return}
        $point=$e.GetPosition($sender)
        if([math]::Abs($point.X-$script:workflowDragPoint.X)+[math]::Abs($point.Y-$script:workflowDragPoint.Y) -lt 8){return}
        $data=[Windows.DataObject]::new('ATOM.QueueEntry',[string]$script:workflowDragEntry.EntryId)
        $script:workflowDragEntry=$null
        [Windows.DragDrop]::DoDragDrop($sender,$data,[Windows.DragDropEffects]::Move) | Out-Null
        $e.Handled=$true
    })
    $list.Add_DragOver({
        param($sender,$e)
        $e.Handled=$true
        $e.Effects=if($script:workflowWorker){[Windows.DragDropEffects]::None}elseif($e.Data.GetDataPresent('ATOM.Action')){[Windows.DragDropEffects]::Copy}elseif($e.Data.GetDataPresent('ATOM.QueueEntry')){[Windows.DragDropEffects]::Move}else{[Windows.DragDropEffects]::None}
    })
    $list.Add_Drop({
        param($sender,$e)
        $e.Handled=$true
        if ($script:workflowWorker) { return }
        $hit=$sender.InputHitTest($e.GetPosition($sender))
        while ($hit -and $hit -isnot [Windows.Controls.ListBoxItem]) { $hit=[Windows.Media.VisualTreeHelper]::GetParent($hit) }
        $index=if($hit){$sender.ItemContainerGenerator.IndexFromContainer($hit)}else{$script:workflowQueue.Count}
        if($e.Data.GetDataPresent('ATOM.Action')) {
            $selection=[string]$e.Data.GetData('ATOM.Action') | ConvertFrom-Json
            if(!$script:workflowCatalog.ContainsKey($selection.ActionId)){return}
            $script:workflowQueue.Insert($index,(New-AtomWorkflowQueueEntry -ActionId $selection.ActionId -OptionId $selection.OptionId))
        } elseif($e.Data.GetDataPresent('ATOM.QueueEntry')) {
            $id=[string]$e.Data.GetData('ATOM.QueueEntry'); $entry=$script:workflowQueue | Where-Object EntryId -eq $id | Select-Object -First 1
            if($entry){$from=$script:workflowQueue.IndexOf($entry);$to=[math]::Min($index,$script:workflowQueue.Count-1);$script:workflowQueue.Move($from,$to);$sender.SelectedIndex=$to}
        }
    })
    $window.FindName('workflowStopScan').Add_Click({
        if ($script:workflowWorker -and $script:workflowState.CanStopScan) {
            $script:workflowState.StopRequested = $true
            $window.FindName('workflowStopScan').IsEnabled = $false
            $window.FindName('workflowStatus').Text = 'Stopping AV scan; remaining actions will be skipped.'
        }
    })
    $window.FindName('workflowLogs').Add_Click({ Show-AtomWorkflowLogWindow })
    $window.FindName('workflowRun').Add_Click({ Start-AtomWorkflow })
    $window.Add_Closing({param($sender,$eventArgs) if($script:workflowWorker){$eventArgs.Cancel=$true;$script:workflowState.StopRequested=$true;$window.FindName('workflowStatus').Text='Waiting for the current step. Close ATOM again after it stops.'}})
}

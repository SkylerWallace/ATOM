function Show-AtomWorkflowLogWindow {
    <# .SYNOPSIS
        Opens the shared live workflow and history viewer.
    #>
    param([string]$SelectPath)
    if ($script:workflowLogWindow -and $script:workflowLogWindow.IsLoaded) {
        if ($SelectPath) { $script:workflowLogWindow.Tag.SelectPath = $SelectPath }
        Update-AtomWorkflowLogView -View $script:workflowLogWindow.Tag
        [void]$script:workflowLogWindow.Activate()
        return
    }
    try { $root = Get-AtomWorkflowLogRoot }
    catch { $window.FindName('workflowStatus').Text = $_.Exception.Message; return }
    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Workflow logs" Width="515" Height="680" MinWidth="450" MinHeight="400" WindowStartupLocation="CenterOwner" Background="{DynamicResource backgroundBrush}" Foreground="{DynamicResource backgroundText}">
 <Grid Margin="0,16,0,5" LayoutTransform="{DynamicResource uiScaleTransform}">
  <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
  <StackPanel Margin="15,0,15,12">
   <TextBlock Text="Workflow log" FontWeight="SemiBold" FontSize="16" Margin="0,0,0,6"/>
   <ComboBox Name="Runs" SelectedValuePath="Tag" Style="{DynamicResource CustomComboBox}" MaxDropDownHeight="260"/>
  </StackPanel>
  <StackPanel Grid.Row="1" Margin="15,0,15,12">
   <TextBlock Text="Summary" FontWeight="SemiBold" FontSize="16" Margin="0,0,0,6"/>
   <TextBlock Name="Summary" TextWrapping="Wrap"/>
  </StackPanel>
  <TextBlock Grid.Row="2" Text="Action results" FontWeight="SemiBold" FontSize="16" Margin="15,0,15,6"/>
  <ScrollViewer Grid.Row="3" Style="{DynamicResource CustomScrollViewerStyle}" VerticalScrollBarVisibility="Visible" HorizontalScrollBarVisibility="Disabled"><StackPanel Name="Steps" Margin="15,0,10,0"/></ScrollViewer>
 </Grid>
</Window>
"@
    $viewer = [Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::new($xaml))
    $viewer.Resources.MergedDictionaries.Add($window.Resources)
    $scale = [double]$window.Resources['uiScale']
    $viewer.MaxHeight = $window.MaxHeight
    $viewer.MinWidth = 450 * $scale
    $viewer.MinHeight = [Math]::Min(400 * $scale, $viewer.MaxHeight)
    $viewer.Width = 515 * $scale
    $viewer.Height = [Math]::Min(680 * $scale, $viewer.MaxHeight)
    $viewer.Owner = $window
    $viewer.FontFamily = $window.FontFamily
    $viewer.FontSize = $window.FontSize
    $view = @{
        Window=$viewer; Root=$root; Runs=$viewer.FindName('Runs'); Steps=$viewer.FindName('Steps')
        Summary=$viewer.FindName('Summary')
        SelectPath=$SelectPath; SelectedPath=$null; Stamp=0; LastHistory=[datetime]::MinValue; HistoryKey=''; HistoryCache=@{}; Updating=$false
    }
    $timer = [Windows.Threading.DispatcherTimer]::new()
    $timer.Interval = [timespan]::FromSeconds(1)
    $timer.Tag = $view
    $view.Timer = $timer
    $viewer.Tag = $view
    $view.Runs.Tag = $view
    $configurePopup = {
        param($sender,$eventArgs)
        [void]$sender.ApplyTemplate()
        $popup = $sender.Template.FindName('Popup', $sender)
        if (!$popup) { return }
        $popup.PlacementTarget = $sender
        $popup.CustomPopupPlacementCallback = [Windows.Controls.Primitives.CustomPopupPlacementCallback]{
            param($popupSize,$targetSize,$offset)
            return [Windows.Controls.Primitives.CustomPopupPlacement[]]@(
                [Windows.Controls.Primitives.CustomPopupPlacement]::new(
                    [Windows.Point]::new(0,0),
                    [Windows.Controls.Primitives.PopupPrimaryAxis]::None
                )
            )
        }
    }
    $view.Runs.Add_Loaded($configurePopup)
    $view.Runs.Add_DropDownOpened($configurePopup)
    $view.Runs.Add_SelectionChanged({ param($sender,$eventArgs) if (!$sender.Tag.Updating) { Update-AtomWorkflowLogView -View $sender.Tag } })
    $timer.Add_Tick({ param($sender,$eventArgs) Update-AtomWorkflowLogView -View $sender.Tag })
    $viewer.Add_Closed({ param($sender,$eventArgs) $sender.Tag.Timer.Stop(); $script:workflowLogWindow=$null })
    $script:workflowLogWindow = $viewer
    Update-AtomWorkflowLogView -View $view
    $timer.Start()
    $viewer.Show()
}

function New-AtomSearchBarXaml {
    <#
    .SYNOPSIS
        Builds the shared search and status layout, with page-specific action slots.
    #>
    param(
        [Parameter(Mandatory)]
        [Hashtable]$Names,
        [String]$ToolTip = 'Search (Ctrl+F)',
        [String]$Margin = '0',
        [String]$SearchActions = '',
        [String]$StatusActions = ''
    )

    $escapedToolTip = [Security.SecurityElement]::Escape($ToolTip)
    $progress = if ($Names.Progress) {
        '<ProgressBar Name="' + $Names.Progress + '" Height="2" Minimum="0" Maximum="100" Value="0" Background="Transparent" Foreground="{DynamicResource surfaceText}" IsHitTestVisible="False"/>'
    } else { '' }
    return @"
<Border Name="$($Names.Border)" Style="{StaticResource CustomBorder}" Padding="5" Margin="$Margin">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="25"/>
        </Grid.RowDefinitions>
        <Grid>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <Button Name="$($Names.Clear)" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Clear search box"/>
            <ContentControl Name="$($Names.Icon)" Grid.Column="1" Opacity="0.38" Width="16" Height="16" Margin="0"/>
            <TextBlock Name="$($Names.Placeholder)" Grid.Column="2" Text="Search" Foreground="{DynamicResource surfaceText}" TextAlignment="Left" VerticalAlignment="Center" Opacity="0.69" Margin="5" IsHitTestVisible="False"/>
            <TextBox Name="$($Names.Input)" Grid.Column="2" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" TextAlignment="Left" VerticalAlignment="Center" Margin="5" ToolTip="$escapedToolTip"/>
            <StackPanel Grid.Column="3" Orientation="Horizontal">$SearchActions</StackPanel>
        </Grid>
        <Grid Grid.Row="1" Height="2" Margin="5,2">
            <Border Height="1" Background="{DynamicResource surfaceText}" Opacity="0.44"/>
            $progress
        </Grid>
        <Grid Grid.Row="2">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <TextBlock Name="$($Names.Status)" Foreground="{DynamicResource surfaceText}" FontSize="10" HorizontalAlignment="Stretch" VerticalAlignment="Center" TextTrimming="CharacterEllipsis" Margin="5"/>
            <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">$StatusActions</StackPanel>
        </Grid>
    </Grid>
</Border>
"@
}

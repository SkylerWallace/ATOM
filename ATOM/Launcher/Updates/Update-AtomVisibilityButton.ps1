function Update-AtomVisibilityButton {
    if ($atomSettings.ShowHiddenPlugins.Value) {
        $visibilityButton.ToolTip = 'Hide hidden plugins'
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'visibilityButton' = 'VisibilityIcon' }
    } else {
        $visibilityButton.ToolTip = 'Show hidden plugins'
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'visibilityButton' = 'VisibilityOffIcon' }
    }
}

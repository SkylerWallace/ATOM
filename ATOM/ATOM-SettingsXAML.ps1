$settingsXaml =
"
<StackPanel MaxWidth='300' Margin='5'>
	<!-- NAV STACKPANEL -->
	<StackPanel Orientation='Horizontal'>
		<Button Name='navButton' Width='25' Height='25' Style='{StaticResource RoundHoverButtonStyle}' Margin='5'/>
		<TextBlock Text='Settings' FontSize='20' FontWeight='Bold' Foreground='{DynamicResource backgroundText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
	</StackPanel>

	<!-- UPDATE STACKPANEL -->
	<Border Style='{StaticResource CustomBorder}' HorizontalAlignment='Stretch' Margin='5' Padding='5'>
		<StackPanel>
			<Grid>
				<TextBlock Text='ATOM Core Version:' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<TextBlock Name='versionText' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Right' VerticalAlignment='Center' Margin='5'/>
			</Grid>
			
			<Grid>
				<TextBlock Text='Hash:' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<TextBlock Name='versionHash' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Right' VerticalAlignment='Center' Margin='5'/>
			</Grid>
			
			<Grid>
				<TextBlock Text='Last checked:' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<TextBlock Name='updateText' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Right' VerticalAlignment='Center' Margin='5'/>
			</Grid>
			
			
			<WrapPanel Orientation='Horizontal' HorizontalAlignment='Center'>
				<Button Name='checkUpdateButton' Width='130' Background='{DynamicResource accentBrush}' Foreground='{DynamicResource accentText}' HorizontalAlignment='Center' Style='{StaticResource RoundedButton}' Margin='5' ToolTip='Check GitHub for ATOM updates'>
					<StackPanel Orientation='Horizontal'>
						<Image Name='checkUpdatesImage' Width='16' Height='16' Margin='5'/>
						<TextBlock Text='Check for Updates' FontSize='11' VerticalAlignment='Center' Margin='0,5,5,5'/>
					</StackPanel>
				</Button>
				<Button Name='updateButton' Width='130' Background='{DynamicResource accentBrush}' Foreground='{DynamicResource accentText}' HorizontalAlignment='Center' Style='{StaticResource RoundedButton}' IsEnabled='False' Opacity='0.2' Margin='5' ToolTip='Updating ATOM will not remove custom plugins'>
					<StackPanel Orientation='Horizontal'>
						<Image Name='updateImage' Width='16' Height='16' Margin='5'/>
						<TextBlock Text='Update ATOM' FontSize='11' VerticalAlignment='Center' Margin='0,5,5,5'/>
					</StackPanel>
				</Button>
			</WrapPanel>
		</StackPanel>
	</Border>

	<!-- SWITCHES STACKPANEL -->
	<Border Style='{StaticResource CustomBorder}' HorizontalAlignment='Stretch' Margin='5' Padding='5'>
		<StackPanel>
			<!-- SAVE ENCRYPTION KEYS -->
			<Grid ToolTip='Save computers encryption key to $logsPath'>
				<TextBlock Text='Save Encryption Keys' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<ToggleButton Name='keysSwitch' HorizontalAlignment='Right' VerticalAlignment='Center' Margin='5'/>
			</Grid>
			
			<!-- LAUNCH ATOM ON RESTART -->
			<Grid ToolTip='Start ATOM when computer reboots'>
				<TextBlock Text='Launch on Restart' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<ToggleButton Name='restartSwitch' HorizontalAlignment='Right' VerticalAlignment='Center' Margin='5'/>
			</Grid>
			
			<!-- SHOW PLUGIN TOOLTIPS -->
			<Grid ToolTip='Show tooltips when hovering over plugins'>
				<TextBlock Text='Show Plugin Tooltips' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<ToggleButton Name='tooltipSwitch' HorizontalAlignment='Right' VerticalAlignment='Center' Margin='5'/>
			</Grid>
			
			<!-- SHOW HIDDEN PLUGINS  -->
			<Grid ToolTip='Show Hidden Plugins for each plugin category'>
				<TextBlock Text='Show Hidden Plugins' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<ToggleButton Name='hiddenSwitch' HorizontalAlignment='Right' VerticalAlignment='Center' Margin='5'/>
			</Grid>
			
			<!-- SHOW ADDITIONAL PLUGINS -->
			<Grid ToolTip='Show Additional Plugins in plugin categories'>
				<TextBlock Text='Show Additional Plugins' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<ToggleButton Name='additionalSwitch' HorizontalAlignment='Right' VerticalAlignment='Center' Margin='5'/>
			</Grid>
			
			<!-- STARTUP COLUMNS -->
			<Grid ToolTip='Default plugin category columns when starting ATOM'>
				<TextBlock Text='Startup Columns' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<StackPanel Name='startupColumnsStackPanel' Orientation='Horizontal' HorizontalAlignment='Right' VerticalAlignment='Center'/>
			</Grid>
			
			<!-- SAVE BUTTONS -->
			<WrapPanel Orientation='Horizontal' HorizontalAlignment='Center'>
				<Button Name='defaultSwitchButton' Width='130' Background='{DynamicResource accentBrush}' HorizontalAlignment='Center' Style='{StaticResource RoundedButton}' Margin='5'>
					<StackPanel Orientation='Horizontal'>
						<Image Name='restoreImage' Width='16' Height='16' Margin='5'/>
						<TextBlock Text='Restore Defaults' FontSize='11' Foreground='{DynamicResource accentText}' VerticalAlignment='Center'/>
					</StackPanel>
				</Button>
				<Button Name='saveSwitchButton' Width='130' Background='{DynamicResource accentBrush}' HorizontalAlignment='Center' Style='{StaticResource RoundedButton}' Margin='5'>
					<StackPanel Orientation='Horizontal'>
						<Image Name='saveImage' Width='16' Height='16' Margin='5'/>
						<TextBlock Text='Save Settings' FontSize='11' Foreground='{DynamicResource accentText}' VerticalAlignment='Center'/>
					</StackPanel>
				</Button>
			</WrapPanel>
		</StackPanel>
	</Border>
	
	<!-- COLORS -->
	<Border Style='{StaticResource CustomBorder}' HorizontalAlignment='Stretch' Margin='5' Padding='5'>
		<WrapPanel Name='colorsPanel' Orientation='Horizontal' HorizontalAlignment='Center'/>
	</Border>
	
	<!-- PATH STACKPANEL -->
	<Border Style='{StaticResource CustomBorder}' HorizontalAlignment='Stretch' Margin='5' Padding='5'>
		<StackPanel>
			<Grid>
				<TextBlock Text='ATOM Path' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<Button Name='pathButton' Height='25' Width='25' HorizontalAlignment='Right' VerticalAlignment='Center' Style='{StaticResource RoundHoverButtonStyle}' Margin='5' ToolTip='Open in Explorer'/>
			</Grid>
			<TextBox Name='pathTextBox' Text='$atomPath' Background='Transparent' Foreground='{DynamicResource surfaceText}' BorderBrush='Transparent' TextAlignment='Center' VerticalAlignment='Center' IsReadOnly='True' Margin='5'/>
		</StackPanel>
	</Border>
		
	<!-- GITHUB STACKPANEL -->
	<Border Style='{StaticResource CustomBorder}' HorizontalAlignment='Stretch' Margin='5' Padding='5'>
		<StackPanel>
			<Grid>
				<StackPanel Orientation='Horizontal' HorizontalAlignment='Left'>
					<Image Name='githubImage' Width='20' Height='20' VerticalAlignment='Center' Margin='5'/>
					<TextBlock Text='GitHub' FontSize='12' Foreground='{DynamicResource surfaceText}' VerticalAlignment='Center' Margin='5'/>
				</StackPanel>
				<StackPanel Orientation='Horizontal' HorizontalAlignment='Right'>
					<Button Name='githubLinkButton' Height='25' Width='25' VerticalAlignment='Center' Style='{StaticResource RoundHoverButtonStyle}' Margin='5' ToolTip='Copy URL to clipboard'/>
					<Button Name='githubLaunchButton' Height='25' Width='25' VerticalAlignment='Center' Style='{StaticResource RoundHoverButtonStyle}' Margin='5' ToolTip='Open URL in web browser'/>
				</StackPanel>
			</Grid>
			<TextBox Name='githubTextBox' Background='Transparent' Foreground='{DynamicResource surfaceText}' BorderBrush='Transparent' TextAlignment='Center' VerticalAlignment='Center' Margin='5' IsReadOnly='True'/>
		</StackPanel>
	</Border>
</StackPanel>
"
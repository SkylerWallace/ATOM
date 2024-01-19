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
			<TextBlock Name='versionText' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Center' VerticalAlignment='Center' Margin='5'/>
			<TextBlock Name='versionHash' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Center' VerticalAlignment='Center' Margin='5'/>
			<Button Name='updateButton' Background='{DynamicResource accentBrush}' Foreground='{DynamicResource accentText}' MaxWidth='250' HorizontalAlignment='Center' Style='{StaticResource RoundedButton}' Margin='5'>
				<StackPanel Orientation='Horizontal'>
					<Image Name='updateImage' Width='16' Height='16' Margin='5'/>
					<TextBlock Text='Check for Updates' VerticalAlignment='Center' Margin='0,5,5,5'/>
				</StackPanel>
			</Button>
			<TextBlock Name='updateText' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Center' VerticalAlignment='Center' Margin='5'/>
		</StackPanel>
	</Border>

	<!-- SWITCHES STACKPANEL -->
	<Border Style='{StaticResource CustomBorder}' HorizontalAlignment='Stretch' Margin='5' Padding='5'>
		<StackPanel>
			<!-- SAVE ENCRYPTION KEYS -->
			<Grid>
				<TextBlock Text='Save Encryption Keys' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<ToggleButton Name='keysSwitch' HorizontalAlignment='Right' VerticalAlignment='Center' Margin='5'/>
			</Grid>
			
			<!-- LAUNCH ATOM ON RESTART -->
			<Grid>
				<TextBlock Text='Launch on Restart' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<ToggleButton Name='restartSwitch' HorizontalAlignment='Right' VerticalAlignment='Center' Margin='5'/>
			</Grid>
			
			<!-- SHOW ADDITIONAL PLUGINS -->
			<Grid>
				<TextBlock Text='Show Additional Plugins' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<ToggleButton Name='additionalSwitch' HorizontalAlignment='Right' VerticalAlignment='Center' Margin='5'/>
			</Grid>
			
			<!-- STARTUP COLUMNS -->
			<Grid>
				<TextBlock Text='Startup Columns' FontSize='12' Foreground='{DynamicResource surfaceText}' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='5'/>
				<StackPanel Name='startupColumnsStackPanel' Orientation='Horizontal' HorizontalAlignment='Right' VerticalAlignment='Center'/>
			</Grid>
			
			<!-- SAVE BUTTONS -->
			<WrapPanel Orientation='Horizontal' HorizontalAlignment='Center'>
				<Button Name='defaultSwitchButton' Width='130' Background='{DynamicResource accentBrush}' HorizontalAlignment='Center' Style='{StaticResource RoundedButton}' Margin='5'>
					<StackPanel Orientation='Horizontal'>
						<Image Name='restoreImage' Width='16' Height='16' Margin='5'/>
						<TextBlock Text='Restore Defaults' Foreground='{DynamicResource accentText}' VerticalAlignment='Center'/>
					</StackPanel>
				</Button>
				<Button Name='saveSwitchButton' Width='130' Background='{DynamicResource accentBrush}' HorizontalAlignment='Center' Style='{StaticResource RoundedButton}' Margin='5'>
					<StackPanel Orientation='Horizontal'>
						<Image Name='saveImage' Width='16' Height='16' Margin='5'/>
						<TextBlock Text='Save Settings' Foreground='{DynamicResource accentText}' VerticalAlignment='Center'/>
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
				<Button Name='pathButton' Height='25' Width='25' HorizontalAlignment='Right' VerticalAlignment='Center' Style='{StaticResource RoundHoverButtonStyle}'/>
			</Grid>
			<TextBox Name='pathTextBox' Text='$atomPath' Background='Transparent' Foreground='{DynamicResource surfaceText}' BorderBrush='Transparent' TextAlignment='Center' VerticalAlignment='Center' Margin='5' IsReadOnly='True'/>
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
					<Button Name='githubLinkButton' Height='25' Width='25' VerticalAlignment='Center' Style='{StaticResource RoundHoverButtonStyle}'/>
					<Button Name='githubLaunchButton' Height='25' Width='25' VerticalAlignment='Center' Style='{StaticResource RoundHoverButtonStyle}'/>
				</StackPanel>
			</Grid>
			<TextBox Name='githubTextBox' Background='Transparent' Foreground='{DynamicResource surfaceText}' BorderBrush='Transparent' TextAlignment='Center' VerticalAlignment='Center' Margin='5' IsReadOnly='True'/>
		</StackPanel>
	</Border>
</StackPanel>
"
Add-Type -AssemblyName PresentationFramework

# Declaring relative paths needed for rest of script
$atomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
$iconsPath = Join-Path $dependenciesPath "Icons"
$settingsPath = Join-Path $dependenciesPath "Settings"

# Import ATOM core resources
. (Join-Path $dependenciesPath "ATOM-Module.ps1")

[xml]$xaml = @"
<Window
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	Title="PassCrack"
	Background="Transparent"
	AllowsTransparency="True"
	WindowStyle="None"
	SizeToContent="WidthAndHeight"
	UseLayoutRounding="True"
	RenderOptions.BitmapScalingMode="HighQuality">
	
	<Window.Resources>
		$resourceDictionary
	</Window.Resources>
	
	<WindowChrome.WindowChrome>
		<WindowChrome ResizeBorderThickness="0" CaptionHeight="0" CornerRadius="10"/>
	</WindowChrome.WindowChrome>

	<Border BorderBrush="Transparent" BorderThickness="0" Background="{DynamicResource backgroundBrush}" CornerRadius="5">
		<Grid>
			<Grid.RowDefinitions>
				<RowDefinition Height="60"/>
				<RowDefinition Height="*"/>
				<RowDefinition Height="Auto"/>
				<RowDefinition Height="Auto"/>
			</Grid.RowDefinitions>
			<Grid Grid.Row="0">
				<Border Background="{DynamicResource primaryBrush}" CornerRadius="5,5,0,0"/>
				<Image Name="logo" Width="40" Height="40" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="15,0,0,0"/>
				<TextBlock Text="PassCrack" FontSize="20" FontWeight="Bold" VerticalAlignment="Center" HorizontalAlignment="Left" Foreground="{DynamicResource primaryText}" Margin="60,0,0,0"/>
				<Button Name="minimizeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,45,0" ToolTip="Minimize"/>
				<Button Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,10,0" ToolTip="Close"/>
			</Grid>
			<Grid Grid.Row="1" Margin="5">
				<Border Style="{StaticResource CustomBorder}" Margin="0,5,0,0" Padding="5">
					<StackPanel Name="usersPanel"/>
				</Border>
			</Grid>
			<Grid Grid.Row="2" Margin="5">
				<Border Style="{StaticResource CustomBorder}" Margin="0,5,0,0" Padding="5">
					<Grid ToolTip="Enables built-in administrator account &#x0a;Recommend not leaving enabled permanently due to security risk">
						<TextBlock Text="Enable Admin Account" Foreground="{DynamicResource primaryText}" HorizontalAlignment="Left" Margin="5"/>
						<ToggleButton Name="adminToggle" HorizontalAlignment="Right" Margin="5"/>
					</Grid>
				</Border>
			</Grid>
			<Grid Grid.Row="3" Margin="5">
				<StackPanel>
					<TextBlock Name="samMessage" Text="WARNING: IN BETA" VerticalAlignment="Center" HorizontalAlignment="Center" Foreground="{DynamicResource primaryText}" Margin="5"/>
					<TextBlock Name="statusMessage" VerticalAlignment="Center" HorizontalAlignment="Center" Foreground="{DynamicResource primaryText}" Margin="5"/>
				</StackPanel>
			</Grid>
		</Grid>
	</Border>
</Window>
"@

# Load XAML
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Assign variables to elements in XAML
$logo = $window.FindName("logo")
$minimizeButton = $window.FindName("minimizeButton")
$closeButton = $window.FindName("closeButton")
$usersPanel = $window.FindName("usersPanel")
$adminToggle = $window.FindName("adminToggle")
$samMessage = $window.FindName("samMessage")
$statusMessage = $window.FindName("statusMessage")

$logo.Source = Join-Path $iconsPath "Plugins\PassCrack.png"

# Set icon sources
$primaryResources = @{
	"minimizeButton" = "Minimize"
	"closeButton" = "Close"
}

Set-ResourceIcons -IconCategory "Primary" -ResourceMappings $primaryResources

# UI event handlers
$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({ $this.DragMove() })

# Early exit if not in PE or registry hives not loaded
$inPE = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
$samMounted = Test-Path "HKLM:\RemoteOS-HKLM-SAM"
$mountedDrive = (Get-ItemProperty -Path "HKLM:\SOFTWARE\ATOM" -Name "MountedDrive").MountedDrive
if (!$inPE -or !$samMounted -or $mountedDrive -eq $null) {
	[System.Windows.MessageBox]::Show("PassCrack requires the following conditions met: `n`n 1. Running in PE (Windows RE or Windows PE) `n 2. Reg hives mounted with ATOM's MountOS", 'PassCrack Error', 'OK', 'Warning')
	return
}

# Username testing
$regKey1 = "HKLM\RemoteOS-HKLM-SAM\SAM\Domains\Account\Users\Names"
$regExport1 = Join-Path $env:TEMP "users.reg"
reg export $regKey1 $regExport1 /y  | Out-Null
$regFile1Contents = Get-Content $regExport1

$userNameTable = [ordered]@{}

for ($i = 0; $i -lt $regFile1Contents.Count; $i++) {
	if ($regFile1Contents[$i] -match "\[HKEY_LOCAL_MACHINE\\RemoteOS-HKLM-SAM\\SAM\\Domains\\Account\\Users\\Names\\(.+)\]") {
		# Get userName
		$userName = $matches[1]
		
		# Get hexId
		if ($regFile1Contents[$i + 1] -match "@=hex\((\w+)\):") {
			$hexId = $matches[1]
		}
		
		# Get regPath
		$regPath = Resolve-Path "HKLM:\RemoteOS-HKLM-SAM\SAM\Domains\Account\Users\*$hexId"
		
		# Check if local account or MS account
		if ((Get-Item -Path $regPath).Property -like "Internet*") {
			$accountType = "Microsoft"
		} else {
			$accountType = "Local"
		}
		
		# Add to hashtable
		$userNameTable[$userName] = @{
			'HexId' = $hexId
			'RegPath' = $regPath
			'AccountType' = $accountType
		}
	}
}

## Get V registry values for each username
# Can't use Get-ItemProperty because it corrupts large reg binaries
# Workaround: export .reg file and parse contents
$regKey2 = "HKLM\RemoteOS-HKLM-SAM\SAM\Domains\Account\Users"
$regExport2 = Join-Path $env:TEMP "values.reg"
reg export $regKey2 $regExport2 /y | Out-Null
$regFile2Contents = Get-Content $regExport2

for ($i = 0; $i -lt $regFile2Contents.Count; $i++) {
	$line = $regFile2Contents[$i]

	# Match reg file's user to userNameTable
	if ($line -match "\[HKEY_LOCAL_MACHINE\\RemoteOS-HKLM-SAM\\SAM\\Domains\\Account\\Users\\0(.+)\]") {
		$keyId = $matches[1]
		$userName = $userNameTable.Keys | Where-Object { $keyId -match $userNameTable[$_].HexId } | Select-Object $_
		continue
	}
	
	# Get hex value for V reg binary key
	if ($line.StartsWith('"V"=hex:')) {
		# Trim unnecessary characters from lines
		$line = $line.Replace('"V"=hex:', "")
		if ($line.EndsWith("\")) {
			$line = ($line -replace "\\$").Trim()
		}
		
		# Set hexValue to first line of V & increment line counter
		$hexValue = $line
		$i++
		
		# Get all lines for V value & put into hexValue variable
		for ($j = $i; !$regFile2Contents[$j].StartsWith('"') -and ![string]::IsNullOrWhiteSpace($regFile2Contents[$j]); $j++) {
			# Trim unnecessary characters from lines
			if ($regFile2Contents[$j].EndsWith("\")) {
				$regFile2Contents[$j] = ($regFile2Contents[$j] -replace "\\$").Trim()
			} else {
				$regFile2Contents[$j] = ($regFile2Contents[$j]).Trim()
			}
			
			# Add line to hexValue
			$hexValue += $regFile2Contents[$j]
		}
		
		# Convert hex string to decimal array so it can be parsed by Set-ItemProperty
		$decimalArray = New-Object System.Collections.ArrayList
		foreach ($couplet in $hexValue.Split(",")) {
			$decimalArray += [convert]::ToInt32($couplet, 16)
		}
		
		# Determine if account has password requirement
		if (($decimalArray[160] -eq 0) -and ($decimalArray[172] -eq 0)) {
			$passwordRequirement = "Unlocked"
		} else {
			$passwordRequirement = "Locked"
		}
		
		# Make modifications to decimal array to remove account password
		$decimalArray[160] = 0
		$decimalArray[172] = 0
		
		# Add values to hashtable
		$userNameTable[$userName] += @{
			'PasswordRequirement' = $passwordRequirement
			'Value' = $decimalArray
		}
	}
}

# Functions
function Backup-Sam {
	# Early exit if SAM has already been backed up
	if ($samBackedUp) {
		return
	}
	
	$samPath = Join-Path $env:TEMP "\SAM"
	$samBase = Join-Path $mountedDrive "Windows\System32\config\SAM"
	$samBackup = $samBase + ".backup"
	if (Test-Path $samBackup) {
		for ($i = 1; (Test-Path $samBackup); $i++) {
			$samBackup = $samBase + ".backup" + $i
		}
	}
	
	Copy-Item $samPath $samBackup -Force | Out-Null
	
	if ($LASTEXITCODE -ne 0) {
		$samMessage.Text = "FAILED TO CREATE BACKUP SAM FILE`n"
		return
	}
	
	# Marking that SAM has been backed up so extra backups aren't made
	$script:samBackedUp = $true
	$samMessage.Text = "Backup: $samBackup"
}

function Add-UserName {
	param (
		[Parameter(Mandatory=$true)]
		[string]$userName,
		[string]$accountType,
		[string]$passwordRequirement,
		[string]$regPath,
		$value
	)
	
	$stackPanel = New-Object System.Windows.Controls.StackPanel
	$stackPanel.Orientation = "Horizontal"
	
	$nameTextBlock = New-Object System.Windows.Controls.TextBlock
	$nameTextBlock.Text = $userName
	$nameTextBlock.Foreground = $surfaceText
	$nameTextBlock.Width = 160
	$nameTextBlock.Margin = "5"
	$nameTextBlock.VerticalAlignment = "Center"
	$stackPanel.Children.Add($nameTextBlock) | Out-Null
	
	$accountTextBlock = New-Object System.Windows.Controls.TextBlock
	$accountTextBlock.Text = $accountType
	$accountTextBlock.Foreground = $surfaceText
	$accountTextBlock.Width = 80
	$accountTextBlock.Margin = "5"
	$accountTextBlock.VerticalAlignment = "Center"
	$stackPanel.Children.Add($accountTextBlock) | Out-Null
	
	$lockTextBlock = New-Object System.Windows.Controls.TextBlock
	$lockTextBlock.Text = $passwordRequirement
	$lockTextBlock.Foreground = $surfaceText
	$lockTextBlock.Width = 80
	$lockTextBlock.Margin = "5"
	$lockTextBlock.VerticalAlignment = "Center"
	$stackPanel.Children.Add($lockTextBlock) | Out-Null
	
	if ($passwordRequirement -eq "Locked") {
		$button = New-Object System.Windows.Controls.Button
		$button.Width = 20; $button.Height = 20
		$button.Margin = 5
		$button.Style = $window.FindResource("RoundHoverButtonStyle")
		$button.Tag = @($userName, $accountType, $regPath, $value, $lockTextBlock, $accountTextBlock)
		$button.ToolTip = "Remove password"
		$button.Content =
			if ($surfaceIcons -eq "Light") {
				New-Object System.Windows.Controls.Image -Property @{ Source = Join-Path $iconsPath "Lock (Light).png" }
			} elseif ($surfaceIcons -eq "Dark") {
				New-Object System.Windows.Controls.Image -Property @{ Source = Join-Path $iconsPath "Lock (Dark).png" }
			}
		$button.Add_Click({
			# Backup SAM reg hive	
			Backup-Sam
			
			# Loop script if backup failed
			if ($LASTEXITCODE -ne 0) {
				$statusMessage.Text = "ABORTING PASSWORD REMOVAL"
				return
			}
			
			# Get values from button tag
			$userName = $this.Tag[0]
			$accountType = $this.Tag[1]
			$regPath = $this.Tag[2]
			$value = $this.Tag[3]
			
			# Remove password
			Set-ItemProperty -Path $regPath -Name "V" -Value $value
			
			# Return script if failed to remove password
			if ($LASTEXITCODE -ne 0) {
				$statusMessage.Text = "TRY REMOUNTING OS W/ MOUNTOS"
				return
			}
			
			# Convert MS account to local account
			if ($accountType -eq "Microsoft") {
				Remove-ItemProperty -Path $regPath -Name "InternetUserName" -Force
				Remove-ItemProperty -Path $regPath -Name "InternetProviderGUID" -Force
				Remove-ItemProperty -Path $regPath -Name "InternetSID" -Force
				Remove-ItemProperty -Path $regPath -Name "InternetUID" -Force
			}
			
			# Success message
			$statusMessage.Text = "Password removed successfully.`n"
			
			# Update status of password requirement and account type
			$this.Tag[4].Text = "Unlocked"
			if ($accountType -eq "Microsoft") { $this.Tag[5].Text = "Local" }
			
			# Disable button
			$window.Dispatcher.Invoke([action]{ $this.IsEnabled = $false; $this.Content = $null })
		})
		
		$stackPanel.Children.Add($button) | Out-Null
	}
	
	$usersPanel.Children.Add($stackPanel) | Out-Null
}

# Add users to listbox
$userNameTable.Keys | ForEach-Object {
	$userName = $_
	$regPath = $userNameTable[$_]['RegPath']
	$passwordRequirement = $userNameTable[$_]['PasswordRequirement']
	$accountType = $userNameTable[$_]['AccountType']
	$value = $userNameTable[$_]['Value']
	
	Add-UserName -UserName $userName -AccountType $accountType -PasswordRequirement $passwordRequirement -RegPath $regPath -Value $value
}

# Add admin account controls
$adminRegKey = "HKLM:\RemoteOS-HKLM-SAM\SAM\Domains\Account\Users\000001F4"
if (!(Test-Path $adminRegKey)) {
	$adminToggle.IsEnabled = $false
	$adminToggle.Opacity = 0.38
} else {
	# Get initial value of admin's F reg value
	$adminValue = (Get-ItemProperty -Path $adminRegKey -Name "F").F
	
	# Set initial state of toggle
	if ($adminValue[56] -eq 0) {
		$adminToggle.IsChecked = $true
	} else {
		$adminToggle.IsChecked = $false
	}
	
	# Toggle event handler
	$adminToggle.Add_Click({
		# Backup SAM
		Backup-Sam
		
		# Toggle actions
		if ($adminToggle.IsChecked) {
			# Enable admin
			$adminValue[56] = 16
			Set-ItemProperty -Path $adminRegKey -Name "F" -Type "Binary" -Value $adminValue
			$statusMessage.Text = "Administrator account enabled."
		} else {
			# Disable admin
			$adminValue[56] = 17
			Set-ItemProperty -Path $adminRegKey -Name "F" -Type "Binary" -Value $adminValue
			$statusMessage.Text = "Administrator account disabled."
		}
	})
}

$window.ShowDialog() | Out-Null
# ATOM (A Tool Of Mine)

<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/assets/ATOM%20Logo%20(Light).png">
  <source media="(prefers-color-scheme: light)" srcset=".github/assets/ATOM%20Logo%20(Dark).png">
  <img alt="ATOM logo" src=".github/assets/ATOM%20Logo%20(Light).png"> <!-- Fallback for browsers that do not support picture -->
</picture>

## What is ATOM?
ATOM is a launcher for PowerShell scripts, batch scripts, and executables. Although ATOM comes with many plugins preloaded, its modular nature invites people to create and add their own scripts.
ATOM is coded in PowerShell and uses WPF for its UI.

## How to Launch ATOM
**Launch directly from PowerShell (requires internet)**
```sh
irm http://tinyurl.com/run-atom | iex
```

**Direct download links**
- [Latest build](https://github.com/SkylerWallace/ATOM/archive/refs/heads/main.zip)
- [Latest release](https://github.com/SkylerWallace/ATOM/releases/latest/download/ATOM.zip)

> [!IMPORTANT]
> **Double-click** plugins to launch.

## Recommended Setup
Below is the recommended way to setup ATOM for continued use:
1. Download the latest ATOM build
2. **[Optional]** Extract the latest build to the root of a flash drive
3. Launch ATOM.bat from the flash drive
4. Double-click the "ATOM Store" plugin
5. Within ATOM Store, select PowerShell Core and any other plugins you may regularly use, click the "Run" button and exit when completed

## PE Functionality
If ATOM is on the root of a flash drive that has Windows PE installed on it, you can click the "PE" button in the titlebar.
Clicking this button will reboot the computer to Windows PE.

If you are booted to Windows PE or RE, you can launch ATOM by performing the following:
1. Launch Command Prompt
2. Navigate to the directory where ATOM is located. This is typically done with the following command:
   ```cd D:```
3. Launch ATOM.bat. This can be done with the following command (press 'Enter' twice):
   ```ATOM.bat```

When ATOM is launched in Windows PE or Windows RE, you will have a "MountOS" button in the titlebar.
Clicking this button will launch MountOS which allows you to mount the registry hives from a selected drive.
Performing this allows some plugins to work in PE/RE.

## Customizing ATOM
**Adding Plugins Categories**

Plugin categories are defined by the `Category` property in `ATOM\Config\Plugins.ps1`. Custom plugins and local category overrides can define this property in `ATOM\Config\PluginsUser.ps1`.

**Adding Plugins**

1. Navigate to "ATOM\Plugins".
2. Place your PowerShell script, batch script, or executable directly in the folder.
3. Add its metadata to the `userPrograms` hashtable in `ATOM\Config\PluginsUser.ps1`. Plugins without a category appear under `Uncategorized`.
4. If ATOM is already open, click the Refresh ↻ icon.

```powershell
$userPrograms = [ordered]@{
    'My Plugin' = @{
        Category  = 'Misc'
        ToolTip   = 'Description of my plugin'
        WorksInOs = $true
        WorksInPe = $false
    }
}
```

**Adding Plugin Icons**

1. Navigate to "ATOM\Resources\Icons\Plugins"
2. Place plugin's PNG file in directory (PNG file must have same name as the plugin, EX: if plugin is "Plugin.ps1", PNG icon must be "Plugin.png")

**Configure Plugin Parameters**

You can customize parameters such as category, aliases, tags, tooltips, visibility, and silent launching.

1. Navigate to `ATOM\Config` and open or create `PluginsUser.ps1`.
2. Add entries to the `userPrograms` hashtable. User values override matching properties from `Plugins.ps1`.

## ATOM Plugins Info
<details><summary><b>ATOM</b></summary>

  **The star of the show!**
  
  ![img](.github/assets/ATOM%20image.png)
</details>

<details><summary><b>ATOM Notes</b></summary>

  **Take notes as you repair a computer**
  - Type notes in the "Notes field", initials in the "Initials" field
  - Once both fields are filled, click the + button or press 'Enter'
  - Right-click a saved note to delete it

  ![img](.github/assets/ATOM%20Notes%20image.png)
</details>

<details><summary><b>ATOM Store</b></summary>

  **Download portable programs**
  - Downloaded programs are stored in the "Programs" folder in the same directory as ATOM
  - If a program is downloaded from the ATOM Store, ATOM will launch the equivalent plugin using ATOM Store's downloaded copy of the program

  ![img](.github/assets/ATOM%20Store%20image.png)
</details>

<details><summary><b>ATOMizer</b></summary>

  **Update & format flash drives**
  - Drive options
    - "ATOM" updates ATOM installation on root of drive
    - "Merge" merges data onto root of drive
    - "Format" formats drive to FAT32 and then merges data
  - File options
    - "Download" downloads latest stable ATOM from GitHub (only works when "ATOM" drive option is selected)
    - "Browse" opens explorer window to manually select a ZIP or ISO file
  - Multiple drives can be selected using **Ctrl + Left-Click** and **Shift + Left-Click**

  ![img](.github/assets/ATOMizer%20image.png)
</details>

<details><summary><b>Windows Debloat &amp; Tune</b></summary>

  **Detect & remove bloatware, adware, and other malicious programs + optimize telemetry & performance**
  
  ![img](.github/assets/Windows%20Debloat%20%26%20Tune%20image.png)
</details>

<details><summary><b>Bulk App Installer</b></summary>

  **Bulk-install programs using multiple package and download sources**
  - Bulk App Installer downloads programs via Winget, Chocolatey, Scoop, Winget installer URLs, direct URLs, and optional mirrors
    - If Winget installation fails then use Chocolatey, if Chocolatey fails then use direct URL (it's redundant!)

  ![img](.github/assets/Bulk%20App%20Installer%20image.png)
</details>

<details><summary><b>Ornstein & S-Mode</b></summary>

  **Disable S-Mode on computers without having to use a Microsoft Account (yes, you can use a local account!)**
  - Before you can run ATOM (and this plugin) on S-Mode computers, you must disable 'driver signature enforcement'
    https://www.tenforums.com/tutorials/156602-how-enable-disable-driver-signature-enforcement-windows-10-a.html

  ![img](.github/assets/Ornstein%20&%20S-Mode%20image.png)
</details>
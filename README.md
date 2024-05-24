# ATOM (A Tool Of Mine)

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="ATOM/Dependencies/Icons/ATOM%20Logo%20(Light).png">
  <source media="(prefers-color-scheme: light)" srcset="ATOM/Dependencies/Icons/ATOM%20Logo%20(Dark).png">
  <img alt="ATOM logo" src="ATOM/Dependencies/Icons/ATOM%20Logo%20(Light).png"> <!-- Fallback for browsers that do not support picture -->
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

1. Navigate to ATOM directory.
2. Create a new folder named "Plugins - CategoryName" where CategoryName is your desired Category name.
3. If ATOM has already been launched, you can reload plugins and plugin categories by clicking the Refresh ↻ icon.

**Adding Plugins**

1. Navigate to ATOM directory.
2. Open the plugin folder you would like to add your plugin to. (EX: "Plugins - Data Services")
3. Place your PowerShell script, batch script, or executable in the folder.
4. If ATOM has already been launched, you can reload plugins and plugin categories by clicking the Refresh ↻ icon.

**Adding Plugin Icons**

1. Navigate to "ATOM\Dependencies\Icons\Plugins"
2. Place plugin's PNG file in directory (PNG file must have same name as the plugin, EX: if plugin is "Plugin.ps1", PNG icon must be "Plugin.png")

**Configure Plugin Parameters**

You can customize parameters for each plugin such as adding tooltips, hiding the plugin by default, and silently launching the plugin.

1. Navigate to "ATOM\Dependencies", open "Plugins-Hashtable (Custom).ps1" and open with a text editor.
2. Add entries to the "customPluginInfo" hashtable for any plugin you would like to set parameters for. Documentation and an example are provided in the file.

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

<details><summary><b>Detectron</b></summary>

  **Detect & remove bloatware, adware, and other malicious programs + optimize telemetry & performance**
  
  ![img](.github/assets/Detectron%20image.png)
</details>

<details><summary><b>Neutron</b></summary>

  **New computer setup suite: customizations, timezone, and programs**
  - Neutron will download programs via Winget, Chocolatey, and direct URL
    - If Winget installation fails then use Chocolatey, if Chocolatey fails then use direct URL (it's redundant!)

  ![img](.github/assets/Neutron%20image.png)
</details>

<details><summary><b>Ornstein & S-Mode</b></summary>

  **Disable S-Mode on computers without having to use a Microsoft Account (yes, you can use a local account!)**
  - Before you can run ATOM (and this plugin) on S-Mode computers, you must disable 'driver signature enforcement'
    https://www.tenforums.com/tutorials/156602-how-enable-disable-driver-signature-enforcement-windows-10-a.html

  ![img](.github/assets/Ornstein%20&%20S-Mode%20image.png)
</details>
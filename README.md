# ATOM (A Tool Of Mine)

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="ATOM/Dependencies/Icons/ATOM%20Logo%20(Light).png">
  <source media="(prefers-color-scheme: light)" srcset="ATOM/Dependencies/Icons/ATOM%20Logo%20(Dark).png">
  <img alt="ATOM logo" src="ATOM/Dependencies/Icons/ATOM%20Logo%20(Light).png"> <!-- Fallback for browsers that do not support picture -->
</picture>

## What is ATOM?
ATOM is a launcher for PowerShell scripts, batch scripts, and executables. Although ATOM comes with many plugins preloaded, its modular nature invites people to create and add their own scripts.
ATOM is coded in PowerShell and uses WPF for its UI.

## Who is ATOM for?
ATOM is intended for computer repair technicians but can also be used by anybody who wishes to repair or modify their Windows installation.

## How to Launch ATOM
**Launch from PowerShell (requires internet)**
```sh
irm http://tinyurl.com/run-atom | iex
```

**[Direct download to latest ATOM](https://github.com/SkylerWallace/ATOM/releases/latest/download/ATOM.zip)**

ATOM.zip can be extracted anywhere but it's recommended to be extracted to the root of a flash drive. If the flash drive has a Windows PE installation on it, ATOM will have additional features.

Launch ATOM by double-clicking the ATOM.bat file.

> [!IMPORTANT]
> Once ATOM is launched, you can launch a Plugin by **double-clicking** the Plugin.

> [!WARNING]
> ATOM.bat and the ATOM folder must remain in the same directory for ATOM.bat to launch ATOM.

> [!NOTE]
> Many of ATOM's plugins are downloaded on-the-fly and will be cached in the Temp directory (C:\Users\UserName\AppData\Local\Temp).
The ATOM Store plugin can be used to download a portable version for use in offline environments.

## Additional PE Functionality
If ATOM.zip is extracted to a flash drive with a Windows PE installation on it, you will have additional functionality.

In the ATOM title bar, you will have an additional button:
- If in an online OS, the button will boot the computer directly to Windows PE
- If in Windows PE (including Windows RE), the button will launch MountOS.ps1
  - MountOS allows you to mount registry hives from offline Windows installations, also supports unlocking encrypted drives

> [!IMPORTANT]
> If your Windows PE installation does not have PowerShell installed onto it and also have PowerShell added to path, you will need to install PowerShell Core via the ATOM Store if you want to launch ATOM in Windows PE.

Since Windows RE is a PE environment, you can launch ATOM in Windows RE provided you downloaded PowerShell Core using the ATOM Store plugin. Launch Command Prompt in Windows RE and navigate to your ATOM installation. Launch ATOM in Command Prompt by starting ATOM.bat.
```sh
ATOM.bat
```

Type ATOM.bat and then press "Enter" three times to launch ATOM.

## Adding Plugin Categories
To add a Plugin Category, do the following:
- Navigate to ATOM directory.
- Create a new folder named "Plugins - CategoryName" where CategoryName is your desired Category name.
- If ATOM has already been launched, you can reload Plugins and Plugin Categories by clicking the Refresh ↻ icon.

## Adding Plugins
To add a Plugin, do the following:
- Navigate to ATOM directory.
- Open the Plugin folder you would like to add your plugin to. (EX: "Plugins - Data Services")
- Place your PowerShell script, batch script, or executable in the folder.
- If ATOM has already been launched, you can reload Plugins and Plugin Categories by clicking the Refresh ↻ icon.

To add a custom icon for your plugin, do the following:
- Create, extract, or download PNG file to be used as your icon (128x128 or native resolution recommended)
- Navigate to "ATOM\Dependencies\Icons\Plugins"
- Place PNG file in directory (PNG file must have same name as the plugin, EX: if plugin is "Plugin.ps1", PNG icon must be "Plugin.png")

If you do not add a custom icon, a default icon from "ATOM\Dependencies\Icons\Default" will be used instead.

## Configuring Plugins to Silently Launch
ATOM has the ability to launch PowerShell and Batch Plugins without displaying the command line window.

For PowerShell script (.ps1), the first line of your script should be:
> \# Launch: Silent

For Batch script (.bat), the first line of your script should be:
> REM Launch: Silent

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

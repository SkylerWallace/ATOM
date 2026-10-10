# Changelog

Notable changes to ATOM are documented in this file. ATOM follows [Semantic Versioning](https://semver.org/).

## [3.4.0] - 2026-10-10

This feature release adds automated workflows, persistent results, new scanning and cleanup tools, and more plugin search options.

### Added

- Added the Workflows page with presets, configurable actions, and a queue that reorders actions in real time while dragging.
- Added Tuneup & cleanup and AV scan presets, with Gentle/Deep cleanup and Quick/Deep/Tinfoil scan options.
- Added workflow actions for cleanup, default service restoration, Windows optimization, unwanted-app removal, system-file repair, and update requests.
- Added workflow logs with live status and elapsed time, action-specific result summaries, computer inventory, report shortcuts, and a stop control.
- Added portable ClamAV and Microsoft Safety Scanner plugins, plus Temp Cleanup with graphical and command-line modes. ClamAV supports scanning a selected file or folder.
- Added plugin filters for favorites, local availability, programs, and scripts, alongside stacked categories and an option to hide appended status icons.
- Added Workflows as a startup-page option and theme-aware status colors for workflow logs, downloads, updates, and plugin validation.
- Added a setting to enable or disable plugin drag-and-drop, enabled by default.

### Changed

- Stored workflow logs on the serviced computer, including the mounted Windows installation in PE. Completed runs use sortable date/time names and ZIP compression; older uncompressed logs remain supported.
- Added unattended parameters to Reset Default Services, Windows Debloat & Tune, and Trifecta while retaining their normal interactive use.
- Expanded antivirus workflow support for Emsisoft and Stinger, including cancellation and Emsisoft scanning with existing definitions when updates are unavailable. ClamAV uses parallel scanning and is reserved for the Tinfoil preset because scans can take 12+ hours.
- Packed built-in program icons into a ZIP while retaining support for custom plugin icons.
- Standardized button hover and pressed feedback, and refined workflow layouts and result presentation.
- Improved plugin dragging with a cursor-following icon and destination category label, visible outside ATOM's window bounds.
- Configured ATOM PE to activate the High performance power plan and launch MountOS automatically. Incompatible actions and presets are omitted in PE.
- Improved update and repair handling for source copies, Git checkouts, and channel changes, with ownership recovery, preservation of user files, backups, and rollback.
- Disabled Webroot until its portable behavior can be verified.

### Fixed

- Restored remote launcher support when executing downloaded script content through PowerShell.
- Corrected update detection for the Windows PE build kit and generated ISO downloads.
- Fixed clicks on formatted download details crashing ATOM.

## [3.3.0] - 2026-09-11

This feature release adds sidebar navigation, a dedicated download manager, user plugin editing, and expanded appearance controls.

### Added

- Added a collapsible sidebar with Plugins, Downloads, Settings, and Updates pages.
- Added download searching, status filters, storage information, and per-program progress and update actions.
- Added plugin creation and editable properties for user plugins, with custom icons and Windows/PE compatibility options.
- Added searchable settings, optional descriptions on Plugins and Settings, and plugin metadata reset controls.
- Added new themes and title-bar graphics with automatic theme pairing, manual selection, and an option to disable them.
- Added automatic UI scaling and expanded manual scaling to 100%-200%.
- Added changelog viewing and editing from the Updates page.

### Changed

- Organized ATOM functions into focused files with explicit dependencies and deferred loading.
- Kept user plugin scripts in the Plugins folder and stored their metadata separately from the built-in catalog.
- Improved properties dialogs, shared search bars, responsive settings panels, and navigation styling.
- Preserved the initial Plugins page window height when switching pages and deferred theme previews until needed.

### Fixed

- Fixed the encryption-key backup setting lookup.

## [3.2.0] - 2026-09-06

This feature release adds portable Windows PE media creation and makes downloading, bulk installation, and Windows cleanup more capable and responsive.

### Added

- Added Windows PE Build Kit and Windows PE ISO downloads for generating customized, bootable ATOM recovery media.
- Added dependency-aware Download Mode selections, per-program update checks, downloaded-state indicators, and individual download or update actions.
- Expanded Bulk App Installer with many new applications, icons, categories, runtimes, package sources, and automatic installation choices.
- Added more flexible installed-program detection and removal definitions to Windows Debloat & Tune.

### Changed

- Improved Download Mode switching and icon-loading performance while keeping its controls consistently arranged at narrow window sizes.
- Redesigned Bulk App Installer controls, responsive program layout, installation-method selection, and output presentation.
- Improved Windows Debloat & Tune startup, selection controls, asynchronous output, error handling, and customization metadata.
- Updated 7-Zip bootstrapping and extraction behavior for current packages and clearer antivirus-related failures.

### Fixed

- Fixed Windows PE startup, boot media compatibility, mouse cursor, background, optional components, and application compatibility issues.
- Fixed update indicators, status messaging, dependency selection, and already-current program handling in Download Mode.
- Fixed program-list loading and several execution and detection failures in Windows Debloat & Tune.

## [3.1.1] - 2026-08-31

This maintenance release improves responsiveness, visual consistency, download behavior, and a fix for the RDS plugin.

### Changed

- Reduced ATOM startup time by optimizing loading of assets and deferring initialization of some tasks.
- Improved download consistency of plugin programs by adding more behaviors to Copy-WebItem.
- Standardized shared PowerShell function parameter conventions.

### Fixed

- Improved button-control contrast across themes.
- Made Download Mode state and program-copy behavior more consistent.
- In RDS plugin, fixed the WLAN AutoConfig startup state.

## [3.1.0] - 2026-08-30

This feature release expands ATOM's update controls, customization, offline program management, and keyboard accessibility.

### Added

- Added Stable and Development update channels, allowing packaged installations to move between release and early-access builds without requiring Git.
- Added **Verify ATOM Files** to identify missing, modified, and unverifiable ATOM-owned files while preserving user-added files.
- Added styled ComboBox controls and reorganized Settings into General, Plugins, Quips, Appearance, Updates, and ATOM sections.
- Added configurable quip tones, rare quips, an inverted-rarity IWHBYD option, and expanded the built-in collection to 100 alphabetized quips.
- Added plugin context-menu actions for opening file locations and editing supported scripts, with automatic detection of Notepad, Visual Studio Code, and Notepad++ plus a custom editor option.
- Added keyboard navigation and shortcuts for Search, Settings, refresh, plugin navigation and launching, favorites, properties, context menus, and Download Mode selection.
- Added offline-availability indicators and a guarded **Remove Offline Download** action that keeps plugin files intact.
- Added automatic download-manifest reconciliation for programs removed outside ATOM.

### Changed

- Replaced commit-generated file lists and hashes with packaged channel metadata and per-file integrity manifests for release and development archives.
- Consolidated update checking, synchronization, repair, and installation into a clearer update action.
- Improved source-ZIP initialization so user-added files are preserved during the first synchronization.
- Made startup-column sizing derive from the scaled interface instead of fixed widths.
- Made Restore Defaults metadata-driven and configured it to preserve the selected update channel.
- Consolidated download-manifest formatting and atomic record maintenance.

### Fixed

- Fixed UI-scaling slider oscillation caused by the control moving while the window resized.
- Fixed ComboBox text colors when changing themes and standardized setting-row sizing and interaction.
- Fixed update-channel detection and messaging for development and unmanaged source copies.
- Fixed stale download records after portable programs are removed.

## [3.0.1] - 2026-08-28

This maintenance release improves update reliability and simplifies several internal behaviors introduced in ATOM 3.0.0.

### Fixed

- Improved update staging and branch detection so development copies follow `dev` while released copies follow `main`.
- Preserved user-created and user-configuration files during updates without failing when legacy configuration files are absent.
- Removed assumptions about ATOM being launched from a particular working directory.
- Fixed runspace output panels so they continue scrolling as new output is written.
- Corrected update availability messaging.

### Changed

- Added shared helpers for atomic file writing, user setting persistence, plugin overrides, and WPF scroll behavior.
- Consolidated package-manager environment PATH refresh behavior.
- Namespaced private functions and refined function and variable names in the main interface.
- Simplified download manifest handling and removed obsolete troubleshooting code, Office product-key code, and an unused icon.
- Updated generated file-list and commit-hash handling for both release branches.

## [3.0.0] - 2026-08-24

ATOM 3.0.0 is a major interface and architecture update focused on making the launcher faster, easier to customize, and more consistent across its WPF plugins.

### Highlights

- Redesigned the main interface, settings, themes, and icon system.
- Added global UI scaling from 1.0x to 1.5x.
- Added search, favorites, hidden-plugin controls, plugin properties, aliases, tags, drag-and-drop plugin support, and configurable single-click or double-click launching.
- Added categorical (default) and alphabetical sorting of plugins.
- Added styled plugin context menus with plugin headers, icons, and theme-aware highlighting.
- Added download mode to the main ATOM window, including selection, progress reporting, and portable-program updates.
- Added Scoop-aware program downloads and improved download manifests, file copying, and web-download handling.
- Replaced Neutron with **Bulk App Installer** and consolidated its application-installation workflow.
- Replaced Detectron with **Windows Debloat & Tune** and consolidated Windows cleanup, privacy, optimization, and application-removal tools.

### WPF and appearance

- Introduced the shared `New-AtomWindow` framework and migrated all WPF dialog plugins to the standardized window structure.
- Standardized headers, rounded window chrome, title-bar actions, icons, scaling, and shared resource loading.
- Added more visual controls for themes including improvements to shadows and gradients.
- Added new themes and improved several existing ones.
- Converted shared interface icons to reusable vector resources and standardized program icon locations and sizing.

### Plugins and configuration

- Flattened the plugin directory and moved category information into plugin metadata.
- Consolidated plugin and program definitions into `ATOM/Config/Plugins.ps1`.
- Consolidated custom plugin metadata, favorites, hidden state, and category overrides into a single `$userPrograms` hashtable.
- Automatically removes plugin overrides when users return built-in plugins to their committed defaults.
- Added and updated numerous diagnostic, security, repair, file-management, and Windows shortcut plugins.
- Reorganized dependencies so plugin-specific assets live alongside their plugins.
- Improved RDS infrastructure and data updates.
- Improved debug-mode behavior and PowerShell function organization.

### Versioning and documentation

- Adopted `MAJOR.MINOR.PATCH` semantic versioning with `ATOM/Config/Version.psd1` as the single version source.
- Added `Set-AtomVersion.ps1` for release version maintenance.
- Added contribution guidance for naming, shared WPF windows, validation, and release preparation.
- Rewrote the README with installation, usage, Windows PE/RE, customization, theming, and contribution guidance.

### Removed or renamed

- Removed the standalone **ATOM Store** plugin; supported downloads and updates are now handled through the main window's download mode.
- Renamed **Neutron** to **Bulk App Installer**.
- Renamed **Detectron** to **Windows Debloat & Tune**.
- Removed obsolete configuration files, duplicate helper functions, raster interface icons, and legacy dependency layouts superseded by the new architecture.

[3.1.1]: https://github.com/SkylerWallace/ATOM/compare/v3.1.0...v3.1.1
[3.1.0]: https://github.com/SkylerWallace/ATOM/compare/v3.0.1...v3.1.0
[3.0.1]: https://github.com/SkylerWallace/ATOM/compare/v3.0.0...v3.0.1
[3.0.0]: https://github.com/SkylerWallace/ATOM/compare/v2.12...v3.0.0

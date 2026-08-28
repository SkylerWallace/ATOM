# Changelog

Notable changes to ATOM are documented in this file. ATOM follows [Semantic Versioning](https://semver.org/).

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

[3.0.1]: https://github.com/SkylerWallace/ATOM/compare/v3.0.0...v3.0.1
[3.0.0]: https://github.com/SkylerWallace/ATOM/compare/v2.12...v3.0.0

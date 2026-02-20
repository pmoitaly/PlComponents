# Table of Contents - Pl Components Documentation

## Quick Navigation
- [Overview](#overview)
- [Package Index](#package-index)
- [Component Index](#component-index)
- [Utility & Infrastructure](#utility--infrastructure)

---

## Overview
This table of contents provides a hierarchical index of all documentation in the Pl Components library. For the main overview, see [readme.md](readme.md).

---

## Package Index

### 1. Pl.Vcl.NonVisualComponents
A set of non-visual components focused on automation, customization, and state persistence.

**Package Documentation:** [pk_pl_vcl_nonvisualcomponents.md](pk_pl_vcl_nonvisualcomponents.md)

#### Included Components
- [TPlDirectoryWatcher](pl_directory_watcher.md) - Non-visual | File system monitoring
- [TPlLanguage](pl_language.md) - Non-visual | Runtime localization management
- [TPlLanguageServer](pl_language_server.md) - Non-visual | Centralized language coordination
- [TPlLockWindowManager](pl_lockwnd_manager.md) - Non-visual | Window state management
- [TPlMenuFromFolder](pl_menu_from_folder.md) - Non-visual | Dynamic menu generation
- [TPlRecentFilesComponent](pl_recent_files_component.md) - Non-visual | Recent files tracking
- [TPlRuntimeDesigner](pl_runtime_designer.md) - Non-visual | Form design at runtime
- [TPlStyleMenuManager](pl_style_menu_manager.md) - Non-visual | Application style management

---

### 2. plc.SE.Components
Complete printing and print preview system based on SynEdit.

**Package Documentation:** [pk_pl_se_components.md](pk_pl_se_components.md)

#### Included Components & Utilities
- [PlSynEditPrintUtils](pl_synedit_print_utils.md) - Utility | SynEdit printing helpers
- [TPlPreviewProperties](pl_preview_properties.md) - Utility | Preview visual settings
- [TPlPreviewUIProperties](pl_preview_ui_properties.md) - Utility | Preview UI configuration
- [TPlPageSetupProperties](pl_page_setup_properties.md) - Utility | Page layout settings
- [TfrmPlPageSetup](pl_page_setup_form.md) - Visual | Page setup dialog
- [TfrmPlPrintPreview](pl_print_preview_form.md) - Visual | Print preview window
- [TPlSynEditPrintSystem](pl_syneditor_print_system.md) - Utility | Complete print workflow

---

### 3. plc.Vcl.Db.DataControls
**Status:** Currently under development

**Package Documentation:** [pk_pl_vcl_db_datacontrols.md](pk_pl_vcl_db_datacontrols.md)

---

### 4. Pl.Vcl.VisualComponents
**Status:** Currently under development

**Package Documentation:** [pk_pl_vcl_visualcomponents.md](pk_pl_vcl_visualcomponents.md)

---

## Component Index

### By Type

#### Non-Visual Components
| Component | Package | Purpose |
|-----------|---------|---------|
| [TPlDirectoryWatcher](pl_directory_watcher.md) | Pl.Vcl.NonVisualComponents | File system monitoring |
| [TPlLanguage](pl_language.md) | Pl.Vcl.NonVisualComponents | Runtime localization |
| [TPlLanguageServer](pl_language_server.md) | Pl.Vcl.NonVisualComponents | Language coordination |
| [TPlLockWindowManager](pl_lockwnd_manager.md) | Pl.Vcl.NonVisualComponents | Window state management |
| [TPlMenuFromFolder](pl_menu_from_folder.md) | Pl.Vcl.NonVisualComponents | Dynamic menu generation |
| [TPlRecentFilesComponent](pl_recent_files_component.md) | Pl.Vcl.NonVisualComponents | Recent files tracking |
| [TPlRuntimeDesigner](pl_runtime_designer.md) | Pl.Vcl.NonVisualComponents | Runtime form design |
| [TPlStyleMenuManager](pl_style_menu_manager.md) | Pl.Vcl.NonVisualComponents | Style management |

#### Visual Components & Forms
| Component | Package | Purpose |
|-----------|---------|---------|
| [TfrmPlPageSetup](pl_page_setup_form.md) | plc.SE.Components | Page setup dialog |
| [TfrmPlPrintPreview](pl_print_preview_form.md) | plc.SE.Components | Print preview window |

#### Utility Classes & Records
| Utility | Package | Purpose |
|---------|---------|---------|
| [TPlLineEncoder](pl_line_encoder.md) | Pl.Vcl.NonVisualComponents | String encoding/decoding |
| [TPlLanguageInfo](pl_language_info.md) | Pl.Vcl.NonVisualComponents | Language metadata record |
| [TPlPreviewProperties](pl_preview_properties.md) | plc.SE.Components | Preview visual settings |
| [TPlPreviewUIProperties](pl_preview_ui_properties.md) | plc.SE.Components | Preview UI configuration |
| [TPlPageSetupProperties](pl_page_setup_properties.md) | plc.SE.Components | Page layout settings |

---

## Utility & Infrastructure

### Language Framework (Localization System)
Core infrastructure for runtime language/translation management.

- [TPlLanguage](pl_language.md) - Main localization component
- [TPlLanguageEngine](pl_language_engine.md) - Abstract engine base class
- [TPlLanguageEngineFactory](pl_language_engine_factory.md) - Engine creation & registration
- [TPlLanguageIniEngine](pl_language_ini_engine.md) - INI-based persistence
- [TPlLanguageJsonEngine](pl_language_json_engine.md) - JSON-based persistence
- [TPlLanguageServer](pl_language_server.md) - Centralized language coordination
- [TPlLanguageInfo](pl_language_info.md) - Language metadata record
- [TPlLanguageInfoIniLoader](pl_language_info_ini_loader.md) - INI language info loader
- [TPlLanguageInfoJsonLoader](pl_language_info_json_loader.md) - JSON language info loader
- [IplTranslationStore](ipl_translation_store.md) - Translation storage interface

#### Localization Utilities
- [TPlLineEncoder](pl_line_encoder.md) - String encoding for persistence

#### Implementation Guides
- [Implementing Custom Language Engine](implementing_custom_language_engine.md) - How to create custom persistence engines

---

### Printing & Preview System
Complete printing subsystem for SynEdit-based applications.

#### Core Components
- [TfrmPlPrintPreview](pl_print_preview_form.md) - Preview window UI
- [TfrmPlPageSetup](pl_page_setup_form.md) - Page setup dialog
- [TPlSynEditPrintSystem](pl_syneditor_print_system.md) - Complete workflow coordinator

#### Properties & Configuration
- [TPlPreviewProperties](pl_preview_properties.md) - Preview appearance settings
- [TPlPreviewUIProperties](pl_preview_ui_properties.md) - Preview UI text & callbacks
- [TPlPageSetupProperties](pl_page_setup_properties.md) - Page layout & margins

#### Utilities
- [PlSynEditPrintUtils](pl_synedit_print_utils.md) - Helper functions

---

### File System & UI Components

#### Directory Monitoring
- [TPlDirectoryWatcher](pl_directory_watcher.md) - Monitor folder changes

#### Menu Management
- [TPlMenuFromFolder](pl_menu_from_folder.md) - Generate menus from folders
- [TPlStyleMenuManager](pl_style_menu_manager.md) - Application style management

#### Application State
- [TPlLockWindowManager](pl_lockwnd_manager.md) - Window state persistence
- [TPlRecentFilesComponent](pl_recent_files_component.md) - Recent files list management

#### Design & Development
- [TPlRuntimeDesigner](pl_runtime_designer.md) - Form editing at runtime

---

## Documentation Guidelines

### For Users
Start with [readme.md](readme.md) for an overview, then consult the package documentation for your needs.

### For Contributors
- All new components must have corresponding `.md` files
- Follow the [STANDARDS.md](STANDARDS.md) template
- Update this table of contents when adding new documentation
- Maintain consistent naming: lowercase with underscores (e.g., `pl_component_name.md`)

### Navigation Tips
- Use Ctrl+F to search for a specific component name
- Click on any component link to view its full documentation
- Cross-references are provided within each document

---

**Last Updated:** 2026-02-20 10:21:51  
**Documentation Version:** Aligned with v0.8.0 release
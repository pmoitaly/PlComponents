# plVCLNonVisualComponents

**Project:** plVCLNonVisualComponents  
**License:** MIT  
**Language:** Delphi / VCL  
**Category:** Non‑visual components for Windows applications

---

## Overview

`plVCLNonVisualComponents` is a collection of **non‑visual Delphi components** designed to enhance VCL applications with advanced runtime features.  
The package focuses on **automation, customization, and persistence** of application behavior, while keeping the components lightweight and easy to integrate.  

This library is intended for developers who want to add **runtime flexibility** to their applications without reinventing common infrastructure.

---
## Package Contents

The package includes the following units:

```pascal
  PlDirectoryWatcher,
  PlLanguage,
  PlLanguageEncoder,
  PlLanguageEngine,
  PlLanguageIniEngine,
  PlLanguageJSONEngine,
  PlLanguageEngineFactory,
  PlLanguageServer,
  PlLanguageTypes,
  PlLockWndManager,
  PlMenuFromFolder,
  PlRecentFilesComponent,
  PlRecentFilesManager,
  PlRunTimeDesigner,
  PlStyleMenuManager;
```

---

## Included Components

The package currently includes the following components:

- **[PlDirectoryWatcher](pl_directory_watcher.md)**  
  Threaded directory watcher for real‑time file system monitoring.

- **[PlMenuFromFolder](pl_menu_from_folder.md)**  
  Dynamically builds menu items from a folder and keeps them synchronized.

- **[PlRecentFilesComponent](pl_recent_files_component.md)**  
  Wrapper component for managing recent files directly in forms.

- **[PlRecentFilesManager](pl_recent_files_manager.md)**  
  Core manager for recent files, with INI persistence and menu population.

- **[PlLockWndManager](pl_lockwnd_manager.md)**  
  Manages redraw locking on windows using `WM_SETREDRAW`, with reference counting.

- **[PlRuntimeDesigner](pl_runtime_designer.md)**  
  Enables runtime editing of forms: selecting, moving, resizing controls, and persisting bounds.

- **[PlStylesMenuManager](pl_language_system.md)**  
  Populates menus with available VCL styles, supports custom styles, and applies them at runtime.

- **[Translation System](planned)**  
  A lightweight, extensible runtime translation system for localizing applications.  

---

## Goals

- Provide **ready‑to‑use infrastructure** for common application needs (menus, styles, recent files, runtime design).  
- Ensure **robustness and maintainability** with clean APIs and minimal dependencies.  
- Support **runtime customization** without requiring design‑time intervention.  
- Keep components **non‑visual** and lightweight, focusing on logic rather than UI.  

---

## Usage

Each component is documented in its own `.md` file.  
Please refer to the linked documentation for installation, usage examples, and API details.

---

## Contributing

Contributions are welcome!  
Areas for improvement include:
- Extending cross‑platform support (FMX, FreePascal)  
- Adding JSON/XML persistence options  
- Enhancing the translation system  
- Providing more advanced runtime design tools  

---

## License

Released under the MIT License. See the LICENSE file for details.
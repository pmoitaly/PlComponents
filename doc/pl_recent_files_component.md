# PlRecentFileComponent

## Overview

`PlRecentFilesComponent` is a **VCL design-time friendly wrapper component**
around `TPlRecentFilesManager`.

Its purpose is to make **recent-file management easily usable from a Form**,
without requiring manual instantiation or lifecycle handling of the underlying
manager class.

The component integrates:

- recent file persistence (INI-based)
- automatic menu rebuilding
- file selection callbacks
- safe delayed initialization at runtime

---

## Design Goals

The component is intentionally designed to:

1. Expose recent-file management as a **drop-in VCL component**
2. Decouple UI logic from persistence logic
3. Delay manager creation until all required dependencies are available
4. Allow safe reconfiguration at runtime
5. Avoid background threads or hidden side effects

It does **not** replace `TPlRecentFilesManager`, but wraps it.

---

## Architecture

```

TPlRecentFilesComponent (TComponent)
+- Configuration properties
�    +- IniFile
�    +- MaxCount
�    +- RecentMenu
�    +- OnFileSelected
+- Lazy creation of TPlRecentFilesManager
+- Menu rebuild delegation
+- Persistence delegation

````

The actual logic (file ordering, persistence, menu creation) lives in
`TPlRecentFilesManager`.

---

## Dependencies

- `Vcl.Menus`
- `PlRecentFilesManager`
- INI file persistence (indirectly)

---

## TPlRecentFilesComponent

### Purpose

`TPlRecentFilesComponent` manages the lifecycle and configuration of a
`TPlRecentFilesManager`, exposing a simplified API suitable for:

- VCL Forms
- visual designers
- runtime reconfiguration

---

### Public & Published Members

| **Member**               | **Category**  | **Type**                  | **Description**                                                                 |
|---------------------------|---------------|---------------------------|---------------------------------------------------------------------------------|
| **Create**                | Public        | Constructor override      | Initializes the component and sets default `MaxCount` to 10.                    |
| **Destroy**               | Public        | Destructor override       | Frees the internal manager and releases resources.                              |
| **Clear**                 | Public        | Method                    | Clears all recent files.                                                        |
| **LastFile**              | Public        | Method                    | Returns the most recent existing file, or empty string if none.                 |
| **Purge**                 | Public        | Method                    | Removes invalid entries, saves the updated list, and rebuilds the menu.         |
| **Rebuild**               | Public        | Method                    | Rebuilds the recent files menu.                                                 |
| **RegisterFile**          | Public        | Method                    | Adds or moves a file to the top of the recent list, then saves and rebuilds.    |
| **Files**                 | Published     | TStringList (read-only)   | Read-only list of recent files.                                                 |
| **IniFile**               | Published     | string                    | Path to the INI file used for persistence.                                      |
| **MaxCount**              | Published     | Integer                   | Maximum number of recent files to keep (default 10).                            |
| **RecentMenu**            | Published     | TMenuItem                 | Root menu item under which recent files are inserted.                           |
| **OnFileSelected**        | Published     | TProc<string>             | Event called when a recent file is selected.                                    |

---

## Lifecycle

### Constructor

```pascal
constructor Create(AOwner: TComponent); override;
````

* Initializes default values
* Default `MaxCount` is set to **10**
* Does **not** create the internal manager immediately

---

### Destructor

```pascal
destructor Destroy; override;
```

* Frees the internal `TPlRecentFilesManager` (if created)
* Safe to destroy at any time

---

### Loaded

```pascal
procedure Loaded; override;
```

Called automatically after the component is fully loaded.

* Attempts to create the internal manager
* Ensures design-time safe behavior
* Avoids premature creation during streaming

---

## Lazy Initialization Strategy

The internal `TPlRecentFilesManager` is created **only if all requirements are met**:

* `IniFile` is not empty
* `RecentMenu` is assigned
* `OnFileSelected` is assigned

This logic is centralized in:

```pascal
RebuildManagerIfReady
```

Every relevant property setter triggers a re-evaluation.

---

## Public Properties

### Files (read-only)

```pascal
property Files: TStringList;
```

Returns the list of recent files managed by the internal manager.

* Returns `nil` if the manager is not yet created
* Ownership remains with the manager

---

### IniFile

```pascal
property IniFile: string;
```

Path to the INI file used for persistence.

* Changing this property recreates the manager
* Must be set before the manager can exist

---

### MaxCount

```pascal
property MaxCount: Integer;
```

Maximum number of recent files to keep.

* Default: **10**
* Applied immediately if the manager exists
* Stored value is forwarded to the manager

---

### RecentMenu

```pascal
property RecentMenu: TMenuItem;
```

Menu item under which recent-file entries are inserted.

* Required for manager creation
* Reassigning triggers manager rebuild

---

### OnFileSelected

```pascal
property OnFileSelected: TProc<string>;
```

Callback invoked when a recent file is selected.

* Receives the selected file path
* Required for manager creation
* Changing it rebuilds the manager

---

## Public Methods

### Clear

```pascal
procedure Clear;
```

Clears the recent files list.

* Delegated to the manager
* Safe to call even if the manager is not created

---

### LastFile

```pascal
function LastFile: string;
```

Returns the most recent **existing** file.

* Returns empty string if unavailable
* Delegated to the manager

---

### Purge

```pascal
procedure Purge;
```

Ensures that all recent files still exist.

* Removes invalid entries
* Saves the updated list
* Rebuilds the menu

---

### Rebuild

```pascal
procedure Rebuild;
```

Forces a menu rebuild.

* Delegated to `TPlRecentFilesManager.BuildMenu`
* No-op if manager is not available

---

### RegisterFile

```pascal
procedure RegisterFile(const FileName: string);
```

Registers a file as recent.

* Moves it to the top of the list
* Saves the list
* Rebuilds the menu

---

## Internal Behavior Summary

* The component never partially initializes the manager
* Any missing dependency prevents creation
* Reconfiguration always recreates the manager cleanly
* Menu state is always derived from persisted data

---

## Intentional Design Limits

The following constraints are by design:

1. Persistence format is fixed (INI via manager)
2. One menu per component
3. No background updates or filesystem monitoring
4. No automatic file existence validation on registration
5. No ownership of menu items outside the manager

---

## Typical Usage

```pascal
RecentFiles := TPlRecentFilesComponent.Create(Self);
RecentFiles.IniFile :Ecco la tabella dei membri **public** della classe `TPlRecentFilesManager`, nello stesso formato che abbiamo usato per le altre unit, con la colonna **Category** per distinguere meglio:

---

# TPlRecentFilesManager � Public Members

| **Member**               | **Category**  | **Type**                  | **Description**                                                                 |
|---------------------------|---------------|---------------------------|---------------------------------------------------------------------------------|
| **Create**                | Public        | Constructor               | Initializes the manager with a target menu, INI file path, and selection event. |
| **Destroy**               | Public        | Destructor override       | Frees resources, including the critical section and file list.                  |
| **BuildMenu**             | Public        | Method                    | Rebuilds the recent files menu from the internal list.                          |
| **Clear**                 | Public        | Method                    | Clears all recent files from memory and the menu, saving immediately.           |
| **LastFile**              | Public        | Method                    | Returns the most recent existing file, or empty string if none exist.           |
| **Purge**                 | Public        | Method                    | Removes invalid entries, saves the updated list, and rebuilds the menu.         |
| **RegisterFile**          | Public        | Method                    | Adds or moves a file to the top of the recent list, then saves and rebuilds.    |
| **MaxCount**              | Public        | Property (Integer)        | Maximum number of recent files to keep (default 10).                            |
| **Files**                 | Public        | Property (TStringList)    | Read-only list of recent files.                                                 |
| **OnFileSelected**        | Public        | Property (TProc<string>)  | Event handler called when a recent file menu item is selected.                  |

---

?? Questa tabella � pronta per essere inserita nella documentazione open source del progetto *PlComponents*. Vuoi che prepari un **README.md unico** che raccolga tutte le tabelle (`TDirectoryWatcherThread`, `TPlMenuFromFolder`, `TPlRecentFilesComponent`, `TPlRecentFilesManager`) per presentare l�intero pacchetto in modo organico?= 'recent.ini';
RecentFiles.RecentMenu := miRecentFiles;
RecentFiles.OnFileSelected :=
  procedure(const FileName: string)
  begin
    OpenFile(FileName);
  end;
```

---

## License

Released under the **MIT License**. See the LICENSE file for details.

# PlMenuFromFolder

## Overview

`PlMenuFromFolder` provides a **VCL component** that dynamically builds menu
items from the contents of a filesystem folder and optionally keeps the menu
synchronized with the folder using a directory watcher.

The core class is:

- `TPlMenuFromFolder`

This component is designed to bridge **filesystem structure to UI menus**,
with optional live updates, minimal assumptions, and full event customization.
It is useful when you want to expose directories
as selectable menu items, automatically updated when the folder structure changes.

---

## Design Goals

The component is intentionally designed to:

1. Build menu items **from subfolders of a directory**
2. Keep menu items **synchronized with filesystem changes**
3. Work safely with **runtime menu reassignment**
4. Delegate policy decisions to the application via events
5. Integrate cleanly with `TDirectoryWatcherThread`

It avoids hard-coded UI logic and leaves styling and behavior extensible.

---

## Features

- Generate menu items directly from a folder’s subdirectories  
- Optional synchronization with a directory watcher (`PlDirectoryWatcher`)  
- Auto-update mode: menus are rebuilt automatically when changes occur  
- Support for custom images (`flag.bmp` per folder) via `TImageList` or direct bitmap assignment  
- Event hooks for customization before and after menu item creation  
- Integration with VCL menu events (`OnDrawItem`, `OnMeasureItem`, etc.)  
- Maintains a `Value` property representing the currently selected item  

---

## Architecture

```

TPlMenuFromFolder (TComponent)
├─ Folder scanning (FindFirst / FindNext)
├─ Menu item generation
├─ Optional flag bitmap loading
├─ Selection state handling (Value)
├─ Directory watcher integration
│    └─ TDirectoryWatcherThread
└─ Event forwarding and customization hooks

````

The component itself does **not** perform background work; all monitoring is
delegated to `TDirectoryWatcherThread`.

---

## Dependencies

- VCL Menus (`Vcl.Menus`)
- Optional ImageList support (`Vcl.ImgList`)
- `PlDirectoryWatcher` for live updates

---

### Public & Published Members

| **Member**               | **Category**  | **Type**                  | **Description**                                                                 |
|---------------------------|---------------|---------------------------|---------------------------------------------------------------------------------|
| **ActivateMonitor**       | Public        | Method                    | Forces the directory watcher to (re)activate if available.                      |
| **Notification**          | Public        | Method override           | Handles component notifications (e.g., linked components being removed).        |
| **Active**                | Published     | Boolean (read-only)       | True if the watcher exists and is active.                                       |
| **AutoUpdate**            | Published     | Boolean                   | When true, the watcher auto-starts and the menu auto-rebuilds.                  |
| **Enabled**               | Published     | Boolean                   | Enables/disables the component and menu visibility.                             |
| **FolderName**            | Published     | string                    | Base folder for menu population (stored with trailing delimiter).               |
| **HelpContext**           | Published     | THelpContext              | Help context propagated to generated menu items.                                |
| **ImageList**             | Published     | TCustomImageList          | Optional image list to host loaded flag bitmaps.                                |
| **MenuItem**              | Published     | TMenuItem                 | Root menu item that hosts generated children.                                   |
| **Value**                 | Published     | string                    | Selected value (matches a menu item caption, case-sensitive, without ampersands).|
| **WatchSubTree**          | Published     | Boolean                   | If true, watches subdirectories as well as the root folder.                     |
| **AfterChangeValue**      | Published     | TNotifyEvent              | Raised after `Value` changes.                                                   |
| **BeforeChangeValue**     | Published     | TNotifyEvent              | Raised before `Value` changes.                                                  |
| **OnAddedFolder**         | Published     | TPlOnFolderChange         | Raised when a new folder is detected.                                           |
| **OnAdvancedDrawItem**    | Published     | TAdvancedMenuDrawItemEvent| Forwarded to created items for advanced drawing.                                |
| **OnChangeFolder**        | Published     | TPlOnFolderChange         | Raised when a folder content is modified.                                       |
| **OnClick**               | Published     | TNotifyEvent              | Forwarded after internal handling of menu clicks.                               |
| **OnDeletedFolder**       | Published     | TPlOnFolderChange         | Raised when a folder is deleted.                                                |
| **OnDrawItem**            | Published     | TMenuDrawItemEvent        | Forwarded to created items for custom drawing.                                  |
| **OnMeasureItem**         | Published     | TMenuMeasureItemEvent     | Forwarded to created items for measuring.                                       |
| **OnMenuItemAdding**      | Published     | TPlOnMenuItemAdding       | Hook called before adding each menu item; can abort the addition.               |
| **OnRenamedFolder**       | Published     | TPlOnFolderRenamed        | Raised when a folder is renamed.                                                |

---

## Public Types

### TPlOnMenuItemAdding

Event raised **before a generated menu item is added**.

```pascal
procedure(Sender: TObject;
          ANewMenuItem: TMenuItem;
          var AAbort: Boolean) of object;
````

* Allows inspection or customization of the menu item
* Setting `AAbort := True` prevents the item from being added

---

## TPlMenuFromFolder

### Purpose

`TPlMenuFromFolder` builds child menu items under a given `TMenuItem` based on
the subdirectories found in a specified folder.

Each subdirectory corresponds to **one menu item**.

---

## Lifecycle

### Destructor

```pascal
destructor Destroy; override;
```

* Stops and frees the directory watcher (if active)
* Ensures no callbacks occur after destruction

Safe to destroy at any time.

---

## Public Properties

### Active (read-only)

```pascal
property Active: Boolean;
```

Returns `True` if the directory watcher exists and is currently active.

---

### AutoUpdate

```pascal
property AutoUpdate: Boolean;
```

* When `True`:

  * Menu is rebuilt automatically
  * Directory watcher is started
* When `False`:

  * Menu remains static
  * Watcher is disabled

Activation is deferred until `Loaded`.

---

### Enabled

```pascal
property Enabled: Boolean;
```

Controls whether the component is active and whether the menu is visible.

* Disabling:

  * Hides the menu
  * Deletes generated items
  * Stops the watcher
* Enabling:

  * Rebuilds the menu
  * Restarts monitoring if applicable

---

### FolderName

```pascal
property FolderName: string;
```

Base folder used to generate menu items.

* Always stored with a trailing path delimiter
* Must exist on disk
* Changing it triggers menu recreation and watcher restart

---

### MenuItem

```pascal
property MenuItem: TMenuItem;
```

Root menu item that will host generated children.

* Children are owned by this component
* Changing the menu item deletes previously generated items

---

### ImageList

```pascal
property ImageList: TCustomImageList;
```

Optional image list used for loading per-folder bitmaps.

If a subfolder contains:

```
<FolderName>\flag.bmp
```

The bitmap is loaded and assigned to the menu item.

---

### Value

```pascal
property Value: string;
```

Represents the currently selected menu value.

* Compared against menu captions
* Ampersands (`&`) are stripped before comparison
* Updates checked state of menu items

---

### WatchSubTree

```pascal
property WatchSubTree: Boolean;
```

If `True`, subdirectories are monitored recursively by the watcher.

---

## Events

### BeforeChangeValue / AfterChangeValue

```pascal
property BeforeChangeValue: TNotifyEvent;
property AfterChangeValue: TNotifyEvent;
```

Raised before and after `Value` changes.

---

### OnMenuItemAdding

```pascal
property OnMenuItemAdding: TPlOnMenuItemAdding;
```

Hook invoked before adding each menu item.

---

### OnClick

```pascal
property OnClick: TNotifyEvent;
```

Forwarded after internal click handling and value update.

---

### Folder Change Events

These events mirror filesystem changes detected by the watcher:

* `OnAddedFolder`
* `OnChangeFolder`
* `OnDeletedFolder`
* `OnRenamedFolder`

Each event receives:

* Full folder path
* Change action

---

### Drawing Events

Forwarded to each generated menu item:

* `OnDrawItem`
* `OnAdvancedDrawItem`
* `OnMeasureItem`

---

## Public Methods

### ActivateMonitor

```pascal
procedure ActivateMonitor;
```

Forces activation of the directory watcher if conditions allow.

Useful when:

* AutoUpdate is enabled
* Folder and menu become available later

---

### Notification

```pascal
procedure Notification(AComponent: TComponent;
                       Operation: TOperation); override;
```

Handles automatic cleanup when linked components (menu or image list) are removed.

---

## Internal Behavior Summary

* Menu items represent **subfolders only**
* Files are ignored
* `.` and `..` entries are skipped
* Menu items are recreated, not incrementally patched
* All watcher callbacks are routed through `DoOnChange`

---

## Intentional Design Limits

The following constraints are by design:

1. Only one menu root per component
2. Folder-to-menu mapping is flat (no nested menus)
3. Windows filesystem semantics assumed
4. No persistence of selection state
5. No background thread inside the component itself

---

## Example Usage

```pascal
MenuFromFolder := TPlMenuFromFolder.Create(Self);
MenuFromFolder.MenuItem := miLanguages;
MenuFromFolder.FolderName := 'C:\Languages\';
MenuFromFolder.AutoUpdate := True;
MenuFromFolder.Enabled := True;
```

---


### Limitations

- Works only on Windows (depends on `PlDirectoryWatcher` and Win32 APIs).  
- Folder icons are loaded only if a `flag.bmp` file exists in the subdirectory.  
- Requires explicit freeing of the component to release resources.  

---

## Contributing

Contributions are welcome.  
Potential improvements include:
- Enhanced filtering and customization of generated items  
- Cross-platform support for directory watching  
- Configurable image loading and debounce options  

---

## License

Released under the **MIT License**. See the LICENSE file for details.

# PlRecentFileManager

## Overview

`TPlRecentFilesManager` manages a list of recent files, saving and loading them from an INI file, and populating a VCL menu with entries to quickly reopen those files.  
It is thread‑safe thanks to the use of a `TCriticalSection` and provides methods to add, remove, validate, and display recent files.

---

## Features

- Manage a list of recent files with persistence in an INI file  
- Automatically populate a `TMenuItem` with recent file entries  
- Event handler for file selection from the menu  
- Automatic removal of duplicates and invalid entries  
- Configurable maximum number of recent files to keep  
- Thread‑safe operations on the list  

---

## Public Members

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
| **Files**                 | Public        | Property (TStringList)    | Read‑only list of recent files.                                                 |
| **OnFileSelected**        | Public        | Property (TProc<string>)  | Event handler called when a recent file menu item is selected.                  |

---

## Internal Behavior

- **Persistence:** Files are saved in the `RecentFiles` section of the INI file, with keys `Recent0`, `Recent1`, etc.  
- **Menu Population:** Each menu entry shows the file name (`Caption`) and stores the full path in `Hint`.  
- **Separator:** If the list is not empty, a separator (`'-'`) is added at the end of the menu.  
- **Thread Safety:** All operations on the list are protected by a `TCriticalSection`.  

---

## Example Usage

```delphi
var
  RecentManager: TPlRecentFilesManager;
begin
  RecentManager := TPlRecentFilesManager.Create(MyRecentMenu, 'recent.ini',
    procedure(const FileName: string)
    begin
      // Open the selected file
      OpenDocument(FileName);
    end);

  // Register a new file
  RecentManager.RegisterFile('C:\Docs\example.txt');

  // Retrieve the last valid file
  ShowMessage('Last file: ' + RecentManager.LastFile);

  // Clear the list
  RecentManager.Clear;
end;
```

---

## Limitations

- Works only on Windows (depends on VCL and `System.IniFiles`).  
- Requires a valid `TMenuItem` to host the entries.  
- The `OnFileSelected` event must be provided in the constructor and cannot be changed later.  

---

## Contributing

Contributions are welcome. Possible improvements include:  
- Support for alternative persistence formats (JSON, XML)  
- Cross‑platform support with FireMonkey  
- Customization options for menu entry rendering  

---

## License

Released under the MIT License. See the LICENSE file for details.

# PlStylesMenuManager

## Overview

`TPlStylesMenuManager` is a Delphi component that manages a menu of available VCL styles.  
It allows users to switch between built‑in and custom styles at runtime, automatically populating a menu with style entries.  
The component supports style previews, custom style directories, and events triggered when the active style changes.

---

## Features

- Dynamically populate a menu with available VCL styles  
- Support for loading custom styles from a directory with a specified extension  
- Apply styles at runtime with automatic redraw handling  
- Optional style preview rendering in menu items  
- Event notification when the style changes  
- Utility functions to detect whether the active style or elements are dark  

---

## Public Members

| **Member**               | **Category**  | **Type**                  | **Description**                                                                 |
|---------------------------|---------------|---------------------------|---------------------------------------------------------------------------------|
| **Create**                | Public        | Constructor override      | Initializes the style menu manager.                                             |
| **Destroy**               | Public        | Destructor override       | Frees resources and detaches handlers.                                          |
| **IsColorDark**           | Public        | Function (TColor → Boolean)| Returns true if the given color is considered dark.                             |
| **IsDarkButton**          | Public        | Function (Boolean)        | Returns true if the current style renders buttons with a dark theme.            |
| **IsDarkElement**         | Public        | Function (TStyleColor → Boolean)| Returns true if the given style element is dark.                           |
| **IsDarkStyleActive**     | Public        | Function (Boolean)        | Returns true if the currently active style is dark.                             |
| **Active**                | Published     | Boolean                   | Enables or disables the style menu manager.                                     |
| **CurrentStyle**          | Published     | string                    | Name of the currently active style.                                             |
| **CustomStylesDir**       | Published     | string                    | Directory path where custom styles are located.                                 |
| **CustomStylesExt**       | Published     | string                    | File extension used for custom style files (e.g., `.vsf`).                      |
| **MenuItem**              | Published     | TMenuItem                 | Root menu item under which style entries are inserted.                          |
| **MenuTag**               | Published     | Integer                   | Tag value assigned to style menu items.                                         |
| **StylePreview**          | Published     | Boolean                   | Enables or disables style preview rendering in menu items.                      |
| **OnStyleChanged**        | Published     | TNotifyEvent              | Event fired after a style change is applied.                                    |

---

## Internal Behavior

- **Menu Population:** The manager rebuilds the menu with available styles, including custom styles loaded from the specified directory.  
- **Style Application:** When a menu item is clicked, the corresponding style is applied using VCL’s `TStyleManager`.  
- **Owner‑Draw Handling:** Temporarily disables owner‑draw during style changes to avoid rendering issues, then restores it.  
- **Message Handling:** Uses a hidden window handle to process style application messages (`WM_PL_APPLYSTYLE`).  
- **Style Cache:** Maintains a dictionary of loaded custom styles for reuse.  

---

## Example Usage

```delphi
var
  StyleManager: TPlStylesMenuManager;
begin
  StyleManager := TPlStylesMenuManager.Create(Form1);
  StyleManager.MenuItem := StylesMenuItem; // Root menu item
  StyleManager.CustomStylesDir := ExtractFilePath(Application.ExeName) + 'Styles';
  StyleManager.CustomStylesExt := '.vsf';
  StyleManager.Active := True;

  StyleManager.OnStyleChanged :=
    procedure(Sender: TObject)
    begin
      ShowMessage('Style changed to: ' + StyleManager.CurrentStyle);
    end;

  // The menu will now be populated with available styles
end;
```

---

## Limitations

- Works only on Windows with VCL applications.  
- Requires a valid `TMenuItem` to host style entries.  
- Custom styles must be valid VCL style files (`.vsf` or specified extension).  

---

## Contributing

Contributions are welcome. Possible improvements include:  
- Support for FireMonkey styles in cross‑platform applications  
- Enhanced preview rendering with thumbnails  
- Automatic detection of system theme (light/dark)  

---

## License

Released under the MIT License. See the LICENSE file for details.
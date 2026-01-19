# PlRuntimeDesigner

## Overview

The `PlRuntimeDesigner` unit provides a component that enables basic runtime form editing in Delphi applications.  
It allows developers and end‑users to **select, move, and resize controls at runtime**, and persist their bounds to an INI file for later restoration.  

This unit defines helper types for resize directions and events, a compatibility control type, and the main component `TPlRunTimeDesigner`.

---

## Types

### `TPlResizeDirection`
Enumerates possible resize and move directions:
- `rdNone`  
- `rdTop`, `rdTopRight`, `rdRight`, `rdBottomRight`, `rdBottom`, `rdBottomLeft`, `rdLeft`, `rdTopLeft`  
- `rdMove`  

### `TPlBeforeResizeEvent`
Event raised before resizing a control.  
Signature: `(Sender: TObject; var Abort: Boolean)`  
Set `Abort := True` to cancel the resize operation.

### `TPlOnResizeEvent`
Event raised while resizing a control.  
Signature: `(Sender: TObject; X, Y: Integer)`  
Provides current mouse coordinates.

### `TPlControl`
Compatibility type: simply a subclass of `TControl` used by the runtime designer.

---

## Class: TPlRunTimeDesigner

### Features
- Enable runtime editing of forms and controls (move, resize, select)  
- Persist control bounds to an INI file and reload them later  
- Configurable minimum width/height for resizing  
- Optionally manage the owning form’s bounds as well  
- Exclude specific controls from persistence via `ExcludeList`  
- Restrict editing to controls owned by the same owner (`OwnerOnly`)  
- Customizable proximity threshold for resize cursor activation  
- Events for load/save completion, resize initiation, and resize progress  

---

### Public and Published Members

| **Member**               | **Category**  | **Type**                  | **Description**                                                                 |
|---------------------------|---------------|---------------------------|---------------------------------------------------------------------------------|
| **Create**                | Public        | Constructor override      | Creates the runtime designer component.                                         |
| **Destroy**               | Public        | Destructor override       | Frees resources and detaches message hooks.                                     |
| **LoadData**              | Public        | Method (overloaded)       | Loads persisted control data from the INI file, from a specific control, or using a provided `TIniFile`. |
| **SaveData**              | Public        | Method (overloaded)       | Saves control data to the INI file, from a specific control, or using a provided `TIniFile`. |
| **Active**                | Published     | Boolean                   | Enables or disables the runtime designer.                                       |
| **ExcludeList**           | Published     | TStrings                  | Comma‑separated list of control names to exclude from load/save. Nil‑safe.      |
| **IniName**               | Published     | TFileName                 | File name of the INI used to persist control bounds.                            |
| **ManageForm**            | Published     | Boolean                   | If true, also load/save the owning form’s bounds.                               |
| **MinHeight**             | Published     | Integer                   | Minimum height allowed when resizing controls (default 10).                     |
| **MinWidth**              | Published     | Integer                   | Minimum width allowed when resizing controls (default 10).                      |
| **OwnerOnly**             | Published     | Boolean                   | If true, designer acts only on controls with the same owner as this component.  |
| **Proximity**             | Published     | Integer                   | Distance in pixels from the edge where resize cursor appears.                   |
| **AfterLoad**             | Published     | TNotifyEvent              | Event invoked after all data were loaded.                                       |
| **AfterSave**             | Published     | TNotifyEvent              | Event invoked after all data were saved.                                        |
| **BeforeResize**          | Published     | TPlBeforeResizeEvent      | Event invoked before a resize; set `Abort := True` to cancel.                   |
| **OnResize**              | Published     | TPlOnResizeEvent          | Event invoked while resizing; provides mouse coordinates.                       |

---

## Example Usage

```delphi
var
  Designer: TPlRunTimeDesigner;
begin
  Designer := TPlRunTimeDesigner.Create(Form1);
  Designer.IniName := 'layout.ini';
  Designer.Active := True;
  Designer.ManageForm := True;
  Designer.MinWidth := 20;
  Designer.MinHeight := 20;

  Designer.AfterLoad :=
    procedure(Sender: TObject)
    begin
      ShowMessage('Layout restored from INI file.');
    end;

  Designer.BeforeResize :=
    procedure(Sender: TObject; var Abort: Boolean)
    begin
      // Prevent resizing of certain controls
      if (Sender is TButton) then
        Abort := True;
    end;

  Designer.OnResize :=
    procedure(Sender: TObject; X, Y: Integer)
    begin
      // Live feedback during resize
      StatusBar1.SimpleText := Format('Resizing at (%d, %d)', [X, Y]);
    end;

  // Load persisted layout
  Designer.LoadData;
end;
```

---

## Limitations

- Works only on Windows (depends on VCL and WinAPI message handling).  
- Designed for basic runtime editing; not a full design‑time environment.  
- Requires an INI file path (`IniName`) for persistence.  

---

## Contributing

Contributions are welcome. Potential improvements include:  
- Support for alternative persistence formats (JSON, XML)  
- Enhanced selection and alignment tools  
- Cross‑platform support with FireMonkey  

---

## License

Released under the MIT License. See the LICENSE file for details.
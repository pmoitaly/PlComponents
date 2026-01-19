# PlPageSetupForm

## Overview

`PlPageSetupForm` provides a ready-to-use VCL dialog that allows end users to configure page size, margins, orientation, and measurement units in a visual and intuitive way.

The form is designed to work together with `TPlPageSetupProperties`, acting as a UI layer that:

* Loads existing page setup settings into editable controls
* Allows quick selection of common page presets (A4, Letter, Portrait/Landscape)
* Produces a new `TPlPageSetupProperties` instance based on user input

This unit is typically used in print preview and printing workflows.

---

## Unit Responsibilities

* Present a modal dialog for page setup configuration
* Support standard page presets and custom sizes
* Convert UI input into a strongly typed configuration object
* Remain independent from the actual printing logic

---

## Main Class

### `TfrmPlPageSetup`

`TfrmPlPageSetup` is a standard VCL form (`TForm`) that hosts all controls required to edit page setup parameters.

---

## Public API

### `function GetValues: TPlPageSetupProperties;`

Reads the current values entered by the user and returns a **new** `TPlPageSetupProperties` instance populated accordingly.

**Notes**

* The caller owns the returned instance.
* Default fallback values are applied if user input cannot be parsed.
* The form itself is passed as owner to the created object.

**Typical usage**

```pascal
var
  pageSetup: TPlPageSetupProperties;
begin
  if frmPlPageSetup.ShowModal = mrOk then
  begin
    pageSetup := frmPlPageSetup.GetValues;
    try
      // Use pageSetup
    finally
      pageSetup.Free;
    end;
  end;
end;
```

---

### `procedure LoadFrom(AProperties: TPlPageSetupProperties);`

Loads the dialog controls from an existing `TPlPageSetupProperties` instance.

**Behavior**

* Updates page size, margins, unit, and orientation
* Does not change the selected preset explicitly
* Safely exits if `AProperties` is `nil`

This method is typically called before showing the dialog.

---

## Preset Handling

The form supports predefined page presets via a combo box:

* A4 Portrait
* A4 Landscape
* Letter Portrait
* Letter Landscape
* Custom

### Internal logic

* `ApplyPreset` updates page size, unit, and orientation based on the selected preset
* `SyncronizePreset` automatically switches to **Custom** when the user manually edits values
* `FApplyingPresets` prevents recursive updates while applying presets

This ensures consistent and predictable behavior between presets and manual input.

---

## Measurement Units

The dialog supports:

* Millimeters
* Inches

Unit selection affects how page width and height values are interpreted and stored in `TPlPageSetupProperties`.

---

## Dependencies

This unit depends on:

* **VCL**

  * `Vcl.Forms`, `Vcl.Controls`, `Vcl.StdCtrls`, `Vcl.Graphics`
* **Printing**

  * `Vcl.Printers` (for orientation constants)
* **Project units**

  * `PlPageSetupProperties`

---

## Typical Integration Flow

1. Create or reuse a `TPlPageSetupProperties` instance
2. Call `LoadFrom` to initialize the dialog
3. Show the form modally
4. Call `GetValues` if the user confirms
5. Apply the returned properties to your printing or preview system

---

## Design Notes

* The form does **not** modify the input properties instance
* A new properties object is always created on confirmation
* The unit intentionally contains no printing logic
* Suitable for reuse in different preview or print subsystems

---

## License

This unit is released under the **MIT License**. See the LICENSE file for details.

---

## Related Units

* [PlPageSetupProperties](pl_page_setup_properties.md)
* [PlPrintPreviewForm](pl_print_preview_form.md)
* [PlPreviewUIProperties](pl_preview_ui_properties.md)
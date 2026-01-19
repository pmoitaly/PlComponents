# PlPageSetupProperties Unit

The `PlPageSetupProperties` unit defines the class **`TPlPageSetupProperties`**, a lightweight and reusable **data container** that encapsulates page layout settings used during printing and print preview operations.

This unit is part of the *Pl printing subsystem* and is typically used together with `TPlSynEditPrintSystem`, page setup dialogs, and preview forms.

---

## Purpose

`TPlPageSetupProperties` provides a **clean abstraction layer** between:

* the VCL `TPageSetupDialog`
* printer configuration (`TPrinter`, `TSynEditPrint`)
* application-specific UI or persistence logic

Its main goals are:

* centralizing page setup data
* enabling easy synchronization with dialogs and printers
* avoiding direct coupling between UI forms and printer APIs

---

## Design Philosophy

* **Pure data object**: no UI logic
* **Serializable-friendly** (INI, JSON, registry, etc.)
* **Reusable** across multiple print operations
* **Explicit units of measure** (millimeters)
* Safe defaults for most printing scenarios

---

## Class Overview

```pascal
TPlPageSetupProperties = class(TPersistent)
```

The class derives from `TPersistent` to allow:

* assignment via `Assign`
* design-time inspection (if exposed)
* future streaming support

---

## Supported Page Attributes

`TPlPageSetupProperties` models the most common page layout parameters:

### Margins (in millimeters)

```pascal
property MarginLeft: Double;
property MarginTop: Double;
property MarginRight: Double;
property MarginBottom: Double;
```

* All margins are expressed in **millimeters**
* Internally converted when applied to printer or SynEdit print engine
* Independent from printer DPI

---

### Page Orientation

```pascal
property Orientation: TPrinterOrientation;
```

Supported values:

* `poPortrait`
* `poLandscape`

---

### Header and Footer

```pascal
property Header: string;
property Footer: string;
```

These strings are passed to the print engine and may include formatting or macro tokens depending on the consumer (`TSynEditPrint`, custom engines, etc.).

---

## Public Methods

### Assign

```pascal
procedure Assign(Source: TPersistent); override;
```

Copies all page setup properties from another instance.

Typical use cases:

* cloning settings
* applying defaults
* restoring user preferences

---

### LoadFromPageSetupDialog

```pascal
procedure LoadFromPageSetupDialog(ADialog: TPageSetupDialog);
```

Reads page setup values from a `TPageSetupDialog` instance and stores them in the object.

Used after:

* dialog execution
* user confirmation

---

### ApplyToPageSetupDialog

```pascal
procedure ApplyToPageSetupDialog(ADialog: TPageSetupDialog);
```

Applies stored properties to a `TPageSetupDialog` before showing it.

Used to:

* prefill dialog fields
* restore last-used settings

---

### ApplyToPrinter

```pascal
procedure ApplyToPrinter(APrinter: TPrinter);
```

Applies page orientation and margins directly to the global `Printer` object.

Notes:

* Margin conversion to printer units is handled internally
* Printer must be assigned and valid

---

### ApplyToSynEditPrint

```pascal
procedure ApplyToSynEditPrint(APrint: TSynEditPrint);
```

Transfers page layout settings to a `TSynEditPrint` instance.

This includes:

* margins
* orientation
* header/footer text

---

## Units of Measure

* **All margins are stored in millimeters**
* Conversion to:

  * printer pixels
  * SynEdit internal units
    is handled inside the apply methods

This ensures:

* device-independent configuration
* consistent layout across printers

---

## Typical Usage

### With a Page Setup Dialog

```pascal
PageSetupProps.ApplyToPageSetupDialog(PageSetupDialog);

if PageSetupDialog.Execute then
  PageSetupProps.LoadFromPageSetupDialog(PageSetupDialog);
```

---

### Applying to Print Engine

```pascal
PageSetupProps.ApplyToSynEditPrint(SynEditPrint);
```

---

### Applying to Printer

```pascal
PageSetupProps.ApplyToPrinter(Printer);
```

---

## Error Handling

* Methods silently ignore `nil` parameters
* No exceptions are raised for invalid printers or dialogs
* Validation is expected to be handled by the caller or UI layer

This keeps the class safe for UI-driven workflows.

---

## Thread Safety

`TPlPageSetupProperties` is **not thread-safe**.

Expected usage:

* main UI thread
* print/preview preparation phase

---

## Extensibility

This class can be safely extended to support:

* paper size
* custom units
* mirrored margins
* gutter margins
* per-page headers/footers

Recommended approach:

* keep it UI-agnostic
* avoid direct dialog execution
* add only data + apply/load methods

---

## Dependencies

* `Vcl.Dialogs` (`TPageSetupDialog`)
* `Vcl.Printers` (`TPrinter`)
* `SynEditPrint`
* `System.Classes`

---

## Architectural Role

`TPlPageSetupProperties` acts as a **bridge object** between:

* user configuration
* dialogs
* print engines

It helps keep:

* forms thin
* print logic centralized
* settings reusable and testable

---

## Contributing

This unit is designed for open-source usage and extension. Contributions are welcome.
Please open issues or submit pull requests on GitHub.

---

## License

Released under the **MIT License**. See the LICENSE file for details.


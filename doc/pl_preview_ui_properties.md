# PlPreviewUIProperties

## Overview

The `PlPreviewUIProperties` unit provides a persistent configuration class that
encapsulates **UI-related settings** for the print preview form
`TfrmPlPrintPreview`.

Its main purpose is to centralize:
- Captions and UI text
- Localization settings
- Callback hooks for Page Setup and Printer Setup dialogs

This separation allows the preview form to remain mostly logic-driven, while
all UI customization and localization concerns are handled externally.

---

## Unit Purpose

This unit is part of the **PlComponents / SynEdit Print Preview subsystem** and
focuses specifically on **user interface configuration**, complementing:

- `PlPreviewProperties` → visual/behavioral preview settings
- `PlPageSetupProperties` → page layout and margins
- `PlPrintPreviewForm` → actual preview UI implementation

`PlPreviewUIProperties` is designed to be:
- Reusable
- Design-time friendly
- Easily assignable and localizable

---

## Dependencies

The unit depends on:

- `System.Classes`
- `System.SysUtils`
- `PlPrintPreviewForm`

It is tightly coupled to `TfrmPlPrintPreview`, as it directly applies properties
to that form.

---

## Main Class

### `TPlPreviewUIProperties`

```pascal
TPlPreviewUIProperties = class(TPersistent)
````

Encapsulates UI-related properties for the print preview form.

Being derived from `TPersistent`, this class:

* Can be exposed as a published property
* Supports streaming and DFM persistence
* Supports `Assign` for copying settings

---

## Constructor

### `Create`

```pascal
constructor Create(AOwner: TComponent);
```

Creates a new instance and initializes default UI values using resource strings.

#### Default values

| Property           | Default value   |
| ------------------ | --------------- |
| `FormCaption`      | `Print preview` |
| `PrintButtonText`  | `&Print`        |
| `CloseButtonText`  | `&Close`        |
| `PageInfoTemplate` | `Page %d of %d` |

> The `AOwner` parameter is currently informational and not stored.

---

## Public Methods

### `ApplyTo`

```pascal
procedure ApplyTo(AForm: TfrmPlPrintPreview);
```

Applies the stored UI properties to a `TfrmPlPrintPreview` instance.

#### Behavior

* Updates form caption
* Updates button captions
* Applies localization settings (`LangPath`, `Language`)
* Sets the page info text template
* Assigns callbacks for Page Setup and Printer Setup
* Updates the page info label if the preview is already initialized

If `AForm` is `nil`, the method safely exits.

---

### `Assign`

```pascal
procedure Assign(Source: TPersistent); override;
```

Copies all UI-related properties from another `TPlPreviewUIProperties` instance.

If `Source` is not of type `TPlPreviewUIProperties`, the inherited `Assign`
method is called.

---

## Published Properties

These properties are intended for design-time editing and DFM persistence.

### `FormCaption`

```pascal
property FormCaption: string;
```

Caption of the print preview form.

---

### `PrintButtonText`

```pascal
property PrintButtonText: string;
```

Caption of the **Print** button.

Mnemonic characters (e.g. `&Print`) are supported.

---

### `CloseButtonText`

```pascal
property CloseButtonText: string;
```

Caption of the **Close** button.

Mnemonic characters are supported.

---

### `PageInfoTemplate`

```pascal
property PageInfoTemplate: string;
```

Format string used to display page information.

Example:

```text
Page %d of %d
```

Where:

* First `%d` → current page number
* Second `%d` → total page count

---

### `LangPath`

```pascal
property LangPath: string;
```

Path containing localization files used by the internal translator component.

---

### `Language`

```pascal
property Language: string;
```

Language identifier used by the translator (e.g. `"en"`, `"it"`, `"de"`).

---

## Callback Properties

These properties are **not published** and must be assigned in code.

### `OpenPageSetupDialog`

```pascal
property OpenPageSetupDialog: TProc;
```

Callback invoked when the user requests the **Page Setup** dialog.

This allows the preview UI to delegate dialog handling to an external controller.

---

### `OpenPrinterSetupDialog`

```pascal
property OpenPrinterSetupDialog: TProc;
```

Callback invoked when the user requests the **Printer Setup** dialog.

---

## Typical Usage Example

```pascal
var
  UIProps: TPlPreviewUIProperties;
begin
  UIProps := TPlPreviewUIProperties.Create(nil);
  try
    UIProps.FormCaption := 'Preview document';
    UIProps.Language := 'en';
    UIProps.LangPath := '.\lang';
    UIProps.OpenPageSetupDialog := ShowMyPageSetup;
    UIProps.OpenPrinterSetupDialog := ShowMyPrinterSetup;

    UIProps.ApplyTo(frmPlPrintPreview);
  finally
    UIProps.Free;
  end;
end;
```

---

## Design Notes

* This class intentionally contains **no UI logic**
* All visual updates are applied through `ApplyTo`
* Dialog handling is externalized via callbacks
* Localization is centralized and optional
* Complements (but does not overlap with) `PlPreviewProperties`

---

## License

This unit is released under the **MIT License**. See the LICENSE file for details.

---

## Related Units

* [PlPreviewProperties](pl_preview_properties.md)
* [PlPageSetupProperties](pl_page_setup_properties.md)
* [PlPrintPreviewForm](pl_print_preview_form.md)
* [PlSynEditPrintUtils](pl_syneditor_print_system.md)
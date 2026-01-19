# PlPreviewProperties

## Overview

The `PlPreviewProperties` unit provides a reusable and persistent configuration class for controlling the **visual appearance and behavior of a print preview**, specifically targeting `TSynEditPrintPreview`.

It is designed to:
- Decouple preview configuration from UI logic
- Support design-time and runtime customization
- Allow easy reuse of preview settings across multiple preview instances

The core class exported by this unit is `TPlPreviewProperties`.

---

## Unit Purpose

This unit belongs to the **PlComponents / SynEdit Print Preview subsystem** and acts as a *property container* that can be applied to a preview component on demand.

Typical use cases include:
- Centralizing preview configuration
- Storing user preferences
- Applying consistent preview behavior across multiple forms
- Simplifying preview setup code

---

## Dependencies

The unit depends on:

- `System.Classes`
- `Vcl.Graphics`
- `SynEditPrintPreview`

It does **not** depend on any UI forms.

---

## Main Class

### `TPlPreviewProperties`

```pascal
TPlPreviewProperties = class(TPersistent)
```

Encapsulates visual and behavioral settings for a print preview component.

Because it descends from `TPersistent`, it can be:

* Used as a published property
* Streamed to/from DFM
* Assigned using `Assign`

---

## Constructor

### `Create`

```pascal
constructor Create(AOwner: TComponent);
```

Creates a new instance and initializes default values.

#### Default values

| Property          | Default   |
| ----------------- | --------- |
| `ScalePercent`    | 100       |
| `BackgroundColor` | `clWhite` |
| `PageShadow`      | `True`    |
| `ShowLineNumber`  | `True`    |
| `ShowScrollHint`  | `True`    |

> The `AOwner` parameter is currently informational and not stored.

---

## Public Methods

### `ApplyTo`

```pascal
procedure ApplyTo(APreview: TSynEditPrintPreview);
```

Applies the stored settings to a `TSynEditPrintPreview` instance.

#### Behavior

* Sets zoom (`ScalePercent`)
* Sets scroll hint visibility
* Sets preview background color
* Enables or disables line numbers on the associated `TSynEditPrint`

If `APreview` is `nil`, the method safely exits.

---

### `Assign`

```pascal
procedure Assign(Source: TPersistent); override;
```

Copies all preview-related properties from another `TPlPreviewProperties` instance.

If `Source` is not of type `TPlPreviewProperties`, the inherited `Assign` method is called.

---

## Published Properties

These properties are suitable for design-time editing and DFM streaming.

### `BackgroundColor`

```pascal
property BackgroundColor: TColor;
```

Background color of the preview area.

* Default: `clWhite`

---

### `PageShadow`

```pascal
property PageShadow: Boolean;
```

Enables or disables the page shadow effect.

> Note: This property is stored for future or external use.
> The current `TSynEditPrintPreview` implementation may not directly consume it.

* Default: `True`

---

### `ScalePercent`

```pascal
property ScalePercent: Integer;
```

Zoom factor expressed as a percentage.

Typical values:

* `50` → 50%

* `100` → 100%

* `200` → 200%

* Default: `100`

---

### `ShowLineNumber`

```pascal
property ShowLineNumber: Boolean;
```

Controls whether line numbers are shown in the preview.

This property affects the underlying `TSynEditPrint.LineNumbers` setting.

* Default: `True`

---

### `ShowScrollHint`

```pascal
property ShowScrollHint: Boolean;
```

Controls the visibility of the scroll hint overlay.

* Default: `True`

---

## Typical Usage Example

```pascal
var
  PreviewProps: TPlPreviewProperties;
begin
  PreviewProps := TPlPreviewProperties.Create(nil);
  try
    PreviewProps.ScalePercent := 120;
    PreviewProps.ShowLineNumber := False;
    PreviewProps.ApplyTo(SynEditPrintPreview1);
  finally
    PreviewProps.Free;
  end;
end;
```

---

## Design Notes

* The class is intentionally **UI-agnostic**
* No direct form dependencies
* Safe to use at both design time and runtime
* Ideal for composition inside higher-level preview controllers or forms

---

## License

This unit is released under the **MIT License**. See the LICENSE file for details.

---

## Related Units

* [PlPreviewUIProperties](pl_preview_ui_properties.md)
* [PlPageSetupProperties](pl_page_setup_properties.md)
* [PlPrintPreviewForm](pl_print_preview_form.md)
* [PlSynEditPrintUtils](pl_syneditor_print_system.md)
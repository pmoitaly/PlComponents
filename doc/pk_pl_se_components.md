# plc.SE.Components

**Project:** plVCLNonVisualComponents  
**License:** MIT  
**Language:** Delphi / VCL  
**Category:** Non‑visual components for Windows applications

---

## Overview

`plc.SE.Components` is a Delphi (VCL) component package designed to provide a complete, reusable **printing and print preview system based on SynEdit**.  
It offers configurable preview UI, page setup handling, printer integration, and localization support, making it suitable for both IDE tools and end-user applications.

The package is designed with:
- Clear separation between **UI**, **behavior**, and **configuration**
- Persistent property containers for easy design-time and runtime customization
- Compatibility with **SynEditPrint** and **SynEditPrintPreview**
- Open-source–friendly structure and documentation

---

## Package Contents

The package includes the following units:

```pascal
  PlSynEditPrintUtils,
  PlPreviewProperties,
  PlPreviewUIProperties,
  PlPageSetupProperties,
  PlPageSetupForm,
  PlPrintPreviewForm;
```

---

## Units Overview

### PlSynEditPrintUtils

Utility functions and helpers shared across the printing and preview system.

**Purpose**

* Common routines for SynEdit print/preview integration
* Shared constants and helper logic

#### Documentation:
[pl_synedit_print_utils](pl_synedit_print_utils.md)

---

### PlPreviewProperties

Defines persistent properties that control **visual and behavioral aspects** of the print preview component.

**Key responsibilities**

* Preview scaling
* Background color
* Page shadow
* Line number visibility
* Scroll hint behavior

This unit is UI-agnostic and meant to be applied to `TSynEditPrintPreview`.

#### Documentation:
[pl_preview_properties](pl_preview_properties.md)

---

### PlPreviewUIProperties

Encapsulates **UI text, captions, localization settings, and callbacks** for the print preview form.

**Key responsibilities**

* Preview form captions and button text
* Page information template
* Language and translation integration
* Hooks for page setup and printer setup dialogs

#### Documentation:
[pl_preview_ui_properties](pl_preview_ui_properties.md)

---

### PlPageSetupProperties

A persistent, reusable container for **page layout and printing configuration**.

**Key responsibilities**

* Page size and measurement units
* Margins
* Orientation
* Page presets (A4, Letter, Portrait/Landscape)

This unit can be reused independently of the UI.

#### Documentation:
[pl_page_setup_properties](pl_page_setup_properties.md)

---

### PlPageSetupForm

A VCL dialog that allows the user to **edit page setup properties visually**.

**Key responsibilities**

* Page size and unit selection
* Margin editing
* Orientation selection
* Preset application (A4, Letter, etc.)

Designed to work directly with `TPlPageSetupProperties`.

#### Documentation:
[pl_page_setup_form](pl_page_setup_form.md)

---

### PlPrintPreviewForm

The main **print preview UI form**, built around `TSynEditPrintPreview`.

**Key responsibilities**

* Page navigation (first, previous, next, last)
* Zoom and scale modes
* Line number toggling
* Print and setup command integration
* Localization via `TPlLanguage`

This form acts as the central UI entry point for printing workflows.

#### Documentation:
[pl_print_preview_form](pl_print_preview_form.md)

---

## Typical Usage Flow

1. Configure printing via `TPlPageSetupProperties`
2. Customize preview behavior using `TPlPreviewProperties`
3. Customize UI and localization using `TPlPreviewUIProperties`
4. Display `TfrmPlPrintPreview`
5. Apply changes and print via `TSynEditPrint`

---

## Requirements

* Delphi 12.x (or compatible recent versions)
* VCL framework
* SynEdit (with `SynEditPrint` and `SynEditPrintPreview`)
* pl.VCL.Components: `TPlLanguage` for localization support

---

## Contributing

Contributions are welcome!  

---

## License

Released under the MIT License. See the LICENSE file for details.
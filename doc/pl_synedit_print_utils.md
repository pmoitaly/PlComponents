# PlSynEditPrintUtils

## Overview

`PlSynEditPrintUtils` provides a high-level utility layer for printing and print preview operations based on **SynEdit** components.

The unit integrates:

* `TSynEditPrint`
* SynEdit print preview
* VCL print, printer setup, and page setup dialogs
* Custom preview UI and behavior through project-specific components

It is designed to offer a **single, cohesive API** for printing SynEdit-based editors with preview support and extensible UI customization.

---

## Main Responsibilities

* Centralize printing logic for `TCustomSynEdit`
* Handle print dialogs, printer setup, and page setup
* Provide print preview with customizable UI and behavior
* Support full document printing, page ranges, and selections
* Expose high-level success and failure events

---

## Key Types

### `TPlPrintDoneEvent`

```pascal
procedure(Sender: TObject) of object;
```

Triggered when a print operation completes successfully.

---

### `TPlPrintFailedEvent`

```pascal
procedure(Sender: TObject; E: Exception) of object;
```

Triggered when a print operation fails with an exception.

---

## Main Class

### `TPlSynEditPrintSystem`

`TPlSynEditPrintSystem` is a component (`TComponent`) that orchestrates all aspects of printing and previewing SynEdit content.

> **Detailed documentation for this important class is provided separately.**
**See:**
[`pl_syneditor_print_system.md`](pl_syneditor_print_system.md)

That document covers:

* Architecture and internal workflow
* Printing modes
* Preview integration
* Header/footer handling
* Error handling strategy
* Usage examples

---

## High-Level Features

Without duplicating the dedicated documentation, `TPlSynEditPrintSystem` provides:

* Unified API for:

  * Printing
  * Print preview
  * Page setup
  * Printer setup
* Seamless integration with:

  * `TPlPreviewProperties`
  * `TPlPreviewUIProperties`
  * `TfrmPlPrintPreview`
* Safe lifecycle management of internal dialogs and components
* Events for success and failure notification

---

## Typical Usage Scenario

1. Drop `TPlSynEditPrintSystem` on a form or create it dynamically
2. Assign a `TCustomSynEdit` instance
3. Configure preview and UI properties if needed
4. Call:

   * `Print`
   * or `PrintPreview`
5. Handle `OnPrintDone` and `OnPrintFailed` events

For concrete examples, refer to
➡ **`pl_syneditor_print_system.md`**

---

## Design Notes

* The unit intentionally hides low-level SynEdit printing details
* Preview UI is fully customizable via composition
* Printing logic is centralized and reusable
* Suitable for IDE-like editors and document viewers

---

## License

This unit is released under the **MIT License**. See the LICENSE file for details.

---

## Related Units

* [PlPageSetupProperties](pl_page_setup_properties.md)
* [PlPageSetupForm](pl_page_setup_form.md)
* [PlPrintPreviewForm](pl_print_preview_form.md)
* [PlPreviewUIProperties](pl_preview_ui_properties.md)
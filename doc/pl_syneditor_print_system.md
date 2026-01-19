# TPlSynEditPrintSystem

`TPlSynEditPrintSystem` is a high-level **printing controller** for **SynEdit** components in Delphi VCL applications, placed in [plSinEditPrintUtils](pl_synedit_print_utils.md) unit.

It orchestrates:

* printing
* print preview
* page setup
* printer setup

by coordinating `TSynEditPrint`, `TSynEditPrintPreview`, dialogs, and custom UI/property classes.

The class is designed to **centralize all printing logic** while keeping UI forms and dialogs loosely coupled.

---

## Design Goals

* Provide a **single entry point** for printing and previewing SynEdit content
* Support:

  * full document printing
  * page range printing
  * selection-only printing
* Integrate cleanly with:

  * print dialog
  * page setup dialog
  * printer setup dialog
* Allow customization via property objects
* Expose lifecycle events (success / failure)
* Keep UI logic out of business logic

---

## Class Overview

```pascal
TPlSynEditPrintSystem = class(TComponent)
```

This class is intended to be dropped on a form or created at runtime and reused for multiple print operations.

---

## Typical Usage

```pascal
PrintSystem := TPlSynEditPrintSystem.Create(Self);
PrintSystem.Editor := SynEdit1;
PrintSystem.Title := 'My Document';

PrintSystem.Print(True);       // Print with dialog
PrintSystem.PrintPreview(True); // Preview, then print with dialog
```

---

## Core Responsibilities

### 1. Print Orchestration

* Decides *how* to print based on:

  * print dialog settings
  * user selection
* Handles:

  * full document
  * page ranges
  * selection-only printing

### 2. Print Preview

* Displays a modal preview window (`TfrmPlPrintPreview`)
* Applies preview configuration and UI customization
* Returns user intent (print / cancel)

### 3. Dialog Management

* `TPrintDialog`
* `TPageSetupDialog`
* `TPrinterSetupDialog`

All dialogs are created internally and exposed as subcomponents.

---

## Public Methods

### Print

```pascal
procedure Print(const WithDialog: Boolean = False);
```

Prints the document associated with `Editor`.

* If `WithDialog = True`, the standard print dialog is shown
* Automatically detects:

  * selection-only printing
  * page ranges
* Raises no exceptions to the caller
* Signals completion or failure via events

---

### PrintPreview

```pascal
procedure PrintPreview(const WithDialog: Boolean = False);
```

Shows the print preview form.

Workflow:

1. Prepares the print engine
2. Opens `TfrmPlPrintPreview` modally
3. Applies preview settings
4. If the user confirms:

   * printing is executed
   * optionally with print dialog

---

### ShowPageSetup

```pascal
procedure ShowPageSetup;
```

Displays the page setup dialog and refreshes the preview if visible.

---

### ShowPrinterSetup

```pascal
procedure ShowPrinterSetup;
```

Displays the printer setup dialog and refreshes the preview if visible.

---

## Key Properties

### Editor

```pascal
property Editor: TCustomSynEdit;
```

The SynEdit control whose content will be printed.

> **Required** – printing and preview will fail without it.

---

### Title

```pascal
property Title: string;
```

Document title used in:

* print headers
* preview UI

---

### PreviewProperties

```pascal
property PreviewProperties: TPlPreviewProperties;
```

Controls preview behavior:

* zoom
* background color
* scroll hints
* line numbers

---

### PreviewUIProperties

```pascal
property PreviewUIProperties: TPlPreviewUIProperties;
```

Controls preview UI text and localization:

* captions
* button labels
* page info format
* language integration

---

### Dialog Components

```pascal
property PrintDialog: TPrintDialog;
property PageSetupDialog: TPageSetupDialog;
property PrinterSetupDialog: TPrinterSetupDialog;
```

* Created internally
* Marked as subcomponents
* Fully configurable at design time or runtime

---

## Events

### OnPrintDone

```pascal
property OnPrintDone: TPlPrintDoneEvent;
```

Triggered after a successful print operation.

---

### OnPrintFailed

```pascal
property OnPrintFailed: TPlPrintFailedEvent;
```

Triggered when printing fails due to an exception.

The exception instance is provided to the handler.

---

## Internal Workflow (Simplified)

```text
Print / PrintPreview
  ↓
PreparePrintEngine
  ↓
(Optional) Show Dialog
  ↓
Determine Print Mode
  ├─ Selection
  ├─ Page Range
  └─ Full Document
  ↓
Execute Print
  ↓
Raise Success / Failure Event
```

---

## Error Handling

* All print operations are wrapped in `try/except`
* Exceptions do **not** propagate to the caller
* Errors are reported via `OnPrintFailed`

This makes the class safe for UI-driven workflows.

---

## Extensibility Notes

You can safely extend this class to:

* Add PDF export
* Inject custom headers / footers
* Implement print presets
* Log print operations
* Add background printing

Avoid:

* embedding UI logic directly
* modifying dialog execution order
* bypassing preview property objects

---

## Dependencies

* SynEdit
* `TSynEditPrint`
* `TSynEditPrintPreview`
* VCL printing dialogs
* `TfrmPlPrintPreview`
* `TPlPreviewProperties`
* `TPlPreviewUIProperties`

---

## Architectural Role

`TPlSynEditPrintSystem` acts as a **facade** over the Delphi printing subsystem and SynEdit printing APIs.

It allows application code to remain simple, declarative, and maintainable while keeping printing logic centralized and testable.

---

## Contributing

This class is designed for open-source usage and extension. Contributions are welcome.
Please open issues or submit pull requests on GitHub.

---

## License

Released under the **MIT License**. See the LICENSE file for details.


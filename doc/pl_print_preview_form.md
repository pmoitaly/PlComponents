# PlPrintPreviewForm

`PlPrintPreviewForm` provides a reusable **print preview window** for Delphi VCL applications based on **SynEdit**.
It wraps `TSynEditPrintPreview` with a complete UI, navigation controls, zoom handling, and integration points for **printing**, **page setup**, **printer setup**, and **localization**.

The form is designed to be embedded into higher-level printing workflows (such as `TPlSynEditPrintSystem`) while remaining reusable and customizable.

---

## Key Features

* Preview of printed output using `TSynEditPrintPreview`
* Page navigation (first / previous / next / last)
* Zoom modes:

  * Whole page
  * Page width
  * Custom zoom percentage
* Optional line number toggle
* Integration with:

  * Print dialog
  * Page setup dialog
  * Printer setup dialog
* Language/localization support via `TPlLanguage`
* Designed for modal usage (`ShowModal`)

---

## Main Class

```pascal
TfrmPlPrintPreview = class(TForm)
```

This form is intended to be created, configured, shown modally, and destroyed by a controller or service class.

---

## Typical Usage

```pascal
var
  PreviewForm: TfrmPlPrintPreview;
begin
  PreviewForm := TfrmPlPrintPreview.Create(nil);
  try
    PreviewForm.LoadPrintData(SynEditPrint);
    PreviewForm.OnShowPageSetup := ShowPageSetupDialog;
    PreviewForm.OnShowPrinterSetup := ShowPrinterSetupDialog;

    if PreviewForm.ShowModal = mrOk then
      ExecutePrint;
  finally
    PreviewForm.Free;
  end;
end;
```

---

## Public API

### LoadPrintData

```pascal
procedure LoadPrintData(APrinter: TSynEditPrint);
```

Assigns a configured `TSynEditPrint` instance to the preview control.

* The preview **does not take ownership** of the printer object.
* The current page count and line-number state are synchronized automatically.

---

### PageInfoText

```pascal
property PageInfoText: string;
```

Format string used to display page information.

Default value:

```text
Page %d of %d
```

Example customization:

```pascal
PreviewForm.PageInfoText := 'Sheet %d / %d';
```

---

### WithDialog

```pascal
WithDialog: Boolean;
```

A public flag typically read by the caller after `ShowModal`.

* `True` → printing should show the print dialog
* `False` → printing should proceed silently

This form does **not** implement printing directly; it only signals intent.

---

### OnShowPageSetup

```pascal
property OnShowPageSetup: TProc;
```

Callback invoked when the user clicks **Page Setup**.

Expected usage:

```pascal
PreviewForm.OnShowPageSetup :=
  procedure
  begin
    PageSetupDialog.Execute;
  end;
```

---

### OnShowPrinterSetup

```pascal
property OnShowPrinterSetup: TProc;
```

Callback invoked when the user clicks **Printer Setup**.

---

## User Interface Behavior

### Navigation Actions

* **First page**
* **Previous page**
* **Next page**
* **Last page**

Buttons are automatically enabled/disabled based on the current page number.

---

### Zoom Handling

* **Whole Page** → `pscWholePage`
* **Page Width** → `pscPageWidth`
* **Custom Zoom** → controlled via the trackbar (`ScalePercent`)

The zoom trackbar updates `TSynEditPrintPreview.ScalePercent` directly.

---

### Line Numbers

The checkbox **With Lines** toggles:

```pascal
sepPreview.SynEditPrint.LineNumbers
```

and refreshes the preview immediately.

---

## Localization Support

The form includes a `TPlLanguage` component:

```pascal
plnTranslator: TPlLanguage;
```

This allows:

* Runtime language switching
* External language files
* Consistent integration with the rest of the PlComponents ecosystem

---

## Design Notes

* The form **does not create or configure** `TSynEditPrint`
* It assumes the printer object is already prepared
* No global state is used
* No printing logic is embedded (Single Responsibility Principle)

---

## Extension Points

You may safely extend this form to:

* Add custom zoom modes
* Add watermark or page overlays
* Integrate PDF export
* Add print presets or profiles
* Customize toolbar or actions

---

## Dependencies

* Delphi VCL
* SynEdit
* `SynEditPrint`
* `SynEditPrintPreview`
* `PlLanguage`

---

## Contributing


This unit is designed for open-source usage and extension. Contributions are welcome.
Please open issues or submit pull requests on GitHub.

---

## License

Released under the **MIT License**. See the LICENSE file for details.


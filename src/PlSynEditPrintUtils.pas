unit PlSynEditPrintUtils;

{*******************************************************************************
 * MIT License
 *
 * Copyright (c) 2023-2025 Paolo Morandotti
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *******************************************************************************}

{*******************************************************************************
 /// Project: PlComponents
 /// Unit: PlSynEditPrintUtils
 /// Provides an unified logic to print documents with SynEditor system
 *******************************************************************************}

interface

uses
  System.Classes, System.SysUtils,
  Vcl.Dialogs,
  SynEdit, SynEditPrint, SynEditPrintPreview,
  PlPrintPreviewForm, PlPreviewProperties, PlPreviewUIProperties;

type
  /// <summary>
  /// Event triggered when a print operation completes successfully.
  /// </summary>
  TPlPrintDoneEvent = procedure(Sender: TObject) of object;

  /// <summary>
  /// Event triggered when a print operation fails.
  /// </summary>
  TPlPrintFailedEvent = procedure(Sender: TObject; E: Exception) of object;

  /// <summary>
  /// High-level printing and preview system for SynEdit controls.
  /// </summary>
  /// <remarks>
  /// TPlSynEditPrintSystem wraps TSynEditPrint and related dialogs,
  /// providing a unified API for:
  /// - printing
  /// - print preview
  /// - page setup
  /// - printer setup
  ///
  /// It supports full document printing, page ranges and selections,
  /// and integrates with a customizable preview UI.
  /// </remarks>
  TPlSynEditPrintSystem = class(TComponent)
  private
    FCustomDateFormat: string;
    FEditor: TCustomSynEdit;
    FOnPrintDone: TPlPrintDoneEvent;
    FOnPrintFailed: TPlPrintFailedEvent;
    FPageSetupDialog: TPageSetupDialog;
    FPreviewForm: TfrmPlPrintPreview;
    FPreviewProperties: TPlPreviewProperties;
    FPreviewUI: TPlPreviewUIProperties;
    FPrint: TSynEditPrint;
    FPrintDialog: TPrintDialog;
    FPrinterSetupDialog: TPrinterSetupDialog;
    FTitle: string;

    procedure DoPrintCompleted;
    procedure DoPrintFailed(E: Exception);

    procedure ExecuteFullPrint;
    procedure ExecutePageRangePrint;
    procedure ExecutePrintBasedOnDialog;
    procedure ExecuteSelectionPrint;

    procedure PrepareHeaderFooter;
    procedure PreparePrintEngine;

    procedure SetEditor(const Value: TCustomSynEdit);
    procedure SetPreviewProperties(const Value: TPlPreviewProperties);
    procedure SetPreviewUI(const Value: TPlPreviewUIProperties);
    procedure SetTitle(const Value: string);

    procedure SetupPrintDialog;
    procedure SetupProperties;
    procedure UpdatePreview;

  public
    /// <summary>
    /// Creates the print system and initializes all internal components.
    /// </summary>
    constructor Create(AOwner: TComponent); override;

    /// <summary>
    /// Destroys the print system and releases all owned resources.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    /// Prints the associated editor content.
    /// </summary>
    /// <param name="WithDialog">
    /// When True, shows the print dialog before printing.
    /// </param>
    procedure Print(const WithDialog: Boolean = False);

    /// <summary>
    /// Displays the print preview dialog.
    /// </summary>
    /// <param name="WithDialog">
    /// When True, shows the print dialog before printing from preview.
    /// </param>
    procedure PrintPreview(const WithDialog: Boolean = False);

    /// <summary>
    /// Displays the page setup dialog.
    /// </summary>
    procedure ShowPageSetup;

    /// <summary>
    /// Displays the printer setup dialog.
    /// </summary>
    procedure ShowPrinterSetup;

  published
    /// <summary>
    /// Custom date format used in the print header.
    /// </summary>
    property CustomDateFormat: string
      read FCustomDateFormat write FCustomDateFormat;

    /// <summary>
    /// SynEdit control associated with this print system.
    /// </summary>
    property Editor: TCustomSynEdit
      read FEditor write SetEditor;

    /// <summary>
    /// Page setup dialog used by the print system.
    /// </summary>
    property PageSetupDialog: TPageSetupDialog
      read FPageSetupDialog stored True;

    /// <summary>
    /// Properties controlling preview rendering behavior.
    /// </summary>
    property PreviewProperties: TPlPreviewProperties
      read FPreviewProperties write SetPreviewProperties stored True;

    /// <summary>
    /// UI-related properties for the preview window.
    /// </summary>
    property PreviewUIProperties: TPlPreviewUIProperties
      read FPreviewUI write SetPreviewUI stored True;

    /// <summary>
    /// Print dialog used by the print system.
    /// </summary>
    property PrintDialog: TPrintDialog
      read FPrintDialog stored True;

    /// <summary>
    /// Printer setup dialog used by the print system.
    /// </summary>
    property PrinterSetupDialog: TPrinterSetupDialog
      read FPrinterSetupDialog stored True;

    /// <summary>
    /// Document title used in headers and print metadata.
    /// </summary>
    property Title: string
      read FTitle write SetTitle;

    /// <summary>
    /// Event fired after a successful print operation.
    /// </summary>
    property OnPrintDone: TPlPrintDoneEvent
      read FOnPrintDone write FOnPrintDone;

    /// <summary>
    /// Event fired when a print operation fails.
    /// </summary>
    property OnPrintFailed: TPlPrintFailedEvent
      read FOnPrintFailed write FOnPrintFailed;
  end;

implementation

uses
  System.UITypes,
  Vcl.Controls,
  Printers;

resourcestring
  SDocumentDoesNotContainPrintablePages =
    'The document does not contain printable pages.';
  SInvalidInterval =
    'Invalid page interval.';
  SUnknownPrintingMode =
    'Unknown printing mode.';
  SNoTextSelected =
    'No text selected for printing.';
  SJSONEditor =
    'JSON Editor';
  SPage =
    'Page %d';
  SNoEditorAssigndForPrinting =
    'No editor assigned for printing.';
  SDdMmYyyy =
    'dd/mm/yyyy';

{$REGION 'TPlSynEditPrintSystem'}

constructor TPlSynEditPrintSystem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetupProperties;
end;

destructor TPlSynEditPrintSystem.Destroy;
begin
  FPageSetupDialog.Free;
  FPreviewUI.Free;
  FPreviewProperties.Free;
  FPrinterSetupDialog.Free;
  FPrintDialog.Free;
  FPrint.Free;
  inherited;
end;

procedure TPlSynEditPrintSystem.DoPrintCompleted;
begin
  if Assigned(FOnPrintDone) then
    FOnPrintDone(Self);
end;

procedure TPlSynEditPrintSystem.DoPrintFailed(E: Exception);
begin
  if Assigned(FOnPrintFailed) then
    FOnPrintFailed(Self, E);
end;

procedure TPlSynEditPrintSystem.ExecuteFullPrint;
begin
  FPrint.SelectedOnly := False;
  FPrint.Print;
end;

procedure TPlSynEditPrintSystem.ExecutePageRangePrint;
var
  fromPage: Integer;
  pageCount: Integer;
  toPage: Integer;
begin
  FPrint.SelectedOnly := False;

  fromPage := FPrintDialog.FromPage;
  toPage := FPrintDialog.ToPage;

  pageCount := FPrint.PageCount;

  if pageCount = 0 then
  begin
    MessageDlg(SDocumentDoesNotContainPrintablePages,
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if fromPage < 1 then
    fromPage := 1;
  if toPage > pageCount then
    toPage := pageCount;
  if fromPage > toPage then
  begin
    MessageDlg(SInvalidInterval, mtError, [mbOK], 0);
    Exit;
  end;

  FPrint.PrintRange(fromPage, toPage);
end;

procedure TPlSynEditPrintSystem.ExecutePrintBasedOnDialog;
begin
  if not Assigned(FEditor)
    or not Assigned(FPrint)
    or not Assigned(FPrintDialog) then
    Exit;

  PreparePrintEngine;
  FPrint.Copies := FPrintDialog.Copies;

  case FPrintDialog.PrintRange of
    prSelection:
      ExecuteSelectionPrint;
    prPageNums:
      ExecutePageRangePrint;
    prAllPages:
      ExecuteFullPrint;
  else
    MessageDlg(SUnknownPrintingMode, mtError, [mbOK], 0);
  end;
end;

procedure TPlSynEditPrintSystem.ExecuteSelectionPrint;
begin
  if FEditor.SelAvail then
  begin
    FPrint.SelectedOnly := True;
    FPrint.Print;
  end
  else
    MessageDlg(SNoTextSelected, mtWarning, [mbOK], 0);
end;

procedure TPlSynEditPrintSystem.PrepareHeaderFooter;
begin
  FPrint.Title := FTitle;

  if FPrint.Header.Count = 0 then
  begin
    FPrint.Header.Clear;
    FPrint.Header.Add(SJSONEditor, nil, taLeftJustify, 0);
    FPrint.Header.Add(
      FormatDateTime(FCustomDateFormat, Now),
      nil,
      taRightJustify,
      0
    );
  end;

  if FPrint.Footer.Count = 0 then
  begin
    FPrint.Footer.Clear;
    FPrint.Footer.Add(SPage, nil, taCenter, 0);
  end;
end;

procedure TPlSynEditPrintSystem.PreparePrintEngine;
begin
  FPrint.SynEdit := FEditor;
  FPrint.Title := FTitle;
  FPrint.LineNumbers := False;
end;

procedure TPlSynEditPrintSystem.Print(const WithDialog: Boolean);
begin
  if not Assigned(FEditor) then
    raise Exception.Create(SNoEditorAssigndForPrinting);

  try
    if WithDialog then
    begin
      SetupPrintDialog;
      if FPrintDialog.Execute then
        ExecutePrintBasedOnDialog;
    end
    else
      ExecutePrintBasedOnDialog;

    DoPrintCompleted;
  except
    on E: Exception do
      DoPrintFailed(E);
  end;
end;

procedure TPlSynEditPrintSystem.PrintPreview(const WithDialog: Boolean);
begin
  if not Assigned(FEditor)
    or not Assigned(FPrint)
    or Assigned(FPreviewForm) then
    Exit;

  PreparePrintEngine;

  FPreviewForm := TfrmPlPrintPreview.Create(Self);
  try
    FPreviewForm.LoadPrintData(FPrint);
    FPreviewProperties.ApplyTo(FPreviewForm.sepPreview);
    FPreviewUI.ApplyTo(FPreviewForm);

    FPreviewForm.sepPreview.UpdatePreview;
    FPreviewForm.sepPreview.FirstPage;

    if FPreviewForm.ShowModal = mrOk then
    begin
      FPreviewProperties.ShowLineNumber :=
        FPreviewForm.chkWithLines.Checked;
      Print(WithDialog and Assigned(FPrintDialog));
    end;
  finally
    FreeAndNil(FPreviewForm);
  end;
end;

procedure TPlSynEditPrintSystem.SetEditor(const Value: TCustomSynEdit);
begin
  FEditor := Value;
  FPrint.SynEdit := FEditor;
  FPrint.Highlighter := FEditor.Highlighter;
  FPrint.Title := FTitle;
end;

procedure TPlSynEditPrintSystem.SetPreviewProperties(
  const Value: TPlPreviewProperties);
begin
  FPreviewProperties.Assign(Value);
end;

procedure TPlSynEditPrintSystem.SetPreviewUI(
  const Value: TPlPreviewUIProperties);
begin
  FPreviewUI.Assign(Value);
end;

procedure TPlSynEditPrintSystem.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

procedure TPlSynEditPrintSystem.SetupPrintDialog;
begin
  if not Assigned(FEditor) or not Assigned(FPrintDialog) then
    Exit;

  PrepareHeaderFooter;
  PreparePrintEngine;
end;

procedure TPlSynEditPrintSystem.SetupProperties;
begin
  FPreviewForm := nil;

  FPageSetupDialog := TPageSetupDialog.Create(Self);
  FPageSetupDialog.Name := 'psdPageSetup';
  FPageSetupDialog.SetSubComponent(True);

  FPrint := TSynEditPrint.Create(Self);
  FPrint.LineNumbers := False;

  FPrinterSetupDialog := TPrinterSetupDialog.Create(Self);
  FPrinterSetupDialog.Name := 'prsPrinterSetup';
  FPrinterSetupDialog.SetSubComponent(True);

  FPrintDialog := TPrintDialog.Create(Self);
  FPrintDialog.Name := 'prdPrint';
  FPrintDialog.SetSubComponent(True);

  FCustomDateFormat := SDdMmYyyy;

  FPreviewProperties := TPlPreviewProperties.Create(Self);
  FPreviewUI := TPlPreviewUIProperties.Create(Self);

  FPreviewUI.OpenPageSetupDialog :=
    procedure
    begin
      ShowPageSetup;
    end;

  FPreviewUI.OpenPrinterSetupDialog :=
    procedure
    begin
      ShowPrinterSetup;
    end;
end;

procedure TPlSynEditPrintSystem.ShowPageSetup;
begin
  if FPageSetupDialog.Execute then
    UpdatePreview;
end;

procedure TPlSynEditPrintSystem.ShowPrinterSetup;
begin
  if FPrinterSetupDialog.Execute then
    UpdatePreview;
end;

procedure TPlSynEditPrintSystem.UpdatePreview;
begin
  FPrint.PrinterInfo.UpdatePrinter;
  if Assigned(FPreviewForm) then
    FPreviewForm.sepPreview.UpdatePreview;
end;

{$ENDREGION}

end.


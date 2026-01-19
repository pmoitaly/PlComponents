unit PlPrintPreviewForm;

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
 /// Unit: PlPageSetupForm
 /// Provides a form for easy page setup configuration
 *******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Actions,
  System.ImageList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ToolWin, Vcl.Menus, Vcl.ActnList,
  Vcl.ActnCtrls, Vcl.ActnMan, Vcl.ActnMenus, Vcl.ActnPopup,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.VirtualImageList,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.ImgList,
  SynEditPrint, SynEditPrintPreview, PlLanguage;

type
  TfrmPlPrintPreview = class(TForm)
    aclPrintPreview: TActionList;
    actClose: TAction;
    actGoFirst: TAction;
    actGoLast: TAction;
    actGoNext: TAction;
    actGoPrev: TAction;
    actPageSetup: TAction;
    actPrint: TAction;
    actPrinterSetup: TAction;
    actScalePageWidth: TAction;
    actScaleWholePage: TAction;
    actScaleZoom: TAction;
    amgPrintPreview: TActionManager;
    atbPrintPreview: TActionToolBar;
    btnClose: TButton;
    btnPrint: TButton;
    chkWithLines: TCheckBox;
    iclDarkGreyIcons: TImageCollection;
    lblPageInfo: TLabel;
    pnlBottomBar: TPanel;
    plnTranslator: TPlLanguage;
    sepPreview: TSynEditPrintPreview;
    tbrZoom: TTrackBar;
    vilIcons: TVirtualImageList;
    procedure aclPrintPreviewUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure actCloseExecute(Sender: TObject);
    procedure actGoFirstExecute(Sender: TObject);
    procedure actGoLastExecute(Sender: TObject);
    procedure actGoNextExecute(Sender: TObject);
    procedure actGoPrevExecute(Sender: TObject);
    procedure actPageSetupExecute(Sender: TObject);
    procedure actPrintClick(Sender: TObject);
    procedure actPrinterSetupExecute(Sender: TObject);
    procedure actScalePageWidthExecute(Sender: TObject);
    procedure actScaleWholePageExecute(Sender: TObject);
    procedure actScaleZoomExecute(Sender: TObject);
    procedure chkWithLinesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tbrZoomChange(Sender: TObject);
  private
    FOnShowPageSetup: TProc;
    FOnShowPrinterSetup: TProc;
    FPageInfoText: string;
    procedure GoToFirstPage;
    procedure GoToLastPage;
    procedure GoToNextPage;
    procedure GoToPrevPage;
    procedure UpdatePageInfo;
  public
    /// <summary>
    /// Indicates whether the print operation should show the print dialog.
    /// </summary>
    WithDialog: Boolean;

    /// <summary>
    /// Loads the print engine data into the preview control.
    /// </summary>
    procedure LoadPrintData(APrinter: TSynEditPrint);

    /// <summary>
    /// Event triggered when the Page Setup dialog is requested.
    /// </summary>
    property OnShowPageSetup: TProc read FOnShowPageSetup
      write FOnShowPageSetup;

    /// <summary>
    /// Event triggered when the Printer Setup dialog is requested.
    /// </summary>
    property OnShowPrinterSetup: TProc read FOnShowPrinterSetup
      write FOnShowPrinterSetup;
  published
    /// <summary>
    /// Format string used to display page information.
    /// Example: 'Page %d of %d'.
    /// </summary>
    property PageInfoText: string read FPageInfoText write FPageInfoText;
  end;

implementation

{$R *.dfm}

{ TfrmPlPrintPreview }

procedure TfrmPlPrintPreview.aclPrintPreviewUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if Assigned(sepPreview.SynEditPrint) then
  begin
    actGoFirst.Enabled := sepPreview.PageNumber > 1;
    actGoPrev.Enabled := sepPreview.PageNumber > 1;
    actGoNext.Enabled :=
      sepPreview.PageNumber < sepPreview.SynEditPrint.PageCount;
    actGoLast.Enabled :=
      sepPreview.PageNumber < sepPreview.SynEditPrint.PageCount;
  end;
end;

procedure TfrmPlPrintPreview.actCloseExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmPlPrintPreview.actGoFirstExecute(Sender: TObject);
begin
  GoToFirstPage;
end;

procedure TfrmPlPrintPreview.actGoLastExecute(Sender: TObject);
begin
  GoToLastPage;
end;

procedure TfrmPlPrintPreview.actGoNextExecute(Sender: TObject);
begin
  GoToNextPage;
end;

procedure TfrmPlPrintPreview.actGoPrevExecute(Sender: TObject);
begin
  GoToPrevPage;
end;

procedure TfrmPlPrintPreview.actPageSetupExecute(Sender: TObject);
begin
  if Assigned(FOnShowPageSetup) then
    FOnShowPageSetup;
end;

procedure TfrmPlPrintPreview.actPrintClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmPlPrintPreview.actPrinterSetupExecute(Sender: TObject);
begin
  if Assigned(FOnShowPrinterSetup) then
    FOnShowPrinterSetup;
end;

procedure TfrmPlPrintPreview.actScalePageWidthExecute(Sender: TObject);
begin
  sepPreview.ScaleMode := pscPageWidth;
  tbrZoom.Position := 100;
end;

procedure TfrmPlPrintPreview.actScaleWholePageExecute(Sender: TObject);
begin
  sepPreview.ScaleMode := pscWholePage;
  tbrZoom.Position := 20;
end;

procedure TfrmPlPrintPreview.actScaleZoomExecute(Sender: TObject);
begin
  { Reserved for future zoom mode handling }
end;

procedure TfrmPlPrintPreview.chkWithLinesClick(Sender: TObject);
begin
  sepPreview.SynEditPrint.LineNumbers := chkWithLines.Checked;
  sepPreview.UpdatePreview;
end;

procedure TfrmPlPrintPreview.FormCreate(Sender: TObject);
begin
  FPageInfoText := 'Page %d of %d';
  tbrZoom.Position := sepPreview.ScalePercent;
  UpdatePageInfo;
end;

procedure TfrmPlPrintPreview.GoToFirstPage;
begin
  sepPreview.FirstPage;
  UpdatePageInfo;
end;

procedure TfrmPlPrintPreview.GoToLastPage;
begin
  sepPreview.LastPage;
  UpdatePageInfo;
end;

procedure TfrmPlPrintPreview.GoToNextPage;
begin
  sepPreview.NextPage;
  UpdatePageInfo;
end;

procedure TfrmPlPrintPreview.GoToPrevPage;
begin
  sepPreview.PreviousPage;
  UpdatePageInfo;
end;

procedure TfrmPlPrintPreview.LoadPrintData(APrinter: TSynEditPrint);
begin
  sepPreview.SynEditPrint := APrinter;

  if Assigned(APrinter) then
    chkWithLines.Checked := APrinter.LineNumbers;

  UpdatePageInfo;
end;

procedure TfrmPlPrintPreview.tbrZoomChange(Sender: TObject);
begin
  sepPreview.ScalePercent := tbrZoom.Position;
end;

procedure TfrmPlPrintPreview.UpdatePageInfo;
begin
  if Assigned(sepPreview.SynEditPrint) then
    lblPageInfo.Caption := Format(FPageInfoText,
      [sepPreview.PageNumber, sepPreview.SynEditPrint.PageCount]);
end;

end.


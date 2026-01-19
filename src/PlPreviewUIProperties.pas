unit PlPreviewUIProperties;

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
 /// Unit: PlPreviewProperties
 /// Provides a class for getting/setting page preview properties.
 *******************************************************************************}

interface

uses
  System.Classes,
  System.SysUtils,
  PlPrintPreviewForm;

type
  /// <summary>
  /// Encapsulates UI-related properties for the print preview form.
  /// </summary>
  /// <remarks>
  /// This class centralizes captions, localization settings and callbacks
  /// used by the preview UI.
  /// </remarks>
  TPlPreviewUIProperties = class(TPersistent)
  private
    FCloseButtonText: string;
    FFormCaption: string;
    FLangPath: string;
    FLanguage: string;
    FOpenPageSetupDialog: TProc;
    FOpenPrinterSetupDialog: TProc;
    FPageInfoTemplate: string;
    FPrintButtonText: string;

    procedure SetLangPath(const Value: string);
    procedure SetLanguage(const Value: string);
  public
    /// <summary>
    /// Creates the UI properties object with default values.
    /// </summary>
    constructor Create(AOwner: TComponent); overload;

    /// <summary>
    /// Applies the stored UI properties to the preview form.
    /// </summary>
    procedure ApplyTo(AForm: TfrmPlPrintPreview);

    /// <summary>
    /// Assigns values from another TPlPreviewUIProperties instance.
    /// </summary>
    procedure Assign(Source: TPersistent); override;

    /// <summary>
    /// Callback invoked to show the page setup dialog.
    /// </summary>
    property OpenPageSetupDialog: TProc
      read FOpenPageSetupDialog write FOpenPageSetupDialog;

    /// <summary>
    /// Callback invoked to show the printer setup dialog.
    /// </summary>
    property OpenPrinterSetupDialog: TProc
      read FOpenPrinterSetupDialog write FOpenPrinterSetupDialog;
  published
    /// <summary>Caption of the preview form.</summary>
    property FormCaption: string
      read FFormCaption write FFormCaption;

    /// <summary>Caption of the Print button.</summary>
    property PrintButtonText: string
      read FPrintButtonText write FPrintButtonText;

    /// <summary>Caption of the Close button.</summary>
    property CloseButtonText: string
      read FCloseButtonText write FCloseButtonText;

    /// <summary>Template used to display page information (e.g. "Page %d of %d").</summary>
    property PageInfoTemplate: string
      read FPageInfoTemplate write FPageInfoTemplate;

    /// <summary>Path containing localization files.</summary>
    property LangPath: string
      read FLangPath write SetLangPath;

    /// <summary>Language identifier used for localization.</summary>
    property Language: string
      read FLanguage write SetLanguage;
  end;

implementation

resourcestring
  SPrintPreview = 'Print preview';
  SPrint = '&Print';
  SClose = '&Close';
  SPageOf = 'Page %d of %d';

{$REGION 'TPlPreviewUIProperties'}

constructor TPlPreviewUIProperties.Create(AOwner: TComponent);
begin
  inherited Create;

  FFormCaption := SPrintPreview;
  FPrintButtonText := SPrint;
  FCloseButtonText := SClose;
  FPageInfoTemplate := SPageOf;
end;

procedure TPlPreviewUIProperties.ApplyTo(AForm: TfrmPlPrintPreview);
begin
  if not Assigned(AForm) then
    Exit;

  AForm.Caption := FFormCaption;
  AForm.btnPrint.Caption := FPrintButtonText;
  AForm.btnClose.Caption := FCloseButtonText;

  AForm.plnTranslator.LangPath := FLangPath;
  AForm.plnTranslator.Language := FLanguage;

  AForm.PageInfoText := FPageInfoTemplate;
  AForm.OnShowPageSetup := FOpenPageSetupDialog;
  AForm.OnShowPrinterSetup := FOpenPrinterSetupDialog;

  { Update page info label if preview is already initialized }
  if Assigned(AForm.sepPreview) and Assigned(AForm.lblPageInfo) then
    AForm.lblPageInfo.Caption := Format(
      FPageInfoTemplate,
      [
        AForm.sepPreview.PageNumber,
        AForm.sepPreview.SynEditPrint.PageCount
      ]
    );
end;

procedure TPlPreviewUIProperties.Assign(Source: TPersistent);
var
  sourceProps: TPlPreviewUIProperties;
begin
  if Source is TPlPreviewUIProperties then
  begin
    sourceProps := TPlPreviewUIProperties(Source);

    FFormCaption := sourceProps.FormCaption;
    FPrintButtonText := sourceProps.PrintButtonText;
    FCloseButtonText := sourceProps.CloseButtonText;
    FPageInfoTemplate := sourceProps.PageInfoTemplate;
    FOpenPageSetupDialog := sourceProps.OpenPageSetupDialog;
    FOpenPrinterSetupDialog := sourceProps.OpenPrinterSetupDialog;
    FLangPath := sourceProps.LangPath;
    FLanguage := sourceProps.Language;
  end
  else
    inherited Assign(Source);
end;

procedure TPlPreviewUIProperties.SetLangPath(const Value: string);
begin
  FLangPath := Value;
end;

procedure TPlPreviewUIProperties.SetLanguage(const Value: string);
begin
  FLanguage := Value;
end;

{$ENDREGION}

end.


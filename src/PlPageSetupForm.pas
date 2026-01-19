unit PlPageSetupForm;

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
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Graphics,
  PlPageSetupProperties;

type
  TfrmPlPageSetup = class(TForm)
    btnCancel: TButton;
    btnOK: TButton;
    cboPreset: TComboBox;
    cboUnit: TComboBox;
    edtHeight: TEdit;
    edtMarginBottom: TEdit;
    edtMarginLeft: TEdit;
    edtMarginRight: TEdit;
    edtMarginTop: TEdit;
    edtWidth: TEdit;
    grpMargins: TGroupBox;
    grpOrientation: TGroupBox;
    lblBottom: TLabel;
    lblHeight: TLabel;
    lblLeft: TLabel;
    lblRight: TLabel;
    lblTop: TLabel;
    lblUnit: TLabel;
    lblWidth: TLabel;
    radLandscape: TRadioButton;
    radPortrait: TRadioButton;
    procedure ApplyPreset(Sender: TObject);
    procedure SyncronizePreset(Sender: TObject);
  private
    FApplyingPresets: Boolean;
  public
    /// <summary>
    /// Reads the values currently entered in the dialog and returns
    /// a new TPlPageSetupProperties instance populated accordingly.
    /// </summary>
    function GetValues: TPlPageSetupProperties;

    /// <summary>
    /// Loads the dialog controls from the specified page setup properties.
    /// </summary>
    procedure LoadFrom(AProperties: TPlPageSetupProperties);
  end;

implementation

{$R *.dfm}

uses
  Vcl.Printers;

{ TfrmPlPageSetup }

procedure TfrmPlPageSetup.ApplyPreset(Sender: TObject);
var
  preset: TPlPagePreset;
begin
  FApplyingPresets := True;
  try
    preset := TPlPagePreset(cboPreset.ItemIndex);

    case preset of
      ppA4Portrait:
        begin
          cboUnit.ItemIndex := Ord(pmMillimeters) - 1;
          edtWidth.Text := '210';
          edtHeight.Text := '297';
          radPortrait.Checked := True;
        end;

      ppA4Landscape:
        begin
          cboUnit.ItemIndex := Ord(pmMillimeters) - 1;
          edtWidth.Text := '297';
          edtHeight.Text := '210';
          radLandscape.Checked := True;
        end;

      ppLetterPortrait:
        begin
          cboUnit.ItemIndex := Ord(pmInches) - 1;
          edtWidth.Text := '8.5';
          edtHeight.Text := '11.0';
          radPortrait.Checked := True;
        end;

      ppLetterLandscape:
        begin
          cboUnit.ItemIndex := Ord(pmInches) - 1;
          edtWidth.Text := '11.0';
          edtHeight.Text := '8.5';
          radLandscape.Checked := True;
        end;

    else
      begin
        { ppCustom: keep current values }
      end;
    end;
  finally
    FApplyingPresets := False;
  end;
end;

function TfrmPlPageSetup.GetValues: TPlPageSetupProperties;
begin
  Result := TPlPageSetupProperties.Create(Self);

  if cboUnit.ItemIndex = 0 then
    Result.PageUnit := pmMillimeters
  else
    Result.PageUnit := pmInches;

  Result.PageWidth := StrToFloatDef(edtWidth.Text, 210);
  Result.PageHeight := StrToFloatDef(edtHeight.Text, 297);

  Result.MarginLeft := StrToFloatDef(edtMarginLeft.Text, 20);
  Result.MarginRight := StrToFloatDef(edtMarginRight.Text, 20);
  Result.MarginTop := StrToFloatDef(edtMarginTop.Text, 25);
  Result.MarginBottom := StrToFloatDef(edtMarginBottom.Text, 25);

  if radPortrait.Checked then
    Result.Orientation := poPortrait
  else
    Result.Orientation := poLandscape;
end;

procedure TfrmPlPageSetup.LoadFrom(AProperties: TPlPageSetupProperties);
begin
  if not Assigned(AProperties) then
    Exit;

  { Load page unit }
  case AProperties.PageUnit of
    pmMillimeters:
      cboUnit.ItemIndex := 0;
    pmInches:
      cboUnit.ItemIndex := 1;
  end;

  edtWidth.Text := FormatFloat('0.##', AProperties.PageWidth);
  edtHeight.Text := FormatFloat('0.##', AProperties.PageHeight);

  edtMarginLeft.Text := FormatFloat('0.##', AProperties.MarginLeft);
  edtMarginRight.Text := FormatFloat('0.##', AProperties.MarginRight);
  edtMarginTop.Text := FormatFloat('0.##', AProperties.MarginTop);
  edtMarginBottom.Text := FormatFloat('0.##', AProperties.MarginBottom);

  radPortrait.Checked := AProperties.Orientation = poPortrait;
  radLandscape.Checked := AProperties.Orientation = poLandscape;
end;

procedure TfrmPlPageSetup.SyncronizePreset(Sender: TObject);
begin
  if not FApplyingPresets then
    cboPreset.ItemIndex := Ord(ppCustom);
end;

end.


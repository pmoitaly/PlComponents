unit PlPageSetupProperties;

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
 /// Unit: PlPageSetupProperties
 /// Provides a class for getting/setting page setup properties.
 *******************************************************************************}

interface

uses
  System.Classes, System.Types,
  Vcl.Dialogs, Vcl.Printers;

type
  /// <summary>
  /// Predefined page layout presets.
  /// </summary>
  TPlPagePreset = (
    ppCustom,
    ppA4Portrait,
    ppA4Landscape,
    ppLetterPortrait,
    ppLetterLandscape
  );

  /// <summary>
  /// Encapsulates page setup and margin properties independent from
  /// a specific printer or printing engine.
  /// </summary>
  /// <remarks>
  /// This class is typically used together with printing components
  /// (e.g. TSynEditPrint) to store, apply and transfer page setup
  /// configuration in a reusable and assignable form.
  /// </remarks>
  TPlPageSetupProperties = class(TPersistent)
  private
    FMarginBottom: Double;
    FMarginLeft: Double;
    FMarginRight: Double;
    FMarginTop: Double;
    FOrientation: TPrinterOrientation;
    FPageHeight: Double;
    FPageUnit: TPageMeasureUnits;
    FPageWidth: Double;
    FPreset: TPlPagePreset;

    function InchesToMM(const AValue: Double): Double;
    function MMToInches(const AValue: Double): Double;
  public
    /// <summary>
    /// Creates the page setup properties and optionally initializes
    /// them from a printing component.
    /// </summary>
    /// <param name="AOwner">
    /// Optional owner. If it is a TSynEditPrint instance, initial values
    /// are read from it.
    /// </param>
    constructor Create(AOwner: TComponent); overload;

    /// <summary>
    /// Applies the stored page setup properties to a printing object.
    /// </summary>
    /// <remarks>
    /// Currently supports TSynEditPrint instances.
    /// </remarks>
    procedure ApplyTo(APrinter: TObject);

    /// <summary>
    /// Assigns values from another TPlPageSetupProperties instance.
    /// </summary>
    procedure Assign(Source: TPersistent); override;

    /// <summary>
    /// Returns the page width expressed in millimeters.
    /// </summary>
    function GetPageWidthMM: Double;

    /// <summary>
    /// Returns the page height expressed in millimeters.
    /// </summary>
    function GetPageHeightMM: Double;

    /// <summary>
    /// Returns margins expressed in millimeters.
    /// </summary>
    function GetMarginsMM: TRect;
  published
    /// <summary>Left page margin.</summary>
    property MarginLeft: Double read FMarginLeft write FMarginLeft;

    /// <summary>Right page margin.</summary>
    property MarginRight: Double read FMarginRight write FMarginRight;

    /// <summary>Top page margin.</summary>
    property MarginTop: Double read FMarginTop write FMarginTop;

    /// <summary>Bottom page margin.</summary>
    property MarginBottom: Double read FMarginBottom write FMarginBottom;

    /// <summary>Page width in the unit specified by PageUnit.</summary>
    property PageWidth: Double read FPageWidth write FPageWidth;

    /// <summary>Page height in the unit specified by PageUnit.</summary>
    property PageHeight: Double read FPageHeight write FPageHeight;

    /// <summary>Measurement unit used for page size values.</summary>
    property PageUnit: TPageMeasureUnits read FPageUnit write FPageUnit
      default pmMillimeters;

    /// <summary>Predefined page preset.</summary>
    property Preset: TPlPagePreset read FPreset write FPreset
      default ppCustom;

    /// <summary>Printer page orientation.</summary>
    property Orientation: TPrinterOrientation read FOrientation
      write FOrientation default poPortrait;
  end;

implementation

uses
  SynEditPrint;

{ TPlPageSetupProperties }

constructor TPlPageSetupProperties.Create(AOwner: TComponent);
begin
  inherited Create;

  { Initialize from a SynEdit printing engine if provided }
  if AOwner is TSynEditPrint then
    with TSynEditPrint(AOwner) do
    begin
      FMarginLeft := Margins.Left;
      FMarginRight := Margins.Right;
      FMarginTop := Margins.Top;
      FMarginBottom := Margins.Bottom;

      FPageWidth := PrinterInfo.PhysicalWidth;
      FPageHeight := PrinterInfo.PhysicalHeight;

      FPageUnit := pmMillimeters;
      FOrientation := Printer.Orientation;
      FPreset := ppCustom;
    end;
end;

procedure TPlPageSetupProperties.ApplyTo(APrinter: TObject);
begin
  Printer.Orientation := FOrientation;

  if APrinter is TSynEditPrint then
    with TSynEditPrint(APrinter) do
    begin
      Margins.Left := FMarginLeft;
      Margins.Right := FMarginRight;
      Margins.Top := FMarginTop;
      Margins.Bottom := FMarginBottom;

      Printer.Orientation := FOrientation;
    end;
end;

procedure TPlPageSetupProperties.Assign(Source: TPersistent);
var
  sourceProps: TPlPageSetupProperties;
begin
  if Source is TPlPageSetupProperties then
  begin
    sourceProps := TPlPageSetupProperties(Source);

    FMarginLeft := sourceProps.MarginLeft;
    FMarginRight := sourceProps.MarginRight;
    FMarginTop := sourceProps.MarginTop;
    FMarginBottom := sourceProps.MarginBottom;

    FPageWidth := sourceProps.PageWidth;
    FPageHeight := sourceProps.PageHeight;
    FPageUnit := sourceProps.PageUnit;
    FOrientation := sourceProps.Orientation;
    FPreset := sourceProps.Preset;
  end
  else
    inherited Assign(Source);
end;

function TPlPageSetupProperties.MMToInches(const AValue: Double): Double;
begin
  Result := AValue / 25.4;
end;

function TPlPageSetupProperties.InchesToMM(const AValue: Double): Double;
begin
  Result := AValue * 25.4;
end;

function TPlPageSetupProperties.GetPageWidthMM: Double;
begin
  if FPageUnit = pmInches then
    Result := InchesToMM(FPageWidth)
  else
    Result := FPageWidth;
end;

function TPlPageSetupProperties.GetPageHeightMM: Double;
begin
  if FPageUnit = pmInches then
    Result := InchesToMM(FPageHeight)
  else
    Result := FPageHeight;
end;

function TPlPageSetupProperties.GetMarginsMM: TRect;
begin
  Result := Rect(
    Round(FMarginLeft),
    Round(FMarginTop),
    Round(FMarginRight),
    Round(FMarginBottom)
  );
end;

end.


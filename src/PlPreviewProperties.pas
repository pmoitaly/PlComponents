unit PlPreviewProperties;

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
  Vcl.Graphics,
  SynEditPrintPreview;

type
  /// <summary>
  /// Encapsulates visual and behavioral settings for a print preview component.
  /// </summary>
  /// <remarks>
  /// This class is typically used to configure a TSynEditPrintPreview instance
  /// in a reusable and design-time friendly way.
  /// </remarks>
  TPlPreviewProperties = class(TPersistent)
  private
    FBackgroundColor: TColor;
    FPageShadow: Boolean;
    FScalePercent: Integer;
    FShowLineNumber: Boolean;
    FShowScrollHint: Boolean;

    procedure SetBackgroundColor(const Value: TColor);
    procedure SetPageShadow(const Value: Boolean);
    procedure SetScalePercent(const Value: Integer);
    procedure SetShowLineNumber(const Value: Boolean);
    procedure SetShowScrollHint(const Value: Boolean);
  public
    /// <summary>
    /// Creates the preview properties object with default values.
    /// </summary>
    constructor Create(AOwner: TComponent);

    /// <summary>
    /// Applies the stored properties to a print preview component.
    /// </summary>
    procedure ApplyTo(APreview: TSynEditPrintPreview);

    /// <summary>
    /// Assigns values from another TPlPreviewProperties instance.
    /// </summary>
    procedure Assign(Source: TPersistent); override;
  published
    /// <summary>Background color of the preview area.</summary>
    property BackgroundColor: TColor read FBackgroundColor
      write SetBackgroundColor default clWhite;

    /// <summary>Enables or disables the page shadow effect.</summary>
    property PageShadow: Boolean read FPageShadow
      write SetPageShadow default True;

    /// <summary>Zoom factor expressed as a percentage.</summary>
    property ScalePercent: Integer read FScalePercent
      write SetScalePercent default 100;

    /// <summary>Shows or hides line numbers in the preview.</summary>
    property ShowLineNumber: Boolean read FShowLineNumber
      write SetShowLineNumber default True;

    /// <summary>Shows or hides the scroll hint overlay.</summary>
    property ShowScrollHint: Boolean read FShowScrollHint
      write SetShowScrollHint default True;
  end;

implementation

{ TPlPreviewProperties }

constructor TPlPreviewProperties.Create(AOwner: TComponent);
begin
  inherited Create;

  FScalePercent := 100;
  FShowScrollHint := True;
  FBackgroundColor := clWhite;
  FPageShadow := True;
  FShowLineNumber := True;
end;

procedure TPlPreviewProperties.ApplyTo(APreview: TSynEditPrintPreview);
begin
  if not Assigned(APreview) then
    Exit;

  APreview.ScalePercent := FScalePercent;
  APreview.ShowScrollHint := FShowScrollHint;
  APreview.PageBGColor := FBackgroundColor;

  { Line numbers are managed by the underlying SynEditPrint instance }
  if Assigned(APreview.SynEditPrint) then
    APreview.SynEditPrint.LineNumbers := FShowLineNumber;
end;

procedure TPlPreviewProperties.Assign(Source: TPersistent);
var
  sourceProps: TPlPreviewProperties;
begin
  if Source is TPlPreviewProperties then
  begin
    sourceProps := TPlPreviewProperties(Source);

    FScalePercent := sourceProps.ScalePercent;
    FShowScrollHint := sourceProps.ShowScrollHint;
    FBackgroundColor := sourceProps.BackgroundColor;
    FPageShadow := sourceProps.PageShadow;
    FShowLineNumber := sourceProps.ShowLineNumber;
  end
  else
    inherited Assign(Source);
end;

procedure TPlPreviewProperties.SetBackgroundColor(const Value: TColor);
begin
  FBackgroundColor := Value;
end;

procedure TPlPreviewProperties.SetPageShadow(const Value: Boolean);
begin
  FPageShadow := Value;
end;

procedure TPlPreviewProperties.SetScalePercent(const Value: Integer);
begin
  FScalePercent := Value;
end;

procedure TPlPreviewProperties.SetShowLineNumber(const Value: Boolean);
begin
  FShowLineNumber := Value;
end;

procedure TPlPreviewProperties.SetShowScrollHint(const Value: Boolean);
begin
  FShowScrollHint := Value;
end;

end.


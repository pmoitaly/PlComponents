unit PlStyleMenuManager;

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
 /// Unit: PlStyleMenuManager
 /// This unit defines:
 /// - TPlStylesMenuManager: builds menu with available styles.
 *******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.IOUtils, System.Types, System.Threading,
  Vcl.Menus, Vcl.Graphics, Vcl.Themes, Vcl.Forms,
  UITypes, Winapi.Windows, Winapi.Messages;

type
  TPlStylesMenuManager = class(TComponent)
  private
    FActive: Boolean;
    FChangingStyle: Boolean;
    FCurrentStyle: string;
    FCustomStylesDir: string;
    FCustomStylesExt: string;
    FMenuItem: TMenuItem;
    FMenuTag: Integer;
    FMsgHandle: HWND;
    FOldOwnerDraw: Boolean;
    FOnStyleChanged: TNotifyEvent;
    FParentMenu: TMenu;
    FPendingStyleName: string;
    FStyleCache: TDictionary<string, TCustomStyleServices>;
    FStylePreview: Boolean;
    procedure ApplyNewStyle(Sender: TObject);
    procedure AttachHandlers;
    procedure DetachHandlers;
    procedure LoadCustomStyles;
    procedure MenuItemDraw(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      Selected: Boolean);
    procedure MenuItemMeasure(Sender: TObject; ACanvas: TCanvas;
      var Width, Height: Integer);
    procedure MsgWndProc(var Msg: TMessage);
    procedure RebuildMenu;
    procedure RestoreOwnerDrawAfterStyleChange;
    procedure SetActive(const Value: Boolean);
    procedure SetCurrentStyle(const Value: string);
    procedure SetCustomStylesDir(const Value: string);
    procedure SetCustomStylesExt(const Value: string);
    procedure SetMenuItem(const Value: TMenuItem);
    procedure SetStylePreview(const Value: Boolean);
    procedure SyncronizeOwnerDraw;
    procedure TemporarilyDisableOwnerDrawForStyleChange;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function IsColorDark(Color: TColor): Boolean;
    function IsDarkButton: Boolean;
    function IsDarkElement(StyleColor: TStyleColor): Boolean;
    function IsDarkStyleActive: Boolean;
  published
    property Active: Boolean read FActive write SetActive;
    property CurrentStyle: string read FCurrentStyle write SetCurrentStyle;
    property CustomStylesDir: string read FCustomStylesDir
      write SetCustomStylesDir;
    property CustomStylesExt: string read FCustomStylesExt
      write SetCustomStylesExt;
    property MenuItem: TMenuItem read FMenuItem write SetMenuItem;
    property MenuTag: Integer read FMenuTag write FMenuTag;
    property StylePreview: Boolean read FStylePreview write SetStylePreview;
    property OnStyleChanged: TNotifyEvent read FOnStyleChanged
      write FOnStyleChanged;
  end;

implementation

uses
  System.Math;

const
  WM_PL_APPLYSTYLE = WM_APP + $100;

procedure CloseActiveMenus;
var
  frm: TCustomForm;
begin
  frm := Screen.ActiveForm;
  if Assigned(frm) and frm.HandleAllocated then
    SendMessage(frm.Handle, WM_CANCELMODE, 0, 0)
  else if Assigned(Application.MainForm) and Application.MainForm.HandleAllocated
  then
    SendMessage(Application.MainForm.Handle, WM_CANCELMODE, 0, 0);
end;

{$REGION 'TPlStylesMenuManager'}

constructor TPlStylesMenuManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCustomStylesExt := '*.vsf';
  FCustomStylesDir := '';
  FMenuTag := 0;
  FActive := False;
  FCurrentStyle := '';
  FStylePreview := False;
  FOldOwnerDraw := False;
  FParentMenu := nil;
  FChangingStyle := False;
  FPendingStyleName := '';

  // avoid creaton of menuitems in design mode
  if csDesigning in ComponentState then
    Exit;

  FStyleCache := TDictionary<string, TCustomStyleServices>.Create;

  // Create a private window to receive posted messages reliably
  FMsgHandle := AllocateHWnd(MsgWndProc);
end;

destructor TPlStylesMenuManager.Destroy;
begin
  if not(csDesigning in ComponentState) then
    begin
      if FChangingStyle then
        RestoreOwnerDrawAfterStyleChange;

      // free our message window
      if FMsgHandle <> 0 then
        begin
          DeallocateHWnd(FMsgHandle);
          FMsgHandle := 0;
        end;

      FStylePreview := False;
      SyncronizeOwnerDraw;

      if Assigned(FMenuItem) then
        begin
          FMenuItem.Clear;
          FMenuItem := nil;
        end;

      FStyleCache.Free;
    end;

  inherited Destroy;
end;

procedure TPlStylesMenuManager.ApplyNewStyle(Sender: TObject);
var
  clickedItem: TMenuItem;
  newStyleName: string;
begin
  if not Assigned(Sender) or not(Sender is TMenuItem) then
    Exit;

  clickedItem := TMenuItem(Sender);
  newStyleName := StripHotKey(clickedItem.Caption);

  // Defer actual style application: post to our message window
  FPendingStyleName := newStyleName;
  CloseActiveMenus;

  if FMsgHandle <> 0 then
    PostMessage(FMsgHandle, WM_PL_APPLYSTYLE, 0, 0);
end;

procedure TPlStylesMenuManager.AttachHandlers;
var
  i: Integer;
begin
  if not Assigned(FMenuItem) then
    Exit;
  for i := 0 to FMenuItem.Count - 1 do
    begin
      FMenuItem[i].OnDrawItem := MenuItemDraw;
      FMenuItem[i].OnMeasureItem := MenuItemMeasure;
    end;
end;

procedure TPlStylesMenuManager.DetachHandlers;
var
  i: Integer;
begin
  if not Assigned(FMenuItem) then
    Exit;
  for i := 0 to FMenuItem.Count - 1 do
    begin
      FMenuItem[i].OnDrawItem := nil;
      FMenuItem[i].OnMeasureItem := nil;
    end;
end;

function TPlStylesMenuManager.IsColorDark(Color: TColor): Boolean;
var
  b: Byte;
  c: LongWord;
  g: Byte;
  r: Byte;
begin
  c := ColorToRGB(Color);
  r := GetRValue(c);
  g := GetGValue(c);
  b := GetBValue(c);
  Result := (r * 299 + g * 587 + b * 114) div 1000 < 128;
end;

function TPlStylesMenuManager.IsDarkButton: Boolean;
var
  colorOut: TColor;
  details: TThemedElementDetails;
begin
  details := StyleServices.GetElementDetails(tbPushButtonNormal);
  if StyleServices.GetElementColor(details, ecFillColor, colorOut) then
    Result := IsColorDark(colorOut)
  else
    Result := False;
end;

function TPlStylesMenuManager.IsDarkElement(StyleColor: TStyleColor): Boolean;
var
  col: TColor;
begin
  col := StyleServices.GetStyleColor(StyleColor);
  Result := IsColorDark(col)
end;

function TPlStylesMenuManager.IsDarkStyleActive: Boolean;
var
  col: TColor;
begin
  try
    if StyleServices.IsSystemStyle then
      col := StyleServices.GetSystemColor(clWindow)
    else
      col := StyleServices.GetStyleColor(scWindow);
  except
    col := clWindow;
  end;
  Result := IsColorDark(col);
end;

procedure TPlStylesMenuManager.LoadCustomStyles;
var
  fileName: string;
  files: TArray<string>;
  i: Integer;
begin
  if (FCustomStylesDir = '') or not DirectoryExists(FCustomStylesDir) then
    Exit;
  try
    files := TDirectory.GetFiles(FCustomStylesDir, FCustomStylesExt);
  except
    Exit;
  end;

  for i := 0 to System.Length(files) - 1 do
    begin
      fileName := files[i];
      if TStyleManager.IsValidStyle(fileName) then
        try
          TStyleManager.LoadFromFile(fileName);
        except
        end;
    end;
end;

procedure TPlStylesMenuManager.MenuItemDraw(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);
var
  ArrowRect, CheckRect, TextRect, ShortcutRect: TRect;
  cxArrow, cxCheck: Integer;
  details, ItemDetails: TThemedElementDetails;
  MenuItem: TMenuItem;
  ShortcutText, CaptionText: string;
  Style: TCustomStyleServices;
  bgColor: TColor;
begin
  if FChangingStyle then
    Exit;
  if csDestroying in ComponentState then
    Exit;
  if not Assigned(Sender) or not(Sender is TMenuItem) then
    Exit;

  MenuItem := Sender as TMenuItem;
  CaptionText := StripHotKey(MenuItem.Caption);

  // Recupera lo stile dalla cache o da StyleManager
  if FStyleCache.ContainsKey(CaptionText) then
    Style := FStyleCache[CaptionText]
  else
    Style := StyleServices;

  // Stato dell’item
  if not MenuItem.Enabled then
    ItemDetails := Style.GetElementDetails(tmPopupItemDisabled)
  else if Selected then
    ItemDetails := Style.GetElementDetails(tmPopupItemHot)
  else
    ItemDetails := Style.GetElementDetails(tmPopupItemNormal);

  // Sfondo: prova con colore dell’item, poi del menù, altrimenti fallback
  if Style.GetElementColor(ItemDetails, ecFillColor, bgColor) or
    Style.GetElementColor(Style.GetElementDetails(tmPopupBackground),
    ecFillColor, bgColor) then
    begin
      ACanvas.Brush.Color := bgColor;
      ACanvas.Font.Assign(Screen.MenuFont); // font del menù
    end
  else
    begin
      ACanvas.Brush.Color := GetSysColor(COLOR_WINDOW); // fallback Window
      ACanvas.Font.Assign(Screen.IconFont);             // font della Window
    end;
  ACanvas.FillRect(ARect);

  cxCheck := GetSystemMetrics(SM_CXMENUCHECK);
  cxArrow := GetSystemMetrics(SM_CXMENUSIZE);

  CheckRect := ARect;
  CheckRect.Right := CheckRect.Left + cxCheck;

  TextRect := ARect;
  TextRect.Left := CheckRect.Right + 4;
  TextRect.Right := ARect.Right - cxArrow - 8;

  // Shortcut
  if MenuItem.ShortCut <> 0 then
    begin
      ShortcutText := ShortCutToText(MenuItem.ShortCut);
      TextRect.Right := TextRect.Right - ACanvas.TextWidth(ShortcutText) - 8;

      ShortcutRect := ARect;
      ShortcutRect.Left := TextRect.Right + 4;
      ShortcutRect.Right := ARect.Right - cxArrow - 4;

      try
        Style.DrawText(ACanvas.Handle, ItemDetails, ShortcutText, ShortcutRect,
          [tfSingleLine, tfVerticalCenter, tfRight]);
      except
      end;
    end;

  // Caption
  try
    Style.DrawText(ACanvas.Handle, ItemDetails, CaptionText, TextRect,
      [tfSingleLine, tfVerticalCenter, tfLeft]);
  except
  end;

  // Disegno check/radio
  if MenuItem.Checked then
    begin
      if MenuItem.RadioItem then
        begin
          if MenuItem.Enabled then
            details := Style.GetElementDetails(tmPopupBulletNormal)
          else
            details := Style.GetElementDetails(tmPopupBulletDisabled);

          try
            if not Style.DrawElement(ACanvas.Handle, details, CheckRect) then
              DrawFrameControl(ACanvas.Handle, CheckRect, DFC_MENU,
                DFCS_MENUBULLET or (IfThen(MenuItem.Enabled, 0,
                DFCS_INACTIVE)));
          except
            DrawFrameControl(ACanvas.Handle, CheckRect, DFC_MENU,
              DFCS_MENUBULLET or (IfThen(MenuItem.Enabled, 0, DFCS_INACTIVE)));
          end;
        end
      else
        begin
          if MenuItem.Enabled then
            details := Style.GetElementDetails(tmPopupCheckNormal)
          else
            details := Style.GetElementDetails(tmPopupCheckDisabled);

          try
            if not Style.DrawElement(ACanvas.Handle, details, CheckRect) then
              DrawFrameControl(ACanvas.Handle, CheckRect, DFC_MENU,
                DFCS_MENUCHECK or (IfThen(MenuItem.Enabled, 0, DFCS_INACTIVE)));
          except
            DrawFrameControl(ACanvas.Handle, CheckRect, DFC_MENU,
              DFCS_MENUCHECK or (IfThen(MenuItem.Enabled, 0, DFCS_INACTIVE)));
          end;
        end;
    end;

  // Freccia submenu
  if MenuItem.Count > 0 then
    begin
      ArrowRect := ARect;
      ArrowRect.Left := ARect.Right - cxArrow - 4;
      ArrowRect.Right := ARect.Right - 4;

      if MenuItem.Enabled then
        details := Style.GetElementDetails(tmPopupSubMenuNormal)
      else
        details := Style.GetElementDetails(tmPopupSubMenuDisabled);

      try
        if not Style.DrawElement(ACanvas.Handle, details, ArrowRect) then
          DrawFrameControl(ACanvas.Handle, ArrowRect, DFC_MENU,
            DFCS_MENUARROW or (IfThen(MenuItem.Enabled, 0, DFCS_INACTIVE)));
      except
        DrawFrameControl(ACanvas.Handle, ArrowRect, DFC_MENU, DFCS_MENUARROW or
          (IfThen(MenuItem.Enabled, 0, DFCS_INACTIVE)));
      end;
    end;
end;

procedure TPlStylesMenuManager.MenuItemMeasure(Sender: TObject;
  ACanvas: TCanvas; var Width, Height: Integer);
var
  MenuItem: TMenuItem;
  ShortcutText: string;
begin
  if FChangingStyle then
    Exit;
  if not Assigned(Sender) or not(Sender is TMenuItem) then
    Exit;

  MenuItem := Sender as TMenuItem;

  Width := ACanvas.TextWidth(StripHotKey(MenuItem.Caption)) + 16;

  if MenuItem.ShortCut <> 0 then
    begin
      ShortcutText := ShortCutToText(MenuItem.ShortCut);
      Inc(Width, ACanvas.TextWidth(ShortcutText) + 16);
    end;

  Inc(Width, GetSystemMetrics(SM_CXMENUCHECK));

  if MenuItem.Count > 0 then
    Inc(Width, GetSystemMetrics(SM_CXMENUSIZE));

  Height := Max(ACanvas.TextHeight(MenuItem.Caption),
    GetSystemMetrics(SM_CYMENUCHECK)) + 4;
end;

procedure TPlStylesMenuManager.MsgWndProc(var Msg: TMessage);
var
  fg: HWND;
  cls: array [0 .. 127] of Char;
  clsLen: Integer;
begin
  if Msg.Msg = WM_PL_APPLYSTYLE then
    begin
      if FPendingStyleName = '' then
        Exit;

      // If a popup menu is still foreground (class '#32768'), retry later
      fg := GetForegroundWindow;
      if fg <> 0 then
        begin
          clsLen := GetClassName(fg, cls, Length(cls));
          if (clsLen > 0) and (StrComp(cls, '#32768') = 0) then
            begin
              // repost to self to try later
              if FMsgHandle <> 0 then
                PostMessage(FMsgHandle, WM_PL_APPLYSTYLE, 0, 0);
              Exit;
            end;
        end;

      // Safe to apply now
      try
        SetCurrentStyle(FPendingStyleName);
      finally
        FPendingStyleName := '';
      end;
    end
  else
    Msg.Result := DefWindowProc(FMsgHandle, Msg.Msg, Msg.WParam, Msg.LParam);
end;

procedure TPlStylesMenuManager.RebuildMenu;
var
  activeName: string;
  newItem: TMenuItem;
  styleName: string;
  styleSvc: TCustomStyleServices;
  ownerForItems: TComponent;
begin

  if (csDesigning in ComponentState) then
    Exit;

  if not Assigned(FMenuItem) then
    Exit;

  DetachHandlers;
  FMenuItem.Clear;

  if not FActive then
    Exit;

  if (FCustomStylesDir <> '') and DirectoryExists(FCustomStylesDir) then
    LoadCustomStyles;

  if Assigned(TStyleManager.ActiveStyle) then
    activeName := TStyleManager.ActiveStyle.Name
  else
    activeName := '';

  ownerForItems := FMenuItem.Owner;
  if not Assigned(ownerForItems) then
    ownerForItems := Self;

  for styleName in TStyleManager.StyleNames do
    begin
      // forza il caricamento dello stile
      styleSvc := TStyleManager.Style[styleName];
      if styleSvc <> nil then
        FStyleCache.AddOrSetValue(styleName, styleSvc);

      newItem := TMenuItem.Create(ownerForItems);
      newItem.Caption := styleName;
      newItem.AutoCheck := True;
      newItem.RadioItem := True;
      newItem.AutoHotkeys := maManual;
      newItem.Checked := SameText(styleName, activeName);
      newItem.GroupIndex := FMenuItem.GroupIndex;
      newItem.Tag := FMenuTag;
      newItem.OnClick := ApplyNewStyle;
      newItem.Visible := True;
      if FStylePreview then
        begin
          newItem.OnDrawItem := MenuItemDraw;
          newItem.OnMeasureItem := MenuItemMeasure;
        end;
      FMenuItem.Add(newItem);
    end;

  SyncronizeOwnerDraw;
end;

procedure TPlStylesMenuManager.RestoreOwnerDrawAfterStyleChange;
begin
  if not Assigned(FParentMenu) then
    begin
      FChangingStyle := False;
      Exit;
    end;

  try
    FParentMenu.OwnerDraw := FOldOwnerDraw;
  except
  end;

  if FStylePreview then
    AttachHandlers
  else
    DetachHandlers;

  FChangingStyle := False;
  FParentMenu := nil;
end;

procedure TPlStylesMenuManager.SetActive(const Value: Boolean);
begin
  if FActive = Value then
    Exit;
  FActive := Value;
  if (csLoading in ComponentState) or (csReading in ComponentState) or
    (csDesigning in ComponentState) then
    Exit;
  RebuildMenu;
end;

procedure TPlStylesMenuManager.SetCurrentStyle(const Value: string);
begin
  if TThread.CurrentThread.ThreadID <> MainThreadID then
    begin
      TThread.Queue(nil,
        procedure
        begin
          SetCurrentStyle(Value);
        end);
      Exit;
    end;

  if SameText(FCurrentStyle, Value) then
    Exit;

  CloseActiveMenus;

  TemporarilyDisableOwnerDrawForStyleChange;
  try
    if not TStyleManager.TrySetStyle(Value, False) then
      begin
        RestoreOwnerDrawAfterStyleChange;
        Exit;
      end;

    FCurrentStyle := Value;

    TThread.Queue(nil,
      procedure
      begin
        if Application.Terminated or (csDestroying in ComponentState) then
          begin
            RestoreOwnerDrawAfterStyleChange;
            Exit;
          end;

        if FActive and Assigned(FMenuItem) and not(csDesigning in ComponentState)
        then
          RebuildMenu;;

        RestoreOwnerDrawAfterStyleChange;

        if Assigned(FOnStyleChanged) then
          FOnStyleChanged(Self);
      end);
  except
    RestoreOwnerDrawAfterStyleChange;
    raise;
  end;
end;

procedure TPlStylesMenuManager.SetCustomStylesDir(const Value: string);
begin
  if FCustomStylesDir = Value then
    Exit;

  if (Value = '') or DirectoryExists(Value) then
    begin
      FCustomStylesDir := Value;
      if not(csDesigning in ComponentState) then
        RebuildMenu;
    end;
end;

procedure TPlStylesMenuManager.SetCustomStylesExt(const Value: string);
begin
  if FCustomStylesExt = Value then
    Exit;
  FCustomStylesExt := Value;
  if not(csDesigning in ComponentState) then
    RebuildMenu;
end;

procedure TPlStylesMenuManager.SetMenuItem(const Value: TMenuItem);
begin
  if FMenuItem = Value then
    Exit;
  if Assigned(FParentMenu) then
    RestoreOwnerDrawAfterStyleChange;
  FMenuItem := Value;
  SyncronizeOwnerDraw;
  if not(csDesigning in ComponentState) then
    RebuildMenu;
end;

procedure TPlStylesMenuManager.SetStylePreview(const Value: Boolean);
begin
  if FStylePreview = Value then
    Exit;
  FStylePreview := Value;
  SyncronizeOwnerDraw;
end;

procedure TPlStylesMenuManager.SyncronizeOwnerDraw;
var
  parentMenu: TMenu;
begin
  if Assigned(FParentMenu) then
    begin
      if (not Assigned(FMenuItem)) or (FParentMenu <> FMenuItem.GetParentMenu)
      then
        begin
          DetachHandlers;
          try
            if Assigned(FParentMenu) then
              FParentMenu.OwnerDraw := FOldOwnerDraw;
          finally
            FParentMenu := nil;
          end;
        end;
    end;

  if not Assigned(FMenuItem) then
    Exit;
  parentMenu := FMenuItem.GetParentMenu;
  if not Assigned(parentMenu) then
    Exit;

  if FStylePreview then
    begin
      if not Assigned(FParentMenu) then
        begin
          FParentMenu := parentMenu;
          FOldOwnerDraw := FParentMenu.OwnerDraw;
        end;
      try
        parentMenu.OwnerDraw := True;
      except
      end;
      AttachHandlers;
    end
  else
    begin
      if Assigned(FParentMenu) then
        begin
          DetachHandlers;
          try
            FParentMenu.OwnerDraw := FOldOwnerDraw;
          finally
            FParentMenu := nil;
          end;
        end
      else
        begin
          DetachHandlers;
          try
            parentMenu.OwnerDraw := FOldOwnerDraw;
          except
          end;
        end;
    end;
end;

procedure TPlStylesMenuManager.TemporarilyDisableOwnerDrawForStyleChange;
var
  parentMenu: TMenu;
begin
  if not Assigned(FMenuItem) then
    Exit;
  parentMenu := FMenuItem.GetParentMenu;
  if not Assigned(parentMenu) then
    Exit;

  if Assigned(FParentMenu) then
    Exit;

  FChangingStyle := True;
  FParentMenu := parentMenu;
  FOldOwnerDraw := FParentMenu.OwnerDraw;

  DetachHandlers;
  try
    FParentMenu.OwnerDraw := False;
  except
  end;

  try
    Application.ProcessMessages;
  except
  end;
end;
{$ENDREGION}

end.

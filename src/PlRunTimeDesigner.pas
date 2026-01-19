unit PlRunTimeDesigner;

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
 /// Unit: PlLockWndManager
 /// This unit defines:
 /// - TPlResizeDirection: dirctions of component resize/move.
 /// - TPlBeforeResizeEvent, TPlOnResizeEvent: Firms of events.
 /// - TPlRunTimeDesigner: a component for GUI runtime design.
 *******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Types, System.IniFiles,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Graphics;

type

  TPlResizeDirection = (rdNone, rdTop, rdTopRight, rdRight, rdBottomRight,
    rdBottom, rdBottomLeft, rdLeft, rdTopLeft, rdMove);

  /// <summary>Event raised before resizing a control; set Abort to True to cancel.</summary>
  TPlBeforeResizeEvent = procedure(Sender: TObject; var Abort: Boolean)
    of object;

  /// <summary>Event raised while resizing; provides X,Y mouse coordinates.</summary>
  TPlOnResizeEvent = procedure(Sender: TObject; X, Y: Integer) of object;

  /// <summary>Compatibility type: control used by the runtime designer.</summary>
  TPlControl = class(TControl);

  /// <summary>
  ///   Component that enables basic runtime form editing: selecting, moving and
  ///   resizing child controls and saving/loading their bounds to an INI file.
  /// </summary>
  TPlRunTimeDesigner = class(TComponent)
  private
    FAction: TPlResizeDirection;
    FActive: Boolean;
    FActiveControl: TControl;
    FAfterLoad: TNotifyEvent;
    FAfterSave: TNotifyEvent;
    FBeforeResize: TPlBeforeResizeEvent;
    FExcludeList: TStrings;
    FIniName: TFileName;
    FManageForm: Boolean;
    FMinHeight: Integer;
    FMinWidth: Integer;
    FOldApplicationOnMessage: TMessageEvent;
    FOldCursor: TCursor;
    FOldHeight: Integer;
    FOldLeft: Integer;
    FOldTop: Integer;
    FOldWidth: Integer;
    FOnResize: TPlOnResizeEvent;
    FOwnerOnly: Boolean;
    FProximity: Integer;

    FDragging: Boolean;      // true while left button drag is active
    FOldBoundsRect: TRect;   // snapshot before drag (for ESC rollback)
    FMouseDownPoint: TPoint; // screen coordinates of LButtonDown
    FResizeDirection: TPlResizeDirection; // explicit direction/operation

    function ActionToCursor(intAction: TPlResizeDirection): TCursor;
    procedure ApplyNewSize(dX: Integer; dY: Integer);
    procedure ButtonDown(var AMsg: tagMSG; TargetControl: TControl);
    procedure ButtonUp;
    function IsHandledMouseMsg(const AMsg: TMsg): Boolean;
    function IsOwner(AControl: TControl): Boolean;
    procedure MouseMove(var AMsg: tagMSG; TargetControl: TControl);
    procedure SetExcludeList(const AValue: TStrings);

    { helpers }
    procedure UpdateCursorWhileHover(TargetControl: TControl;
      const ScreenPt: TPoint);
  protected
    /// <summary>Translates Windows messages into designer actions.</summary>
    procedure ApplicationOnMessage(var AMsg: TMsg; var Handled: Boolean);
    /// <summary>Returns True if given control may have its height changed.</summary>
    function CanSetHeight(AControl: TControl): Boolean;
    /// <summary>Returns True if given control may have its width changed.</summary>
    function CanSetWidth(AControl: TControl): Boolean;
    /// <summary>Converts cursor coordinates into an action mask (resize/move).</summary>
    function CoordinatesToDirection(TargetControl: TControl; X: Integer;
      Y: Integer): TPlResizeDirection;
    /// <summary>Loads persisted settings for a single control from INI.</summary>
    procedure LoadControl(AControl: TControl; AFile: TIniFile);
    /// <summary>Handles resizing while mouse moves.</summary>
    procedure ResizingComponent(var AMsg: tagMSG);
    /// <summary>Saves persisted settings for a single control to INI.</summary>
    procedure SaveControl(AControl: TControl; AFile: TIniFile);
    /// <summary>Handles selection logic when mouse moves without active resizing.</summary>
    procedure SelectingComponent(var AMsg: tagMSG; TargetControl: TControl);
    /// <summary>Activates/deactivates the runtime designer.</summary>
    procedure SetActive(const AValue: Boolean);
  public
    /// <summary>Creates the runtime designer component.</summary>
    constructor Create(AOwner: TComponent); override;
    /// <summary>Destroys the runtime designer and frees resources.</summary>
    destructor Destroy; override;
    /// <summary>Load all persisted control data from the component's INI file.</summary>
    procedure LoadData; overload;
    /// <summary>Load persisted data starting from a specific control.</summary>
    procedure LoadData(AControl: TControl); overload;
    /// <summary>Load persisted data using a provided TIniFile instance.</summary>
    procedure LoadData(AControl: TControl; AFile: TIniFile); overload;
    /// <summary>Save all controls' persisted data to the component's INI file.</summary>
    procedure SaveData; overload;
    /// <summary>Save persisted data starting from a specific control.</summary>
    procedure SaveData(AControl: TControl); overload;
    /// <summary>Save persisted data using a provided TIniFile instance.</summary>
    procedure SaveData(AControl: TControl; AFile: TIniFile); overload;
  published
    /// <summary>Enable or disable the runtime designer.</summary>
    property Active: Boolean read FActive write SetActive;
    /// <summary>
    ///   Comma separated list of control names to exclude from load/save.
    ///   Use Assign to set. Nil-safe.
    /// </summary>
    property ExcludeList: TStrings read FExcludeList write SetExcludeList;
    /// <summary>File name of the INI used to persist control bounds.</summary>
    property IniName: TFileName read FIniName write FIniName;
    /// <summary>If True the designer will also load/save the owning form bounds.</summary>
    property ManageForm: Boolean read FManageForm write FManageForm;
    /// <summary>Minimum height allowed when resizing controls (default 10).</summary>
    property MinHeight: Integer read FMinHeight write FMinHeight default 10;
    /// <summary>Minimum width allowed when resizing controls (default 10).</summary>
    property MinWidth: Integer read FMinWidth write FMinWidth default 10;
    /// <summary>If True designer acts only on controls that have the same Owner as this component.</summary>
    property OwnerOnly: Boolean read FOwnerOnly write FOwnerOnly;
    /// <summary>Distance in pixels from the edge where resize cursor appears.</summary>
    property Proximity: Integer read FProximity write FProximity;
    /// <summary>Event invoked after all data were loaded.</summary>
    property AfterLoad: TNotifyEvent read FAfterLoad write FAfterLoad;
    /// <summary>Event invoked after all data were saved.</summary>
    property AfterSave: TNotifyEvent read FAfterSave write FAfterSave;
    /// <summary>Event invoked before a resize; set Abort True to cancel.</summary>
    property BeforeResize: TPlBeforeResizeEvent read FBeforeResize
      write FBeforeResize;
    /// <summary>Event invoked while resizing; provides mouse coordinates.</summary>
    property OnResize: TPlOnResizeEvent read FOnResize write FOnResize;
  end;

implementation

uses
  System.Math, Json;

const
  EDGE = 8;
  MIN_HEIGHT = 10;
  MIN_WIDTH = 10;

  { TPlRunTimeDesigner }

constructor TPlRunTimeDesigner.Create(AOwner: TComponent);
begin
  inherited;
  FExcludeList := TStringList.Create;
  FMinHeight := MIN_HEIGHT;
  FMinWidth := MIN_WIDTH;
  FOwnerOnly := True;
  FProximity := EDGE; { reasonable default proximity in pixels }
  FDragging := False;
  FResizeDirection := rdNone;
  FActiveControl := nil;
  FOldCursor := crDefault;
end;

destructor TPlRunTimeDesigner.Destroy;
begin
  { Free owned resources safely }
  FreeAndNil(FExcludeList);
  inherited;
end;

function TPlRunTimeDesigner.ActionToCursor
  (intAction: TPlResizeDirection): TCursor;
begin
  { Select the cursor by the resize direction }
  case intAction of
    rdTop, rdBottom:
      Result := crSizeNS;
    rdLeft, rdRight:
      Result := crSizeWE;
    rdTopLeft, rdBottomRight:
      Result := crSizeNWSE;
    rdTopRight, rdBottomLeft:
      Result := crSizeNESW;
    rdMove:
      Result := crSizeAll;
    else
      Result := crDefault;
  end;
end;

procedure TPlRunTimeDesigner.ApplicationOnMessage(var AMsg: TMsg;
  var Handled: Boolean);
var
  TargetControl: TControl;
begin
  Handled := False;

  { If ESC pressed while dragging -> rollback and cancel }
  if (AMsg.Message = WM_KEYDOWN) and (AMsg.wParam = VK_ESCAPE) and FDragging
  then
    begin
      if Assigned(FActiveControl) then
        begin
          FActiveControl.SetBounds(FOldBoundsRect.Left, FOldBoundsRect.Top,
            FOldBoundsRect.Right - FOldBoundsRect.Left, FOldBoundsRect.Bottom -
            FOldBoundsRect.Top);
        end;
      FDragging := False;
      FResizeDirection := rdNone;
      FAction := rdNone;
      FActiveControl := nil;
      { restore default cursor }
      Screen.Cursor := crDefault;
      Handled := True;
      Exit;
    end;

  { Only intercept mouse messages when Active }
  if not IsHandledMouseMsg(AMsg) then
    begin
      if Assigned(FOldApplicationOnMessage) then
        FOldApplicationOnMessage(AMsg, Handled);
      Exit;
    end;

  { Handle LButtonUp unconditionally to ensure drag always ends }
  if AMsg.Message = WM_LBUTTONUP then
    begin
      ButtonUp;
      Handled := True;
      Exit;
    end;

  { For other mouse messages, decide the flow depending on drag state }
  if FDragging then
    begin
      { During an active drag we must continue resizing regardless of the control under cursor }
      case AMsg.Message of
        WM_MOUSEMOVE:
          begin
            { Pass the existing active control to ResizingComponent }
            ResizingComponent(AMsg);
            Handled := True;
            Exit;
          end;
      end;
    end
  else
    begin
      { Not dragging: perform hover / potential start of drag }
      TargetControl := FindDragTarget(AMsg.pt, True);
      if not Assigned(TargetControl) or not IsOwner(TargetControl) then
        begin
          { clear hover state when mouse is over non-owned control/area }
          if FActiveControl <> nil then
            begin
              FActiveControl := nil;
              Screen.Cursor := crDefault;
            end;
          Exit;
        end;

      case AMsg.Message of
        WM_LBUTTONDOWN:
          begin
            ButtonDown(AMsg, TargetControl);
            Handled := True;
            Exit;
          end;
        WM_MOUSEMOVE:
          begin
            MouseMove(AMsg, TargetControl);
            Handled := True;
            Exit;
          end;
      end;
    end;
end;

procedure TPlRunTimeDesigner.ApplyNewSize(dX: Integer; dY: Integer);
begin
  if not Assigned(FActiveControl) then
    Exit;

  { Move }
  if FAction = rdMove then
    begin
      FActiveControl.Top := FOldTop + dY;
      FActiveControl.Left := FOldLeft + dX;
      Exit;
    end;

  { Resize }
  if FResizeDirection in [rdTop, rdTopRight, rdTopLeft] then
    begin
      FActiveControl.Top := FOldTop + dY;
      FActiveControl.Height := Max(FOldHeight - dY, FMinHeight);
    end;

  if FResizeDirection in [rdLeft, rdTopLeft, rdBottomLeft] then
    begin
      FActiveControl.Left := FOldLeft + dX;
      FActiveControl.Width := Max(FOldWidth - dX, FMinWidth);
    end;

  if FResizeDirection in [rdBottom, rdBottomRight, rdBottomLeft] then
    FActiveControl.Height := Max(FOldHeight + dY, FMinHeight);

  if FResizeDirection in [rdRight, rdBottomRight, rdTopRight] then
    FActiveControl.Width := Max(FOldWidth + dX, FMinWidth);
end;

procedure TPlRunTimeDesigner.ButtonDown(var AMsg: tagMSG;
  TargetControl: TControl);
var
  localPoint: TPoint;
  abortResize: Boolean;
begin
  if not Assigned(TargetControl) or (TargetControl is TForm) then
    begin
      FActiveControl := nil;
      Exit;
    end;

  { Set active control to the target (do not toggle off) }
  FActiveControl := TargetControl;

  { Save starting point (screen coords) and compute local coords }
  FMouseDownPoint := AMsg.pt;
  localPoint := TargetControl.ScreenToClient(FMouseDownPoint);

  { Determine intended action (move / which resize direction) - fixed once here }
  FResizeDirection := CoordinatesToDirection(TargetControl, localPoint.X,
    localPoint.Y);
  FAction := FResizeDirection;

  { Fire BeforeResize: allow caller to cancel }
  abortResize := False;
  if Assigned(FBeforeResize) then
    FBeforeResize(TargetControl, abortResize);

  if abortResize then
    begin
      FAction := rdNone;
      FActiveControl := nil;
      Exit;
    end;

  { snapshot original bounds (for commit or cancel) }
  FOldLeft := FActiveControl.Left;
  FOldTop := FActiveControl.Top;
  FOldWidth := FActiveControl.Width;
  FOldHeight := FActiveControl.Height;
  FOldBoundsRect := Rect(FOldLeft, FOldTop, FOldLeft + FOldWidth,
    FOldTop + FOldHeight);

  { start dragging: subsequent mousemoves will resize/move }
  FDragging := True;

  { store old cursor so we can restore it on mouse up or cancel }
  FOldCursor := Screen.Cursor;
end;

procedure TPlRunTimeDesigner.ButtonUp;
begin
  if FDragging then
    begin
      { finalize: keep current bounds (already applied by ApplyNewSize) }
      FDragging := False;
      FAction := rdNone;
      FResizeDirection := rdNone;
      { clear active control so further MouseMove has no effect until new LButtonDown }
      FActiveControl := nil;
    end;

  { restore cursor on mouse up }
  Screen.Cursor := FOldCursor;
end;

function TPlRunTimeDesigner.CanSetHeight(AControl: TControl): Boolean;
begin
  { Allow height change when align is none/top/bottom and not anchored top+bottom }
  Result := Assigned(AControl) and (AControl.Align in [alNone, alTop, alBottom])
    and not((akTop in AControl.Anchors) and (akBottom in AControl.Anchors));
end;

function TPlRunTimeDesigner.CanSetWidth(AControl: TControl): Boolean;
begin
  { Allow width change when align is none/left/right and not anchored left+right }
  Result := Assigned(AControl) and (AControl.Align in [alNone, alLeft, alRight])
    and not((akLeft in AControl.Anchors) and (akRight in AControl.Anchors));
end;

function TPlRunTimeDesigner.CoordinatesToDirection(TargetControl: TControl;
  X: Integer; Y: Integer): TPlResizeDirection;
var
  leftHit, topHit, rightHit, bottomHit: Boolean;
begin
  { Compute resize direction based on proximity to edges; return rdMove if inside }
  leftHit := X <= FProximity;
  topHit := Y <= FProximity;
  bottomHit := Y >= (TargetControl.Height - FProximity);
  rightHit := X >= (TargetControl.Width - FProximity);

  if leftHit and topHit then
    Exit(rdTopLeft);
  if rightHit and topHit then
    Exit(rdTopRight);
  if leftHit and bottomHit then
    Exit(rdBottomLeft);
  if rightHit and bottomHit then
    Exit(rdBottomRight);

  if leftHit then
    Exit(rdLeft);
  if rightHit then
    Exit(rdRight);
  if topHit then
    Exit(rdTop);
  if bottomHit then
    Exit(rdBottom);

  Exit(rdMove);
end;

function TPlRunTimeDesigner.IsHandledMouseMsg(const AMsg: TMsg): Boolean;
begin
  { Returns True if the incoming Windows message is a mouse message
    that should be handled by the runtime designer while active. }
  case AMsg.Message of
    WM_MOUSEMOVE, WM_LBUTTONDOWN, WM_LBUTTONUP:
      Result := FActive;
    else
      Result := False;
  end;
end;

function TPlRunTimeDesigner.IsOwner(AControl: TControl): Boolean;
begin
  Result := Assigned(AControl) and
    ((not FOwnerOnly) or (AControl.Owner = Owner));
end;

procedure TPlRunTimeDesigner.LoadControl(AControl: TControl; AFile: TIniFile);
var
  controlHeight, controlLeft, controlTop, controlWidth: Integer;
  keyName: string;
  sectionName: string;
begin
  if not Assigned(AControl) or not Assigned(AFile) then
    Exit;

  sectionName := '';
  if Assigned(Owner) then
    sectionName := Owner.Name;

  controlLeft := AControl.Left;
  controlTop := AControl.Top;
  controlHeight := AControl.Height;
  controlWidth := AControl.Width;

  if (AControl.Name <> '') and (AControl.Align <> alClient) and
    (FExcludeList.IndexOf(AControl.Name) = -1) then
    begin
      keyName := AControl.Name + '.';
      if AControl.Align = alNone then
        begin
          controlLeft := AFile.ReadInteger(sectionName, keyName + 'left',
            AControl.Left);
          controlTop := AFile.ReadInteger(sectionName, keyName + 'top',
            AControl.Top);
        end;

      if not TPlControl(AControl).Autosize then
        begin
          if CanSetHeight(AControl) then
            controlHeight := AFile.ReadInteger(sectionName, keyName + 'height',
              AControl.Height);
          if CanSetWidth(AControl) then
            controlWidth := AFile.ReadInteger(sectionName, keyName + 'width',
              AControl.Width);
        end;

      AControl.SetBounds(controlLeft, controlTop, controlWidth, controlHeight);
    end;
end;

procedure TPlRunTimeDesigner.LoadData;
begin
  LoadData(TControl(Owner));
  if Assigned(FAfterLoad) then
    FAfterLoad(Self);
end;

procedure TPlRunTimeDesigner.LoadData(AControl: TControl);
var
  theIniFile: TIniFile;
begin
  if FIniName = '' then
    Exit;

  theIniFile := TIniFile.Create(FIniName);
  try
    LoadData(AControl, theIniFile);
  finally
    theIniFile.Free;
  end;
end;

procedure TPlRunTimeDesigner.LoadData(AControl: TControl; AFile: TIniFile);
var
  i, n: Integer;
begin
  if not Assigned(AFile) or not Assigned(AControl) then
    Exit;

  if FManageForm or (AControl <> Owner) then
    LoadControl(AControl, AFile);

  if AControl is TWinControl then
    begin
      n := TWinControl(AControl).ControlCount - 1;
      for i := 0 to n do
        LoadData(TWinControl(AControl).Controls[i], AFile);
    end;
end;

procedure TPlRunTimeDesigner.MouseMove(var AMsg: tagMSG;
  TargetControl: TControl);
begin
  if FDragging and Assigned(FActiveControl) then
    ResizingComponent(AMsg)
  else
    SelectingComponent(AMsg, TargetControl);
end;

procedure TPlRunTimeDesigner.ResizingComponent(var AMsg: TMsg);
var
  dX, dY: Integer;
begin
  dX := AMsg.pt.X - FMouseDownPoint.X;
  dY := AMsg.pt.Y - FMouseDownPoint.Y;

  ApplyNewSize(dX, dY);

  { Removed Application.ProcessMessages to avoid reentrancy issues }
  if Assigned(FOnResize) and Assigned(FActiveControl) then
    FOnResize(FActiveControl, AMsg.pt.X, AMsg.pt.Y);
end;

procedure TPlRunTimeDesigner.SaveControl(AControl: TControl; AFile: TIniFile);
var
  keyName: string;
  sectionName: string;
begin
  if not Assigned(AControl) or not Assigned(AFile) then
    Exit;

  sectionName := '';
  if Assigned(Owner) then
    sectionName := Owner.Name;

  if (AControl.Name <> '') and (AControl.Align <> alClient) and
    (FExcludeList.IndexOf(AControl.Name) = -1) then
    begin
      keyName := AControl.Name + '.';
      AFile.WriteInteger(sectionName, keyName + 'left', AControl.Left);
      AFile.WriteInteger(sectionName, keyName + 'top', AControl.Top);
      AFile.WriteInteger(sectionName, keyName + 'height', AControl.Height);
      AFile.WriteInteger(sectionName, keyName + 'width', AControl.Width);
    end;
end;

procedure TPlRunTimeDesigner.SaveData;
begin
  SaveData(TControl(Owner));
  if Assigned(FAfterSave) then
    FAfterSave(Self);
end;

procedure TPlRunTimeDesigner.SaveData(AControl: TControl);
var
  theIniFile: TIniFile;
begin
  if FIniName = '' then
    Exit;

  theIniFile := TIniFile.Create(FIniName);
  try
    SaveData(AControl, theIniFile);
  finally
    theIniFile.Free;
  end;
end;

procedure TPlRunTimeDesigner.SaveData(AControl: TControl; AFile: TIniFile);
var
  i, n: Integer;
begin
  if not Assigned(AFile) or not Assigned(AControl) then
    Exit;

  SaveControl(AControl, AFile);

  if AControl is TWinControl then
    begin
      n := TWinControl(AControl).ControlCount - 1;
      for i := 0 to n do
        SaveData(TWinControl(AControl).Controls[i], AFile);
    end;
end;

procedure TPlRunTimeDesigner.SelectingComponent(var AMsg: TMsg;
  TargetControl: TControl);
var
  Abort: Boolean;
  controlPoint: TPoint;
begin
  if Assigned(TargetControl) and not(TargetControl is TForm) then
    begin
      Abort := False;
      if Assigned(FBeforeResize) then
        FBeforeResize(TargetControl, Abort);

      if Abort then
        begin
          FAction := rdNone;
          FActiveControl := nil;
          Screen.Cursor := crDefault;
          Exit;
        end;

      { Use FActiveControl to represent the control under the mouse while not dragging }
      if FActiveControl <> TargetControl then
        FActiveControl := TargetControl;

      controlPoint := TargetControl.ScreenToClient(AMsg.pt);
      FAction := CoordinatesToDirection(TargetControl, controlPoint.X,
        controlPoint.Y);

      { centralized hover cursor update }
      UpdateCursorWhileHover(TargetControl, AMsg.pt);
    end
  else
    begin
      FActiveControl := nil;
      FAction := rdNone;
      Screen.Cursor := crDefault;
    end;
end;

procedure TPlRunTimeDesigner.SetActive(const AValue: Boolean);
begin
  if FActive = AValue then
    Exit;

  FActive := AValue;

  { Do not wire Application.OnMessage when designing in IDE }
  if csDesigning in ComponentState then
    Exit;

  if FActive then
    begin
      { Save previous handler and install ours. Use nil-checks to be defensive. }
      FOldApplicationOnMessage := Application.OnMessage;
      Application.OnMessage := ApplicationOnMessage;
    end
  else
    begin
      { Restore previous handler; guard against nil to avoid overwriting unexpected handlers. }
      Application.OnMessage := FOldApplicationOnMessage;
      FOldApplicationOnMessage := nil;

      { clear any hover/active state and restore default cursor immediately }
      FDragging := False;
      FAction := rdNone;
      FResizeDirection := rdNone;
      FActiveControl := nil;
      Screen.Cursor := crDefault;
    end;
end;

procedure TPlRunTimeDesigner.SetExcludeList(const AValue: TStrings);
begin
  { Accept nil (means empty list) and assign safely }
  if not Assigned(FExcludeList) then
    FExcludeList := TStringList.Create;
  if Assigned(AValue) then
    FExcludeList.Assign(AValue)
  else
    FExcludeList.Clear;
end;

{------------------------------------------------------------------------------}
{ Helpers }
{------------------------------------------------------------------------------}

procedure TPlRunTimeDesigner.UpdateCursorWhileHover(TargetControl: TControl;
  const ScreenPt: TPoint);
var
  clientPt: TPoint;
  dir: TPlResizeDirection;
  cur: TCursor;
begin
  if not Assigned(TargetControl) then
    begin
      Screen.Cursor := crDefault;
      Exit;
    end;

  { Convert screen coordinates to control client coordinates }
  clientPt := TargetControl.ScreenToClient(ScreenPt);

  { Use the shared logic to compute the direction }
  dir := CoordinatesToDirection(TargetControl, clientPt.X, clientPt.Y);

  { Map direction to cursor and apply it }
  cur := ActionToCursor(dir);
  Screen.Cursor := cur;
end;

end.

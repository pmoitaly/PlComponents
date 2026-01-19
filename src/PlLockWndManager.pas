unit PlLockWndManager;

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
 /// - TPlLockWndManager: a component that manages redraw locking on a target
 ///   window using WM_SETREDRAW. Locking is reference-counted.
 *******************************************************************************}

interface

uses
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Forms,
  System.SyncObjs,
  System.Classes;

type
  /// <summary>
  /// Component that manages redraw locking using WM_SETREDRAW. Supports
  /// reference counting and optional custom target HWND.
  /// </summary>
  TPlLockWndManager = class(TComponent)
  private
    FAfterRemoveLock: TNotifyEvent;
    FBeforeAddLock: TNotifyEvent;
    FCount: Integer;
    FTargetHwnd: HWND;
    { Sends WM_SETREDRAW(False) to the target window }
    procedure ApplyLock;
    { Sends WM_SETREDRAW(True) and triggers full redraw }
    procedure ReleaseLock;
  public
    /// <summary>
    /// Creates the component using the owner&apos;s window handle if possible.
    /// </summary>
    constructor Create(AOwner: TComponent); overload; override;

    /// <summary>
    /// Creates the component targeting a specific window handle.
    /// </summary>
    constructor Create(AOwner: TComponent; ATarget: HWND); reintroduce;
      overload;

    /// <summary>
    /// Ensures lock is released if still active.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    /// Increases the lock counter and applies WM_SETREDRAW(False) when
    /// transitioning to locked state.
    /// </summary>
    procedure AddLock;

    /// <summary>
    /// Decreases the lock counter and releases WM_SETREDRAW(True) when the
    /// counter reaches zero.
    /// </summary>
    procedure RemoveLock;

    /// <summary>
    /// Forces immediate unlock regardless of counter by resetting it safely.
    /// </summary>
    procedure ResetCounter;
  published
    /// <summary>
    /// Current lock counter.
    /// </summary>
    property Count: Integer read FCount;

    /// <summary>
    /// Event fired after the lock is removed and redraw is re-enabled.
    /// </summary>
    property AfterRemoveLock: TNotifyEvent read FAfterRemoveLock
      write FAfterRemoveLock;

    /// <summary>
    /// Event fired before the lock is applied.
    /// </summary>
    property BeforeAddLock: TNotifyEvent read FBeforeAddLock
      write FBeforeAddLock;
  end;

implementation

uses
  Winapi.Messages,
  System.Math;

constructor TPlLockWndManager.Create(AOwner: TComponent);
begin
  inherited;
  { Determine the target window: owner first, otherwise main form }
  if (Owner is TWinControl) then
    FTargetHwnd := TWinControl(Owner).Handle
  else if Assigned(Application.MainForm) then
    FTargetHwnd := Application.MainForm.Handle
  else
    FTargetHwnd := 0;
end;

constructor TPlLockWndManager.Create(AOwner: TComponent; ATarget: HWND);
begin
  inherited Create(AOwner);
  { Validate target HWND }
  if (ATarget <> 0) and IsWindow(ATarget) then
    FTargetHwnd := ATarget
  else
    FTargetHwnd := 0;
end;

destructor TPlLockWndManager.Destroy;
begin
  System.TMonitor.Enter(Self);
  try
    if FCount > 0 then
      ReleaseLock;
  finally
    System.TMonitor.Exit(Self);
  end;
  inherited;
end;

procedure TPlLockWndManager.AddLock;
begin
  System.TMonitor.Enter(Self);
  try
    if FCount = 0 then
      ApplyLock;
    Inc(FCount);
  finally
    System.TMonitor.Exit(Self);
  end;
end;

procedure TPlLockWndManager.ApplyLock;
begin
  { Validate HWND before applying lock }
  if (FTargetHwnd <> 0) and IsWindow(FTargetHwnd) and
    IsWindowVisible(FTargetHwnd) then
    begin
      if Assigned(FBeforeAddLock) then
        FBeforeAddLock(Self);

      SendMessage(FTargetHwnd, WM_SETREDRAW, WPARAM(False), 0);
    end;
end;

procedure TPlLockWndManager.ReleaseLock;
begin
  { Validate HWND }
  if (FTargetHwnd <> 0) and IsWindow(FTargetHwnd) then
    begin
      SendMessage(FTargetHwnd, WM_SETREDRAW, WPARAM(True), 0);

      RedrawWindow(FTargetHwnd, nil, 0, RDW_INVALIDATE or RDW_ERASE or
        RDW_ALLCHILDREN);

      if Assigned(FAfterRemoveLock) then
        FAfterRemoveLock(Self);
    end;
end;

procedure TPlLockWndManager.RemoveLock;
begin
  System.TMonitor.Enter(Self);
  try
    if FCount > 0 then
      begin
        Dec(FCount);
        if FCount = 0 then
          ReleaseLock;
      end;
  finally
    System.TMonitor.Exit(Self);
  end;
end;

procedure TPlLockWndManager.ResetCounter;
begin
  { Unlock even if counter was > 1 }
  if FCount > 0 then
    begin
      FCount := 1;
      RemoveLock;
    end;
end;

end.

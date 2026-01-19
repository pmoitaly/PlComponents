unit PlDirectoryWatcher;

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
 /// Unit: PlDirectoryWatcher
 /// Provides a threaded directory watcher using ReadDirectoryChangesW with
 /// debounce, pause/resume and runtime folder switching.
 *******************************************************************************}

interface

uses
  System.Classes,
  System.SyncObjs,
  Winapi.Windows,
  System.SysUtils;

type
  PFILE_NOTIFY_INFORMATION = ^FILE_NOTIFY_INFORMATION;

  FILE_NOTIFY_INFORMATION = record
    NextEntryOffset: ULONG;
    Action: ULONG;
    FileNameLength: ULONG;
    FileName: array [0 .. 0] of WCHAR;
  end;

  TPlFileChangeAction = (fcaAdded, fcaRemoved, fcaModified, fcaRenamedOld,
    fcaRenamedNew, fcaUnknown);

  /// <summary>Event fired for file changes inside the watched folder.</summary>
  TPlOnFolderChange = procedure(Sender: TObject; const AFolderName: string;
    AnAction: TPlFileChangeAction) of object;

  /// <summary>Event fired when a folder rename has occurred.</summary>
  TPlOnFolderRenamed = procedure(Sender: TObject;
    const AOldName, ANewName: String) of object;

  TRecentChange = record
    FileName: string;
    Action: TPlFileChangeAction;
    Timestamp: Cardinal;
  end;

  /// <summary>
  /// Thread monitoring a directory using ReadDirectoryChangesW with debounce
  /// and ability to pause/resume and change folder at runtime.
  /// </summary>
  TDirectoryWatcherThread = class(TThread)
  private
    FActive: Boolean;
    FChangeRequested: Boolean;
    FCrit: TCriticalSection;
    FDirHandle: THandle;
    FFolder: string;
    FLastChange: TRecentChange;
    FNewFolder: string;
    FOnChange: TPlOnFolderChange;
    FPauseEvent: TEvent;
    FStartPaused: Boolean;
    FWatchSubtree: Boolean;
    procedure DoApplyFolderChange;
    procedure DoNotify(const AFileName: string; AnAction: TPlFileChangeAction);
    function GetActive: Boolean;
    function IsDuplicateEvent(const AFileName: string;
      AAction: TPlFileChangeAction): Boolean;
    function MapAction(const AAction: DWORD): TPlFileChangeAction;
    procedure SetActive(const AValue: Boolean);
  protected
    procedure Execute; override;
  public
    /// <summary>Creates the watcher for a folder. Thread is created suspended.</summary>
    constructor Create(const AFolder: string; AWatchSubtree: Boolean;
      AOnChange: TPlOnFolderChange; AStartPaused: Boolean = True);
    /// <summary>Destroys the watcher and ensures resources are released.</summary>
    destructor Destroy; override;
    /// <summary>Starts the thread after construction.</summary>
    procedure AfterConstruction; override;
    /// <summary>Request a change of the watched folder at runtime.</summary>
    procedure ChangeFolder(const ANewFolder: string);
    /// <summary>Checks whether the given path is a directory.</summary>
    function IsDirectory(const APath: string): Boolean;
    /// <summary>Pause watching (thread remains alive).</summary>
    procedure PauseWatching;
    /// <summary>Resume watching.</summary>
    procedure ResumeWatching;
    procedure Stop;
    /// <summary>Indicates whether the watcher is active.</summary>
    property Active: Boolean read GetActive write SetActive;
  end;

implementation

uses
  Winapi.Messages;

{ TDirectoryWatcherThread }

constructor TDirectoryWatcherThread.Create(const AFolder: string;
  AWatchSubtree: Boolean; AOnChange: TPlOnFolderChange; AStartPaused: Boolean);
begin
  inherited Create(True); // suspended
  FreeOnTerminate := False;

  FCrit := TCriticalSection.Create;
  FPauseEvent := TEvent.Create(nil, True, True, '');
  FDirHandle := INVALID_HANDLE_VALUE;

  FFolder := AFolder;
  FWatchSubtree := AWatchSubtree;
  FOnChange := AOnChange;
  FStartPaused := AStartPaused;
  FChangeRequested := False;

  FActive := not AStartPaused;
  if AStartPaused then
    FPauseEvent.ResetEvent
  else
    FPauseEvent.SetEvent;
end;

destructor TDirectoryWatcherThread.Destroy;
begin
//  Terminate;
//
//  { Unblock wait and pending IO }
//  FPauseEvent.SetEvent;
//
//  if FDirHandle <> INVALID_HANDLE_VALUE then
//    begin
//      CancelIoEx(FDirHandle, nil);
//      Sleep(10);
//    end;
  // Use Stop to centralize cancellation logic and avoid duplication
  Stop;
//
  WaitFor;

  if FDirHandle <> INVALID_HANDLE_VALUE then
    CloseHandle(FDirHandle);

  FPauseEvent.Free;
  FCrit.Free;

  inherited;
end;

procedure TDirectoryWatcherThread.AfterConstruction;
begin
  inherited;
  Start;
end;

procedure TDirectoryWatcherThread.ChangeFolder(const ANewFolder: string);
begin
  FCrit.Enter;
  try
    FNewFolder := ANewFolder;
    FChangeRequested := True;
  finally
    FCrit.Leave;
  end;
end;

procedure TDirectoryWatcherThread.DoApplyFolderChange;
begin
  if Terminated then
    Exit;

  if FDirHandle <> INVALID_HANDLE_VALUE then
    CloseHandle(FDirHandle);

  FDirHandle := CreateFile(PChar(FFolder), FILE_LIST_DIRECTORY,
    FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, nil,
    OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, 0);
end;

procedure TDirectoryWatcherThread.DoNotify(const AFileName: string; AnAction:
    TPlFileChangeAction);
begin
  if Assigned(FOnChange) then
    FOnChange(Self, IncludeTrailingPathDelimiter(FFolder) + AFileName, AnAction);
end;

procedure TDirectoryWatcherThread.Execute;
var
  action: TPlFileChangeAction;
  buffer: array [0 .. 1023] of Byte;
  bytesReturned: DWORD;
  fileNameW: WideString;
  info: PFILE_NOTIFY_INFORMATION;
begin
  { Open directory handle under protection to avoid races }
  FCrit.Enter;
  try
    FDirHandle := CreateFile(PChar(FFolder), FILE_LIST_DIRECTORY,
      FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, nil,
      OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, 0);
  finally
    FCrit.Leave;
  end;

  while not Terminated do
    begin
      if FPauseEvent.WaitFor(100) = wrTimeout then
        Continue;

      if Terminated then
        Break;

      FCrit.Enter;
      try
        if FChangeRequested then
          begin
            FFolder := FNewFolder;
            FChangeRequested := False;
            DoApplyFolderChange;
          end;
      finally
        FCrit.Leave;
      end;

      if (FDirHandle = INVALID_HANDLE_VALUE) then
        Continue;

      if ReadDirectoryChangesW(FDirHandle, @buffer, SizeOf(buffer),
        FWatchSubtree, FILE_NOTIFY_CHANGE_FILE_NAME or
        FILE_NOTIFY_CHANGE_DIR_NAME or FILE_NOTIFY_CHANGE_CREATION or
        FILE_NOTIFY_CHANGE_LAST_WRITE, @bytesReturned, nil, nil) then
        begin
          info := PFILE_NOTIFY_INFORMATION(@buffer);
          repeat
            SetString(fileNameW, info^.FileName, info^.FileNameLength div 2);
            action := MapAction(info^.Action);

            if not IsDuplicateEvent(fileNameW, action) then
              begin
                FLastChange.FileName := fileNameW;
                FLastChange.Action := action;
                FLastChange.Timestamp := GetTickCount;

                TThread.Queue(nil,
                  procedure
                  begin
                    DoNotify(fileNameW, Action);
                  end);
              end;

            if info^.NextEntryOffset = 0 then
              Break;

            info := PFILE_NOTIFY_INFORMATION
              (PByte(info) + info^.NextEntryOffset);
          until False;
        end
      else
        begin
          { If ReadDirectoryChangesW fails, sleep briefly and try again, unless terminating }
          if not Terminated then
            Sleep(50);
        end;
    end;
end;

function TDirectoryWatcherThread.GetActive: Boolean;
begin
  Result := FActive;
end;

function TDirectoryWatcherThread.IsDirectory(const APath: string): Boolean;
var
  attrs: DWORD;
begin
  attrs := GetFileAttributes(PChar(APath));
  Result := (attrs <> INVALID_FILE_ATTRIBUTES) and
    ((attrs and FILE_ATTRIBUTE_DIRECTORY) <> 0);
end;

function TDirectoryWatcherThread.IsDuplicateEvent(const AFileName: string;
AAction: TPlFileChangeAction): Boolean;
const
  DEBOUNCE_INTERVAL_MS = 250;
begin
  Result := (FLastChange.FileName = AFileName) and
    (FLastChange.Action = AAction) and
    (GetTickCount - FLastChange.Timestamp < DEBOUNCE_INTERVAL_MS);
end;

function TDirectoryWatcherThread.MapAction(const AAction: DWORD)
  : TPlFileChangeAction;
begin
  case AAction of
    FILE_ACTION_ADDED:
      Result := fcaAdded;
    FILE_ACTION_REMOVED:
      Result := fcaRemoved;
    FILE_ACTION_MODIFIED:
      Result := fcaModified;
    FILE_ACTION_RENAMED_OLD_NAME:
      Result := fcaRenamedOld;
    FILE_ACTION_RENAMED_NEW_NAME:
      Result := fcaRenamedNew;
    else
      Result := fcaUnknown;
  end;
end;

procedure TDirectoryWatcherThread.PauseWatching;
begin
  FPauseEvent.ResetEvent;
  FActive := False;
end;

procedure TDirectoryWatcherThread.ResumeWatching;
begin
  FPauseEvent.SetEvent;
  FActive := True;
end;

procedure TDirectoryWatcherThread.SetActive(const AValue: Boolean);
begin
  if AValue <> FActive then
    begin
      if AValue then
        ResumeWatching
      else
        PauseWatching;
    end;
end;

procedure TDirectoryWatcherThread.Stop;
begin
  // Request termination and ensure any blocking ReadDirectoryChangesW is cancelled.
  Terminate;

  // Unblock any wait so Execute can re-check Terminated quickly
  if Assigned(FPauseEvent) then
    FPauseEvent.SetEvent;

  FCrit.Enter;
  try
    if FDirHandle <> INVALID_HANDLE_VALUE then
    begin
      // Cancel any pending IO and close the handle under the same lock used in Execute
      CancelIoEx(FDirHandle, nil);
      CloseHandle(FDirHandle);
      FDirHandle := INVALID_HANDLE_VALUE;
    end;
  finally
    FCrit.Leave;
  end;
end;

end.

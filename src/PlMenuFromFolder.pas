unit PlMenuFromFolder;

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
 /// Unit: PlMenuFromFolder
 /// Provides TPlFlyMenuManager: generates dynamic menu items from a folder and
 /// optionally keeps them in sync using a directory watcher.
 *******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Menus,
  Vcl.ImgList,
  PlDirectoryWatcher;

type
  /// <summary>Signature used before adding each generated menu item. Can abort.</summary>
  TPlOnMenuItemAdding = procedure(Sender: TObject; ANewMenuItem: TMenuItem;
    var AAbort: Boolean) of object;

  /// <summary>Component that builds menu items from directories and optionally
  /// keeps them updated using a TDirectoryWatcherThread.</summary>
  TPlMenuFromFolder = class(TComponent)
  private
    { Fields (alphabetical) }
    FAfterChangeValue: TNotifyEvent;
    FAutoUpdate: Boolean;
    FBeforeChangeValue: TNotifyEvent;
    FEnabled: Boolean;
    FFolderName: string;
    FHelpContext: THelpContext;
    FImageList: TCustomImageList;
    FMenuItem: TMenuItem;
    FMustActivate: Boolean;
    FMonitor: TDirectoryWatcherThread;
    FOldFolderName: string;
    FOnAddedFolder: TPlOnFolderChange;
    FOnAdvancedDrawItem: TAdvancedMenuDrawItemEvent;
    FOnChangeFolder: TPlOnFolderChange;
    FOnClick: TNotifyEvent;
    FOnDeletedFolder: TPlOnFolderChange;
    FOnDrawItem: TMenuDrawItemEvent;
    FOnMeasureItem: TMenuMeasureItemEvent;
    FOnMenuItemAdding: TPlOnMenuItemAdding;
    FOnRenamedFolder: TPlOnFolderRenamed;
    FValue: string;
    FWatchSubTree: Boolean;

    { Property setters and helpers (alphabetical) }
    procedure SetAutoUpdate(const AValue: Boolean);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetFolderName(const AValue: string);
    procedure SetHelpContext(const AValue: THelpContext);
    procedure SetImageList(const AValue: TCustomImageList);
    procedure SetMenuItem(const AValue: TMenuItem);
    procedure SetValue(const ANewValue: string);
    procedure SetWatchSubTree(const AValue: Boolean);
    procedure TryCreateOrActivateMonitor;
  protected
    { Build a single menu item from folder name }
    procedure AddMenuItem(const AName: string);

    { Check if the manager can operate (menu+folder+enabled) }
    function CanUpdate: Boolean;

    { Create/Delete menu contents }
    procedure CreateMenu;
    procedure DeleteMenu;

    { Directory watcher callbacks }
    procedure DoChangeFolder(const AFolderName: string); virtual;
    procedure DoOldNameFolder(const AFolderName: string); virtual;
    procedure DoOnChange(Sender: TObject; const AFolderName: string;
      Action: TPlFileChangeAction); virtual;

    { State helpers }
    function GetActive: Boolean;
    procedure Loaded; override;
    procedure OnMenuClick(Sender: TObject);
    procedure RecreateMenu;
  public
    { Lifecycle }
    /// <summary>Frees resources and stops the monitor if running.</summary>
    destructor Destroy; override;

    { Operations }
    /// <summary>Force the directory watcher to (re)activate if available.</summary>
    procedure ActivateMonitor;

    /// <summary>Handle component notifications (e.g., linked components being removed).</summary>
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

    /// <summary>True if the watcher exists and is active.</summary>
    property Active: Boolean read GetActive;
  published
    /// <summary>When True, the watcher is auto-started and the menu auto-rebuilt.</summary>
    property AutoUpdate: Boolean read FAutoUpdate write SetAutoUpdate;

    /// <summary>Enable/disable the component and its menu visibility.</summary>
    property Enabled: Boolean read FEnabled write SetEnabled;

    /// <summary>Base folder for menu population (always stored with trailing delimiter).</summary>
    property FolderName: string read FFolderName write SetFolderName;

    /// <summary>Help context propagated to generated menu items.</summary>
    property HelpContext: THelpContext read FHelpContext write SetHelpContext;

    /// <summary>Optional image list to host loaded flag bitmaps.</summary>
    property ImageList: TCustomImageList read FImageList write SetImageList;

    /// <summary>Root menu item that will host generated children.</summary>
    property MenuItem: TMenuItem read FMenuItem write SetMenuItem;

    /// <summary>Selected value (matches a menu item caption, case-sensitive, without ampersands).</summary>
    property Value: string read FValue write SetValue;

    /// <summary>Watch subdirectories as well as the root folder.</summary>
    property WatchSubTree: Boolean read FWatchSubTree write SetWatchSubTree;

    /// <summary>Event raised after Value changes.</summary>
    property AfterChangeValue: TNotifyEvent read FAfterChangeValue
      write FAfterChangeValue;

    /// <summary>Event raised before Value changes.</summary>
    property BeforeChangeValue: TNotifyEvent read FBeforeChangeValue
      write FBeforeChangeValue;

    /// <summary>Raised when a new folder is detected.</summary>
    property OnAddedFolder: TPlOnFolderChange read FOnAddedFolder
      write FOnAddedFolder;

    /// <summary>Advanced draw event forwarded to created items.</summary>
    property OnAdvancedDrawItem: TAdvancedMenuDrawItemEvent
      read FOnAdvancedDrawItem write FOnAdvancedDrawItem;

    /// <summary>Raised when a folder content is modified.</summary>
    property OnChangeFolder: TPlOnFolderChange read FOnChangeFolder
      write FOnChangeFolder;

    /// <summary>Click event forwarded after internal handling.</summary>
    property OnClick: TNotifyEvent read FOnClick write FOnClick;

    /// <summary>Raised when a folder is deleted.</summary>
    property OnDeletedFolder: TPlOnFolderChange read FOnDeletedFolder
      write FOnDeletedFolder;

    /// <summary>Draw event forwarded to created items.</summary>
    property OnDrawItem: TMenuDrawItemEvent read FOnDrawItem write FOnDrawItem;

    /// <summary>Measure event forwarded to created items.</summary>
    property OnMeasureItem: TMenuMeasureItemEvent read FOnMeasureItem
      write FOnMeasureItem;

    /// <summary>Hook called before adding each menu item; can abort the addition.</summary>
    property OnMenuItemAdding: TPlOnMenuItemAdding read FOnMenuItemAdding
      write FOnMenuItemAdding;

    /// <summary>Raised when a folder is renamed.</summary>
    property OnRenamedFolder: TPlOnFolderRenamed read FOnRenamedFolder
      write FOnRenamedFolder;
  end;

implementation

uses
  System.Types,
  Graphics;

{ TPlMenuFromFolder }

destructor TPlMenuFromFolder.Destroy;
begin
  { Free watcher first to stop callbacks, then inherited }
  FreeAndNil(FMonitor);
  inherited;
end;

procedure TPlMenuFromFolder.ActivateMonitor;
begin
  if Assigned(FMonitor) then
    begin
      try
        FMonitor.Active := CanUpdate;
      except
        FMonitor.Active := False;
      end;
    end
  else
    FMustActivate := True;
end;

procedure TPlMenuFromFolder.AddMenuItem(const AName: string);
var
  AAbort: Boolean;
  flagName: string;
  newImage: TBitmap;
  newItem: TMenuItem;
begin
  { Skip pseudo-folders }
  if (AName = '.') or (AName = '..') then
    Exit;

  newItem := TMenuItem.Create(Self);
  try
    newItem.Caption := AName;
    newItem.Checked := AName = FValue;
    newItem.RadioItem := True;
    newItem.AutoHotkeys := maParent;
    newItem.HelpContext := FHelpContext;

    if Assigned(FOnAdvancedDrawItem) then
      newItem.OnAdvancedDrawItem := FOnAdvancedDrawItem;
    if Assigned(FOnDrawItem) then
      newItem.OnDrawItem := FOnDrawItem;
    if Assigned(FOnMeasureItem) then
      newItem.OnMeasureItem := FOnMeasureItem;

    newItem.OnClick := OnMenuClick;

    { Try to load optional flag bitmap }
    flagName := IncludeTrailingPathDelimiter(FFolderName) + AName + '\flag.bmp';
    if FileExists(flagName) then
      begin
        if Assigned(FImageList) then
          begin
            newImage := TBitmap.Create;
            try
              newImage.LoadFromFile(flagName);
              newItem.ImageIndex := FImageList.Add(newImage, nil);
            finally
              newImage.Free;
            end;
          end
        else
          newItem.Bitmap.LoadFromFile(flagName);
      end;

    AAbort := False;
    if Assigned(FOnMenuItemAdding) then
      FOnMenuItemAdding(Self, newItem, AAbort);

    if Assigned(FMenuItem) and not AAbort then
      FMenuItem.Add(newItem)
    else
      newItem.Free; { avoid orphan item leak }
  except
    newItem.Free;
    raise;
  end;
end;

function TPlMenuFromFolder.CanUpdate: Boolean;
begin
  Result := Assigned(FMenuItem) and DirectoryExists(FFolderName) and FEnabled;
end;

procedure TPlMenuFromFolder.CreateMenu;
var
  searchRec: TSearchRec;
begin
  if not CanUpdate then
    Exit;

  if FindFirst(FFolderName + '*.*', faDirectory, searchRec) = 0 then
    try
      repeat
        AddMenuItem(searchRec.Name);
      until FindNext(searchRec) <> 0;
    finally
      FindClose(searchRec);
    end
  else if Assigned(FMenuItem) then
    FMenuItem.Visible := False;
end;

procedure TPlMenuFromFolder.DeleteMenu;
var
  idx: Integer;
  last: Integer;
begin
  if not Assigned(FMenuItem) then
    Exit;

  last := FMenuItem.Count - 1;
  for idx := last downto 0 do
    FMenuItem.Items[idx].Free;
end;

procedure TPlMenuFromFolder.DoChangeFolder(const AFolderName: string);
begin
  { Rebuild menu to reflect changes }
  if CanUpdate then
    begin
      DeleteMenu;
      CreateMenu;
    end;
end;

procedure TPlMenuFromFolder.DoOldNameFolder(const AFolderName: string);
begin
  FOldFolderName := AFolderName;
end;

procedure TPlMenuFromFolder.DoOnChange(Sender: TObject;
  const AFolderName: string; Action: TPlFileChangeAction);
begin
  case Action of
    fcaAdded:
      begin
        DoChangeFolder(AFolderName);
        if Assigned(FOnAddedFolder) then
          FOnAddedFolder(Self, AFolderName, Action);
      end;
    fcaModified:
      begin
        DoChangeFolder(AFolderName);
        if Assigned(FOnChangeFolder) then
          FOnChangeFolder(Self, AFolderName, Action);
      end;
    fcaRemoved:
      begin
        DoChangeFolder(AFolderName);
        if Assigned(FOnDeletedFolder) then
          FOnDeletedFolder(Self, AFolderName, Action);
      end;
    fcaRenamedNew:
      begin
        DoChangeFolder(AFolderName);
        if Assigned(FOnRenamedFolder) then
          FOnRenamedFolder(Self, AFolderName, FOldFolderName);
      end;
    fcaRenamedOld:
      DoOldNameFolder(AFolderName);
    fcaUnknown:
      Exit;
  end;
end;

function TPlMenuFromFolder.GetActive: Boolean;
begin
  Result := Assigned(FMonitor) and FMonitor.Active;
end;

procedure TPlMenuFromFolder.Loaded;
begin
  inherited;
  if (csDesigning in ComponentState) then
    Exit;

  { Only auto-activate after the component is fully created and linked }
  if FAutoUpdate then
    TryCreateOrActivateMonitor;
end;

procedure TPlMenuFromFolder.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
    begin
      if AComponent = FMenuItem then
        MenuItem := nil
      else if AComponent = FImageList then
        ImageList := nil;
    end;
  inherited;
end;

procedure TPlMenuFromFolder.OnMenuClick(Sender: TObject);
var
  cleanCaption: string;
begin
  if Sender is TMenuItem then
    begin
      cleanCaption := TMenuItem(Sender).Caption.Replace('&', '');
      Value := cleanCaption;
    end;
  if Assigned(FOnClick) then
    FOnClick(Sender);
end;

procedure TPlMenuFromFolder.RecreateMenu;
begin
  if not CanUpdate then
    Exit;

  DeleteMenu;
  CreateMenu;

  if FAutoUpdate then
    ActivateMonitor;
end;

procedure TPlMenuFromFolder.SetAutoUpdate(const AValue: Boolean);
begin
  if FAutoUpdate = AValue then
    Exit;

  FAutoUpdate := AValue;

  { Only deactivate immediately if turned off }
  if not AValue then
    begin
      if Assigned(FMonitor) then
        begin
          FMonitor.Active := False;
          FMustActivate := False;
        end;
    end;
  { If AValue = True, the activation will happen in Loaded }
end;

procedure TPlMenuFromFolder.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;

  FEnabled := AValue;

  if Assigned(FMenuItem) then
    begin
      FMenuItem.Visible := AValue;
      if AValue then
        RecreateMenu
      else
        DeleteMenu;
    end;

  TryCreateOrActivateMonitor;
end;

procedure TPlMenuFromFolder.SetFolderName(const AValue: string);
var
  newValue: string;
begin
  newValue := IncludeTrailingPathDelimiter(AValue);
  if (FFolderName = newValue) or not DirectoryExists(newValue) then
    Exit;

  FFolderName := newValue;
  TryCreateOrActivateMonitor;
end;

procedure TPlMenuFromFolder.SetHelpContext(const AValue: THelpContext);
var
  idx: Integer;
  last: Integer;
begin
  if FHelpContext = AValue then
    Exit;

  FHelpContext := AValue;

  if not Assigned(FMenuItem) then
    Exit;

  last := FMenuItem.Count - 1;
  for idx := 0 to last do
    FMenuItem.Items[idx].HelpContext := AValue;
end;

procedure TPlMenuFromFolder.SetImageList(const AValue: TCustomImageList);
begin
  if FImageList = AValue then
    Exit;

  FImageList := AValue;
  if Assigned(FMenuItem) then
    FMenuItem.SubMenuImages := AValue;
end;

procedure TPlMenuFromFolder.SetMenuItem(const AValue: TMenuItem);
begin
  if FMenuItem = AValue then
    Exit;

  if Assigned(FMenuItem) then
    DeleteMenu;

  FMenuItem := AValue;
  TryCreateOrActivateMonitor;
end;

procedure TPlMenuFromFolder.SetValue(const ANewValue: string);
var
  cleanCaption: string;
  idx: Integer;
  last: Integer;
begin
  if FValue = ANewValue then
    Exit;

  if Assigned(FBeforeChangeValue) then
    FBeforeChangeValue(Self);

  FValue := ANewValue;
  cleanCaption := ANewValue.Replace('&', '');

  if Assigned(FMenuItem) then
    begin
      last := FMenuItem.Count - 1;
      for idx := 0 to last do
        FMenuItem.Items[idx].Checked :=
          (FMenuItem.Items[idx].Caption.Replace('&', '') = cleanCaption);
    end;

  if Assigned(FAfterChangeValue) then
    FAfterChangeValue(Self);
end;

procedure TPlMenuFromFolder.SetWatchSubTree(const AValue: Boolean);
begin
  if FWatchSubTree = AValue then
    Exit;

  FWatchSubTree := AValue;
  TryCreateOrActivateMonitor;
end;

procedure TPlMenuFromFolder.TryCreateOrActivateMonitor;
begin
  if not DirectoryExists(FFolderName) then
    Exit;

  { Dispose previous monitor safely }
  if Assigned(FMonitor) then
    begin
      try
        FMonitor.Active := False; { ensure stopped }
        FMonitor.Terminate;       { request thread termination }
        FMonitor.WaitFor;         { wait for thread to finish }
      except
        { ignore errors on shutdown }
      end;
      FreeAndNil(FMonitor);
    end;

  { Create a watcher only if component can operate }
  if CanUpdate then
    begin
      { NOTE: The last parameter is StartSuspended; it is inverted from AutoUpdate. }
      FMonitor := TDirectoryWatcherThread.Create(FFolderName, FWatchSubTree,
        DoOnChange, (not FAutoUpdate));
      if FEnabled then
        RecreateMenu;
    end
  else
    FMustActivate := FAutoUpdate;
end;

end.

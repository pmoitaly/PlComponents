unit PlRecentFilesManager;

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
 /// Unit: PlRecentFileManager
 /// Provides TPlRecentFileManagr: a class to manage the menu's
 /// recents' file list.
 *******************************************************************************}

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, System.Math,
  Vcl.Menus, System.IOUtils;

type
  /// <summary>
  ///  Manages a list of recent files, saving and loading from an INI file,
  ///  and populates a VCL menu with entries to reopen those files.
  /// </summary>
  TPlRecentFileManager = class
  private
    FFiles: TStringList;
    FIniName: string;
    FMaxCount: Integer;
    FRecentFilesMenu: TMenuItem;
    FOnFileSelected: TProc<string>;
    FCritSect: TCriticalSection;

    procedure ClearRecentMenuItems;
    procedure LoadFromIni;
    procedure RecentFileClick(Sender: TObject);
    procedure SanitizeRecentList;
    procedure SaveToIni;
    procedure AddFile(const AFileName: string);
  public
    /// <summary>
    ///  Creates the RecentFileManager.
    /// </summary>
    /// <param name="RecentFileMenu">The TMenuItem under which recent files will be listed. Must not be nil.</param>
    /// <param name="AIniName">Path to the INI file where recent files are saved.</param>
    /// <param name="OnFileSelected">Event handler called when a recent file menu item is clicked. Must not be nil.</param>
    /// <exception cref="EArgumentNilException">If RecentFileMenu or OnFileSelected is nil.</exception>
    constructor Create(RecentFileMenu: TMenuItem; const AIniName: string;
      OnFileSelected: TProc<string>);
    destructor Destroy; override;

    /// <summary>
    ///  Rebuilds the recent files menu from the internal list.
    /// </summary>
    procedure BuildMenu;

    /// <summary>
    ///  Clears all recent files from memory and the menu, saving immediately.
    /// </summary>
    procedure Clear;

    /// <summary>
    ///  Returns the most recent existing file from the list, or empty string if none exist.
    /// </summary>
    function LastFile: string;

    /// <summary>
    ///  Ensures all files in the recent list still exist, removes invalid entries,
    ///  saves the updated list, and rebuilds the menu.
    /// </summary>
    procedure Purge;

    /// <summary>
    ///  Adds or moves the specified file to the top of the recent files list,
    ///  then saves and rebuilds the menu.
    /// </summary>
    /// <param name="FileName">The file path to register as recent.</param>
    procedure RegisterFile(const FileName: string);

    /// <summary>
    ///  The maximum number of recent files to keep (default 10).
    /// </summary>
    property MaxCount: Integer read FMaxCount write FMaxCount;

    /// <summary>
    ///  Read-only list of recent files.
    /// </summary>
    property Files: TStringList read FFiles;

    /// <summary>
    ///  Event handler called when a recent file menu item is selected.
    ///  Set in constructor and immutable.
    /// </summary>
    property OnFileSelected: TProc<string> read FOnFileSelected;
  end;

implementation

uses
  System.IniFiles;

const
  RECENT_FILES_SECTION = 'RecentFiles';

  { TRecentFileManager }

constructor TPlRecentFileManager.Create(RecentFileMenu: TMenuItem;
  const AIniName: string; OnFileSelected: TProc<string>);
begin
  inherited Create;
  if not Assigned(RecentFileMenu) then
    raise EArgumentNilException.Create('RecentFileMenu cannot be nil');
  if not Assigned(OnFileSelected) then
    raise EArgumentNilException.Create('OnFileSelected event cannot be nil');

  FFiles := TStringList.Create;
  FFiles.Duplicates := dupIgnore;
  FFiles.Sorted := False;

  FCritSect := TCriticalSection.Create;

  FMaxCount := 10;
  FRecentFilesMenu := RecentFileMenu;
  FOnFileSelected := OnFileSelected;
  FIniName := AIniName;

  LoadFromIni;
  BuildMenu;
end;

destructor TPlRecentFileManager.Destroy;
begin
  FCritSect.Enter;
  try
    FFiles.Free;
  finally
    FCritSect.Leave;
    FCritSect.Free;
  end;
  inherited;
end;

procedure TPlRecentFileManager.BuildMenu;
var
  item: TMenuItem;
  i: Integer;
begin
  FCritSect.Enter;
  try
    ClearRecentMenuItems;

    for i := 0 to FFiles.Count - 1 do
      begin
        item := TMenuItem.Create(FRecentFilesMenu);
        item.Caption := ExtractFileName(FFiles[i]);
        item.Hint := FFiles[i];
        item.Tag := 100;
        item.OnClick := RecentFileClick;
        FRecentFilesMenu.Insert(i, item);
      end;

    if FFiles.Count > 0 then
      begin
        item := TMenuItem.Create(FRecentFilesMenu);
        item.Caption := '-';
        item.Tag := 100;
        FRecentFilesMenu.Insert(FFiles.Count, item);
      end;
  finally
    FCritSect.Leave;
  end;
end;

procedure TPlRecentFileManager.Clear;
begin
  FCritSect.Enter;
  try
    FFiles.Clear;
    SaveToIni;
    ClearRecentMenuItems;
  finally
    FCritSect.Leave;
  end;
end;

procedure TPlRecentFileManager.ClearRecentMenuItems;
var
  i: Integer;
begin
  for i := FRecentFilesMenu.Count - 1 downto 0 do
    if FRecentFilesMenu.Items[i].Tag = 100 then
      FRecentFilesMenu.Delete(i);
end;

function TPlRecentFileManager.LastFile: string;
var
  i: Integer;
begin
  Result := '';
  FCritSect.Enter;
  try
    for i := 0 to FFiles.Count - 1 do
      if TFile.Exists(FFiles[i]) then
        begin
          Result := FFiles[i];
          Exit;
        end;
  finally
    FCritSect.Leave;
  end;
end;

procedure TPlRecentFileManager.LoadFromIni;
var
  ini: TMemIniFile;
  allValues: TStringList;
  keyName, FileName: string;
  i: Integer;
begin
  FCritSect.Enter;
  try
    FFiles.Clear;
    if not FileExists(FIniName) then
      Exit;

    ini := TMemIniFile.Create(FIniName);
    try
      allValues := TStringList.Create;
      try
        ini.ReadSectionValues(RECENT_FILES_SECTION, allValues);

        if allValues.Count = 0 then
          Exit;

        for i := 0 to allValues.Count - 1 do
          begin
            keyName := allValues.Names[i];
            if keyName.StartsWith('Recent') then
              begin
                FileName := allValues.ValueFromIndex[i];
                if (FileName <> '') and TFile.Exists(FileName) then
                  FFiles.Add(FileName);
                if FFiles.Count >= FMaxCount then
                  Break;
              end;
          end;
      finally
        allValues.Free;
      end;
    finally
      ini.Free;
    end;
  finally
    FCritSect.Leave;
  end;
end;

procedure TPlRecentFileManager.Purge;
begin
  FCritSect.Enter;
  try
    SanitizeRecentList;
    SaveToIni;
    BuildMenu;
  finally
    FCritSect.Leave;
  end;
end;

procedure TPlRecentFileManager.RecentFileClick(Sender: TObject);
var
  FileName: string;
begin
  if Assigned(Sender) and (Sender is TMenuItem) then
    begin
      FileName := TMenuItem(Sender).Hint;
      if Assigned(FOnFileSelected) then
        FOnFileSelected(FileName);
    end;
end;

procedure TPlRecentFileManager.RegisterFile(const FileName: string);
begin
  FCritSect.Enter;
  try
    AddFile(FileName);
    SaveToIni;
    BuildMenu;
  finally
    FCritSect.Leave;
  end;
end;

procedure TPlRecentFileManager.AddFile(const AFileName: string);
var
  index: Integer;
begin
  // Assumes FCritSect already entered
  index := FFiles.IndexOf(AFileName);
  if index > -1 then
    FFiles.Delete(index);
  FFiles.Insert(0, AFileName);
  while FFiles.Count > FMaxCount do
    FFiles.Delete(FFiles.Count - 1);
end;

procedure TPlRecentFileManager.SaveToIni;
var
  ini: TMemIniFile;
  i: Integer;
  key: string;
begin
  // Assumes FCritSect already entered
  ini := TMemIniFile.Create(FIniName);
  try
    if ini.SectionExists(RECENT_FILES_SECTION) then
      ini.EraseSection(RECENT_FILES_SECTION);

    for i := 0 to Min(FFiles.Count - 1, FMaxCount - 1) do
      begin
        key := 'Recent' + i.ToString;
        ini.WriteString(RECENT_FILES_SECTION, key, FFiles[i]);
      end;

    ini.UpdateFile;
  finally
    ini.Free;
  end;
end;

procedure TPlRecentFileManager.SanitizeRecentList;
var
  UniqueList: TStringList;
  i: Integer;
begin
  UniqueList := TStringList.Create;
  try
    UniqueList.Duplicates := dupIgnore;
    UniqueList.Sorted := False;

    for i := 0 to FFiles.Count - 1 do
      if TFile.Exists(FFiles[i]) then
        UniqueList.Add(FFiles[i]);

    FFiles.Assign(UniqueList);
  finally
    UniqueList.Free;
  end;
end;

end.

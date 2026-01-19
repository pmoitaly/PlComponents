unit PlRecentFilesComponent;

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
 /// Unit: PlRecentFileComponent
 /// Provides TPlRecentFileComponent: a component to manage the menu's
 /// recents' file list.
 *******************************************************************************}

interface

uses
  System.Classes, System.SysUtils,
  Vcl.Menus, PlRecentFilesManager;

type
  TPlOnRecentFileSelected = procedure(Sender: TObject; AFileName: string) of object;

  /// <summary>
  ///  Componente wrapper per TPlRecentFileManager, utilizzabile direttamente in una form.
  /// </summary>
  TPlRecentFilesComponent = class(TComponent)
  private
    FIniFile: string;
    FManager: TPlRecentFileManager;
    FMaxCount: Integer;
    FOnFileSelected: TPlOnRecentFileSelected;
    FRecentMenu: TMenuItem;
    function GetFiles: TStringList;
    procedure RebuildManagerIfReady;
    procedure SetIniFile(const Value: string);
    procedure SetMaxCount(Value: Integer);
    procedure SetOnFileSelected(Value: TPlOnRecentFileSelected);
    procedure SetRecentMenu(Value: TMenuItem);
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    /// <summary>
    ///  Clears all recent files.
    /// </summary>
    procedure Clear;
    /// <summary>
    ///  Returns the most recent existing file.
    /// </summary>
    function LastFile: string;
    /// <summary>
    ///  Ensures all files in the recent list still exist, removes invalid entries,
    ///  saves the updated list, and rebuilds the menu.
    /// </summary>
    procedure Purge;
    /// <summary>
    ///  Rebuilds the menu.
    /// </summary>
    procedure Rebuild;
    /// <summary>
    ///  Adds or moves the specified file to the top of the recent files list,
    ///  then saves and rebuilds the menu.
    /// </summary>
    /// <param name="FileName">The file path to register as recent.</param>
    procedure RegisterFile(const FileName: string);
  published
    /// <summary>
    ///  Read-only list of recent files.
    /// </summary>
    property Files: TStringList read GetFiles;
    /// <summary>
    ///  Percorso del file INI.
    /// </summary>
    property IniFile: string read FIniFile write SetIniFile;
    /// <summary>
    ///  The maximum number of recent files to keep (default 10).
    /// </summary>
    property MaxCount: Integer read FMaxCount write SetMaxCount default 10;
    /// <summary>
    ///  Menu under which to insert the entries of recent files.
    /// </summary>
    property RecentMenu: TMenuItem read FRecentMenu write SetRecentMenu;
    /// <summary>
    ///  Event fired when a recent file is selected.
    /// </summary>
    property OnFileSelected: TPlOnRecentFileSelected read FOnFileSelected
      write SetOnFileSelected;
  end;

implementation

{ TPlRecentFileComponent }

constructor TPlRecentFilesComponent.Create(AOwner: TComponent);
begin
  inherited;
  FMaxCount := 10;
end;

destructor TPlRecentFilesComponent.Destroy;
begin
  FManager.Free;
  inherited;
end;

function TPlRecentFilesComponent.GetFiles: TStringList;
begin
  if Assigned(FManager) then
    Result := FManager.Files
  else
    Result := nil;
end;

procedure TPlRecentFilesComponent.Clear;
begin
  if Assigned(FManager) then
    FManager.Clear;
end;

function TPlRecentFilesComponent.LastFile: string;
begin
  if Assigned(FManager) then
    Result := FManager.LastFile
  else
    Result := '';
end;

procedure TPlRecentFilesComponent.Loaded;
begin
  inherited;
  RebuildManagerIfReady;
end;

procedure TPlRecentFilesComponent.Purge;
begin
  if Assigned(FManager) then
    FManager.Purge;
end;

procedure TPlRecentFilesComponent.Rebuild;
begin
  if Assigned(FManager) then
    FManager.BuildMenu;
end;

procedure TPlRecentFilesComponent.RebuildManagerIfReady;
var
  canCreateManager: boolean;
begin
  if Assigned(FManager) then
    FreeAndNil(FManager);
  canCreateManager := (FIniFile <> '') and Assigned(FRecentMenu) and
    Assigned(FOnFileSelected);
  if canCreateManager then
    begin
      FManager := TPlRecentFileManager.Create(FRecentMenu, FIniFile,
        procedure(AFileName: string) begin
          if Assigned(FOnFileSelected) then
            FOnFileSelected(Self, AFileName);
        end);
      FManager.MaxCount := FMaxCount;
    end;
end;

procedure TPlRecentFilesComponent.RegisterFile(const FileName: string);
begin
  if Assigned(FManager) then
    FManager.RegisterFile(FileName);
end;

procedure TPlRecentFilesComponent.SetIniFile(const Value: string);
begin
  if FIniFile <> Value then
    begin
      FIniFile := Value;
      RebuildManagerIfReady;
    end;
end;

procedure TPlRecentFilesComponent.SetMaxCount(Value: Integer);
begin
  FMaxCount := Value;
  if Assigned(FManager) then
    FManager.MaxCount := Value;
end;

procedure TPlRecentFilesComponent.SetOnFileSelected(Value:
    TPlOnRecentFileSelected);
begin
  if @Value = @FOnFileSelected then
    Exit;

  FOnFileSelected := Value;
  RebuildManagerIfReady;
end;

procedure TPlRecentFilesComponent.SetRecentMenu(Value: TMenuItem);
begin
  if FRecentMenu <> Value then
    begin
      FRecentMenu := Value;
      RebuildManagerIfReady;
    end;
end;

end.


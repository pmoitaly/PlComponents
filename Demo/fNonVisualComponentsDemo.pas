unit fNonVisualComponentsDemo;

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

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.FileCtrl, Vcl.Grids, Vcl.Outline, Vcl.ExtCtrls,
  Vcl.Samples.DirOutln,
  PlRunTimeDesigner, PlStyleMenuManager, PlMenuFromFolder, PlLanguageServer,
  PlRecentFilesComponent, PlLockWndManager, PlLanguage, System.ImageList,
  Vcl.ImgList;

type
  TfrmNonVisualCompDemo = class(TForm)
    btnLoad: TButton;
    btnStartLock: TButton;
    chkAutoUpdateMenu: TCheckBox;
    chkSearchForSubfolders: TCheckBox;
    chkStylePreview: TCheckBox;
    douMenuFromFolder: TDirectoryOutline;
    flbRecent: TFileListBox;
    imlFlags: TImageList;
    lblCursorPosition: TLabel;
    lblLastMenuItemSelectd: TLabel;
    lblPlLanguage: TLabel;
    lblPlLockWndManager: TLabel;
    lblPlMenuFromFolder: TLabel;
    lblPlRecentFiles: TLabel;
    lblPlRuntimeDemo: TLabel;
    lblPlStyleMenuManager: TLabel;
    lngDemo: TPlLanguage;
    lwmDemo: TPlLockWndManager;
    memLockWnd: TMemo;
    memTest: TMemo;
    mmnMain: TMainMenu;
    mffDemo: TPlMenuFromFolder;
    mffLanguage: TPlMenuFromFolder;
    mitClearList: TMenuItem;
    mitDesigner: TMenuItem;
    mitDesignerEnd: TMenuItem;
    mitDesignerLoad: TMenuItem;
    mitDesignerSave: TMenuItem;
    mitDesignerStart: TMenuItem;
    mitExit: TMenuItem;
    mitFile: TMenuItem;
    mitFolder: TMenuItem;
    mitLanguage: TMenuItem;
    mitOptions: TMenuItem;
    mitPurgeList: TMenuItem;
    mitRecentFiles: TMenuItem;
    mitStyle: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    pctMain: TPageControl;
    rbtLanguageIni: TRadioButton;
    rbtLanguageJson: TRadioButton;
    rfcDemo: TPlRecentFilesComponent;
    rtdDemo: TPlRunTimeDesigner;
    smmDemo: TPlStylesMenuManager;
    tbsIntro: TTabSheet;
    tbsPlLanguage: TTabSheet;
    tbsPlLockWndManager: TTabSheet;
    tbsPlMenuFromFolder: TTabSheet;
    tbsPlRecentFilesComponent: TTabSheet;
    tbsPlRuntimeDesigner: TTabSheet;
    tbsPlStyleMenuManager: TTabSheet;
    tmrLockWindow: TTimer;
    procedure AllowAutoUpdateMenu(Sender: TObject);
    procedure AllowSubfoldersInMenu(Sender: TObject);
    procedure ClearRecentFilesList(Sender: TObject);
    procedure EndRuntimeDesign(Sender: TObject);
    procedure ExitApplication(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure LoadPositions(Sender: TObject);
    procedure LoadTextFile(Sender: TObject);
    procedure LockWindowUpdate(Sender: TObject);
    procedure ChangeLanguage(Sender: TObject);
    procedure lngDemoAfterLoad(Sender: TObject; AFile: string);
    procedure NewMenuFromFolder(Sender: TObject);
    procedure PerformLock(Sender: TObject);
    procedure PurgeRecentFilesList(Sender: TObject);
    procedure ReloadSelected(Sender: TObject; AFileName: string);
    procedure SavePositionsData(Sender: TObject);
    procedure ShowLastMenuSelection(Sender: TObject);
    procedure StartRuntimeDesign(Sender: TObject);
    procedure SwitchStylePreview(Sender: TObject);
    procedure UseIni(Sender: TObject);
    procedure UseJson(Sender: TObject);
  private
    FIniFolder: string;
    FLanguagesFolder: string;
    function GetIniName: string;
  public
    { Public declarations }
  end;

var
  frmNonVisualCompDemo: TfrmNonVisualCompDemo;

implementation

{$R *.dfm}

uses
  System.IoUtils,
  PlLanguageIniEngine, PlLanguageJsonEngine, PlLanguageTypes;

resourcestring
  SLoaded = 'Loaded';
  SCursorPosition = 'Cursor position';
{$REGION 'TPlLanguage demo'}


procedure TfrmNonVisualCompDemo.lngDemoAfterLoad(Sender: TObject; AFile:
    string);
begin
  ShowMessage(Format('%s %s.', [lngDemo.Translate(SLoaded), lngDemo.LangFile]));
end;

procedure TfrmNonVisualCompDemo.ChangeLanguage(Sender: TObject);
begin
  TPlLanguageServer.Language := mffLanguage.Value;
end;

procedure TfrmNonVisualCompDemo.UseIni(Sender: TObject);
begin
  TPlLanguageServer.FileFormat := lpIni;
end;

procedure TfrmNonVisualCompDemo.UseJson(Sender: TObject);
begin
  TPlLanguageServer.FileFormat := lpJson;
end;
{$ENDREGION}

{$REGION 'TPlLockWndManager demo'}
procedure TfrmNonVisualCompDemo.LockWindowUpdate(Sender: TObject);
begin
  memLockWnd.Lines.Add(Format('Operation #%d done.', [memLockWnd.Lines.Count]));
end;

procedure TfrmNonVisualCompDemo.PerformLock(Sender: TObject);
begin
  memLockWnd.Lines.Clear;
  memLockWnd.Lines.Add('Starting Window Lock');
  lwmDemo.AddLock;
  try
    tmrLockWindow.Enabled := True;
    while memLockWnd.Lines.Count < 6 do
      Application.ProcessMessages;
  finally
    lwmDemo.RemoveLock;
  end;
  while memLockWnd.Lines.Count < 10 do
    Application.ProcessMessages;
  tmrLockWindow.Enabled := False;
end;
{$ENDREGION}

{$REGION 'TPlMenuFromFolder demo'}
procedure TfrmNonVisualCompDemo.AllowAutoUpdateMenu(Sender: TObject);
begin
  mffDemo.AutoUpdate := chkAutoUpdateMenu.Checked;
end;

procedure TfrmNonVisualCompDemo.AllowSubfoldersInMenu(Sender: TObject);
begin
  mffDemo.WatchSubTree := chkSearchForSubfolders.Checked;
end;

procedure TfrmNonVisualCompDemo.NewMenuFromFolder(Sender: TObject);
begin
  mffDemo.FolderName := douMenuFromFolder.Directory;
end;

procedure TfrmNonVisualCompDemo.ShowLastMenuSelection(Sender: TObject);
begin
  lblLastMenuItemSelectd.Caption := 'Last selection: ' + mffDemo.Value;
end;

{$ENDREGION}

{$REGION 'TPlRecentFilesComponent Demo'}

procedure TfrmNonVisualCompDemo.ClearRecentFilesList(Sender: TObject);
begin
  rfcDemo.Clear;
end;

procedure TfrmNonVisualCompDemo.LoadTextFile(Sender: TObject);
begin
  memTest.Lines.LoadFromFile(flbRecent.FileName);
  rfcDemo.RegisterFile(flbRecent.FileName)
end;

procedure TfrmNonVisualCompDemo.PurgeRecentFilesList(Sender: TObject);
begin
  rfcDemo.Purge;
end;

procedure TfrmNonVisualCompDemo.ReloadSelected(Sender: TObject; AFileName:
    string);
begin
  memTest.Lines.LoadFromFile(AFileName);
end;

{$ENDREGION}

{$REGION 'TPlRuntimeDesigner Demo'}
procedure TfrmNonVisualCompDemo.EndRuntimeDesign(Sender: TObject);
begin
  rtdDemo.Active := False;
  mitDesignerStart.Enabled := True;
  mitDesignerEnd.Enabled := False;
end;

procedure TfrmNonVisualCompDemo.LoadPositions(Sender: TObject);
begin
  rtdDemo.LoadData;
end;

procedure TfrmNonVisualCompDemo.SavePositionsData(Sender: TObject);
begin
  rtdDemo.SaveData;
end;

procedure TfrmNonVisualCompDemo.StartRuntimeDesign(Sender: TObject);
begin
  rtdDemo.Active := True;
  mitDesignerStart.Enabled := False;
  mitDesignerEnd.Enabled := True;
end;

{$ENDREGION}

{$REGION 'TPlStylesMenuManager demo'}

procedure TfrmNonVisualCompDemo.SwitchStylePreview(Sender: TObject);
begin
  smmDemo.StylePreview := chkStylePreview.Checked;
end;
{$ENDREGION}

{$REGION 'Generic code'}
procedure TfrmNonVisualCompDemo.ExitApplication(Sender: TObject);
begin
  Close;
end;

procedure TfrmNonVisualCompDemo.FormCreate(Sender: TObject);
var
  baseFolder: string;
begin
  {Data folders}
  baseFolder := TPath.GetPublicPath + '\morandotti.it\PlcVCLNonVisualcomponentsDemo\';
  ForceDirectories(baseFolder);
  FIniFolder := baseFolder + 'ini\';
//  FLanguagesFolder := baseFolder + 'Languages\';
  FLanguagesFolder := TPath.GetFullPath('..\..\Languages\');
  ForceDirectories(FIniFolder);
  ForceDirectories(FLanguagesFolder);
  {TPlMenuFromFolder Example: components setup}
  douMenuFromFolder.Drive := 'C';
  {TplRecentFilesComponent Example: components setup}
  rfcDemo.IniFile := GetIniName;
  flbRecent.Directory := '..\\..\\resources';
  flbRecent.Mask := '*.txt';
  {TplRecentFilesComponent Example: components setup}
  rtdDemo.IniName := GetIniName;
  {TPlLanguage Demo: component setup}
  TPlLanguageServer.FileFormat := lpIni;
  TPlLanguageServer.LanguagesFolder := FLanguagesFolder;
  mffLanguage.FolderName := FLanguagesFolder;
end;

procedure TfrmNonVisualCompDemo.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y:
    Integer);
begin
  lblCursorPosition.Caption := Format('%s: %d, %d', [lngDemo.Translate(SCursorPosition), X, Y]);
end;

function TfrmNonVisualCompDemo.GetIniName: string;
begin
  Result := FIniFolder + 'VCLNonVisualComponentsDemo.ini';
end;


{$ENDREGION}

end.

unit PlLanguage;

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

{ *************************************************************
  /// Project: PlComponents
  /// Unit: PlLanguage
  /// This unit contains:
  /// - TPlLanguage: a component to change at runtime the
  ///   language of an application.
 ************************************************************* }

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils,
  PlLanguageTypes, PlLanguageEncoder, PlTranslationStore;

type

  TPlLanguage = class(TComponent)
  private
    FAfterLoad: TPlAfterLoadLanguageEvent;
    FAfterSave: TPlAfterSaveLanguageEvent;
    FBeforeLoad: TPlBeforeLoadLanguageEvent;
    FBeforeSave: TPlBeforeSaveLanguageEvent;
    FContainer: TComponent;
    FCreateIfMissing: Boolean;
    FEngine: IPlLanguageEngine;
    FExcludeClasses: TStrings;
    FExcludeOnAction: Boolean;
    FExcludeProperties: TStrings;
    FFileFormat: TPlLanguagePersistence;
    FLangFile: string;
    FLangPath: string;
    FLanguage: string;
    FLanguageInfo: TPlLanguageInfo;
    FOnLanguageError: TPlOnLanguageError;
    FRegisterOnStart: Boolean;
    FStore: IPlTranslationStore;

    procedure CalculateLangFile;
    procedure CreateEngine;
    function EnsureReady: Boolean;
    function FullName(const APath: string): string;
    function FullPath: string;
    function ReadLangPathFromFileName(const AFileName: string): string;
    procedure SetCreateIfMissing(const Value: Boolean);
    procedure SetExcludeClasses(const Value: TStrings);
    procedure SetExcludeOnAction(const Value: Boolean);
    procedure SetExcludeProperties(const Value: TStrings);
    procedure SetFileFormat(const Value: TPlLanguagePersistence);
    procedure SetLangFile(const Value: string);
    procedure SetLangPath(const Value: string);
    procedure SetLanguage(const Value: string);
    procedure TestPath(const APath: string);
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property LanguageInfo: TPlLanguageInfo read FLanguageInfo write FLanguageInfo;

    procedure LoadLanguage; overload;
    procedure LoadLanguage(AContainer: TComponent); overload;
    procedure LoadLanguage(AContainer: TComponent; AFile: string); overload;

    procedure SaveLanguage; overload;
    procedure SaveLanguage(AContainer: TComponent); overload;
    procedure SaveLanguage(AContainer: TComponent; AFile: string); overload;

    function Translate(const AString: string): string;
  published
    /// <summary>Called after a language file has been loaded.</summary>
    property AfterLoad: TPlAfterLoadLanguageEvent read FAfterLoad write FAfterLoad;

    /// <summary>Called after a language file has been saved.</summary>
    property AfterSave: TPlAfterSaveLanguageEvent read FAfterSave write FAfterSave;

    /// <summary>Called before loading a language file.</summary>
    property BeforeLoad: TPlBeforeLoadLanguageEvent read FBeforeLoad write FBeforeLoad;

    /// <summary>Called before saving a language file.</summary>
    property BeforeSave: TPlBeforeSaveLanguageEvent read FBeforeSave write FBeforeSave;

    /// <summary>If True, missing language files will be created automatically.</summary>
    property CreateIfMissing: Boolean read FCreateIfMissing write SetCreateIfMissing;

    /// <summary>List of component classes excluded from translation.</summary>
    property ExcludeClasses: TStrings read FExcludeClasses write SetExcludeClasses stored True;

    /// <summary>Exclude Action components from translation.</summary>
    property ExcludeOnAction: Boolean read FExcludeOnAction write SetExcludeOnAction;

    /// <summary>List of properties excluded from translation.</summary>
    property ExcludeProperties: TStrings read FExcludeProperties write SetExcludeProperties stored True;

    /// <summary>Persistence format used for language files.</summary>
    property FileFormat: TPlLanguagePersistence read FFileFormat write SetFileFormat;

    /// <summary>Full path of the current language file.</summary>
    property LangFile: string read FLangFile write SetLangFile;

    /// <summary>Base path where language folders are stored.</summary>
    property LangPath: string read FLangPath write SetLangPath;

    /// <summary>Current language identifier.</summary>
    property Language: string read FLanguage write SetLanguage;

    /// <summary>If true, the component register itself in TPLanguageManager</summary>
    property RegisterOnStart: Boolean read FRegisterOnStart write
        FRegisterOnStart;

    /// <summary>Called when a non-fatal language error occurs.</summary>
    property OnLanguageError: TPlOnLanguageError read FOnLanguageError write
        FOnLanguageError;
  end;

implementation

uses
  System.StrUtils,
  PlLanguageServer, PlLanguageEngineFactory;

{$REGION 'TPlLanguage'}

constructor TPlLanguage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FContainer := AOwner;
  FRegisterOnStart := True;
  FStore := TPlTranslationStore.Create;

  FExcludeClasses := TStringList.Create(dupIgnore, True, False);
//  FExcludeClasses.Add('TPlLanguage');
//  FExcludeClasses.Add('TPlMenuFromFolder');
//  FExcludeClasses.Add('TPlRecentFilesComponent');
//  FExcludeClasses.Add('TPlStylesMenuManager');
//  FExcludeClasses.Add('TImageList');

  FExcludeProperties := TStringList.Create(dupIgnore, True, False);
//  FExcludeProperties.Add('Category');
//  FExcludeProperties.Add('HelpFile');
//  FExcludeProperties.Add('HelpKeyword');
//  FExcludeProperties.Add('ImageName');
//  FExcludeProperties.Add('ImeName');
//  FExcludeProperties.Add('Name');
//  FExcludeProperties.Add('DefaultDir');
//  FExcludeProperties.Add('FileName');
//  FExcludeProperties.Add('LangFile');
//  FExcludeProperties.Add('LangPath');
//  FExcludeProperties.Add('Language');
//  FExcludeProperties.Add('PrioritySchedule');
//  FExcludeProperties.Add('StyleName');

  FExcludeOnAction := True;
  FFileFormat := lpIni;

  CreateEngine;
end;

destructor TPlLanguage.Destroy;
begin
  TPlLanguageServer.UnregisterClient(Self);
  FEngine := nil;
  FExcludeClasses.Free;
  FExcludeProperties.Free;
  inherited;
end;

procedure TPlLanguage.CalculateLangFile;
var
  newName: string;
  newPath: string;
begin
  if (FLanguage <> '') and (FLangPath <> '') then
    begin
      newPath := FullPath;
      newName := FullName(newPath);
      SetLangFile(newName);
    end;
end;

procedure TPlLanguage.CreateEngine;
begin
  try
    FEngine := TPlLanguageEngineFactory.CreateEngine(FFileFormat);
    FEngine.CreateIfMissing := FCreateIfMissing;
    FEngine.ExcludeOnAction := FExcludeOnAction;
    FEngine.ExcludeClasses.Assign(FExcludeClasses);
    FEngine.ExcludeProperties.Assign(FExcludeProperties);
  except
    FEngine := nil;
  end;
end;

function TPlLanguage.EnsureReady: Boolean;
begin
  if not Assigned(FEngine) then
    CreateEngine;

  Result := Assigned(FEngine) and (FLangFile <> '');
end;

function TPlLanguage.FullName(const APath: string): string;
var
  ext: string;
begin
  ext := IfThen(FFileFormat = lpJson, '.json', '.lng');
  Result := APath + FContainer.Name + ext;
end;

function TPlLanguage.FullPath: string;
var
  newPath: string;
begin
  newPath := IncludeTrailingPathDelimiter(
    IncludeTrailingPathDelimiter(FLangPath) + FLanguage);
  TestPath(newPath);
  Result := newPath;
end;

procedure TPlLanguage.Loaded;
begin
  inherited;
  if FRegisterOnStart then
    TPlLanguageServer.RegisterClient(Self);
  if not Assigned(FEngine) then
    CreateEngine;
  if Assigned(FEngine) then
    begin
      FEngine.ExcludeClasses.Assign(FExcludeClasses);
      FEngine.ExcludeProperties.Assign(FExcludeProperties);
      FEngine.ExcludeOnAction := FExcludeOnAction;
      FEngine.CreateIfMissing := FCreateIfMissing;
    end;
  // Ora è sicuro caricare la lingua
  if (FLangFile <> '') and not (csDesigning in ComponentState) then
    LoadLanguage;
end;

procedure TPlLanguage.LoadLanguage;
begin
  LoadLanguage(FContainer);
end;

procedure TPlLanguage.LoadLanguage(AContainer: TComponent);
begin
  LoadLanguage(AContainer, FLangFile);
end;

procedure TPlLanguage.LoadLanguage(AContainer: TComponent; AFile: string);
var
  allow: Boolean;
begin
  if not EnsureReady then
    Exit;

  allow := True;
  if Assigned(FBeforeLoad) then
    FBeforeLoad(AContainer, AFile, allow);

  if not allow then
    Exit;


  try
    FStore.Clear;
    FEngine.LoadLanguage(AContainer, AFile, FStore);
  except
    on e: EPlLanguageException do
      begin
        if Assigned(FOnLanguageError) then
          FOnLanguageError(Self, e.Message);
        Exit;
      end;
  end;

  if Assigned(FAfterLoad) then
    FAfterLoad(AContainer, AFile);
end;

procedure TPlLanguage.SaveLanguage;
begin
  SaveLanguage(FContainer, FLangFile);
end;

procedure TPlLanguage.SaveLanguage(AContainer: TComponent);
begin
  SaveLanguage(AContainer, FLangFile);
end;

procedure TPlLanguage.SaveLanguage(AContainer: TComponent; AFile: string);
var
  allow: Boolean;
begin
  if FLangFile = '' then
    raise EPlLanguageException.Create(SNoLanguageFileSelected);

  if not EnsureReady then
    Exit;

  allow := True;
  if Assigned(FBeforeSave) then
    FBeforeSave(AContainer, FLangFile, allow);
  if not allow then
    Exit;

  try
    FEngine.SaveLanguage(AContainer, AFile);
  except
    on e: EPlLanguageException do
      begin
        if Assigned(FOnLanguageError) then
          FOnLanguageError(Self, e.Message);
        Exit;
      end;
  end;

  if Assigned(FAfterSave) then
    FAfterSave(AContainer, FLangFile);
end;


procedure TPlLanguage.SetCreateIfMissing(const Value: Boolean);
begin
  if FCreateIfMissing <> Value then
    begin
      FCreateIfMissing := Value;
      if Assigned(FEngine) then
        FEngine.CreateIfMissing := Value;
    end;
end;

procedure TPlLanguage.SetExcludeClasses(const Value: TStrings);
begin
  FExcludeClasses.Assign(Value);

  if (not (csLoading in ComponentState)) and Assigned(FEngine) then
    FEngine.ExcludeClasses.Assign(FExcludeClasses);
end;

procedure TPlLanguage.SetExcludeOnAction(const Value: Boolean);
begin
  FExcludeOnAction := Value;
  if Assigned(FEngine) then
    FEngine.ExcludeOnAction := Value;
end;

procedure TPlLanguage.SetExcludeProperties(const Value: TStrings);
begin
  FExcludeProperties.Assign(Value);

  if (not (csLoading in ComponentState)) and Assigned(FEngine) then
    FEngine.ExcludeProperties.Assign(Value);
end;

procedure TPlLanguage.SetFileFormat(const Value: TPlLanguagePersistence);
begin
  if FFileFormat <> Value then
    begin
      FFileFormat := Value;
      CreateEngine;
      if not (csLoading in ComponentState) then
        LoadLanguage;
    end;
end;

procedure TPlLanguage.SetLangFile(const Value: string);
begin
  if FLangFile <> Value then
    begin
      FLangFile := Value;
      FLangPath := ReadLangPathFromFileName(Value);
      FLanguage := ExtractFileName(ExcludeTrailingPathDelimiter(ExtractFileDir(Value)));
      if not (csLoading in ComponentState) then
        LoadLanguage;
    end;
end;

function TPlLanguage.ReadLangPathFromFileName(const AFileName: string): string;
var
  tempPath: string;
begin
  tempPath := ExcludeTrailingPathDelimiter(ExtractFilePath(AFileName));
  if tempPath.EndsWith(PathDelim + FLanguage) then
    tempPath := tempPath.Substring(0, tempPath.LastIndexOf(PathDelim) + 1);
  Result := tempPath;
end;

procedure TPlLanguage.SetLangPath(const Value: string);
begin
  if FLangPath <> Value then
    begin
      FLangPath := Value;
      if FLangPath <> '' then
        CalculateLangFile;
    end;
end;

procedure TPlLanguage.SetLanguage(const Value: string);
begin
  if Value = '' then
    raise EPlLanguageException.Create(SLanguagePropertyCannotBeEmpty);

  if FLanguage <> Value then
    begin
      FLanguage := Value;
      CalculateLangFile;
    end;
end;

procedure TPlLanguage.TestPath(const APath: string);
begin
  if not DirectoryExists(APath) then
    if not ForceDirectories(APath) then
      raise EPlLanguageException.Create(Format(SCanTCreatePath, [APath]));
end;

function TPlLanguage.Translate(const AString: string): string;
begin
  if FStore.TryGetValue(AString, Result) then
    Exit;

  Result := TPlLanguageServer.Translate(AString);
end;

{$ENDREGION}

end.


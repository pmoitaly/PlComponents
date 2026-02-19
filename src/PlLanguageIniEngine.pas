unit PlLanguageIniEngine;

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
 /// Unit: PlLanguageIniEngine
 /// This unit contains:
 /// - TPlLanguageCustomIniEngine: an abstract ini based engine
 /// - TPlLanguageIniEngine: the implementation of an ini based engine
 /// - TPlLanguageIniFlatEngine: the implementation of an ini based engine
 ************************************************************* }

interface

uses
  System.Classes, System.IniFiles,
  PlLanguageTypes, PlLanguageEncoder, PlLanguageEngine, PlLanguageInfoIniLoader;

type

  /// <summary>
  /// Base INI persistence engine for TPlLanguage.
  /// Implements common logic for hierarchical and flat INI formats.
  /// </summary>
  TPlLanguageCustomIniEngine = class(TPlLanguageEngine)
  private const
    SECTION_NAME = 'UIElements';
  private
    procedure WriteComponentData(LangIni: TMemIniFile; AComponent: TComponent);
    procedure LoadStringsSection(AIni: TMemIniFile;
      AStore: IPlTranslationStore);
  protected
    /// <summary>
    /// Creates am instance of the mtadata loader.
    /// </summary>
    function CreateInfoLoader: IPlLanguageInfoLoader; override;

    /// <summary>
    /// Resolves a fully-qualified component name (Parent.Child.SubChild).
    /// </summary>
    function FindQualifiedComponent(Source: TComponent; const AName: string)
      : TComponent;

    /// <summary>
    /// Returns the qualified name of a component, walking up the Parent chain.
    /// </summary>
    function QualifiedName(AComponent: TComponent): string;

    /// <summary>
    /// Reads and applies translations for a component section.
    /// </summary>
    procedure ReadSectionData(LangIni: TMemIniFile; AForm: TComponent;
      const AName: string);

    /// <summary>
    /// Writes a property value to the INI file using explicit component name.
    /// </summary>
    procedure WritePropertyValue(AIniFile: TMemIniFile;
      const AComponentName, AName, AValue: string); overload;

    /// <summary>
    /// Writes a property value to the INI file using the component instance.
    /// </summary>
    procedure WritePropertyValue(AIniFile: TMemIniFile; AComponent: TComponent;
      const AName, AValue: string); overload;
  public
    /// <summary>
    /// Loads translations from an INI file and applies them to components.
    /// </summary>
    procedure LoadTranslation(ASource: TComponent; const AFile: string; AStore:
        IPlTranslationStore = nil); override;


    /// <summary>
    /// Saves translatable properties of components to an INI file.
    /// </summary>
    procedure SaveTranslation(ASource: TComponent;
      const AFile: string); override;
  end;

  /// <summary>
  /// Flat-style INI engine (single section).
  /// </summary>
  TPlLanguageIniFlatEngine = class(TPlLanguageCustomIniEngine)
  public
    constructor Create; override;
  end;

  /// <summary>
  /// Hierarchical INI engine (one section per component).
  /// </summary>
  TPlLanguageIniEngine = class(TPlLanguageCustomIniEngine)
  public
    constructor Create; override;
  end;

implementation

uses
  System.SysUtils, System.RTTI,
  Vcl.Controls, Vcl.Forms,
  PlLanguageEngineFactory;

{$REGION 'TPlLanguageCustomIniEngine'}

function TPlLanguageCustomIniEngine.CreateInfoLoader: IPlLanguageInfoLoader;
begin
  Result := TPlLanguageInfoIniLoader.Create;
end;

function TPlLanguageCustomIniEngine.FindQualifiedComponent(Source: TComponent;
  const AName: string): TComponent;
var
  name: string;
  names: TArray<string>;
begin
  Result := Source;
  names := AName.Split(['.']);
  try
    for name in names do
      begin
        Result := Result.FindComponent(name);
        if not Assigned(Result) then
          begin
            Result := Source.FindComponent(names[High(names)]);
            Exit;
          end;
      end;
  except
    Result := nil;
  end;
end;

procedure TPlLanguageCustomIniEngine.LoadTranslation(
  ASource: TComponent;
  const AFile: string;
  AStore: IPlTranslationStore
);
var
  i: Integer;
  ini: TMemIniFile;
  sections: TStringList;
begin
  ini := TMemIniFile.Create(AFile, TEncoding.UTF8);
  try
    sections := TStringList.Create;
    try
      ini.ReadSections(sections);

      for i := 0 to sections.Count - 1 do
      begin
        if SameText(sections[i], 'strings') then
        begin
          if Assigned(AStore) then
            LoadStringsSection(ini, AStore);
        end
        else if Assigned(ASource) then
          ReadSectionData(ini, ASource, sections[i]);
      end;

    finally
      sections.Free;
    end;
  finally
    ini.Free;
  end;
end;

procedure TPlLanguageCustomIniEngine.LoadStringsSection(
  AIni: TMemIniFile;
  AStore: IPlTranslationStore
);
var
  keys: TStringList;
  i: Integer;
  key: string;
  value: string;
begin
  keys := TStringList.Create;
  try
    AIni.ReadSection('strings', keys);

    for i := 0 to keys.Count - 1 do
    begin
      key := keys[i];
      value := TPlLineEncoder.RestoreMultiline(
        AIni.ReadString('strings', key, '')
      );

      AStore.AddOrSetEncoded(key, value);
    end;
  finally
    keys.Free;
  end;
end;


function TPlLanguageCustomIniEngine.QualifiedName
  (AComponent: TComponent): string;
var
  current: TComponent;
begin
  Result := '';
  current := AComponent;

  if not Assigned(current) then
    Exit;

  Result := current.name;

  if current is TControl then
    while Assigned(current) and (current is TControl) and
      not(TControl(current).Parent is TForm) do
      begin
        current := TControl(current).Parent;
        if Assigned(current) then
          Result := current.name + '.' + Result;
      end;
end;

procedure TPlLanguageCustomIniEngine.ReadSectionData(LangIni: TMemIniFile;
  AForm: TComponent; const AName: string);
var
  component: TComponent;
  componentSection: TStringList;
  i: Integer;
begin
  component := FindQualifiedComponent(AForm, AName);
  if not IsEligibleClass(component) then
    Exit;

  componentSection := TStringList.Create;
  try
    LangIni.ReadSectionValues(AName, componentSection);
    for i := 0 to componentSection.Count - 1 do
      SetPropertyValue(component, componentSection.names[i],
        componentSection.ValueFromIndex[i]);
  finally
    componentSection.Free;
  end;
end;

procedure TPlLanguageCustomIniEngine.SaveTranslation(ASource: TComponent;
  const AFile: string);
var
  i: Integer;
  ini: TMemIniFile;
begin
  ini := TMemIniFile.Create(AFile, TEncoding.UTF8);
  try
    for i := ASource.ComponentCount - 1 downto 0 do
      WriteComponentData(ini, ASource.Components[i]);

    ini.UpdateFile;
  finally
    ini.Free;
  end;
end;

procedure TPlLanguageCustomIniEngine.WriteComponentData(LangIni: TMemIniFile;
  AComponent: TComponent);
var
  compName: string;
  i: Integer;
  rContext: TRttiContext;
  rProperty: TRttiProperty;
  rType: TRttiType;
begin
  if not IsEligibleClass(AComponent) then
    Exit;

  compName := QualifiedName(AComponent);
  if compName = '' then
    Exit;

  rType := rContext.GetType(AComponent.ClassType);
  for rProperty in rType.GetProperties do
    if IsTranslatableProperty(rProperty) and ShouldTranslateProperty(rProperty,
      AComponent) then
      WritePropertyValue(LangIni, compName, rProperty.name,
        rProperty.GetValue(AComponent).AsString);

  for i := AComponent.ComponentCount - 1 downto 0 do
    //     if ShouldTranslateProperty(nil, AComponent.Components[i]) then
    WriteComponentData(LangIni, AComponent.Components[i]);
end;

procedure TPlLanguageCustomIniEngine.WritePropertyValue(AIniFile: TMemIniFile;
  const AComponentName, AName, AValue: string);
var
  actualSection: string;
  actualValue: string;
begin
  actualValue := TPlLineEncoder.JoinMultiline(AValue);
  if actualValue = '-' then
    Exit;

  case FFileStyle of
    lpIniFlat:
      actualSection := SECTION_NAME;
    else
      actualSection := AComponentName;
  end;

  AIniFile.WriteString(actualSection, AName, actualValue);
end;

procedure TPlLanguageCustomIniEngine.WritePropertyValue(AIniFile: TMemIniFile;
  AComponent: TComponent; const AName, AValue: string);
begin
  WritePropertyValue(AIniFile, AComponent.name, AName, AValue);
end;

{$ENDREGION}
{$REGION 'TPlLanguageIniFlatEngine'}

constructor TPlLanguageIniFlatEngine.Create;
begin
  inherited;
  FFileStyle := lpIniFlat;
end;

{$ENDREGION}
{$REGION 'TPlLanguageIniEngine'}

constructor TPlLanguageIniEngine.Create;
begin
  inherited;
  FFileStyle := lpIni;
end;

{$ENDREGION}

initialization

TPlLanguageEngineFactory.Register(lpIni, TPlLanguageIniEngine);
TPlLanguageEngineFactory.Register(lpIniFlat, TPlLanguageIniFlatEngine);

finalization

TPlLanguageEngineFactory.Unregister(lpIni);
TPlLanguageEngineFactory.Unregister(lpIniFlat);

end.

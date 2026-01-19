unit PlLanguageEngine;

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
 /// - TPlLanguageEngine: an abstract engine to load and save
 ///  text to and from an User Interface
 ************************************************************* }

interface

uses
  System.Classes, System.RTTI, System.TypInfo, System.Generics.Collections,
  PlLanguageTypes, plLanguageEncoder;

type

  /// <summary>
  /// Base class for all language persistence engines.
  /// </summary>
  /// <remarks>
  /// TPlLanguageEngine provides the common infrastructure for loading,
  /// saving and translating localized strings using RTTI inspection.
  ///
  /// Concrete engines (INI, JSON, etc.) must inherit from this class and
  /// implement LoadTranslation and SaveTranslation.
  ///
  /// The class deliberately separates:
  /// - structural eligibility of a property (IsTranslatableProperty)
  /// - contextual translation decision (ShouldTranslateProperty)
  ///
  /// to allow fine-grained control and safe extensibility.
  /// </remarks>
  TPlLanguageEngine = class(TInterfacedObject, IPlLanguageEngine)
  private
    FCreateIfMissing: Boolean;
    FExcludeClasses: TStrings;
    FExcludeOnAction: Boolean;
    FExcludeProperties: TStrings;
    function GetCreateIfMissing: Boolean;
    function GetExcludeClasses: TStrings;
    function GetExcludeOnAction: Boolean;
    function GetExcludeProperties: TStrings;
    procedure SetCreateIfMissing(const Value: Boolean);
    procedure SetExcludeClasses(const Value: TStrings);
    procedure SetExcludeOnAction(const Value: Boolean);
    procedure SetExcludeProperties(const Value: TStrings);
  protected
    /// <summary>
    /// RTTI context shared by the engine during its lifetime.
    /// </summary>
    FContext: TRTTIContext;
    /// <summary>
    /// Persistence format handled by the concrete engine.
    /// </summary>
    FFileStyle: TPlLanguagePersistence;
    /// <summary>
    /// Internal dictionary used for runtime string translation.
    /// </summary>
    FTranslationsDict: TDictionary<string, string>;
    /// <summary>
    /// Returns True if the source object is associated with an Action.
    /// </summary>
    function HasAction(ASource: TObject): Boolean;
    /// <summary>
    /// Determines whether a component instance is eligible for translation.
    /// </summary>
    /// <remarks>
    /// Eligibility is based on class exclusion rules and, optionally,
    /// on Action association when ExcludeOnAction is enabled.
    /// </remarks>
    function IsEligibleClass(AnElement: TPersistent): Boolean;
    /// <summary>
    /// Determines whether a property is structurally eligible for translation.
    /// </summary>
    /// <remarks>
    /// This method checks only intrinsic property characteristics:
    /// - published visibility
    /// - readable and writable
    /// - string-compatible type
    ///
    /// It does NOT consider runtime context, exclusions or actions.
    /// </remarks>
    function IsTranslatableProperty(AProperty: TRttiProperty): Boolean;
    /// <summary>
    /// Checks whether the language file exists and optionally creates it.
    /// </summary>
    /// <remarks>
    /// If CreateIfMissing is True, missing directories and files
    /// are created automatically by invoking SaveLanguage.
    /// </remarks>
    function LanguageFileExists(ASource: TComponent;
      const AFile: string): Boolean;
    /// <summary>
    /// Loads translations from a persistence-specific file.
    /// </summary>
    /// <remarks>
    /// This method must be implemented by concrete engines.
    /// It should populate component properties and runtime dictionaries.
    /// </remarks>
    procedure LoadTranslation(ASource: TComponent; const AFile: string);
      virtual; abstract;
    /// <summary>
    /// Saves translations to a persistence-specific file.
    /// </summary>
    /// <remarks>
    /// This method must be implemented by concrete engines.
    /// It should extract translatable properties and persist them.
    /// </remarks>
    procedure SaveTranslation(ASource: TComponent; const AFile: string);
      virtual; abstract;
    /// <summary>
    /// Assigns a translated value to a component property using RTTI.
    /// </summary>
    procedure SetPropertyValue(AComponent: TComponent;
      const AProp, AValue: string);
    /// <summary>
    /// Determines whether a property should actually be translated in context.
    /// </summary>
    /// <remarks>
    /// This method applies higher-level rules such as:
    /// - ExcludeProperties
    /// - ExcludeOnAction
    /// - Action precedence over Caption/Hint
    ///
    /// It is evaluated only after IsTranslatableProperty returns True.
    /// </remarks>
    function ShouldTranslateProperty(AProperty: TRttiProperty;
      ASource: TObject): Boolean;
  public
    /// <summary>
    /// Creates the language engine and initializes default filters.
    /// </summary>
    constructor Create; virtual;
    /// <summary>
    /// Destroys the engine and releases all internal resources.
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    /// Loads language data into the specified component container.
    /// </summary>
    procedure LoadLanguage(ASource: TComponent; const AFile: string); virtual;
    /// <summary>
    /// Saves language data from the specified component container.
    /// </summary>
    procedure SaveLanguage(ASource: TComponent; const AFile: string); virtual;
    /// <summary>
    /// Translates a runtime string using the internal dictionary.
    /// </summary>
    /// <remarks>
    /// If no translation is found, the original string is returned.
    /// This method never raises exceptions.
    /// </remarks>
    function Translate(const AString: string): string;
    /// <summary>
    /// Enables automatic creation of missing language files and folders.
    /// </summary>
  public
    property CreateIfMissing: Boolean read GetCreateIfMissing
      write SetCreateIfMissing;
    /// <summary>
    /// List of component class names excluded from translation.
    /// </summary>
    property ExcludeClasses: TStrings read FExcludeClasses
      write SetExcludeClasses;
    /// <summary>
    /// When True, properties managed by Actions are not translated.
    /// </summary>
    property ExcludeOnAction: Boolean read GetExcludeOnAction
      write SetExcludeOnAction;
    /// <summary>
    /// List of property names that must never be translated.
    /// </summary>
    property ExcludeProperties: TStrings read FExcludeProperties
      write SetExcludeProperties;
  end;

implementation

uses
  System.SysUtils, System.StrUtils,
  Vcl.Forms;

{$REGION 'TPlLanguageEngine'}

constructor TPlLanguageEngine.Create;
begin
  inherited;

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
//  FExcludeProperties.Add('StyleName');

  FExcludeClasses := TStringList.Create(dupIgnore, True, False);
//  FExcludeClasses.Add(Self.ClassName);

  FTranslationsDict := TDictionary<string, string>.Create;
  FContext := TRTTIContext.Create;
end;

destructor TPlLanguageEngine.Destroy;
begin
  FTranslationsDict.Free;
  FExcludeClasses.Free;
  FExcludeProperties.Free;
  FContext.Free;
  inherited;
end;

function TPlLanguageEngine.IsTranslatableProperty
  (AProperty: TRttiProperty): Boolean;
const
  STRING_TYPE = [tkUString, tkWString, tkLString, tkString];
begin
  Result := Assigned(AProperty) and AProperty.IsReadable and
    AProperty.IsWritable and (AProperty.Visibility = mvPublished) and
    (AProperty.PropertyType.TypeKind in STRING_TYPE) and
    (AProperty.Name <> 'Name');
end;

function TPlLanguageEngine.ShouldTranslateProperty(AProperty: TRttiProperty;
  ASource: TObject): Boolean;
var
  propertyName: string;
begin
  propertyName := IfThen(Assigned(Aproperty), AProperty.Name, '');
  Result := IsTranslatableProperty(AProperty) and
    (FExcludeProperties.IndexOf(propertyName) = -1)  and
    (propertyName <> 'Name') and
    not(FExcludeOnAction and HasAction(ASource) and
    ((propertyName = 'Caption') or (propertyName = 'Hint')));
end;

function TPlLanguageEngine.IsEligibleClass(AnElement: TPersistent): Boolean;
begin
  Result := Assigned(AnElement) and
    (FExcludeClasses.IndexOf(AnElement.ClassName) = -1);
end;

function TPlLanguageEngine.HasAction(ASource: TObject): Boolean;
var
  action: TObject;
  rProperty: TRttiProperty;
begin
  Result := False;
  if not Assigned(ASource) then
    Exit;

  action := nil;
  rProperty := FContext.GetType(ASource.ClassInfo).GetProperty('Action');
  if Assigned(rProperty) then
    action := rProperty.GetValue(ASource).AsObject;
  Result := Assigned(action);
end;

function TPlLanguageEngine.LanguageFileExists(ASource: TComponent;
  const AFile: string): Boolean;
var
  fileDir: string;
begin
  fileDir := ExtractFileDir(AFile);

  if not DirectoryExists(fileDir) and FCreateIfMissing then
    ForceDirectories(fileDir);

  Result := FileExists(AFile);

  if (not Result) and FCreateIfMissing then
    begin
      SaveLanguage(ASource, AFile);
      Result := True;
    end;
end;

procedure TPlLanguageEngine.LoadLanguage(ASource: TComponent;
  const AFile: string);
begin
  if not LanguageFileExists(ASource, AFile) then
    Exit;

  LoadTranslation(ASource, AFile);
end;

procedure TPlLanguageEngine.SaveLanguage(ASource: TComponent;
  const AFile: string);
var
  fileDir: string;
begin
  fileDir := ExtractFileDir(AFile);

  if not DirectoryExists(fileDir) and FCreateIfMissing then
    ForceDirectories(fileDir);

  SaveTranslation(ASource, AFile);
end;

procedure TPlLanguageEngine.SetPropertyValue(AComponent: TComponent;
  const AProp, AValue: string);
var
  rProperty: TRttiProperty;
begin
  if not Assigned(AComponent) then
    Exit;

  rProperty := FContext.GetType(AComponent.ClassInfo).GetProperty(AProp);

  if Assigned(rProperty) and ShouldTranslateProperty(rProperty, AComponent) then
    rProperty.SetValue(AComponent, TPlLineEncoder.RestoreMultiline(AValue));
end;

function TPlLanguageEngine.Translate(const AString: string): string;
var
  normalizedString: string;
begin
  normalizedString := TPlLineEncoder.MakeKey(AString);

  if FTranslationsDict.ContainsKey(normalizedString) then
    Result := TPlLineEncoder.RestoreMultiline
      (FTranslationsDict[normalizedString])
  else
    Result := AString;
end;

function TPlLanguageEngine.GetCreateIfMissing: Boolean;
begin
  Result := FCreateIfMissing;
end;

function TPlLanguageEngine.GetExcludeClasses: TStrings;
begin
  Result := FExcludeClasses;
end;

function TPlLanguageEngine.GetExcludeOnAction: Boolean;
begin
  Result := FExcludeOnAction;
end;

function TPlLanguageEngine.GetExcludeProperties: TStrings;
begin
  Result := FExcludeProperties;
end;

procedure TPlLanguageEngine.SetCreateIfMissing(const Value: Boolean);
begin
  FCreateIfMissing := Value;
end;

procedure TPlLanguageEngine.SetExcludeClasses(const Value: TStrings);
begin
  FExcludeClasses.Assign(Value);
end;

procedure TPlLanguageEngine.SetExcludeOnAction(const Value: Boolean);
begin
  FExcludeOnAction := Value;
end;

procedure TPlLanguageEngine.SetExcludeProperties(const Value: TStrings);
begin
  FExcludeProperties.Assign(Value);
end;

{$ENDREGION}

end.

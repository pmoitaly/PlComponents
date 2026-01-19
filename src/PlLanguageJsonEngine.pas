unit PlLanguageJsonEngine;

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
 /// - TPlLanguageJSONEngine: an engine to load and save
 ///  text to and from an User using Json local files.
 ************************************************************* }

interface

uses
  System.Classes, System.JSON, System.RTTI,
  PlLanguageTypes, PlLanguageEncoder, PlLanguageEngine;

type
  /// <summary>
  /// JSON-based persistence engine for TPlLanguage.
  /// Serializes and deserializes translatable properties using RTTI.
  /// </summary>
  TPlLanguageJsonEngine = class(TPlLanguageEngine)
  private
    /// <summary>
    /// Recursively applies JSON translations to a component or object instance.
    /// </summary>
    procedure TranslateObject(AJson: TJSONObject; ATarget: TObject);
  protected
    /// <summary>
    /// Serializes a component and its subcomponents into a JSON structure.
    /// </summary>
    procedure ComponentToJson(ASource: TComponent; AStructure: TJSONObject);

    /// <summary>
    /// Recursively serializes an object into a JSON object using RTTI.
    /// </summary>
    procedure SerializeObject(ASource: TObject; AJson: TJSONObject);

    /// <summary>
    /// Loads runtime translation strings into the internal dictionary.
    /// </summary>
    procedure LoadTranslationsToDict(ASource: TJSONObject);
  public
    /// <summary>
    /// Creates the JSON language engine.
    /// </summary>
    constructor Create; override;

    /// <summary>
    /// Loads translations from a JSON language file and applies them to components.
    /// </summary>
    procedure LoadTranslation(ASource: TComponent;
      const AFile: string); override;

    /// <summary>
    /// Saves translatable properties of components to a JSON language file.
    /// </summary>
    procedure SaveTranslation(ASource: TComponent;
      const AFile: string); override;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.TypInfo,
  Vcl.Graphics,
  PlLanguageEngineFactory;

{$REGION 'TPlLanguageJsonEngine'}

constructor TPlLanguageJsonEngine.Create;
begin
  inherited;
  FFileStyle := lpJson;
end;

procedure TPlLanguageJsonEngine.ComponentToJson(ASource: TComponent;
  AStructure: TJSONObject);
var
  componentJson: TJSONObject;
  i: Integer;
begin
  if not IsEligibleClass(ASource) then
    Exit;

  componentJson := TJSONObject.Create;
  SerializeObject(ASource, componentJson);

  if componentJson.Count > 0 then
    AStructure.AddPair(ASource.Name, componentJson)
  else
    componentJson.Free;

  for i := 0 to ASource.ComponentCount - 1 do
    if ASource.Components[i].Name <> '' then
      ComponentToJson(ASource.Components[i], AStructure);
end;

procedure TPlLanguageJsonEngine.SerializeObject(ASource: TObject;
  AJson: TJSONObject);
var
  rType: TRttiType;
  rProperty: TRttiProperty;
  rValue: TValue;
  subJson: TJSONObject;
  lStrings: TStrings;
  sConcat: string;
  i: Integer;
begin
  if not Assigned(ASource) then
    Exit;

  rType := FContext.GetType(ASource.ClassType);

  for rProperty in rType.GetProperties do
    begin
      if not IsTranslatableProperty(rProperty) then
        Continue;

      // Explicitly ignore TFont
      if rProperty.PropertyType.Handle = TypeInfo(TFont) then
        Continue;

      rValue := rProperty.GetValue(ASource);

      // TStrings handling
      if rValue.IsObject and (rValue.AsObject is TStrings) then
        begin
          lStrings := TStrings(rValue.AsObject);
          sConcat := '';
          for i := 0 to lStrings.Count - 1 do
            sConcat := sConcat + lStrings[i] + '§';
          if sConcat <> '' then
            Delete(sConcat, Length(sConcat), 1);

          subJson := TJSONObject.Create;
          subJson.AddPair('Text', sConcat);
          AJson.AddPair(rProperty.Name, subJson);
        end
      // Nested object
      else if rValue.IsObject then
        begin
          subJson := TJSONObject.Create;
          SerializeObject(rValue.AsObject, subJson);
          if subJson.Count > 0 then
            AJson.AddPair(rProperty.Name, subJson)
          else
            subJson.Free;
        end
      // Plain string property
      else
        begin
          AJson.AddPair(rProperty.Name,
            TJSONString.Create(rValue.ToString));
        end;
    end;
end;

procedure TPlLanguageJsonEngine.LoadTranslation(ASource: TComponent;
  const AFile: string);
var
  jsonString: string;
  jsonRoot: TJSONObject;
begin
  jsonString := TFile.ReadAllText(AFile);
  jsonRoot := TJSONObject.ParseJSONValue(jsonString) as TJSONObject;
  try
    LoadTranslationsToDict(jsonRoot);
    TranslateObject(jsonRoot, ASource);
  finally
    jsonRoot.Free;
  end;
end;

procedure TPlLanguageJsonEngine.LoadTranslationsToDict(ASource: TJSONObject);
var
  jStrings: TJSONValue;
  jPair: TJSONPair;
begin
  jStrings := ASource.Values['Strings'];
  if not Assigned(jStrings) or not (jStrings is TJSONObject) then
    Exit;

  FTranslationsDict.Clear;
  for jPair in TJSONObject(jStrings) do
    FTranslationsDict.AddOrSetValue(jPair.JSONString.Value,
      jPair.JSONValue.Value);
end;

procedure TPlLanguageJsonEngine.TranslateObject(AJson: TJSONObject;
  ATarget: TObject);
var
  jPair: TJSONPair;
  rType: TRttiType;
  rProperty: TRttiProperty;
  subObject: TObject;
  subJson: TJSONObject;
  subValue: TJSONValue;
begin
  if not Assigned(ATarget) then
    Exit;

  rType := FContext.GetType(ATarget.ClassType);

  for jPair in AJson do
    begin
      rProperty := rType.GetProperty(jPair.JSONString.Value);
      if not Assigned(rProperty) then
        Continue;

      if rProperty.PropertyType.Handle = TypeInfo(TFont) then
        Continue;

      // TStrings handling
      if rProperty.PropertyType.IsInstance and
        (rProperty.PropertyType.Handle = TypeInfo(TStrings)) then
        begin
          subJson := jPair.JSONValue as TJSONObject;
          subValue := subJson.Values['Text'];
          if Assigned(subValue) then
            TStrings(rProperty.GetValue(ATarget).AsObject).Text :=
              StringReplace(subValue.Value, '§', sLineBreak,
                [rfReplaceAll]);
          Continue;
        end;

      // Plain string or eligible property
      if ShouldTranslateProperty(rProperty, ATarget) then
        begin
          rProperty.SetValue(ATarget,
            TPlLineEncoder.RestoreMultiline(jPair.JSONValue.Value));
        end
      // Nested object
      else if rProperty.PropertyType.IsInstance then
        begin
          subObject := rProperty.GetValue(ATarget).AsObject;
          if Assigned(subObject) and (jPair.JSONValue is TJSONObject) then
            TranslateObject(TJSONObject(jPair.JSONValue), subObject);
        end;
    end;
end;

procedure TPlLanguageJsonEngine.SaveTranslation(ASource: TComponent;
  const AFile: string);
var
  jsonRoot: TJSONObject;
begin
  jsonRoot := TJSONObject.Create;
  try
    ComponentToJson(ASource, jsonRoot);
    if jsonRoot.Count > 0 then
      TFile.WriteAllText(AFile, jsonRoot.ToJSON);
  finally
    jsonRoot.Free;
  end;
end;

{$ENDREGION}

initialization
  TPlLanguageEngineFactory.Register(lpJson, TPlLanguageJsonEngine);

finalization
  TPlLanguageEngineFactory.Unregister(lpJson);

end.


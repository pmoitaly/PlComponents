unit PlLanguageInfoJsonLoader;

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
  /// Unit: PlLanguageInfoJsonLoader
  /// This unit contains:
  /// - TPlLanguageInfoJsonLoader: a class to load metadata
  ///   about the language of an application from a Json file.
 ************************************************************* }

interface

uses
  PlLanguageTypes;

type
  /// <summary>
  /// Loader implementation that reads language information from Json files
  /// and produces a <c>TPlLanguageInfo</c> record.
  /// </summary>
  TPlLanguageInfoJsonLoader = class(TInterfacedObject, IPlLanguageInfoLoader)
  public
    /// <summary>
    /// Loads language metadata from the specified Json file and returns a populated
    /// <c>TPlLanguageInfo</c> instance.
    /// </summary>
    /// <param name="AFile">
    /// Path to the Json file containing the language definition.
    /// </param>
    /// <returns>
    /// A <c>TPlLanguageInfo</c> record filled with the data read from the Json file.
    /// </returns>
    function LoadFromFile(const AFile: string): TPlLanguageInfo;
  end;

implementation

uses
  System.JSON, System.IOUtils;

function TPlLanguageInfoJsonLoader.LoadFromFile(
  const AFile: string): TPlLanguageInfo;
var
  json: TJSONObject;
  lang: TJSONObject;
begin
  FillChar(Result, SizeOf(Result), 0);

  json := TJSONObject.ParseJSONValue(
    TFile.ReadAllText(AFile)) as TJSONObject;
  try
    lang := json.Values['language'] as TJSONObject;
    if not Assigned(lang) then
      Exit;

    Result.Id := lang.GetValue<string>('id', '');
    Result.Name := lang.GetValue<string>('name', '');
    Result.NativeName := lang.GetValue<string>('nativeName', '');
    Result.IsRightToLeft := lang.GetValue<Boolean>('isRightToLeft', False);
    Result.UIFont := lang.GetValue<string>('uiFont', '');
    Result.FallbackFont := lang.GetValue<string>('fallbackFont', '');
  finally
    json.Free;
  end;
end;


end.

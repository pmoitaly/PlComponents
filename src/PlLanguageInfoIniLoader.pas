unit PlLanguageInfoIniLoader;

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
  /// Unit: PlLanguageInfoIniLoader
  /// This unit contains:
  /// - TPlLanguageInfoIniLoader: a class to load metadata
  ///   about the language of an application from an Ini file.
 ************************************************************* }

interface

uses
  PlLanguageTypes;

type
/// <summary>
/// Loader implementation that reads language information from INI files
/// and produces a <c>TPlLanguageInfo</c> record.
/// </summary>
TPlLanguageInfoIniLoader = class(TInterfacedObject, IPlLanguageInfoLoader)
public
  /// <summary>
  /// Loads language metadata from the specified INI file and returns a populated
  /// <c>TPlLanguageInfo</c> instance.
  /// </summary>
  /// <param name="AFile">
  /// Path to the INI file containing the language definition.
  /// </param>
  /// <returns>
  /// A <c>TPlLanguageInfo</c> record filled with the data read from the INI file.
  /// </returns>
  function LoadFromFile(const AFile: string): TPlLanguageInfo;
end;

implementation

uses
  System.IniFiles;

{$REGION 'TPlLanguageInfoIniLoader'}

function TPlLanguageInfoIniLoader.LoadFromFile(
  const AFile: string): TPlLanguageInfo;
var
  ini: TIniFile;
begin
  FillChar(Result, SizeOf(Result), 0);

  ini := TIniFile.Create(AFile);
  try
    Result.Id := ini.ReadString('Language', 'Id', '');
    Result.Name := ini.ReadString('Language', 'Name', '');
    Result.NativeName := ini.ReadString('Language', 'NativeName', '');
    Result.IsRightToLeft := ini.ReadBool('Language', 'IsRightToLeft', False);
    Result.UIFont := ini.ReadString('Language', 'UIFont', '');
    Result.FallbackFont := ini.ReadString('Language', 'FallbackFont', '');
  finally
    ini.Free;
  end;
end;

{$ENDREGION}

end.

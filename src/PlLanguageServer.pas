unit PlLanguageServer;

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
 /// Unit: PlLanguageServer
 /// This unit contains:
 /// - IPlLanguageEngine: the engines interface
 /// - Types of events
 /// - Types to select engines
 /// - Constants
 ************************************************************* }

interface

uses
  System.Classes, System.Generics.Collections,
  plLanguage, plLanguageTypes, plLanguageEncoder;

type

  /// <summary>
  /// Centralized static language server for managing translations and clients.
  /// </summary>
  /// <remarks>
  /// TPlLanguageServer acts as a centralized language manager for an application.

  ///  Key responsibilities:
  ///  - Store and manage the currently selected language and language folder.
  ///  - Propagate language changes automatically to registered TPlLanguage clients.
  ///  - Provide runtime translation lookup from INI files (other formats can be added).
  ///  - Notify non-client modules via a global OnLanguageChanged event.
  ///
  ///  Usage:
  ///  - Register a TPlLanguage client with RegisterClient.
  ///  - Change Language or LanguagesFolder to trigger automatic updates.
  ///  - Use Translate() for runtime string translations.
  ///  - Subscribe to OnLanguageChanged for global notifications.
  ///  - Don't use it if you use different languages in the same application.
  /// </remarks>
  TPlLanguageServer = class
  private
    class var FClients: TList<TPlLanguage>;
    class var FLanguage: string;
    class var FLanguagesFolder: string;
    class var FTranslationsDict: TDictionary<string, string>;
    class var FOnLanguageChanged: TLanguageChangedEvent;
    class function CanSync: Boolean; static;
    class function FindRuntimeTranslation(out Persistence
      : TPlLanguagePersistence; out AFileName: string): Boolean; static;
    class procedure ImportFromIni(AFileName: string); static;
    class procedure ImportRuntimeStrings; static;
    class procedure SynchronizeClient(AClient: TPlLanguage); static;
    class procedure SynchronizeClients; static;
    class procedure DoLanguageChanged; static;
    class procedure SetLanguage(const Value: string); static;
    class procedure SetLanguagesFolder(const Value: string); static;
    class procedure UpdateClients; static;
  public
    /// <summary>
    /// Initializes the server (called automatically once).
    /// </summary>
    class constructor Create;

    /// <summary>
    /// Cleans up resources (called automatically once).
    /// </summary>
    class destructor Destroy;

    /// <summary>
    /// Registers a client component to receive language updates.
    /// Safe against duplicates.
    /// </summary>
    class procedure RegisterClient(AClient: TPlLanguage);

    /// <summary>
    /// Unregisters a client component (should be called in client destructor).
    /// </summary>
    class procedure UnregisterClient(AClient: TPlLanguage);

    /// <summary>
    /// Translates a given string using the current dictionary.
    /// If not found, the original text is returned.
    /// </summary>
    class function TranslateString(const AString: string): string; static;

    /// <summary>
    /// The currently active language identifier (e.g. "en", "it").
    /// </summary>
    class property Language: string read FLanguage write SetLanguage;

    /// <summary>
    /// The folder where translation files are stored.
    /// </summary>
    class property LanguagesFolder: string read FLanguagesFolder
      write SetLanguagesFolder;

    /// <summary>
    /// Global event triggered when the language changes.
    /// Useful for modules that are not TPlLanguage clients.
    /// </summary>
    class property OnLanguageChanged: TLanguageChangedEvent
      read FOnLanguageChanged write FOnLanguageChanged;
  end;

implementation

uses
  System.SysUtils, System.IniFiles;

{$REGION 'TPlLanguageServer'}

class constructor TPlLanguageServer.Create;
begin
  FClients := TList<TPlLanguage>.Create;
  FTranslationsDict := TDictionary<string, string>.Create;
end;

class destructor TPlLanguageServer.Destroy;
begin
  TMonitor.Enter(FClients);
  try
    FClients.Clear;
    FreeAndNil(FTranslationsDict);
  finally
    TMonitor.Exit(FClients);
  end;
  FreeAndNil(FClients);
end;

class function TPlLanguageServer.CanSync: Boolean;
begin
  Result := (FLanguagesFolder <> '') and DirectoryExists(FLanguagesFolder) and
    (FLanguage <> '') and DirectoryExists
    (IncludeTrailingPathDelimiter(FLanguagesFolder) + FLanguage);
end;

class function TPlLanguageServer.FindRuntimeTranslation(out Persistence
  : TPlLanguagePersistence; out AFileName: string): Boolean;
var
  basePath: string;
  fileName: string;
  persistenceType: TPlLanguagePersistence;
begin
  basePath := IncludeTrailingPathDelimiter(FLanguagesFolder) +
    IncludeTrailingPathDelimiter(FLanguage) + RUNTIME_FILE_NAME;

  for persistenceType := Low(TPlLanguagePersistence)
    to High(TPlLanguagePersistence) do
    begin
      fileName := basePath + FILE_EXT[persistenceType];
      if FileExists(fileName) then
        begin
          Result := True;
          Persistence := persistenceType;
          AFileName := fileName;
          Exit;
        end;
    end;
  Result := False;
end;

class procedure TPlLanguageServer.ImportRuntimeStrings;
var
  fileName: string;
  Persistence: TPlLanguagePersistence;
begin
  if not CanSync then
    Exit;

  if FindRuntimeTranslation(Persistence, fileName) then
    case Persistence of
      lpIni, lpIniFlat:
        ImportFromIni(fileName);
      lpJson: { TODO: Implement JSON }
        ;
(*      lpPo: { TODO: Implement PO }
        ;
      lpPot: { TODO: Implement POT }
        ;
      lpXml: { TODO: Implement XML }
        ;
*)
    end;
end;

class procedure TPlLanguageServer.ImportFromIni(AFileName: string);
var
  keys: TStringList;
  i: Integer;
  iniFile: TMemIniFile;
begin
  TMonitor.Enter(FTranslationsDict);
  try
    FTranslationsDict.Clear;
    iniFile := TMemIniFile.Create(AFileName);
    try
      keys := TStringList.Create;
      try
        iniFile.ReadSection('Strings', keys);
        for i := 0 to keys.Count - 1 do
          FTranslationsDict.AddOrSetValue(keys[i], iniFile.ReadString('Strings',
            keys[i], ''));
      finally
        keys.Free;
      end;
    finally
      iniFile.Free;
    end;
  finally
    TMonitor.Exit(FTranslationsDict);
  end;
end;

class procedure TPlLanguageServer.RegisterClient(AClient: TPlLanguage);
begin
  if AClient = nil then
    Exit;

  TMonitor.Enter(FClients);
  try
    if not FClients.Contains(AClient) then
      begin
        FClients.Add(AClient);
        if CanSync then
          SynchronizeClient(AClient);
      end;
  finally
    TMonitor.Exit(FClients);
  end;
end;

class procedure TPlLanguageServer.UnregisterClient(AClient: TPlLanguage);
begin
  if AClient = nil then
    Exit;

  TMonitor.Enter(FClients);
  try
    FClients.Remove(AClient);
  finally
    TMonitor.Exit(FClients);
  end;
end;

class procedure TPlLanguageServer.SetLanguage(const Value: string);
begin
  if Value <> FLanguage then
    begin
      FLanguage := Value;
      UpdateClients;
    end;
end;

class procedure TPlLanguageServer.SetLanguagesFolder(const Value: string);
begin
  if Value <> FLanguagesFolder then
    begin
      FLanguagesFolder := Value;
      UpdateClients;
    end;
end;

class procedure TPlLanguageServer.SynchronizeClient(AClient: TPlLanguage);
begin
  // Each client will handle BeforeChangeLanguage/AfterChangeLanguage internally.
  AClient.Language := FLanguage;
  AClient.LangPath := FLanguagesFolder;
end;

class procedure TPlLanguageServer.SynchronizeClients;
var
  client: TPlLanguage;
begin
  if CanSync then
    begin
      TMonitor.Enter(FClients);
      try
        for client in FClients do
          SynchronizeClient(client);
      finally
        TMonitor.Exit(FClients);
      end;
    end;
end;

class procedure TPlLanguageServer.DoLanguageChanged;
begin
  if Assigned(FOnLanguageChanged) then
    FOnLanguageChanged(FLanguage, FLanguagesFolder);
end;

class function TPlLanguageServer.TranslateString(const AString: string): string;
var
  normalizedString: string;
begin
  normalizedString := TPlLineEncoder.MakeKey(AString);
  TMonitor.Enter(FTranslationsDict);
  try
    if FTranslationsDict.ContainsKey(normalizedString) then
      Result := TPlLineEncoder.RestoreMultiline
        (FTranslationsDict[normalizedString])
    else
      Result := AString; // fallback
  finally
    TMonitor.Exit(FTranslationsDict);
  end;
end;

class procedure TPlLanguageServer.UpdateClients;
begin
  ImportRuntimeStrings;
  SynchronizeClients;
  DoLanguageChanged;
end;

{$ENDREGION}

end.

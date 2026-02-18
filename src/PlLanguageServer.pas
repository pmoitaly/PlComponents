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
  plLanguage, plLanguageTypes, plLanguageEncoder,
  plLanguageEngineFactory, PlTranslationStore;

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
  ///  Warning:
  ///  - Don't use it if you use different languages in the same application.
  /// </remarks>
  TPlLanguageServer = class
  private
    class var FClients: TList<TPlLanguage>;
    class var FEngine: IPlLanguageEngine;
    class var FFileFormat: TPlLanguagePersistence;
    class var FLanguage: string;
    class var FLanguagesFolder: string;
    class var FLanguageInfo: TPlLanguageInfo;
    class var FOnLanguageChanged: TLanguageChangedEvent;
    class var FStore: IPlTranslationStore;
    class function CanSync: Boolean; static;
    class procedure DoLanguageChanged; static;
    class procedure EnsureEngine;
    class function GetGlobalLangFile: string;
    class function GetLanguageInfoFile: string; static;
    class procedure ImportLanguageInfo; static;
    class procedure ImportRuntimeStrings; static;
    class procedure SetFileFormat(const Value: TPlLanguagePersistence); static;
    class procedure SetLanguage(const Value: string); static;
    class procedure SetLanguagesFolder(const Value: string); static;
    class procedure SynchronizeClient(AClient: TPlLanguage); static;
    class procedure SynchronizeClients; static;
    class procedure SynchronizeClientsInfo; static;
    class procedure UpdateData; static;
  public
    /// <summary>
    /// Initializes the server (called automatically once).
    /// </summary>
    class constructor Create;

    /// <summary>
    /// Cleans up server's resources (called automatically once).
    /// </summary>
    class destructor Destroy;

    /// <summary>
    /// Persistence format used for language files.
    /// </summary>
    class property FileFormat: TPlLanguagePersistence read FFileFormat
      write SetFileFormat;

    /// <summary>
    /// The currently active language identifier (e.g. "en", "it").
    /// </summary>
    class property Language: string read FLanguage write SetLanguage;

    /// <summary>
    /// The folder where translation files are stored.
    /// </summary>
    class property LanguageInfo: TPlLanguageInfo read FLanguageInfo
      write FLanguageInfo;

    /// <summary>
    /// The folder where translation files are stored.
    /// </summary>
    class property LanguagesFolder: string read FLanguagesFolder
      write SetLanguagesFolder;

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
    class function Translate(const AString: string): string; static;

    /// <summary>
    /// Global event triggered when the language changes.
    /// Useful for modules that are not TPlLanguage clients.
    /// </summary>
    class property OnLanguageChanged: TLanguageChangedEvent
      read FOnLanguageChanged write FOnLanguageChanged;
  end;

implementation

uses
  System.SysUtils;

{$REGION 'TPlLanguageServer'}

class constructor TPlLanguageServer.Create;
begin
  FClients := TList<TPlLanguage>.Create;
  FStore := TPlTranslationStore.Create;
end;

class destructor TPlLanguageServer.Destroy;
begin
  TMonitor.Enter(FClients);
  try
    FClients.Clear;
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

class procedure TPlLanguageServer.DoLanguageChanged;
begin
  if Assigned(FOnLanguageChanged) then
    FOnLanguageChanged(FLanguage, FLanguagesFolder);
end;

class procedure TPlLanguageServer.EnsureEngine;
begin
  if not Assigned(FEngine) then
    FEngine := TPlLanguageEngineFactory.CreateEngine(FFileFormat);
end;

class function TPlLanguageServer.GetGlobalLangFile: string;
begin
  Result := IncludeTrailingPathDelimiter(FLanguagesFolder) + FLanguage +
    PathDelim + 'global' + FILE_EXT[FFileFormat];
end;

class function TPlLanguageServer.GetLanguageInfoFile: string;
begin
  Result := IncludeTrailingPathDelimiter(FLanguagesFolder) + FLanguage +
    PathDelim + 'lang' + FILE_EXT[FFileFormat];
end;

class procedure TPlLanguageServer.ImportLanguageInfo;
var
  infoName: string;
begin
  infoName := GetLanguageInfoFile;
  if FileExists(GetLanguageInfoFile) then
    FLanguageInfo := FEngine.ReadLanguageInfo(infoName);
end;

class procedure TPlLanguageServer.ImportRuntimeStrings;
var
  fileName: string;
begin
  if not CanSync then
    Exit;

  fileName := GetGlobalLangFile;
  if not FileExists(fileName) then
    begin
      FStore.Clear;
      Exit;
    end;

  EnsureEngine;
  FStore.Clear;

  // if ASource = nil then no UI traversal
  FEngine.LoadLanguage(nil, fileName, FStore);
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

class procedure TPlLanguageServer.SetFileFormat(const Value
  : TPlLanguagePersistence);
begin
  if Value <> FFileFormat then
    begin
      FFileFormat := Value;
      FEngine := nil;
      FStore.Clear;
      UpdateData;
    end;
end;

class procedure TPlLanguageServer.SetLanguage(const Value: string);
begin
  if Value <> FLanguage then
    begin
      FLanguage := Value;
      UpdateData;
    end;
end;

class procedure TPlLanguageServer.SetLanguagesFolder(const Value: string);
begin
  if Value <> FLanguagesFolder then
    begin
      FLanguagesFolder := Value;
      UpdateData;
    end;
end;

class procedure TPlLanguageServer.SynchronizeClient(AClient: TPlLanguage);
begin
  // Each client will handle BeforeChangeLanguage/AfterChangeLanguage internally.
  AClient.Language := FLanguage;
  AClient.LangPath := FLanguagesFolder;
  AClient.FileFormat := FFileFormat;
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

class procedure TPlLanguageServer.SynchronizeClientsInfo;
var
  client: TPlLanguage;
begin
  if CanSync then
    begin
      TMonitor.Enter(FClients);
      try
        for client in FClients do
          client.LanguageInfo := FLanguageInfo;
      finally
        TMonitor.Exit(FClients);
      end;
    end;
end;

class function TPlLanguageServer.Translate(const AString: string): string;
begin
  if AString = '' then
    Exit('');

  if FStore.TryGetValue(AString, Result) then
    Exit;

  Result := AString;
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

class procedure TPlLanguageServer.UpdateData;
begin
  ImportRuntimeStrings;
  SynchronizeClients;
  ImportLanguageInfo;
  SynchronizeClientsInfo;
  DoLanguageChanged;
end;

{$ENDREGION}

end.

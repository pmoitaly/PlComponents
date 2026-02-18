unit PlTranslationStore;

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
 /// Unit: PlTranslationStore
 /// This unit contains:
 /// - TPlTranslationStore: a store for runtime translation
 ///  of strings.
 ************************************************************* }

interface

uses
  System.Classes, System.Generics.Collections,
  PlLanguageTypes;

type

  /// <summary>
  ///   Default in-memory implementation of IPlTranslationStore
  ///   based on a dictionary.
  ///   The store automatically normalizes and encodes translation keys using
  ///   TPlLineEncoder.MakeKey. Callers must always use the original
  ///   logical key.
  /// </summary>
  TPlTranslationStore = class(TInterfacedObject, IPlTranslationStore)
  private
    FItems: TDictionary<string, string>;
  public
    /// <summary>
    ///   Creates an empty translation store.
    /// </summary>
    constructor Create;

    /// <summary>
    ///   Destroys the store and releases internal resources.
    /// </summary>
    destructor Destroy; override;

    /// <inheritdoc/>
    procedure Clear;

    /// <inheritdoc/>
    procedure AddOrSet(const AKey, AValue: string);

    /// <inheritdoc/>
    procedure AddOrSetEncoded(const AEncodedKey, AValue: string);


    /// <inheritdoc/>
    function TryGetValue(const AKey: string; out AValue: string): Boolean;

    /// <inheritdoc/>
    function IsEmpty: Boolean;
  end;

implementation

uses
  PlLanguageEncoder;

{$REGION 'TPlDictionaryTranslationStore'}

constructor TPlTranslationStore.Create;
begin
  inherited Create;
  FItems := TDictionary<string, string>.Create;
end;

destructor TPlTranslationStore.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TPlTranslationStore.AddOrSet(const AKey, AValue: string);
begin
  FItems.AddOrSetValue(TPlLineEncoder.MakeKey(AKey), AValue);
end;


procedure TPlTranslationStore.AddOrSetEncoded(const AEncodedKey,
  AValue: string);
begin
  FItems.AddOrSetValue(AEncodedKey, AValue);
end;

procedure TPlTranslationStore.Clear;
begin
  FItems.Clear;
end;

function TPlTranslationStore.IsEmpty: Boolean;
begin
  Result := FItems.Count = 0;
end;

function TPlTranslationStore.TryGetValue(
  const AKey: string;
  out AValue: string): Boolean;
begin
  Result := FItems.TryGetValue(TPlLineEncoder.MakeKey(AKey), AValue);
end;

end.


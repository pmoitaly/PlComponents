unit PlLanguageEncoder;

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
 /// - TPlLineEncoder: an engine to consistently encode strings references
 ************************************************************* }

interface

uses
  PlLanguageTypes;

type
  /// <summary>
  ///   Provides utility functions for encoding and decoding strings,
  ///   generating CRC32 keys, and normalizing values for persistence
  ///   in INI files or text storage.
  /// </summary>
  TPlLineEncoder = record
    /// <summary>
    ///   Computes the CRC32 checksum of a string, considering both
    ///   low and high bytes of UTF-16 characters.
    /// </summary>
    /// <param name="S">The input string.</param>
    /// <returns>The CRC32 checksum as a Cardinal.</returns>
    class function CRC32OfString(const S: string): Cardinal; static;

    /// <summary>
    ///   Decodes a string by replacing encoded tokens with their
    ///   original characters (e.g. [CRLF] becomes line break).
    /// </summary>
    /// <param name="S">The encoded string.</param>
    /// <returns>The decoded string.</returns>
    class function Decode(const S: string): string; static;

    /// <summary>
    ///   Encodes a string by replacing special characters with tokens
    ///   (e.g. line breaks becomes [CRLF], section sign becomes [§]).
    /// </summary>
    /// <param name="S">The input string.</param>
    /// <returns>The encoded string.</returns>
    class function Encode(const S: string): string; static;

    /// <summary>
    ///   Generates a hexadecimal key based on the CRC32 checksum of a string.
    /// </summary>
    /// <param name="S">The input string.</param>
    /// <returns>An 8-character hexadecimal key.</returns>
    class function MakeKey(const S: string): string; static;

    /// <summary>
    ///   Restores an INI key string by replacing encoded tokens
    ///   with their original characters (e.g. [EQUAL] becomes =).
    /// </summary>
    /// <param name="S">The encoded INI key.</param>
    /// <returns>The denormalized INI key.</returns>
    class function DenormalizeIniKey(const S: string): string; static;

    /// <summary>
    ///   Joins multiline text into a single line by replacing
    ///   line breaks with a placeholder (~~).
    /// </summary>
    /// <param name="S">The multiline string.</param>
    /// <returns>The joined single-line string.</returns>
    class function JoinMultiline(const S: string): string; static;

    /// <summary>
    ///   Normalizes an INI key by escaping special characters
    ///   (apostrophes, semicolons, equals signs).
    /// </summary>
    /// <param name="S">The original INI key.</param>
    /// <returns>The normalized INI key.</returns>
    class function NormalizeIniKey(const S: string): string; static;

    /// <summary>
    ///   Normalizes a file path by escaping backslashes.
    /// </summary>
    /// <param name="S">The original path string.</param>
    /// <returns>The normalized path string.</returns>
    class function NomalizePath(const S: string): string; static;

    /// <summary>
    ///   Restores multiline text by replacing placeholders (~~)
    ///   with actual line breaks.
    /// </summary>
    /// <param name="S">The single-line string with placeholders.</param>
    /// <returns>The restored multiline string.</returns>
    class function RestoreMultiline(const S: string): string; static;
  end;

implementation

uses
  SysUtils;

{$REGION 'TPlLineEncoder'}

class function TPlLineEncoder.CRC32OfString(const S: string): Cardinal;
var
  i: Integer;
  c: Cardinal;
begin
  Result := $FFFFFFFF;
  for i := 1 to Length(S) do
    begin
      c := Ord(S[i]) and $FF;
      // Consideriamo il char low-byte (UTF-16 -> 0..65535)
      Result := (Result shr 8) xor CRC32Table[(Result xor c) and $FF];
      c := (Ord(S[i]) shr 8) and $FF; // High-byte (per supporto Unicode >255)
      Result := (Result shr 8) xor CRC32Table[(Result xor c) and $FF];
    end;
  Result := Result xor $FFFFFFFF;
end;

class function TPlLineEncoder.Decode(const S: string): string;
begin
  Result := S.Replace('[CRLF]', #13#10).Replace('[§]', '§');
end;

class function TPlLineEncoder.Encode(const S: string): string;
begin
  Result := S.Replace('§', '[§]').Replace(#13#10, '[CRLF]');
end;

class function TPlLineEncoder.MakeKey(const S: string): string;
begin
  Result := IntToHex(CRC32OfString(S), 8);
end;

class function TPlLineEncoder.DenormalizeIniKey(const S: string): string;
begin
  Result := S;
  Result := StringReplace(Result, '[EQUAL]', '=', [rfReplaceAll]);
  Result := StringReplace(Result, '[SEMICOLON]', ';', [rfReplaceAll]);
  Result := StringReplace(Result, '''''', '''', [rfReplaceAll]);
  // Ripristina apostrofi
end;

class function TPlLineEncoder.JoinMultiline(const S: string): string;
begin
  Result := S.Replace(sLineBreak, '~~', [rfReplaceAll]);
end;

class function TPlLineEncoder.RestoreMultiline(const S: string): string;
begin
  Result := S.Replace('~~', sLineBreak, [rfReplaceAll]);
end;

class function TPlLineEncoder.NomalizePath(const S: string): string;
begin
  Result := S.Replace('\', '\\');
end;

class function TPlLineEncoder.NormalizeIniKey(const S: string): string;
begin
  Result := S;
  Result := StringReplace(Result, '''', '''''', [rfReplaceAll]);
  // Escape apostrofi
  Result := StringReplace(Result, ';', '[SEMICOLON]', [rfReplaceAll]);
  // Proteggi il punto e virgola
  Result := StringReplace(Result, '=', '[EQUAL]', [rfReplaceAll]);
end;

{$ENDREGION}

end.

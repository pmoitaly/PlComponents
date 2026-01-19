# TPlLineEncoder

## Overview

`TPlLineEncoder` is a utility record that provides a consistent way to **encode and decode strings**, generate **CRC32 keys**, and normalize values for persistence in INI files or text storage.  
It is designed to support translation systems and configuration management by ensuring that special characters and multiline text are handled safely and predictably.

---

## Features

- Compute CRC32 checksums of strings (Unicode‑aware)  
- Encode and decode special characters and line breaks  
- Generate stable hexadecimal keys for string references  
- Normalize and denormalize INI keys for safe persistence  
- Join and restore multiline text using placeholders  
- Normalize file paths by escaping backslashes  

---

## Public Members

| **Member**               | **Type**      | **Description**                                                                 |
|---------------------------|---------------|---------------------------------------------------------------------------------|
| **CRC32OfString**         | Function      | Computes the CRC32 checksum of a string, considering both low and high bytes of UTF‑16 characters. |
| **Decode**                | Function      | Decodes a string by replacing encoded tokens with their original characters (e.g. `[CRLF]` → line break). |
| **Encode**                | Function      | Encodes a string by replacing special characters with tokens (e.g. line breaks → `[CRLF]`, section sign → `[§]`). |
| **MakeKey**               | Function      | Generates an 8‑character hexadecimal key based on the CRC32 checksum of a string. |
| **DenormalizeIniKey**     | Function      | Restores an INI key string by replacing encoded tokens with their original characters (e.g. `[EQUAL]` → `=`). |
| **JoinMultiline**         | Function      | Joins multiline text into a single line by replacing line breaks with a placeholder (`~~`). |
| **RestoreMultiline**      | Function      | Restores multiline text by replacing placeholders (`~~`) with actual line breaks. |
| **NormalizeIniKey**       | Function      | Normalizes an INI key by escaping apostrophes and replacing semicolons and equals signs with tokens. |
| **NomalizePath**          | Function      | Normalizes a file path by escaping backslashes. |

---

## Example Usage

```delphi
var
  Encoded, Decoded, Key: string;
begin
  Encoded := TPlLineEncoder.Encode('Hello§World' + sLineBreak + 'Line2');
  // Encoded = 'Hello[§]World[CRLF]Line2'

  Decoded := TPlLineEncoder.Decode(Encoded);
  // Decoded = 'Hello§World' + LineBreak + 'Line2'

  Key := TPlLineEncoder.MakeKey('Hello World');
  // Key = CRC32-based hex string, e.g. '1A2B3C4D'
end;
```

---

## Limitations

- Works only with string inputs; binary data must be converted to string first.  
- Designed for INI persistence and translation systems; not a general‑purpose serializer.  
- Path normalization is simplistic (escapes backslashes only).  

---

## Contributing

Contributions are welcome. Possible improvements include:  
- Adding support for JSON/XML safe encoding  
- Extending path normalization for cross‑platform compatibility  
- Providing configurable token sets for custom encoding schemes  

---

## License

Released under the MIT License. See the LICENSE file for details.
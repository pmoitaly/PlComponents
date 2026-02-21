# TPlLineEncoder  
**Version:** 0.8  
**Category:** Translation System – Encoding Utilities  
**Project:** PlComponents  

---

## Introduction
This document describes the `TPlLineEncoder` record, a utility component within the Pl Translation System.  
Its purpose is to provide **string encoding, decoding, normalization, and key‑generation utilities** used by translation engines, metadata loaders, and persistence mechanisms.

`TPlLineEncoder` ensures that strings stored in INI files, JSON files, or other text-based formats remain safe, consistent, and reversible, even when they contain special characters, Unicode symbols, or multiline content.

---

## Body

### 1. Overview of TPlLineEncoder
`TPlLineEncoder` is a static utility record that offers:

- **CRC32-based key generation**  
- **Encoding/decoding of special characters**  
- **Normalization of INI keys**  
- **Normalization of file paths**  
- **Multiline text joining and restoration** 

Its Design Goals are:

- Deterministic key generation
- Safe storage of multiline and special-character strings
- INI-compatible normalization
- Unicode-safe CRC calculation
- Zero instance allocation (record with static methods)
 

It is used internally by translation engines and loaders, but can also be used by applications that need consistent text serialization.

---

### 2. Record Definition

```pascal
TPlLineEncoder = record
  class function CRC32OfString(const S: string): Cardinal; static;
  class function Decode(const S: string): string; static;
  class function Encode(const S: string): string; static;
  class function MakeKey(const S: string): string; static;
  class function DenormalizeIniKey(const S: string): string; static;
  class function JoinMultiline(const S: string): string; static;
  class function NormalizeIniKey(const S: string): string; static;
  class function NomalizePath(const S: string): string; static;
  class function RestoreMultiline(const S: string): string; static;
end;
```

---

### 3. Responsibilities

`TPlLineEncoder` is responsible for:

- **Ensuring safe persistence** of strings in INI or text files  
- **Encoding characters** that may conflict with file formats  
- **Decoding tokens** back into their original characters  
- **Generating stable keys** for translation lookup  
- **Handling Unicode correctly**, including UTF‑16 high/low bytes  
- **Managing multiline text** in formats that do not support it  

---

### 4. Method Reference

#### 4.1 `CRC32OfString`
Computes a CRC32 checksum of a Unicode string, processing both low and high bytes of UTF‑16 characters.

Use cases:
- Generating stable identifiers  
- Creating hash-based translation keys  

---

#### 4.2 `Encode`
Replaces special characters with safe tokens, e.g.:

- Line breaks -> `[CRLF]`  
- Section sign -> `[§]`  

Useful when storing text in formats that do not support raw control characters.

---

#### 4.3 `Decode`
Restores encoded tokens to their original characters.

This ensures full reversibility of the encoding process.

---

#### 4.4 `MakeKey`
Generates an **8-character hexadecimal key** based on the CRC32 checksum of a string.

Used by translation engines to create compact, collision-resistant identifiers.

---

#### 4.5 `NormalizeIniKey`
Escapes characters that are problematic in INI keys:

- Apostrophes  
- Semicolons  
- Equals signs  

Ensures compatibility with INI parsers.

---

#### 4.6 `DenormalizeIniKey`
Restores normalized INI keys to their original form.

This is the inverse of `NormalizeIniKey`.

---

#### 4.7 `JoinMultiline`
Converts multiline text into a single line using the placeholder `~~`.

Useful for formats that do not support multiline values.

---

#### 4.8 `RestoreMultiline`
Reverses `JoinMultiline`, restoring actual line breaks.

---

#### 4.9 `NomalizePath`
Escapes backslashes in file paths.

Note: The method name contains a minor typo (`NomalizePath` instead of `NormalizePath`), but is documented as implemented.

---

### 5. Integration in the Translation System

`TPlLineEncoder` is used by:

- **[PlLanguageIniEngine](pl_language_ini_engine.md)**  
  - To encode values stored in INI files  
  - To normalize keys  

- **[PlLanguageJsonEngine](pl_language_json_engine.md)**  
  - To ensure consistent key generation  

- **[PlTranslationStore](pl_translation_store.md)**  
  - To generate stable lookup keys  

- **Metadata loaders**  
  - When handling special characters in metadata fields  

Its role is foundational: it ensures that all text processed by the translation system is safe, reversible, and consistent across formats.

---

## Conclusion
`TPlLineEncoder` provides essential encoding, decoding, and normalization utilities for the Pl Translation System.  
Its methods ensure that strings remain safe for persistence, that special characters are handled correctly, and that translation keys are stable and reproducible.

Future improvements may include:
- Additional escape sequences  
- Configurable token sets  
- Support for alternative hashing algorithms  

---

## References
- Pl Translation System Architecture  
- INI file format specifications  
- CRC32 algorithm documentation  
- Delphi Unicode string handling  

---

## Appendix

### A. Example Encoded String

Input:

```
Hello§World
Line1
Line2
```

Encoded:

```
Hello[§]World[CRLF]Line1[CRLF]Line2
```

---

### B. Example Normalized INI Key

Input:

```
User=Name;Admin
```

Normalized:

```
User[EQUAL]Name[SEMICOLON]Admin
```

See also MakeFile.dpr in Demo folder.

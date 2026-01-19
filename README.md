# Pl Components

---

## Overview

Pl Components is a collection of **open‑source Delphi components** designed to enhance VCL applications with practical, ready‑to‑use features.  
The library focuses on **automation**, **customization**, and **persistence** of application behavior, while keeping every component **lightweight**, **non‑intrusive**, and **easy to integrate** into existing projects.

The components are built and tested with **Delphi 12.1**, but they are designed to remain compatible with earlier and future Delphi versions whenever possible.  
The goal is to provide developers with **simple, reliable building blocks** that speed up common tasks and reduce boilerplate code, without forcing them to reinvent infrastructure or adopt heavy frameworks.

Pl Components is intended for open‑source developers who value **clean architecture**, **maintainability**, and **practical enhancements** to everyday VCL development.

---

## Included Packages

The collection currently includes the following packages:

- **[Pl.Vcl.NonVisualComponents](pk_pl_vcl_nonvisualcomponents.md)**  
  A set of non‑visual components focused on **automation**, **customization**, and **state persistence**.  
  These components are designed to simplify recurring tasks and provide application‑level services with minimal configuration.

- **[plc.SE.Components](pk_pl_se_components.md)**  
  Utility components for SynEdit/SynEditor.  
  They aim to simplify common editor‑related tasks and extend SynEditor with practical, ready‑to‑use features.

- **[plc.Vcl.Db.DataControls](pk_pl_vcl_db_datacontrols.md)**  
  A collection of DB‑bound VCL controls.  
  It offers lightweight alternatives to Delphi’s LiveBindings system by relying on the native data‑binding architecture.  
  **Currently under development.**

- **[Pl.Vcl.VisualComponents](pk_pl_vcl_visualcomponents.md)**  
  A small set of visual components that implement common UI behaviors and patterns, helping developers build consistent and maintainable interfaces.
  **Currently under development.**

---

## Goals

Pl Components aims to:

- Provide **easy‑to‑use components** that solve real‑world problems without unnecessary complexity.  
- Offer **value‑added features** that speed up development and reduce repetitive code.  
- Maintain **clean, idiomatic Delphi design**, respecting component streaming, VCL conventions, and developer expectations.  
- Encourage **extensibility** and **customization**, allowing developers to adapt components to their specific needs.  
- Support the open‑source community with **transparent**, **well‑documented**, and **actively maintained** code.

---

## Usage

Each package is documented in its own `.md` file.  
Please refer to the linked documentation for:

- Installation instructions  
- Usage examples  
- Component reference and API details  
- Notes on version compatibility  

---

## Roadmap

* v0.8.0: First release of Pl.Vcl.NonVisualComponents and Pl.Se.Components
* v0.8.1: First release of plc.Vcl.Db.DataControls
* v0.8.2: First release of plc.Vcl.isualComponents
* v0.9.0: First official beta release
* v1.0.0: First non working release (see Murphy's laws)
* v1.1.0: First working release

## Contributing

Contributions are welcome!  
Possible areas for improvement include:

- Extending cross‑platform support (FMX, FreePascal)  
- Adding JSON/XML persistence options  
- Enhancing the translation/localization system  
- Providing more advanced runtime design tools  
- Expanding the set of visual and non‑visual components  

If you wish to contribute, feel free to open issues, submit pull requests, or propose new ideas.

---

## License

Released under the **MIT License**.  See the `LICENSE` file for details.
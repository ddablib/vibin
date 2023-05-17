# `vibin` Binary Version Information Manipulation Units

## Contents

* [Description](#descripton)
* [Installation](#installation)
* [Source Code](#source-code)
* [Documentation](#documentation)
* [Demo Code](#demo-code)
* [Update History](#update-history)
* [License](#license)
* [Bugs and Feature Requests](#bugs-and-feature-requests)
* [About the Author](#about-the-author)

## Descripton

These units contain a set of classes that can be used to read, manipulate and write Windows version information in its raw binary form. This is the form used to store version information in Windows executables and resource files.

The advantage of using this code over the Windows API for reading version information is that the code can cope with badly formed version information that would defeat the API routines. Furthermore, this code can enumerate the contents of string tables and list and access non-standard string table entries. It also works with string tables in multiple languages.

### Compatibility

These classes can be compiled with Delphi XE and later. It is possible that they may compile with Delphi 2009 or 2010, but this has not been tested.

⚠️ At present the code is Windows 32 bit only and so is not suitable for use with Windows 64 bit builds.

## Installation

The _Binary Version Information Manipulation Units_ are distributed in a zip file. Before installing you need to extract all the files, preserving the directory structure. The following files will be extracted:

* **`DelphiDabbler.Lib.VIBin.Resource.pas`** - Contains the single class you need to interact with to manipulate binary version information.
* **`DelphiDabbler.Lib.VIBin.VarRec.pas`** - Contains support classes required by `DelphiDabbler.Lib.VIBin.Resource.pas`. These classes do not need to be accessed directly.
* **`DelphiDabbler.Lib.VIBin.Defines.inc`** - Include file that defines symbols required by the `.pas` files to enable conditional compilation.
* `README.md` - This read-me file.
* `CHANGELOG.md` - The project's change log.
* `MPL-2.0.txt` - Mozilla Public License v2.0.
* `Documentation.URL` - Short-cut to online documentation.

There are also [demo programs](#demo-code) and documentation in the `Demos`. directory.

There are four possible ways to use the units:

1. The simplest way is to add `DelphiDabbler.Lib.VIBin.Resource.pas`, `DelphiDabbler.Lib.VIBin.VarRec.pas` and `DelphiDabbler.Lib.VIBin.Defines.inc` to your project.
2. To make the units easier to re-use you can either copy them, with the associated `.inc` file, to a folder on your Delphi search path, or add the folder where you extracted the units to the search path. You then simply use the units as required without needing to add them to your project.
3. For maximum portability you can add the units to a Delphi package.
4. If you use Git you can add the [`ddablib/vibin`](https://github.com/ddablib/vibin) GitHub repository as a Git submodule. Obviously, it's safer if you fork the repo and use your own copy, just in case `ddablib/vibin` ever goes away.

## Source Code

The project's source code is available from the [`ddablib/vibin`](https://github.com/ddablib/vibin) GitHub repository.

> This project was created by extracting the core functionality from the  [`delphidabbler/vilib`](https://github.com/delphidabbler/vilib) project. Those files were transfered to the `vibin` project on 2023-05-05 and brought their Git history with them. The point at which the files were imported from `vilib` is tagged `import-from-vilib` in the Git repository.

## Documentation

The _Binary Version Information Manipulation Units_ are fully [documented online](https://delphidabbler.com/url/vibin-docs).

## Demo Code

Two demo projects are included in the `Demos` directory. See `Demos/README.md` for details.

## Update History

A complete change log is provided in [`CHANGELOG.md`](https://github.com/ddablib/vibin/blob/main/CHANGELOG.md) that is included in the download.

More granular change information can be found using the `git log` command on the Git repository. Some files maay have been renamed. To follow their history you will need to use the `--follow` parameter with `git log`.

## License

The _Binary Version Information Manipulation Units_ are copyright © 2002-2023 [Peter D Johnson](https://gravatar.com/delphidabbler) and are released under the terms of the [Mozilla Public License, v2.0](https://www.mozilla.org/MPL/2.0/).

Demos are [MIT licensed](https://delphidabbler.mit-license.org/2023-/).

## Bugs and Feature Requests

Bugs can be reported or new features requested via the [Issue Tracker](https://github.com/ddablib/vibin/issues). A GitHub account is required.

## About the Author

I'm Peter Johnson – a hobbyist programmer living in Ceredigion in West Wales, UK, writing mainly in Delphi. My programs and other library code are available from [https://delphidabbler.com/](https://delphidabbler.com/).

This document is copyright © 2023, [Peter D Johnson](https://gravatar.com/delphidabbler).

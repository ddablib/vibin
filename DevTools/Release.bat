:: -----------------------------------------------------------------------------
:: Script used to create zip file containing source code of Binary Version
:: Information Manipulation Units.
::
:: Requirements:
::
:: 1) This script uses the InfoZip zip.exe program to create the release zip
::    file.
::
:: 2) If the ZIPPATH environment variable exists it must provide the path to
::    the directory where zip.exe is located. ZIPPATH *must not* have a
::    trailing backslash. If ZIPPATH does not exist then Zip.exe is expected
::    to be on the path.
::
:: 3) A release version number may be provided as a parameter to the script.
::    When present the version number is included in the name of the zip file
::    that is created.
::
:: Any copyright in this file is dedicated to the Public Domain.
:: http://creativecommons.org/publicdomain/zero/1.0/
:: ---------------------------------------------------------------------------

@echo off

setlocal

cd ..

set SrcDir=
set DocsDir=Docs
set DemoDir=Demos

set RelDir=_release
set OutFile=%RelDir%\dd-vibin
if not "%1"  == "" set OutFile=%OutFile%-%1
set OutFile=%OutFile%.zip
echo Output file name = %OutFile%
if exist %OutFile% del %OutFile%

if not "%ZIPPATH%" == "" set ZIPPATH=%ZIPPATH%\
echo Zip path = %ZIPPATH%

if exist %RelDir% rmdir /S /Q %RelDir%
mkdir %RelDir%

%ZIPPATH%Zip.exe -j -9 %OutFile% DelphiDabbler.Lib.VIBin.Defines.inc
%ZIPPATH%Zip.exe -j -9 %OutFile% DelphiDabbler.Lib.VIBin.Resource.pas
%ZIPPATH%Zip.exe -j -9 %OutFile% DelphiDabbler.Lib.VIBin.VarRec.pas

%ZIPPATH%Zip.exe -j -9 %OutFile% CHANGELOG.md
%ZIPPATH%Zip.exe -j -9 %OutFile% README.md
%ZIPPATH%Zip.exe -j -9 %OutFile% %DocsDir%\MPL-2.0.txt
%ZIPPATH%Zip.exe -j -9 %OutFile% %DocsDir%\Documentation.URL

%ZIPPATH%Zip.exe %OutFile% -r -9 %DemoDir%\*.*

endlocal

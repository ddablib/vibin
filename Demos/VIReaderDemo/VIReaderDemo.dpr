{
  Part of a demo project for ddablib/vibin

  Copyright (c) 2023, Peter D Johnson (https://gravatar.com/delphidabbler).

  MIT License: https://delphidabbler.mit-license.org/2023-/
}

program VIReaderDemo;

{$Include ..\..\DelphiDabbler.Lib.VIBin.Defines.inc}

uses
  {$IFDEF Supports_ScopedUnitNames}
  Vcl.Forms,
  {$ELSE}
  Forms,
  {$ENDIF}
  ULogger in '..\Shared\ULogger.pas',
  FmVIReaderDemo in 'FmVIReaderDemo.pas' {VIReaderDemoForm},
  UVerInfoFileStream in 'UVerInfoFileStream.pas',
  DelphiDabbler.Lib.VIBin.Resource in '..\..\DelphiDabbler.Lib.VIBin.Resource.pas',
  DelphiDabbler.Lib.VIBin.VarRec in '..\..\DelphiDabbler.Lib.VIBin.VarRec.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TVIReaderDemoForm, VIReaderDemoForm);
  Application.Run;
end.

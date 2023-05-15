{
  Part of a demo project for ddablib/vibin

  Copyright (c) 2023, Peter D Johnson (https://gravatar.com/delphidabbler).

  MIT License: https://delphidabbler.mit-license.org/2023-/
}

program ResRWDemo;

{$Include ..\..\DelphiDabbler.Lib.VIBin.Defines.inc}

uses
  {$IFDEF Supports_ScopedUnitNames}
  Vcl.Forms,
  {$ELSE}
  Forms,
  {$ENDIF}
  DelphiDabbler.Lib.VIBin.Resource in '..\..\DelphiDabbler.Lib.VIBin.Resource.pas',
  DelphiDabbler.Lib.VIBin.VarRec in '..\..\DelphiDabbler.Lib.VIBin.VarRec.pas',
  ULogger in '..\Shared\ULogger.pas',
  PJResFile in 'Vendor\PJResFile.pas',
  FmResRWDemo in 'FmResRWDemo.pas' {ResRWDemoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TResRWDemoForm, ResRWDemoForm);
  Application.Run;
end.

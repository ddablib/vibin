{
  Part of a demo project for ddablib/vibin

  Copyright (c) 2023, Peter D Johnson (https://gravatar.com/delphidabbler).

  MIT License: https://delphidabbler.mit-license.org/2023-/
}

unit ULogger;

{$Include ..\..\DelphiDabbler.Lib.VIBin.Defines.inc}

interface

uses
  {$IFDEF Supports_ScopedUnitNames}
  Vcl.StdCtrls;
  {$ELSE}
  StdCtrls;
  {$ENDIF}

type
  TLogger = class(TObject)
  strict private
    var
      fMemo: TMemo;
      fColWidth: UInt8;
  public
    constructor Create(Memo: TMemo; ColWidth: UInt8);
    type
      TNumberFmt = (Decimal, Hex, HexC);
    procedure Log; overload;
    procedure Log(Txt: string); overload;
    procedure Log(Fmt: string; Args: array of const); overload;
    procedure Log(Txt: string; Value: string); overload;
    procedure Log(Txt: string; Value: Int64; Fmt: TNumberFmt = Decimal); overload;
    procedure Log(Txt: string; Value: Word; Fmt: TNumberFmt = HexC); overload;
    procedure Log(Txt: string; Value: LongWord; Fmt: TNumberFmt = HexC); overload;
    procedure HexDump(Data: array of Byte);
  end;

implementation

uses
  {$IFDEF Supports_ScopedUnitNames}
  System.SysUtils;
  {$ELSE}
  SysUtils;
  {$ENDIF}

{ TLogger }

constructor TLogger.Create(Memo: TMemo; ColWidth: UInt8);
begin
  inherited Create;
  fMemo := Memo;
  fColWidth := ColWidth;
end;

procedure TLogger.Log;
begin
  Log('');
end;

procedure TLogger.Log(Txt: string);
begin
  fMemo.Lines.Add(Txt);
end;

procedure TLogger.Log(Fmt: string; Args: array of const);
begin
  Log(Format(Fmt, Args));
end;

procedure TLogger.Log(Txt, Value: string);
begin
  Log(
    StringOfChar(' ', fColWidth - Length(Txt)) + Txt + ' | ' + Value
  );
end;

procedure TLogger.Log(Txt: string; Value: Int64; Fmt: TNumberFmt);
begin
  case Fmt of
    Decimal:  Log(Txt, IntToStr(Value));
    Hex:      Log(Txt, IntToHex(Value, 16));
    HexC:     Log(Txt, '0x' + IntToHex(Value, 16));
  end;
end;

procedure TLogger.HexDump(Data: array of Byte);
var
  Pos: Integer;
  HexLine: string;
  CharLine: string;
  B: Byte;
  BHex: string;
const
  cColCount = 16;
  cLineFmt = '%-48s %s';
begin
  Pos := 1;
  HexLine := '';
  CharLine := '';
  for B in Data do
  begin
    BHex := IntToHex(Integer(B), SizeOf(Byte)*2);
    HexLine := HexLine + BHex + ' ';
    if B in [32..126] then
      CharLine := CharLine + Chr(B)
    else
      CharLine := CharLine + '.';
    if Pos = cColCount then
    begin
      Log(cLineFmt, [HexLine, CharLine]);
      HexLine := '';
      CharLine := '';
      Pos := 1;
    end
    else
      Inc(Pos);
  end;
  if HexLine <> '' then
    Log('%-48s %s', [HexLine, CharLine]);
end;

procedure TLogger.Log(Txt: string; Value: LongWord; Fmt: TNumberFmt);
begin
  case Fmt of
    Decimal:  Log(Txt, IntToStr(Value));
    Hex:      Log(Txt, IntToHex(Value, 8));
    HexC:     Log(Txt, '0x' + IntToHex(Value, 8));
  end;
end;

procedure TLogger.Log(Txt: string; Value: Word; Fmt: TNumberFmt);
begin
  case Fmt of
    Decimal:  Log(Txt, IntToStr(Value));
    Hex:      Log(Txt, IntToHex(Value, 4));
    HexC:     Log(Txt, '0x' + IntToHex(Value, 4));
  end;
end;

end.

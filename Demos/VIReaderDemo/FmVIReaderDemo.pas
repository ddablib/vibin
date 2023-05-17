{
  Part of a demo project for ddablib/vibin

  Copyright (c) 2023, Peter D Johnson (https://gravatar.com/delphidabbler).

  MIT License: https://delphidabbler.mit-license.org/2023-/
}

{$Include ..\..\DelphiDabbler.Lib.VIBin.Defines.inc}

unit FmVIReaderDemo;

interface

uses
  {$IFDEF Supports_ScopedUnitNames}
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ActiveX,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Mask,
  Vcl.ExtCtrls,
  {$ELSE}
  Windows,
  Messages,
  ActiveX,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Mask,
  ExtCtrls,
  {$ENDIF}

  // Class for extracting version information resources from an executable file
  // or DLL. Provides a read-onle TStream inerface to the version information
  // data.
  UVerInfoFileStream,

  // Logger class
  ULogger,

  // VI Data class
  DelphiDabbler.Lib.VIBin.Resource;

type
  TVIReaderDemoForm = class(TForm)
    bvlDescription: TBevel;
    lblDescription: TLabel;
    btnOpenExeOrDLL: TButton;
    dlgExePath: TFileOpenDialog;
    memoView: TMemo;
    lblDesc: TLabel;
    lblExePath: TLabel;
    procedure btnOpenExeOrDLLClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  strict private
    var
      fVI: TVIBinResource;
      fLog: TLogger;
    procedure LoadVersionInfo(const FilePath: string);
    procedure DisplayVersionInfo;
    function FormatVersion(MS, LS: LongWord): string; overload; inline;
    function FormatVersion(V: LongWord): string; overload; inline;
  public
  end;

var
  VIReaderDemoForm: TVIReaderDemoForm;

implementation

{$R *.dfm}

procedure TVIReaderDemoForm.btnOpenExeOrDLLClick(Sender: TObject);
begin
  // Get file from user
  if not dlgExePath.Execute then
    Exit;
  lblExePath.Caption := dlgExePath.FileName;
  // Load and display version information
  LoadVersionInfo(dlgExePath.FileName);
  DisplayVersionInfo;
end;

procedure TVIReaderDemoForm.DisplayVersionInfo;
var
  FFI: TVSFixedFileInfo;
  Idx, TransCount, TblCount, TblIdx, StrCount, StrIdx: Integer;
  CharSet, LanguageID: Word;
  TransStr, TblTransStr, StrName, StrValue: string;
begin
  memoView.Lines.BeginUpdate;
  try
    memoView.Clear;
    // Get and display Fixed File Information
    FFI := fVI.GetFixedFileInfo;
    fLog.Log('FFI');
    fLog.Log('dwSignature', FFI.dwSignature, HexC);
    fLog.Log('dwStrucVersion', FFI.dwStrucVersion, HexC);
    fLog.Log('dwFileVersionMS', FFI.dwFileVersionMS, HexC);
    fLog.Log('dwFileVersionLS', FFI.dwFileVersionLS, HexC);
    fLog.Log('dwProductVersionMS', FFI.dwProductVersionMS, HexC);
    fLog.Log('dwProductVersionLS', FFI.dwProductVersionLS, HexC);
    fLog.Log('dwFileFlagsMask', FFI.dwFileFlagsMask, HexC);
    fLog.Log('dwFileFlags', FFI.dwFileFlags, HexC);
    fLog.Log('dwFileOS', FFI.dwFileOS, HexC);
    fLog.Log('dwFileType', FFI.dwFileType, HexC);
    fLog.Log('dwFileSubtype', FFI.dwFileSubtype, HexC);
    fLog.Log('dwFileDateMS', FFI.dwFileDateMS);
    fLog.Log('dwFileDateLS', FFI.dwFileDateLS);
    fLog.Log;

    // Display some FFI fields in a more human readable way
    fLog.Log('Interpretation of some FFI fields');
    fLog.Log('Structure version',  FormatVersion(FFI.dwStrucVersion));
    fLog.Log(
      'FileVersion',
      FormatVersion(FFI.dwFileVersionMS, FFI.dwFileVersionLS)
    );
    fLog.Log(
      'ProductVersion',
      FormatVersion(FFI.dwProductVersionMS, FFI.dwProductVersionLS)
    );
    fLog.Log;

    // Display translation(s)
    fLog.Log('Translations');
    TransCount := fVI.GetTranslationCount;
    fLog.Log('Translation count', TransCount);
    for Idx := 0 to Pred(TransCount) do
    begin
      CharSet := fVI.GetTranslationCharSet(Idx);
      LanguageID := fVI.GetTranslationLanguageID(Idx);
      TransStr := fVI.GetTranslationString(Idx);
      fLog.Log('Translation #', Idx);
      fLog.Log('Translation string', TransStr);
      fLog.Log('Translation language ID', LanguageID, HexC);
      fLog.Log('Translation character set', CharSet, HexC);
    end;
    fLog.Log;

    // Display string table(s)
    fLog.Log('String tables');
    TblCount := fVI.GetStringTableCount;
    fLog.Log('String table count', TblCount);
    for TblIdx := 0 to Pred(TblCount) do
    begin
      fLog.Log;
      StrCount := fVI.GetStringCount(TblIdx);
      TblTransStr := fVI.GetStringTableTransStr(TblIdx);
      CharSet := fVI.GetStringTableCharSet(TblIdx);
      LanguageID := fVI.GetStringTableLanguageID(TblIdx);
      fLog.Log('String table #', TblIdx);
      fLog.Log('String table tanslation string', TblTransStr);
      fLog.Log('String table language ID', LanguageID);
      fLog.Log('String table character set', CharSet);
      fLog.Log('String count', StrCount);
      fLog.Log;
      // Display strings in a string table
      for StrIdx := 0 to Pred(StrCount) do
      begin
        StrName := fVI.GetStringName(TblIdx, StrIdx);
        StrValue := fVI.GetStringValue(TblIdx, StrIdx);
        fLog.Log('String #', StrIdx);
        fLog.Log('String name=value', StrName + '=' + StrValue);
      end;
    end;
    fLog.Log;
  finally
    memoView.Lines.EndUpdate;
  end;
end;

function TVIReaderDemoForm.FormatVersion(MS, LS: LongWord): string;
begin
  // Format version information encoded in two 32 bit word values
  Result := FormatVersion(MS) + '.' + FormatVersion(LS);
end;

function TVIReaderDemoForm.FormatVersion(V: LongWord): string;
begin
  // Format version information encoded in a 32 bit word value
  Result := Format('%d.%d', [LongRec(V).Hi, LongRec(V).Lo]);
end;

procedure TVIReaderDemoForm.FormCreate(Sender: TObject);
begin
  fVI := TVIBinResource.Create(vrtUnicode);
  fLog := TLogger.Create(memoView, 32);
end;

procedure TVIReaderDemoForm.FormDestroy(Sender: TObject);
begin
  fLog.Free;
  fVI.Free;
end;

procedure TVIReaderDemoForm.LoadVersionInfo(const FilePath: string);
var
  VIFS: TVerInfoFileStream;
  Stm: IStream;
begin
  // Load version information from specified execuatable file / DLL
  // We read the version information from the specified file's resources using
  // TStream object. But IVerInfoBinaryReader reads data from an IStream, not a
  // TStream, so we use TStreamAdapter to get an IStream interface to the
  // TStream.
  VIFS := TVerInfoFileStream.Create(FilePath);
  try
    Stm := TStreamAdapter.Create(VIFS, soReference);
    fVI.ReadFromStream(Stm);
  finally
    VIFS.Free;
  end;
end;

end.

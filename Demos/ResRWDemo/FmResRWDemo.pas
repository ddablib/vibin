{
  Part of a demo project for ddablib/vibin

  Copyright (c) 2023, Peter D Johnson (https://gravatar.com/delphidabbler).

  MIT License: https://delphidabbler.mit-license.org/2023-/
}

{$Include ..\..\DelphiDabbler.Lib.VIBin.Defines.inc}

unit FmResRWDemo;

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
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Mask,
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
  ExtCtrls,
  StdCtrls,
  Mask,
  {$ENDIF}

  // Unit for reading / writing 32 bit resorces files from
  // https://github.com/ddablib/resfiles
  PJResFile,

  // Logger class
  ULogger,

  // vibin
  DelphiDabbler.Lib.VIBin.Resource;


type
  TResRWDemoForm = class(TForm)
    lblDescription: TLabel;
    bvlDescription: TBevel;
    btnView: TButton;
    memoView: TMemo;
    btnOpen: TButton;
    btnSave: TButton;
    btnViewRaw: TButton;
    btnViewResFile: TButton;
    btnAddTranslation: TButton;
    leCharSet: TLabeledEdit;
    leLanguageID: TLabeledEdit;
    leStringName: TLabeledEdit;
    leStringValue: TLabeledEdit;
    btnDeleteTrans: TButton;
    btnIndexOfTrans: TButton;
    leTransIdx: TLabeledEdit;
    leStrTableIdx: TLabeledEdit;
    btnAddStrTable: TButton;
    btnIndexOfStrTable: TButton;
    btnDeleteStrTable: TButton;
    btnAddOrUpdateString: TButton;
    btnDeleteString: TButton;
    btnSetFFI: TButton;
    btnIndexOfString: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnViewRawClick(Sender: TObject);
    procedure btnViewResFileClick(Sender: TObject);
    procedure HexEditKeyPress(Sender: TObject; var Key: Char);
    procedure btnAddTranslationClick(Sender: TObject);
    procedure btnDeleteTransClick(Sender: TObject);
    procedure btnIndexOfTransClick(Sender: TObject);
    procedure btnAddStrTableClick(Sender: TObject);
    procedure btnIndexOfStrTableClick(Sender: TObject);
    procedure btnDeleteStrTableClick(Sender: TObject);
    procedure btnAddOrUpdateStringClick(Sender: TObject);
    procedure btnDeleteStringClick(Sender: TObject);
    procedure btnSetFFIClick(Sender: TObject);
    procedure btnIndexOfStringClick(Sender: TObject);
  strict private
    const
      ResFileName = 'TestVI.res';
    var
      fVI: TVIBinResource;
      fLog: TLogger;
    function ResFilePath: string;
    procedure ReadVIFromResourceFile;
    procedure WriteVIToResourceFile;
    function VIAsBytes: TArray<Byte>;
  public

  end;

var
  ResRWDemoForm: TResRWDemoForm;

implementation

uses
  {$IFDEF Supports_ScopedUnitNames}
  System.IOUtils;
  {$ELSE}
  IOUtils;
  {$ENDIF}

{$R *.dfm}

procedure TResRWDemoForm.btnAddOrUpdateStringClick(Sender: TObject);
var
  Name: string;
  Value: string;
  TblIdx: Integer;
  StrIdx: Integer;
begin
  Name := Trim(leStringName.Text);
  Value := leStringValue.Text;
  TblIdx := StrToInt(leStrTableIdx.Text);
  if Name = '' then
    raise Exception.Create('String name required');
  StrIdx := fVI.AddOrUpdateString(TblIdx, Name, Value);
  fLog.Log(
    '### Added or updated string named "%s" to string table %d at index %d',
    [Name, TblIdx, StrIdx]
  );
  fLog.Log;
end;

procedure TResRWDemoForm.btnAddStrTableClick(Sender: TObject);
var
  NewIdx: Integer;
  CharSet, LanguageID: Word;
begin
  CharSet := Word(StrToIntDef('$' + leCharSet.Text, $FFFF));
  LanguageID := Word(StrToIntDef('$' + leLanguageID.Text, $FFFF));
  NewIdx := fVI.AddStringTableByTrans(LanguageID, CharSet);
  fLog.Log('### Added string table %s at index %d', [fVI.TransToString(LanguageID, CharSet), NewIdx]);
  fLog.Log;
end;

procedure TResRWDemoForm.btnAddTranslationClick(Sender: TObject);
var
  NewIdx: Integer;
  CharSet, LanguageID: Word;
begin
  CharSet := Word(StrToIntDef('$' + leCharSet.Text, $FFFF));
  LanguageID := Word(StrToIntDef('$' + leLanguageID.Text, $FFFF));
  NewIdx := fVI.AddTranslation(LanguageID, CharSet);
  fLog.Log('### Added translation %s at index %d', [fVI.TransToString(LanguageID, CharSet), NewIdx]);
  fLog.Log;
end;

procedure TResRWDemoForm.btnDeleteStringClick(Sender: TObject);
var
  Name: string;
  TblIdx: Integer;
begin
  Name := Trim(leStringName.Text);
  TblIdx := StrToInt(leStrTableIdx.Text);
  if Name = '' then
    raise Exception.Create('String name required');
  fVI.DeleteStringByName(TblIdx, Name);
  fLog.Log(
    '### Deleted string named "%s" from string table %d', [Name, TblIdx]
  );
  fLog.Log;
end;

procedure TResRWDemoForm.btnDeleteStrTableClick(Sender: TObject);
var
  DelIdx: Integer;
begin
  DelIdx := StrToInt(leStrTableIdx.Text);
  fVI.DeleteStringTable(DelIdx);
  fLog.Log('### Deleted string table at index %d', [DelIdx]);
  fLog.Log;
end;

procedure TResRWDemoForm.btnDeleteTransClick(Sender: TObject);
var
  DelIdx: Integer;
begin
  DelIdx := StrToInt(leTransIdx.Text);
  fVI.DeleteTranslation(DelIdx);
  fLog.Log('### Deleted translation at index %d', [DelIdx]);
  fLog.Log;
end;

procedure TResRWDemoForm.btnIndexOfStringClick(Sender: TObject);
var
  StrTableIdx, Idx: Integer;
  StrName: string;
begin
  StrTableIdx := StrToInt(leStrTableIdx.Text);
  StrName := Trim(leStringName.Text);
  Idx := fVI.IndexOfString(StrTableIdx, StrName);
  fLog.Log(
    '### Index of string "%s" in string table %d is %d',
    [StrName, StrTableIdx, Idx]
  );
  fLog.Log;
end;

procedure TResRWDemoForm.btnIndexOfStrTableClick(Sender: TObject);
var
  Idx: Integer;
  CharSet, LanguageID: Word;
begin
  CharSet := Word(StrToIntDef('$' + leCharSet.Text, $FFFF));
  LanguageID := Word(StrToIntDef('$' + leLanguageID.Text, $FFFF));
  Idx := fVI.IndexOfStringTableByTrans(LanguageID, CharSet);
  fLog.Log('### Index of string table %s = %d', [fVI.TransToString(LanguageID, CharSet), Idx]);
  fLog.Log;
end;

procedure TResRWDemoForm.btnIndexOfTransClick(Sender: TObject);
var
  Idx: Integer;
  CharSet, LanguageID: Word;
begin
  CharSet := Word(StrToIntDef('$' + leCharSet.Text, $FFFF));
  LanguageID := Word(StrToIntDef('$' + leLanguageID.Text, $FFFF));
  Idx := fVI.IndexOfTranslation(LanguageID, CharSet);
  fLog.Log('### Index of translation %s = %d', [fVI.TransToString(LanguageID, CharSet), Idx]);
  fLog.Log;
end;

procedure TResRWDemoForm.btnOpenClick(Sender: TObject);
begin
  if TFile.Exists(ResFilePath) then
    ReadVIFromResourceFile
  else
    // File doesn't exist: just free current version info (i.e. create new file)
    fVI.Reset;
end;

procedure TResRWDemoForm.btnSaveClick(Sender: TObject);
begin
  WriteVIToResourceFile;
end;

procedure TResRWDemoForm.btnSetFFIClick(Sender: TObject);
var
  FFI: TVSFixedFileInfo;
begin
  // Set Fixed File Information to some arbitrary values
  // We're not allowing user to enter these values, just because there would
  // be many too any buttons!!
  FFI.dwSignature := 0;     // will be overwritten with fixed signature
  FFI.dwStrucVersion := 0;  // will be overwritten with value meaning v1.0
  FFI.dwFileVersionMS := $00020004;
  FFI.dwFileVersionLS := $00060A76;     // file version 2.4.6.2678
  FFI.dwProductVersionMS := $07E70005;
  FFI.dwProductVersionLS := $00000000;  // product version 2023.5.0.0
  FFI.dwFileFlagsMask := VS_FF_PRIVATEBUILD or VS_FF_SPECIALBUILD;
  FFI.dwFileFlags := VS_FF_SPECIALBUILD;
  FFI.dwFileOS := VOS__WINDOWS32;
  FFI.dwFileType := VFT_APP;
  FFI.dwFileSubtype := 0;     // sub-type N/a for file type VFT_APP
  FFI.dwFileDateMS := 0;
  FFI.dwFileDateLS := 0;      // no date
  // Set the FFI
  fVI.SetFixedFileInfo(FFI);
end;

procedure TResRWDemoForm.btnViewClick(Sender: TObject);
var
  FFI: TVSFixedFileInfo;
  Idx, TransCount, TblCount, StrCount, StrIdx, TblIdx: Integer;
  CharSet, LanguageID: Word;
  TransStr, TblTransStr, StrName, StrValue: string;
begin
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

  // Display translation(s)
  fLog.Log('Translations');
  TransCount := fVI.GetTranslationCount;
  fLog.Log('Translation count', TransCount);
  for Idx := 0 to Pred(TransCount) do
  begin
    LanguageID := fVI.GetTranslationLanguageID(Idx);
    CharSet := fVI.GetTranslationCharSet(Idx);
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
    LanguageID := fVI.GetStringTableLanguageID(TblIdx);
    CharSet := fVI.GetStringTableCharSet(TblIdx);
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
end;

procedure TResRWDemoForm.btnViewRawClick(Sender: TObject);
begin
  fLog.Log('Version Information Raw Data');
  fLog.HexDump(VIAsBytes);
  fLog.Log;
end;

procedure TResRWDemoForm.btnViewResFileClick(Sender: TObject);
begin
  if TFile.Exists(ResFilePath) then
  begin
    fLog.Log('Resource file content');
    fLog.HexDump(TFile.ReadAllBytes(ResFilePath));
  end
  else
    fLog.Log('Resource file does not exist');
  fLog.Log;
end;

procedure TResRWDemoForm.FormCreate(Sender: TObject);
begin
  fVI := TVIBinResource.Create(vrtUnicode);
  fLog := TLogger.Create(memoView, 32);
end;

procedure TResRWDemoForm.FormDestroy(Sender: TObject);
begin
  fLog.Free;
  fVI.Free;
end;

procedure TResRWDemoForm.HexEditKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['1'..'9', '0', 'a'..'f', 'A'..'F', #8]) then
    Key := #0;
end;

procedure TResRWDemoForm.ReadVIFromResourceFile;
var
  ResFile: TPJResourceFile;
  VIEntry: TPJResourceEntry;
  DataStreamAdapter: IStream;
begin
  // PRECONDITION: Resource file must exist
  // Create a resource file object and load resource file into it
  ResFile := TPJResourceFile.Create;
  try
    ResFile.LoadFromFile(ResFilePath);
    // Find RT_VERSION resource, if present
    VIEntry := ResFile.FindEntry(RT_VERSION, MakeIntResource(1));
    if Assigned(VIEntry) then
    begin
      // Found resource entry: load data from resource entry into version
      // information object fVI.
      // NOTE: fVI reads data from an IStream while TPJResourceEntry exposes its
      // data as a TStream, so we use TStreamAdapter to convert between the two
      // stream types.
      DataStreamAdapter := TStreamAdapter.Create(VIEntry.Data);
      fVI.ReadFromStream(DataStreamAdapter);
    end
    else
      // Version information resource not found: clear existing VI data
      fVI.Reset;
  finally
    ResFile.Free;
  end;
end;

function TResRWDemoForm.ResFilePath: string;
begin
  // Resource file is located in the same directory as the demo executable
  Result := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), ResFileName);
end;

function TResRWDemoForm.VIAsBytes: TArray<Byte>;
var
  DataStream: TMemoryStream;
  DataAdapter: IStream;
begin
  // Copy raw data from version information object into a byte array
  // The only way to get raw data out of the version info object is to copy it
  // to a stream and then to copy the stream to the required byte array.
  // Create a memory stream to recieve the data
  DataStream := TMemoryStream.Create;
  try
    // Adapt the memory stream into an IStream that version info object can save
    // into. The saved data gets written to the wrapped memory stream
    DataAdapter := TStreamAdapter.Create(DataStream);
    fVI.WriteToStream(DataAdapter);
    // Reset the memory stream to the start
    DataStream.Position := 0;
    // Set the size of the byte array to same as memory stream
    SetLength(Result, DataStream.Size);
    // Copy data from memory stream into byte array
    DataStream.ReadBuffer(Pointer(Result)^, Length(Result));
  finally
    DataStream.Free;
  end;
end;

procedure TResRWDemoForm.WriteVIToResourceFile;
var
  ResFile: TPJResourceFile;
  VIEntry: TPJResourceEntry;
  DataStreamAdapter: IStream;
begin
  // Create a resource file object and add an empty version info resource to it
  ResFile := TPJResourceFile.Create;
  try
    // Version info resources have type RT_VERSION and *always* have ID of 1
    VIEntry := ResFile.AddEntry(RT_VERSION, MakeIntResource(1));
    // TPJResourceEntry exposes its data as a TStream, bit the version
    // information object writes to an IStream. So we use TStreamAdapter to
    // convert between the two types.
    DataStreamAdapter := TStreamAdapter.Create(VIEntry.Data);
    fVI.WriteToStream(DataStreamAdapter);
    // Save resource file containing a single RT_VERSION resource.
    // Note that it is possible to replace an existing resource and have more
    // than one different resource in a resource file, but that's beyond the
    // scope of this demo: see https://github.com/ddablib/resfile for more info.
    ResFile.SaveToFile(ResFilePath);
  finally
    ResFile.Free;
  end;
end;

end.


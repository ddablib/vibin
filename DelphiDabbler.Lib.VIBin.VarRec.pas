{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2002-2023, Peter Johnson (https://gravatar.com/delphidabbler).
 *
 * Classes that encapsulate general version information variable length records.
 * They expose properties for the key record elements and can also read and
 * write their data from and to a stream. There are classes for both 16 and 32
 * bit versions of the record format.
}

unit DelphiDabbler.Lib.VIBin.VarRec;

{$Include .\DelphiDabbler.Lib.VIBin.Defines.inc}

interface


uses
  // Delphi
  {$IFDEF Supports_ScopedUnitNames}
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.ActiveX,
  Vcl.AxCtrls;
  {$ELSE}
  SysUtils,
  Classes,
  Windows,
  ActiveX,
  AxCtrls;
  {$ENDIF}


type

  ///  <summary>Class reference to <c>TVIBinVarRec</c> and descendent classes.
  ///  </summary>
  TVIBinVarRecClass = class of TVIBinVarRec;

  ///  <summary>Abstract base class for classes that encapsulate 16 and 32 bit
  ///  version information records.</summary>
  ///  <remarks>
  ///  <para>Version information records are represented in binary format as a
  ///  heirachy of variable length records. The structure of 16 and 32 bit
  ///  version information records varies slightly, but has records of the
  ///  following general structure:</para>
  ///  <para><c>wLength</c>: length of structure including any children (Word).
  ///  </para>
  ///  <para><c>wValueLength</c>: length of value member (0 if no value)
  ///  (Word). May be inconsistent for wide string types (i.e. it may be
  ///  either number of wide chars in string (+ #0#0) or may be size of string
  ///  in bytes - so don't rely on this value when reading in wide string
  ///  values).</para>
  ///  <para><c>wType</c>: 32 bit records only: type of value (1=>wide string,
  ///  0=>binary) (Word)</para>
  ///  <para><c>szKey</c>: identifies record type - 32 bit records have a zero
  ///  terminated WChar array while 16 bit records have a zero terminated
  ///  AnsiChar array.</para>
  ///  <para><c>padding1</c>: array of bytes padding structure to DWORD
  ///  boundary.</para>
  ///  <para><c>value</c>: optional value (type/structure depends on record
  ///  type).</para>
  ///  <para><c>padding2</c>: array of bytes padding structure to DWORD
  ///  boundary.</para>
  ///  <para><c>children</c>: optional list of child version info structures.
  ///  </para>
  ///  <para>This class encapsulates a general version information record and
  ///  exposes properties for the key record elements. It can also read and
  ///  write its data from and to a stream. It provides the functionality common
  ///  to both 16 and 32 bit versions of the records and declares abstract
  ///  methods that specialised descendants override to account for the
  ///  differences between versions.</para>
  ///  </remarks>
  TVIBinVarRec = class(TObject)
  private
    ///  <summary>Value of <c>Name</c> property.</summary>
    fName: string;
    ///  <summary>Value of <c>DataType</c> property.</summary>
    fDataType: Word;
    ///  <summary>Read access method for <c>Children</c> property.</summary>
    function GetChild(I: Integer): TVIBinVarRec;
    ///  <summary>Read access method for <c>NumChildren</c> property.</summary>
    function GetNumChildren: Integer;
    ///  <summary>Read access method for <c>Value</c> property.</summary>
    function GetValue: Pointer;
  private
    ///  <summary>List of child record structures.</summary>
    fList: TList;
    ///  <summary>Buffer that stores the value associated with this record.
    ///  </summary>
    fValueBuffer: PByte;
    ///  <summary>Size of value buffer.</summary>
    fValueBufferSize: WORD;
    ///  <summary>Reference to version info record that is the parent of this
    ///  one: nil if this is the root record.</summary>
    fParent: TVIBinVarRec;
  protected
    ///  <summary>Returns reference to the type of class this is. Sub classes
    ///  return their own classes when overriding.</summary>
    ///  <remarks>Used to create child instances of the correct type.</remarks>
    function ClassRef: TVIBinVarRecClass; virtual; abstract;
    ///  <summary>Sets data type to given value.</summary>
    ///  <remarks>For use in descendent classes.</remarks>
    procedure SetDataType(AValue: Word);
    ///  <summary>Deletes the given child from the list of child objects.
    ///  </summary>
    procedure UnLink(const Child: TVIBinVarRec);
    ///  <summary>Allocates a buffer of given size to hold a value. Deallocates
    ///  any existing buffer first.</summary>
    procedure AllocateValueBuffer(const Size: Integer);
    ///  <summary>Deallocates any existing value buffer.</summary>
    procedure DeallocateValueBuffer;
    ///  <summary>Reads the version information record object using the given
    ///  reader stream and returns the number of bytes read.</summary>
    function ReadObject(const Reader: TStream): Integer;
    ///  <summary>Writes the version information record object's binary data
    ///  using the given writer stream and returns the number of bytes written.
    ///  </summary>
    function WriteObject(const Writer: TStream): Integer;
    ///  <summary>Reads any 'padding' bytes necessary to round BytesRead up to a
    ///  <c>DWORD</c> boundary. Returns the number of bytes read.</summary>
    function ReadPadding(const Reader: TStream; const BytesRead: Integer):
      Integer;
    ///  <summary>Writes sufficent zero bytes to pad the given number of bytes
    ///  to a <c>DWORD</c> boundary. Returns number of bytes written.</summary>
    function WritePadding(const Writer: TStream; const BytesWritten: Integer):
      Integer;
    ///  <summary>Reads the common header fields, and any padding characters,
    ///  from any version information structure. Returns number of bytes read.
    ///  </summary>
    ///  <remarks>Descendants must implement since the header format varies
    ///  between 16 and 32 bit version information.</remarks>
    function ReadHeader(const Reader: TStream; out RecSize, ValueSize,
      DataType: Word; out KeyName: string): Integer; virtual; abstract;
    ///  <summary>Writes the common header fields, and any padding characters,
    ///  from any version info structure. The position where the record size is
    ///  written is passed back in <c>RecSizePos</c>. Returns number of bytes
    ///  written.</summary>
    ///  <remarks>
    ///  <para><c>RecSizePos</c> is used to return to the correct position to
    ///  write the record size once it has been calculated.</para>
    ///  <para>Descendants must implement since the header format varies between
    ///  16 and 32 bit version information.</para>
    ///  </remarks>
    function WriteHeader(const Writer: TStream; out RecSizePos: LongInt):
      Integer; virtual; abstract;
    ///  <summary>Converts the text value pointed to by <c>ValuePtr</c> to a
    ///  string.</summary>
    ///  <remarks><c>ValuePtr</c> will point to an ANSI string for 16 bit format
    ///  and WideString for 32 bit format, so descendants must implement.
    ///  </remarks>
    function ValuePtrToStr(const ValuePtr: Pointer): string; virtual; abstract;
  public
    ///  <summary>Object constructor. Creates a top level version information
    ///  i.e. one with no parent.</summary>
    constructor Create; overload;

    ///  <summary>Object constructor. Creates a version information record with
    ///  a given parent record.</summary>
    ///  <param name="Parent"><c>TVIBinVarRec</c> [in] Parent record.</param>
    constructor Create(const Parent: TVIBinVarRec); overload;

    ///  <summary>Object destructor. Frees any allocated buffer, all child
    ///  objects and owned object.</summary>
    destructor Destroy; override;

    ///  <summary>Clears record, destroying all data and child records.
    ///  </summary>
    procedure Clear;

    ///  <summary>Returns size of value buffer.</summary>
    function GetValueSize: Integer;

    ///  <summary>Sets value buffer to a binary value. Sets data type to
    ///  <c>0</c></summary>
    ///  <param name="Buffer">Untyped [in] Reference to data to be copied to
    ///  value buffer.</param>
    ///  <param name="Size"><c>Integer</c> [in] Size of data in <c>Buffer</c>.
    ///  </param>
    procedure SetBinaryValue(const Buffer; const Size: Integer);

    ///  <summary>Sets value buffer to the content of a string.</summary>
    ///  <param name="Str"><c>string</c> [in] String to be copied to value
    ///  buffer.</param>
    ///  <remarks>Descendants must copy string in required ANSI or Wide format
    ///  and set data type to 0 for 16 bit (ANSI) strings or 1 for 32 bit (wide)
    ///  strings.</remarks>
    procedure SetStringValue(const Str: string); virtual; abstract;

    ///  <summary>Gets the data from the value buffer as a string and returns
    ///  it.</summary>
    ///  <returns><c>string</c> String from value buffer.</returns>
    ///  <remarks>Internally this will be stored as either an ANSI string or a
    ///  Wide string.</remarks>
    function GetStringValue: string;

    ///  <summary>Reads a version information record structure, along with any
    ///  child structures, from a stream.</summary>
    ///  <param name="Stream"><c>IStream</c> [in] Stream to be read from.
    ///  </param>
    procedure ReadFromStream(const Stream: IStream);

    ///  <summary>Writes the encapsulated version information record structure,
    ///  along with any child structures, to a stream.</summary>
    ///  <param name="Stream"><c>IStream</c> [in] Stream to be written to.
    ///  </param>
    procedure WriteToStream(const Stream: IStream);

    ///  <summary>Array of child version information structures parented by this
    ///  object.</summary>
    ///  <param name="I"><c>Integer</c> [in] Index into array.</param>
    ///  <returns><c>TVIBinVarRec</c>. Child record at index <c>I</c>.</returns>
    property Children[I: Integer]: TVIBinVarRec read GetChild;

    ///  <summary>Number of child structures parented by this object.</summary>
    ///  <returns><c>Integer</c> Number of child structure.</returns>
    property NumChildren: Integer read GetNumChildren;

    ///  <summary>Name of this record.</summary>
    ///  <returns><c>string</c>. The name.</returns>
    property Name: string read fName write fName;

    ///  <summary>Pointer to any value associated with this object.</summary>
    ///  <returns><c>Pointer</c>. Value pointer.</returns>
    property Value: Pointer read GetValue;

    ///  <summary>Code indicating type of data associated with this record.
    ///  </summary>
    ///  <returns><c>Word</c>. 0 for ANSI string or binary data, 1 for Wide
    ///  string.</returns>
    property DataType: Word read fDataType;
  end;

  ///  <summary>Implements a generalised 16 bit version information record.
  ///  </summary>
  ///  <remarks>Simply provides implementations for abstract methods of the base
  ///  class.</remarks>
  TVIBinVarRecA = class(TVIBinVarRec)
  protected
    ///  <summary>Returns reference to this class type.</summary>
    ///  <remarks>Used to create child instances of the correct type.</remarks>
    function ClassRef: TVIBinVarRecClass; override;
    ///  <summary>Reads the common header fields, and any padding characters,
    ///  from a 16 bit version information structure. Returns number of bytes
    ///  read.</summary>
    function ReadHeader(const Reader: TStream; out RecSize, ValueSize,
      DataType: Word; out KeyName: string): Integer; override;
    ///  <summary>Writes the common header fields, and any padding characters,
    ///  from a 16 bit version info structure. The position where the record
    ///  size is written is passed back in <c>RecSizePos</c>. Returns number of
    ///  bytes written.</summary>
    ///  <remarks><c>RecSizePos</c> is used to return to the correct position to
    ///  write the record size once it has been calculated.</remarks>
    function WriteHeader(const Writer: TStream; out RecSizePos: LongInt):
      Integer; override;
    ///  <summary>Converts the text value pointed to by <c>ValuePtr</c> to an
    ///  ANSI string.</summary>
    function ValuePtrToStr(const ValuePtr: Pointer): string; override;
  public
    ///  <summary>Sets value buffer to the content of an ANSI string.</summary>
    ///  <param name="Str"><c>string</c> [in] String to be copied to value
    ///  buffer.</param>
    procedure SetStringValue(const Str: string); override;
  end;

  ///  <summary>Implements a generalised 32 bit version information record.
  ///  </summary>
  ///  <remarks>Simply provides implementations for abstract methods of the base
  ///  class.</remarks>
  TVIBinVarRecW = class(TVIBinVarRec)
  protected
    ///  <summary>Returns reference to this class type.</summary>
    ///  <remarks>Used to create child instances of the correct type.</remarks>
    function ClassRef: TVIBinVarRecClass; override;
    ///  <summary>Reads the common header fields, and any padding characters,
    ///  from a 32 bit version information structure. Returns number of bytes
    ///  read.</summary>
    function ReadHeader(const Reader: TStream; out RecSize, ValueSize,
      DataType: Word; out KeyName: string): Integer; override;
    ///  <summary>Writes the common header fields, and any padding characters,
    ///  from a 32 bit version info structure. The position where the record
    ///  size is written is passed back in <c>RecSizePos</c>. Returns number of
    ///  bytes written.</summary>
    ///  <remarks><c>RecSizePos</c> is used to return to the correct position to
    ///  write the record size once it has been calculated.</remarks>
    function WriteHeader(const Writer: TStream; out RecSizePos: LongInt):
      Integer; override;
    ///  <summary>Converts the text value pointed to by <c>ValuePtr</c> to a
    ///  Wide string.</summary>
    function ValuePtrToStr(const ValuePtr: Pointer): string; override;
  public
    ///  <summary>Sets value buffer to the content of a Wide string.</summary>
    ///  <param name="Str"><c>string</c> [in] String to be copied to value
    ///  buffer.</param>
    procedure SetStringValue(const Str: string); override;
  end;

  ///  <summary>Class of exception raised by TVersionInfoRec instances.
  ///  </summary>
  EVIBinVarRec = class(Exception);


implementation


resourcestring
  // Error messages
  sNoVerInfo = 'No version information present.';
  sVerInfoCorrupt = 'Version information data is corrupt.';

{ Support routine }

///  <summary>Returns number of bytes of padding required to increase
///  <c>ANum</c> to a multiple of <c>PadTo</c>.</summary>
function PaddingRequired(const ANum, PadTo: Integer): Integer;
begin
  if ANum mod PadTo = 0 then
    Result := 0
  else
    Result := PadTo - ANum mod PadTo;
end;

{ TVIBinVarRec }

procedure TVIBinVarRec.AllocateValueBuffer(const Size: Integer);
begin
  DeallocateValueBuffer;
  fValueBufferSize := Size;
  GetMem(fValueBuffer, fValueBufferSize);
end;

procedure TVIBinVarRec.Clear;
var
  I: Integer; // loops thru all child objects
begin
  // Free any currently allocated value buffer
  DeallocateValueBuffer;
  // Free all child objects
  for I := fList.Count - 1 downto 0 do
    GetChild(I).Free;
  Assert(fList.Count = 0);  // should all have unlinked themselves
  // Reset other fields - leave name field unchanged
  SetDataType(0);
end;

constructor TVIBinVarRec.Create;
begin
  // Simply create with nil owner
  Create(nil);
end;

constructor TVIBinVarRec.Create(const Parent: TVIBinVarRec);
begin
  inherited Create;
  // Create list to store child records
  fList := TList.Create;
  // Record parent, and add self into any parent's list of children
  fParent := Parent;
  if fParent <> nil then
    fParent.fList.Add(Self);
  // Clear this new record to default values
  Clear;
end;

procedure TVIBinVarRec.DeallocateValueBuffer;
begin
  if fValueBufferSize > 0 then
  begin
    FreeMem(fValueBuffer, fValueBufferSize);
    fValueBufferSize := 0;
  end;
end;

destructor TVIBinVarRec.Destroy;
begin
  // Get rid of owned objects
  Clear;
  // Free owned list
  fList.Free;
  // Unlink from parent's list
  if fParent <> nil then
    fParent.Unlink(Self);
  inherited Destroy;
end;

function TVIBinVarRec.GetChild(I: Integer): TVIBinVarRec;
begin
  Result := TVIBinVarRec(fList[I]);
end;

function TVIBinVarRec.GetNumChildren: Integer;
begin
  Result := fList.Count;
end;

function TVIBinVarRec.GetStringValue: string;
var
  ValuePtr: Pointer;  // points to buffer containing string value
begin
  // Get pointer to value buffer (has value nil if there is no value buffer)
  ValuePtr := GetValue;
  if Assigned(ValuePtr) then
    Result := ValuePtrToStr(ValuePtr)
  else
    // No value buffer: return empty string
    Result := '';
end;

function TVIBinVarRec.GetValue: Pointer;
begin
  if fValueBufferSize = 0 then
    // There is no value, return nil
    Result := nil
  else
    // There is a value, return a pointer to it
    Result := fValueBuffer;
end;

function TVIBinVarRec.GetValueSize: Integer;
begin
  Result := fValueBufferSize;
end;

procedure TVIBinVarRec.ReadFromStream(const Stream: IStream);
var
  Reader: TStream;  // Adapts IStream as TStream
begin
  // Use a reader object to read from stream
  Reader := TOleStream.Create(Stream);
  try
    // Get object to read itself using reader
    ReadObject(Reader);
  finally
    Reader.Free;
  end;
end;

function TVIBinVarRec.ReadObject(const Reader: TStream): Integer;
var
  wLength, wValueLength: WORD;  // length of structure and Value member
  Child: TVIBinVarRec;           // reference to child record objects
  WC: WideChar;                 // wide character read from value string
  WValue: WideString;           // wide string to hold wide string value
  WVIdx: Integer;               // index into wide string buffer
  StartPos: Integer;            // stream position of start of record
  HeaderSize: Integer;          // size of header inc padding
  ValueSize: Integer;           // size of value adjusted for WChare exc padding
  ChildrenOffset: Integer;      // offset of start of any child records
  ChildrenSize: Integer;        // total size of all child records
  ChildrenBytesRead: Integer;   // number of bytes read from child data
begin
  // Check there's something to read
  if Reader.Size = 0 then
    raise EVIBinVarRec.Create(sNoVerInfo);
  try
    // Clear the existing contents
    Clear;
    // Record position of start of record in stream
    StartPos := Reader.Position;
    // Read header: i.e. record size, value length, data type  & key name
    HeaderSize := ReadHeader(Reader, wLength, wValueLength, fDataType, fName);
    // Calculate size of value (adjust for WChars if data type = 1)
    if fDataType = 0 then
      ValueSize := wValueLength
    else
      ValueSize := SizeOf(WChar) * wValueLength;
    // Calculate offset of any child records and total size of the records
    ChildrenOffset := HeaderSize + ValueSize
      + PaddingRequired(ValueSize, SizeOf(DWORD));
    ChildrenSize := wLength - ChildrenOffset;
    // Check if we need to read in a value
    if wValueLength > 0 then
    begin
      // We are reading in a value - method we use depends on type of data
      if fDataType = 0 then
      begin
        // We are reading in ansi data - simply read number of bytes per
        //   wValueLength
        //
        // this code assumes that bytes and ansi chars have size 1
        Assert(SizeOf(Byte) = 1);
        Assert(SizeOf(AnsiChar) = 1);
        // we're reading a value - allocate required buffer size
        AllocateValueBuffer(wValueLength);    // binary bytes or ansi char value
        // read in the buffer and count the bytes
        Reader.ReadBuffer(fValueBuffer^, fValueBufferSize);
      end
      else
      begin
        // We are reading in wide char data. We can't rely on wValueLength to
        //   tell us amount of data to read since some ver info compilers set
        //   this value to length of string and some to size of buffer (i.e.
        //   length of string * SizeOf(WideChar) and some even pad with rubbish
        //   characters following end of string #0#0 to the (wrong) size of the
        //   value (e.g. Wise installer files)!!
        //
        // So we create a wide string of sufficient size to hold value and read
        //   each wide character into it until terminating #0#0 is read. We then
        //   store this string in value buffer. This method (rather than direct
        //   read into buffer) creates a buffer of correct size to store value,
        //   thereby ensuring that correct value length is written when data is
        //   output, regardless of wValueLength.
        //
        // WARNING: Because of this workaround, we can't detect any Children
        //   following a WideString value. Since we can't rely on wValueLength
        //   being set correctly, we can't use it to find the offset of a
        //   Children node. Luckily, the only time wide string values occur is
        //   in String type nodes and String nodes never have a Children node.
        //   Unfortunately, although this class is supposed to be general and
        //   should work without knowledge of the type of the node, we do need
        //   to assume that any node with wide string will not have children.

        // Create wide string of sufficent size (may be either correct size or
        //   twice size required depending on meaning of wValueLength)
        SetLength(WValue, wValueLength);
        // Read in wide string up to and including terminating #0#0
        // .. initialise index into wide string
        WVIdx := 1;
        repeat
          // .. read a single char and record in string
          Reader.ReadBuffer(WC, SizeOf(WideChar));
          WValue[WVIdx] := WC;
          // .. move up string and count bytes read
          Inc(WVIdx);
        until Ord(WC) = 0;
        // .. set string to actual length
        SetLength(WValue, WVIdx);
        // .. store string in value buffer (ensures buffer of correct size)
        SetStringValue(WValue);
      end;
    end;
    // Now read in any Children records
    if ChildrenSize > 0 then
    begin
      // initialise: no bytes read and set stream pointer to start of child data
      ChildrenBytesRead := 0;
      Reader.Seek(StartPos + ChildrenOffset, STREAM_SEEK_SET);
      // loop while there are still bytes to be read from child data
      while ChildrenBytesRead < ChildrenSize do
      begin
        // create next child and add to list
        Child := ClassRef.Create(Self);
        // get child to read itself, counting bytes read
        ChildrenBytesRead := ChildrenBytesRead + Child.ReadObject(Reader);
      end;
    end;
    // Seek to start of next record (if any) and return bytes read
    Result := wLength + PaddingRequired(wLength, SizeOf(DWORD));
    Reader.Seek(StartPos + Result, STREAM_SEEK_SET);
  except
    // Convert any stream errors into a version info record corrupt exception
    on E: EStreamError do
      raise EVIBinVarRec.Create(sVerInfoCorrupt);
    on E: Exception do
      raise;
  end;
end;

function TVIBinVarRec.ReadPadding(const Reader: TStream;
  const BytesRead: Integer): Integer;
var
  PadBuf: array[0..SizeOf(DWORD)-1] of Byte;    // buffer to read padding into
begin
  // Find padding required
  Result := PaddingRequired(BytesRead, SizeOf(DWORD));
  if Result > 0 then
    // Some padding required: read and discard it
    Reader.ReadBuffer(PadBuf, Result);
end;

procedure TVIBinVarRec.SetBinaryValue(const Buffer; const Size: Integer);
begin
  // Allocate value buffer of required size and copy the given data buffer to it
  AllocateValueBuffer(Size);
  Move(Buffer, fValueBuffer^, Size);
  // Data type is 0
  SetDataType(0);
end;

procedure TVIBinVarRec.SetDataType(AValue: Word);
begin
  fDataType := AValue;
end;

procedure TVIBinVarRec.UnLink(const Child: TVIBinVarRec);
var
  Index: Integer; // index of child in list of children
begin
  // Find index of child in list of children: it must be in list
  Index := fList.IndexOf(Child);
  Assert(Index <> -1);
  // Delete the list entry for the child
  fList.Delete(Index);
end;

function TVIBinVarRec.WriteObject(const Writer: TStream): Integer;
var
  RecSize: WORD;            // size of header section of record
  I: Integer;               // loops thru children
  RecSizePos: LongInt;      // marks position of record size field in stream
  ValuePadding: WORD;       // bytes needed to pad Value to DWORD boundary
begin
  // Write header with dummy record size field, record position of this field
  Result := WriteHeader(Writer, RecSizePos);
  // Write out any value
  if fValueBufferSize > 0 then
  begin
    // write out the data
    Writer.WriteBuffer(fValueBuffer^, fValueBufferSize);
    Inc(Result, fValueBufferSize);
    // pad out value to DWORD boundary, recording how many byes written
    ValuePadding := WritePadding(Writer, Result);
    Result := Result + ValuePadding;
  end
  else
    // no value => no padding
    ValuePadding := 0;
  // Write out any children, recording bytes written
  for I := 0 to NumChildren - 1 do
    Result := Result + Children[I].WriteObject(Writer);
  // Now update record size
  // record size is number of bytes written less any padding after value
  RecSize := Result - ValuePadding;
  // rewind stream
  Writer.Seek(RecSizePos, STREAM_SEEK_SET);
  // write new value
  Writer.WriteBuffer(RecSize, SizeOf(RecSize));
  // go back to end of stream
  Writer.Seek(0, STREAM_SEEK_END);
end;

function TVIBinVarRec.WritePadding(const Writer: TStream;
  const BytesWritten: Integer): Integer;
var
  PadBuf: array[0..SizeOf(DWORD)-1] of Byte;    // buffer holding padding bytes
begin
  // Find padding required
  Result := PaddingRequired(BytesWritten, SizeOf(DWORD));
  if Result > 0 then
  begin
    // Some padding is required - output required no of zero bytes
    FillChar(PadBuf, Result, #0);
    Writer.WriteBuffer(PadBuf, Result);
  end;
end;

procedure TVIBinVarRec.WriteToStream(const Stream: IStream);
var
  Writer: TStream;  // Adapts IStream as TStream
begin
  // We use a writer object to perform actual writing to stream
  Writer := TOleStream.Create(Stream);
  try
    // Get object to write itself using writer object
    WriteObject(Writer);
  finally
    Writer.Free;
  end;
end;

{ TVIBinVarRecA }

function TVIBinVarRecA.ClassRef: TVIBinVarRecClass;
begin
  Result := TVIBinVarRecA;
end;

function TVIBinVarRecA.ReadHeader(const Reader: TStream; out RecSize, ValueSize,
  DataType: Word; out KeyName: string): Integer;
var
  KeyChar: AnsiChar;  // character in key name
begin
  // Read first three word values
  Reader.ReadBuffer(RecSize, SizeOf(Word));
  Reader.ReadBuffer(ValueSize, SizeOf(Word));
  DataType := 0;
  Result := 2 * SizeOf(Word);
  // Read key name
  KeyName := '';
  repeat
    Reader.ReadBuffer(KeyChar, SizeOf(AnsiChar));
    Inc(Result, SizeOf(AnsiChar));
    if KeyChar <> #0 then
      KeyName := KeyName + WideChar(KeyChar);
  until KeyChar = #0;
  // Skip any padding to DWORD boundary
  Result := Result + ReadPadding(Reader, Result);
end;

procedure TVIBinVarRecA.SetStringValue(const Str: string);
var
  BufLen: Integer;  // required value buffer size
  StrA: AnsiString; // ANSI string conversion of Str
begin
  // Allocate value buffer of required size
  StrA := AnsiString(Str);
  BufLen := SizeOf(AnsiChar) * (Length(StrA) + 1);
  AllocateValueBuffer(BufLen);
  // Store given string as an ANSI string in buffer
  Move(PAnsiChar(StrA)^, fValueBuffer^, BufLen);
  // Data type is always 0
  SetDataType(0);
end;

function TVIBinVarRecA.ValuePtrToStr(const ValuePtr: Pointer): string;
var
  Value: AnsiString;
begin
  Value := PAnsiChar(ValuePtr);
  Result := UnicodeString(Value);
end;

function TVIBinVarRecA.WriteHeader(const Writer: TStream;
  out RecSizePos: Integer): Integer;
var
  RecSize: Word;    // dummy value for record: written as a placeholder
  ValueSize: Word;  // size of value buffer as a Word value
  Key: AnsiString;  // the key to be written out as ansi string
begin
  // Don't know record size yet - mark place & write dummy value to come back to
  RecSize := 0;                                       // dummy record size value
  RecSizePos := Writer.Position;                 // gets current stream position
  Writer.WriteBuffer(RecSize, SizeOf(Word));               // writes dummy value
  // Write size of value data
  ValueSize := GetValueSize;
  Writer.WriteBuffer(ValueSize, SizeOf(Word));
  // Record number of bytes written
  Result := 2 * SizeOf(Word);
  // write key as zero termitaed ANSI string
  Assert(SizeOf(AnsiChar) = 1);
  Key := AnsiString(Name);
  Writer.WriteBuffer(PAnsiChar(Key)^, Length(Key) + 1);
  Inc(Result, Length(Key) + 1);
  // pad key out to DWORD boundary
  Result := Result + WritePadding(Writer, Result);
end;

{ TVIBinVarRecW }

function TVIBinVarRecW.ClassRef: TVIBinVarRecClass;
begin
  Result := TVIBinVarRecW;
end;

function TVIBinVarRecW.ReadHeader(const Reader: TStream; out RecSize, ValueSize,
  DataType: Word; out KeyName: string): Integer;
var
  KeyChar: WideChar;  // character in key name
begin
  // Read first three word values
  Reader.ReadBuffer(RecSize, SizeOf(RecSize));
  Reader.ReadBuffer(ValueSize, SizeOf(ValueSize));
  Reader.ReadBuffer(DataType, SizeOf(DataType));
  Result := 3 * SizeOf(Word);
  // Read key name
  KeyName := '';
  repeat
    Reader.ReadBuffer(KeyChar, SizeOf(WChar));
    Inc(Result, SizeOf(KeyChar));
    if KeyChar <> #0 then
      KeyName := KeyName + KeyChar;
  until KeyChar = #0;
  // Skip any padding to DWORD boundary
  Result := Result + ReadPadding(Reader, Result);
end;

procedure TVIBinVarRecW.SetStringValue(const Str: string);
var
  BufLen: Integer;  // required value buffer size
begin
  // Allocate value buffer of required size
  BufLen := SizeOf(WideChar) * (Length(Str) + 1);
  AllocateValueBuffer(BufLen);
  // Store given string as a wide string in buffer
  Move(PWideChar(Str)^, fValueBuffer^, BufLen);
  // Data type is 1
  SetDataType(1);
end;

function TVIBinVarRecW.ValuePtrToStr(const ValuePtr: Pointer): string;
var
  Value: UnicodeString;
begin
  Value := PWideChar(ValuePtr);
  Result := Value;
end;

function TVIBinVarRecW.WriteHeader(const Writer: TStream;
  out RecSizePos: Integer): Integer;
var
  RecSize: Word;            // dummy record size: this is actually written later
  ValueSize: Word;          // size of value data
  UnicodeBufSize: Integer;  // size of buffer to store key as wide string
  UnicodeBuf: PWideChar;    // buffer to store key as wide string
  Key: string;              // name of key as string
  DataTypeVal: Word;        // value used to write data type as word
begin
  // Don't know record size yet - mark place & write dummy value to come back to
  RecSize := 0;                                       // dummy record size value
  RecSizePos := Writer.Position;                 // gets current stream position
  Writer.WriteBuffer(RecSize, SizeOf(Word));               // writes dummy value
  // Write size of value data
  if DataType = 0 then
    ValueSize := GetValueSize                          // number of bytes in buf
  else
    ValueSize := GetValueSize div SizeOf(WChar);      // number of wchars in buf
  Writer.WriteBuffer(ValueSize, SizeOf(Word));
  // Write record data type
  DataTypeVal := DataType;
  Writer.WriteBuffer(DataTypeVal, SizeOf(Word));
  // Record number of bytes written
  Result := 3 * SizeOf(Word);
  // Write key as Unicode
  Key := Name;
  UnicodeBufSize := SizeOf(WideChar) * (Length(Key) + 1);
  GetMem(UnicodeBuf, UnicodeBufSize);
  try
    Move(PWideChar(Key)^, UnicodeBuf^, UnicodeBufSize);
    Writer.WriteBuffer(UnicodeBuf^, UnicodeBufSize);
    Inc(Result, UnicodeBufSize);
  finally
    FreeMem(UnicodeBuf, UnicodeBufSize);
  end;
  // pad key out to DWORD boundary
  Result := Result + WritePadding(Writer, Result);
end;

end.


{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2002-2023, Peter Johnson (https://gravatar.com/delphidabbler).
 *
 * Class that encapsulates a binary version information resource and exposes
 * methods that permit the resource to be read and modified.
}

unit DelphiDabbler.Lib.VIBin.Resource;

{$Include .\DelphiDabbler.Lib.VIBin.Defines.inc}

interface

uses
  // Delphi
  {$IFDEF Supports_ScopedUnitNames}
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.ActiveX,
  {$ELSE}
  SysUtils,
  Classes,
  Windows,
  ActiveX,
  {$ENDIF}
  // Project
  DelphiDabbler.Lib.VIBin.VarRec;

type

  ///  <summary>Enumeration that specifies the type of a version information
  ///  resource.</summary>
  ///  <remarks>
  ///  <para><c>vrtAnsi</c>: 16 bit resource with ANSI strings.</para>
  ///  <para><c>vrtUnicode</c>: 32 bit resource with Unicode strings.</para>
  ///  </remarks>
  TVerResType =(
    vrtAnsi,
    vrtUnicode
  );

  ///  <summary>Class that encapsulates the binary representation of version
  ///  information and exposes properties and methods that permit this data to
  ///  be read and modified.</summary>
  ///  <remarks>The version information is maintained as a tree of variable
  ///  length records, each record being interpreted according to a key
  ///  associated with the record. <c>TVerInfoRec</c> objects are used to
  ///  encapsulate the generic version information records while
  ///  <c>TVerInfoData</c> interprets their meaning.</remarks>
  TVerInfoData = class(TObject)
  private
    ///  <summary>Records the type of resource we're accessing (16 or 32 bit).
    ///  </summary>
    fVerResType: TVerResType;
    ///  <summary>Reference to root version information record that acts as root
    ///  of record tree and stores fixed file information.</summary>
    fVIRoot: TVerInfoRec;
    ///  <summary>Returns class of version info record object to be created.
    ///  </summary>
    function VerInfoRecClass: TVerInfoRecClass;
    ///  <summary>Raises a <c>EVerInfoData</c> exception formatted from given
    ///  format string and arguments.</summary>
    procedure Error(const FmtStr: string; const Args: array of const);
    ///  <summary>Finds the first child record of the given <c>root</c> record
    ///  that has the given <c>Name</c> and returns a reference to it. If no
    ///  such child record exists then <c>nil</c> is returned.</summary>
    function FindChildByName(const Root: TVerInfoRec;
      const Name: string): TVerInfoRec;
    ///  <summary>Examines the list of child nodes of version info record
    ///  <c>Root</c> and returns the index in the list of the the child record
    ///  with name <c>Name</c> or -1 if there is no such child record.</summary>
    function IndexOfChildByName(const Root: TVerInfoRec;
      const Name: string): Integer;
    ///  <summary>Returns reference to the <c>VarFileInfo</c> record which must
    ///  exist.</summary>
    function GetVarFileInfoRoot: TVerInfoRec;
    ///  <summary>Returns a reference to the version information record that
    ///  stores information about all supported translations - i.e. the
    ///  <c>Translation</c> record, which must exist.</summary>
    function GetTranslationRec: TVerInfoRec;
    ///  <summary>Returns reference to the <c>StringFileInfo</c> record, which
    ///  must exist.</summary>
    function GetStringFileInfoRoot: TVerInfoRec;
    ///  <summary>Returns reference to the string file information table at
    ///  child index <c>TableIdx</c> in the <c>StringFileInfo</c> record. Raises
    ///  an exception if <c>TableIdx</c> is out of range.</summary>
    function GetStringFileInfoTable(TableIdx: Integer): TVerInfoRec;
    ///  <summary>Returns a reference to the string file information record at
    ///  index <c>StrIdx</c> in the string table at child index <c>TableIdx</c>
    ///  in the <c>StringFileInfo</c> record. Raises exception if
    ///  <c>TableIdx</c> or <c>StrIdx</c> are out of bounds.</summary>
    function GetStringFileInfoItem(TableIdx, StrIdx: Integer): TVerInfoRec;
    ///  <summary>Returns the number of translations in the version information
    ///  record <c>TransRec</c>.</summary>
    function InternalGetTranslationCount(TransRec: TVerInfoRec): Integer;
    ///  <summary>Returns the translation code stored at index <c>TransIdx</c>
    ///  in the translation list.</summary>
    function InternalGetTranslation(TransIdx: Integer): DWORD;
    ///  <summary>Sets the translation code of the translation at index
    ///  <c>TransIdx</c> to <c>Value</c>.</summary>
    procedure InternalSetTranslation(TransIdx: Integer; Value: DWORD);
    ///  <summary>Ensures that the compulsory version information data nodes are
    ///  present.</summary>
    procedure EnsureRequiredNodes;
    ///  <summary>Creates a new child node (i.e. record) of <c>Owner</c>. The
    ///  new node is created with the correct type (i.e. 16 or 32 bit) and is
    ///  given name <c>Name</c>.</summary>
    function CreateNode(Owner: TVerInfoRec; const Name: string): TVerInfoRec;
    ///  <summary>Decodes translation code <c>Trans</c> into its constituent
    ///  language ID and character set components and passes these out in the
    ///  <c>Language</c> and <c>CharSet</c> parameters.</summary>
    class procedure DecodeTrans(const Trans: DWORD;
      out Language, CharSet: WORD);
    ///  <summary>Decodes translation string <c>TransStr</c> into its
    ///  constituent language ID and character set components and passes these
    ///  out in the <c>Language</c> and <c>CharSet</c> parameters.</summary>
    class procedure DecodeTransStr(const TransStr: string;
      out Language, CharSet: WORD);
    ///  <summary>Updates the given translation code <c>OldTrans</c> with the
    ///  either or both of language ID <c>Language</c> and <c>CharSet</c> codes
    ///  and returns the revised translation code. If either of these codes are
    ///  <c>$FFFF</c> they are ignored and not updated.</summary>
    class function EncodeTrans(const OldTrans: DWORD;
      const Language, CharSet: WORD): DWORD;
    ///  <summary>Updates fixed file info structure <c>FFI</c> as necessary to
    ///  ensure it has the correct version and signature fields.</summary>
    ///  <remarks>The version field always represents v1.0 and the signature is
    ///  always <c>$FEEF04BD</c>.</remarks>
    class procedure StampFFI(var FFI: TVSFixedFileInfo);
  public
    ///  <summary>Object constructor: creates a new version information object
    ///  its default state.</summary>
    ///  <param name="VerResType"><c>TVerResType</c> [in] Indicates whether this
    ///  is to be a 16 or 32 bit version information object.</param>
    ///  <remarks>See the <c>Reset</c> method for a description of 'default
    ///  state'</remarks>
    constructor Create(VerResType: TVerResType);

    ///  <summary>Object destructor.</summary>
    destructor Destroy; override;

    // General methods

    ///  <summary>Resets the version information object to the default state.
    ///  </summary>
    ///  <remarks>The default state is a version information object containing
    ///  a root record with an empty fixed file info, an empty string
    ///  information sub tree and a variable file info subtree containig an
    ///  empty translation entry.</remarks>
    procedure Reset;

    ///  <summary>Reads the binary representation of the version information
    ///  from a stream, parses it and stores it in this object.</summary>
    ///  <param name="Stream"><c>IStream</c> Stream from which to read.</param>
    procedure ReadFromStream(const Stream: IStream);

    ///  <summary>Writes the binary representation of the version information
    ///  to a stream.</summary>
    ///  <param name="Stream"><c>IStream</c> Stream to be written to.</param>
    procedure WriteToStream(const Stream: IStream);

    ///  <summary>Copies the contents of another source object to this
    ///  object, making the content of the two objects the same.</summary>
    ///  <param name="Source"><c>TVerInfoData</c> [in] Object whose content is
    ///  copied.</param>
    ///  <remarks>This method can be used to convert a 16 bit resource into a
    ///  32 bit resource and vice versa if one object is created as 16 bit and
    ///  the other as 32 bit.</remarks>
    procedure Assign(const Source: TVerInfoData);

    // Fixed file information methods

    ///  <summary>Gets the version information's fixed file information record.
    ///  </summary>
    ///  <returns><c>TVSFixedFileInfo</c>. The fixed file information record.
    ///  </returns>
    function GetFixedFileInfo: TVSFixedFileInfo;

    ///  <summary>Sets the version information's fixed file information record
    ///  to a copy of a given record.</summary>
    ///  <param name="Value"><c>TVSFixedFileInfo</c> [in] The fixed file
    ///  information record to be used.</param>
    ///  <remarks>This method ensures that the fixed file information record's
    ///  version and signature fields are set to the correct values, regardless
    ///  of what they are set to in <c>Value</c>.</remarks>
    procedure SetFixedFileInfo(const Value: TVSFixedFileInfo);

    // Variable info methods

    ///  <summary>Gets the number of translations in the version information.
    ///  </summary>
    ///  <returns><c>Integer</c>. The number of translations.</returns>
    function GetTranslationCount: Integer;

    ///  <summary>Gets the language ID of a translation.</summary>
    ///  <param name="TransIdx"><c>Integer</c> [in] Index of the required
    ///  translation in the translation table.</param>
    ///  <returns><c>Word</c>. The required language ID.</returns>
    ///  <exception><c>EVerInfoData</c> raised if <c>TransIdx</c> is out of
    ///  bounds.</exception>
    function GetTranslationLanguageID(TransIdx: Integer): Word;

    ///  <summary>Gets the character set a translation.</summary>
    ///  <param name="TransIdx"><c>Integer</c> [in] Index of the required
    ///  translation in the translation table.</param>
    ///  <returns><c>Word</c>. The required character set code.</returns>
    ///  <exception><c>EVerInfoData</c> raised if <c>TransIdx</c> is out of
    ///  bounds.</exception>
    function GetTranslationCharSet(TransIdx: Integer): Word;

    ///  <summary>Gets the translation code string of a translation.</summary>
    ///  <param name="TransIdx"><c>Integer</c> [in] Index of the required
    ///  translation in the translation table.</param>
    ///  <returns><c>Word</c>. The required character set code.</returns>
    ///  <exception><c>EVerInfoData</c> raised if <c>TransIdx</c> is out of
    ///  bounds.</exception>
    function GetTranslationString(TransIdx: Integer): string;

    ///  <summary>Sets a translation to have a given language ID and character
    ///  set code.</summary>
    ///  <param name="TransIdx"><c>Integer</c> [in] Index of the required
    ///  translation in the translation table.</param>
    ///  <param name="LanguageID"><c>Word</c> [in] Required language ID. If
    ///  value is $FFFF then the language ID is not updated.</param>
    ///  <param name="CharSet"><c>Word</c> [in] Code of required character set.
    ///  If value is $FFFF then the character set code is not updated.</param>
    ///  <exception><c>EVerInfoData</c> raised if <c>TransIdx</c> is out of
    ///  bounds.</exception>
    procedure SetTranslation(TransIdx: Integer; LanguageID, CharSet: Word);

    ///  <summary>Adds a new translation to the translation table.</summary>
    ///  <param name="LanguageID"><c>Word</c> [in] Required language ID. If
    ///  value is $FFFF then the language ID is set to 0.</param>
    ///  <param name="CharSet"><c>Word</c> [in] Code of required character set.
    ///  If value is $FFFF then the character set code is set to 0.</param>
    ///  <returns><c>Integer</c>. Index of the new translation in the
    ///  translation table.</returns>
    function AddTranslation(LanguageID, CharSet: Word): Integer;

    ///  <summary>Deletes a translation from the translation table.</summary>
    ///  <param name="TransIdx"><c>Integer</c> [in] Index of the translation to
    ///  be deleted in the translation table.</param>
    ///  <exception><c>EVerInfoData</c> raised if <c>TransIdx</c> is out of
    ///  bounds.</exception>
    procedure DeleteTranslation(TransIdx: Integer);

    ///  <summary>Finds the index of a translation in the translation table.
    ///  </summary>
    ///  <param name="LanguageID"><c>Word</c> [in] Language ID of the required
    ///  translation. A value of $FFFF is converted to 0.</param>
    ///  <param name="CharSet"><c>Word</c> [in] Character set code of the
    ///  required translation. A value of $FFFF is converted to 0.</param>
    ///  <returns><c>Integer</c>. Index of the translation in the translation
    ///  table, or -1 if the translation is not found.</returns>
    function IndexOfTranslation(LanguageID, CharSet: Word): Integer;

    // String tables methods

    ///  <summary>Gets the number of string tables in the version information.
    ///  </summary>
    ///  <returns><c>Integer</c>. The required number of string tables.
    ///  </returns>
    function GetStringTableCount: Integer;

    ///  <summary>Gets the translation code string of a string table.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of the required string
    ///  table in the string table list.</param>
    ///  <returns><c>string</c>. The required translation code string.</returns>
    ///  <exception><c>EVerInfoData</c> raised if <c>TableIdx</c> is out of
    ///  bounds.</exception>
    function GetStringTableTransStr(TableIdx: Integer): string;

    ///  <summary>Gets the language ID encoded in the translation code string of
    ///  a string table.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of the required string
    ///  table in the string table list.</param>
    ///  <returns><c>Word</c>. The required language ID.</returns>
    ///  <exception><c>EVerInfoData</c> raised if <c>TableIdx</c> is out of
    ///  bounds.</exception>
    function GetStringTableLanguageID(TableIdx: Integer): Word;

    ///  <summary>Gets the character set code encoded in the translation code
    ///  string of a string table.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of the required string
    ///  table in the string table list.</param>
    ///  <returns><c>Word</c>. The required character set code.</returns>
    ///  <exception><c>EVerInfoData</c> raised if <c>TableIdx</c> is out of
    ///  bounds.</exception>
    function GetStringTableCharSet(TableIdx: Integer): Word;

    ///  <summary>Adds a new string table to the string table list.</summary>
    ///  <param name="TransStr"><c>string</c> [in] Translation code string that
    ///  identifies the new string table.</param>
    ///  <returns><c>Integer</c>. The index of the new string table in the
    ///  string table list.</returns>
    ///  <remarks>The translation code string uniquely identifies that string
    ///  table.</remarks>
    function AddStringTable(TransStr: string): Integer;

    ///  <summary>Adds a new string table to the string table list.</summary>
    ///  <param name="LanguageID"><c>Word</c> [in] Language ID that partially
    ///  identifies the new string table.</param>
    ///  <param name="CharSet"><c>Word</c> [in] Character set code that
    ///  partially identifies the new string table.</param>
    ///  <returns><c>Integer</c>. The index of the new string table in the
    ///  string table list.</returns>
    ///  <remarks>The language ID and character set code taken together form the
    ///  translation code string that uniquely identifies the string table.
    ///  </remarks>
    function AddStringTableByTrans(LanguageID, CharSet: Word): Integer;

    ///  <summary>Deletes a string table from the string table list.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] String table index of the
    ///  string table to be deleted.</param>
    ///  <exception><c>EVerInfoData</c> raised if <c>TableIdx</c> is out of
    ///  bounds.</exception>
    procedure DeleteStringTable(TableIdx: Integer);

    ///  <summary>Finds the index of a string table in the string table list.
    ///  </summary>
    ///  <param name="TransStr"><c>string</c> [in] Translation code string that
    ///  identifies the new string table.</param>
    ///  <returns><c>Integer</c>. The index of the string table in the string
    ///  table list, or -1 if the string table is not found.</returns>
    function IndexOfStringTable(const TransStr: string): Integer;

    ///  <summary>Finds the index of a string table in the string table list.
    ///  </summary>
    ///  <param name="LanguageID"><c>Word</c> [in] Language ID that partially
    ///  identifies the new string table.</param>
    ///  <param name="CharSet"><c>Word</c> [in] Character set code that
    ///  partially identifies the new string table.</param>
    ///  <returns><c>Integer</c>. The index of the string table in the string
    ///  table list, or -1 if the string table is not found.</returns>
    ///  <remarks>Taken together, <c>LanguageID</c> and <c>CharSet</c> uniquely
    ///  identify the string table.</remarks>
    function IndexOfStringTableByTrans(LanguageID, CharSet: Word): Integer;

    // String information methods

    ///  <summary>Gets the number of string information items in a string table.
    ///  </summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of string table in
    ///  string table list.</param>
    ///  <returns><c>Integer</c>. Number of string information items in string
    ///  table.</returns>
    function GetStringCount(TableIdx: Integer): Integer;

    ///  <summary>Gets the value of a string information item in a specified
    ///  string table.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of required string
    ///  table in string table list.</param>
    ///  <param name="StringIdx"><c>Integer</c> [in] Index of required string
    ///  information item in string table.</param>
    ///  <returns><c>string</c>. Required string value.</returns>
    ///  <exception><c>EVerInfoData</c> raised if either <c>TableIdx</c> or
    ///  <c>StringIdx</c> is out of bounds.</exception>
    function GetStringValue(TableIdx, StringIdx: Integer): string;

    ///  <summary>Gets the name of a string information item in a specified
    ///  string table.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of required string
    ///  table in string table list.</param>
    ///  <param name="StringIdx"><c>Integer</c> [in] Index of required string
    ///  information item in string table.</param>
    ///  <returns><c>string</c>. Required string name.</returns>
    ///  <exception><c>EVerInfoData</c> raised if either <c>TableIdx</c> or
    ///  <c>StringIdx</c> is out of bounds.</exception>
    function GetStringName(TableIdx, StringIdx: Integer): string;

    ///  <summary>Gets the value of a named string information item in a
    ///  specified string table.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of required string
    ///  table in string table list.</param>
    ///  <param name="Name"><c>string</c> [in] String information item name.
    ///  </param>
    ///  <returns><c>string</c>. Required string value.</returns>
    ///  <exception><c>EVerInfoData</c> raised if either <c>TableIdx</c> is out
    ///  of bounds or if there is no string information item named by
    ///  <c>Name</c>.</exception>
    function GetStringValueByName(TableIdx: Integer; Name: string): string;

    ///  <summary>Gets the index of the a named string info item within a
    ///  specified string table.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of required string
    ///  table in string table list.</param>
    ///  <param name="Name"><c>string</c> [in] String information item name to
    ///  be found.</param>
    ///  <returns><c>Integer</c>. Index of the named string information item in
    ///  the specified string table, or -1 if the name can't be found.</returns>
    ///  <exception><c>EVerInfoData</c> raised if either <c>TableIdx</c> is out
    ///  of bounds.</exception>
    function IndexOfString(TableIdx: Integer; const Name: string): Integer;

    ///  <summary>Gets the index of the a named string info item within a
    ///  string table.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of required string
    ///  table in string table list.</param>
    ///  <param name="Name"><c>string</c> [in] String information item name.
    ///  </param>
    ///  <returns><c>Integer</c>. Index of named string information item or -1
    ///  if no such item exists.</returns>
    ///  <exception><c>EVerInfoData</c> raised if <c>TableIdx</c> is out of
    ///  bounds.</exception>
    function AddString(TableIdx: Integer; const Name, Value: string): Integer;

    ///  <summary>Sets the value of a named string information item in a
    ///  specified string table, adding a new item if one doesn't already exist
    ///  with that name.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of required string
    ///  table in string table list.</param>
    ///  <param name="Name"><c>string</c> [in] String information item name.
    ///  </param>
    ///  <param name="Value"><c>string</c> [in] Value to be set.</param>
    ///  <returns><c>Integer</c>. Index of the updated or added string
    ///  information item in the string table.</returns>
    function AddOrUpdateString(TableIdx: Integer; const Name, Value: string):
      Integer;

    ///  <summary>Sets the value of a string information item in a specified
    ///  string table.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of required string
    ///  table in string table list.</param>
    ///  <param name="StringIdx"><c>Integer</c> [in] Index of string information
    ///  item to be updated in string table.</param>
    ///  <param name="Value"><c>string</c> [in] Value to be set.</param>
    ///  <exception><c>EVerInfoData</c> raised if either <c>TableIdx</c> or
    ///  <c>StringIdx</c> is out of bounds.</exception>
    procedure SetStringValue(TableIdx, StringIdx: Integer;
      const Value: string);

    ///  <summary>Sets the value of a named string information item in a
    ///  specified string table.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of required string
    ///  table in string table list.</param>
    ///  <param name="Name"><c>string</c> [in] String information item name.
    ///  </param>
    ///  <param name="Value"><c>string</c> [in] Value to be set.</param>
    ///  <exception><c>EVerInfoData</c> raised if either <c>TableIdx</c> is out
    ///  of bounds or if there is no string information item named by
    ///  <c>Name</c>.</exception>
    procedure SetStringValueByName(TableIdx: Integer;
      const Name, Value: string);

    ///  <summary>Deletes a string information item from a specified string
    ///  table.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of required string
    ///  table in string table list.</param>
    ///  <param name="StringIdx"><c>Integer</c> [in] Index of string information
    ///  to be deleted within string table.</param>
    ///  <exception><c>EVerInfoData</c> raised if either <c>TableIdx</c> or
    ///  <c>StringIdx</c> is out of bounds.</exception>
    procedure DeleteString(TableIdx, StringIdx: Integer);

    ///  <summary>Deletes a named string information item from a specified
    ///  string table.</summary>
    ///  <param name="TableIdx"><c>Integer</c> [in] Index of required string
    ///  table in string table list.</param>
    ///  <param name="Name"><c>string</c> [in] Name of string information item
    ///  to be deleted within string table.</param>
    ///  <exception><c>EVerInfoData</c> raised if either <c>TableIdx</c> is out
    ///  of bounds or if there is no string information item named by
    ///  <c>Name</c>.</exception>
    procedure DeleteStringByName(TableIdx: Integer; Name: string);

    // Helper method

    ///  <summary>Converts a language ID and a character set code into a
    ///  translation string.</summary>
    ///  <param name="Language"><c>Word</c> [in] Language ID.</param>
    ///  <param name="CharSet"><c>Word</c> [in] Character set code.</param>
    ///  <returns><c>string</c>. The translation string.</returns>
    class function TransToString(const Language, CharSet: WORD): string;
  end;

  ///  <summary>Class of exceptions raised by methods of <c>TVerInfoData</c>
  ///  class.</summary>
  EVerInfoData = class(Exception);


implementation

{
  The heirachy of version information records is:

    VS_VERSION_INFO = record
      wLength       // length of structure inc children (Word)
      wValueLength  // size of TVSFixedFileInfo record (Word)
      wType         // 0 - binary (Word: 32 bit records only)
      szKey         // 'VS_VERSION_INFO' (WideStr: 32 bit, AnsiStr: 16 bit)
      pad1          // padding to DWORD boundary
      value         // fixed file information (TVSFixedFileInfo)
      pad2          // padding to DWORD boundary
      children      // VarFileInfo and StringFileInfo records
    end;

    VarFileInfo = record
      wLength       // length of structure inc children (Word)
      wValueLength  // 0 - there is no value (Word)
      wType         // 0 - binary (Word: 32 bit records only)
      szKey         // 'VarFileInfo' (WideStr: 32 bit, AnsiStr: 16 bit)
      pad1          // padding to DWORD boundary
      children      // array of Var records (usually just one)
    end;

    Var = record
      wLength       // length of structure inc children (Word)
      wValueLength  // length of list of translation ids (Word)
      wType         // 0 - binary (Word: 32 bit records only)
      szKey         // 'Translation' (WideStr: 32 bit, AnsiStr: 16 bit)
      pad1          // padding to DWORD boundary
      value         // list of translation ids (array of DWORD)
    end;

    StringFileInfo = record
      wLength       // length of structure inc children (Word)
      wValueLength  // 0 - no value (Word)
      wType         // 0 - binary (Word: 32 bit records only)
      szKey         // 'StringFileInfo' (WideStr: 32 bit, AnsiStr: 16 bit)
      pad1          // padding to DWORD boundary
      children      // array of StringTable records
    end;

    StringTable = record
      wLength       // length of structure inc children (Word)
      wValueLength  // 0 - no value (Word)
      wType         // 0 - binary (Word: 32 bit records only)
      szKey         // translation code (WideStr: 32 bit, AnsiStr: 16 bit)
      pad1          // padding to DWORD boundary
      children      // array of string records
    end;

    String = record
      wLength       // length of structure inc children (Word)
      wValueLength  // length of string value (Word)
      wType         // 1 - text (Word: 32 bit records only)
      szKey         // name of string (WideStr: 32 bit, AnsiStr: 16 bit)
      pad1          // padding to DWORD boundary
      value         // string's value
    end;
}

resourcestring
  // Error messages
  sStrIndexOutOfBounds = 'String information item at index %0:d is out of '
    + 'bounds in string table %1:d';
  sStrTableIndexOutOfBounds = 'String table index %0:d is out of bounds';
  sStrItemExists = 'String item in table %0:d with name "%1:s" already exists';
  sTransIndexOutOfBounds = 'Translation index %0:d is out of bounds';
  sBadStrName = 'There is no string named "%0:s" in table %1:d';

const
  // Version info data record names
  cVarFileInfo = 'VarFileInfo';
  cTranslation = 'Translation';
  cStringFileInfo = 'StringFileInfo';

type
  {
  TDWORDArray:
    Type used to permit access to an area of memory as a DWORD array.
  }
  TDWORDArray = array[0..MaxInt div SizeOf(DWORD) - 1] of DWORD;


{ TVerInfoData }

function TVerInfoData.AddOrUpdateString(TableIdx: Integer; const Name,
  Value: string): Integer;
begin
  Result := IndexOfString(TableIdx, Name);
  if Result = -1 then
    // No such string: add it and record index
    Result := AddString(TableIdx, Name, Value)
  else
    // String exists: update value
    SetStringValue(TableIdx, Result, Value);
end;

function TVerInfoData.AddString(TableIdx: Integer; const Name,
  Value: string): Integer;
var
  StrTable: TVerInfoRec;    // string table record at given index
  StrRec: TVerInfoRec;      // string info record with given name
begin
  // New string is added to end of string table
  Result := GetStringCount(TableIdx);
  // Get reference to root string file info record for given translation
  StrTable := GetStringFileInfoTable(TableIdx);
  Assert(Assigned(StrTable));
  // Find the string info rec for given name: its a child of translation record
  StrRec := FindChildByName(StrTable, Name);
  if Assigned(StrRec) then
    Error(sStrItemExists, [TableIdx, Name]);
  // Create new string item in table and set name and value
  StrRec := CreateNode(StrTable, Name);
  StrRec.SetStringValue(Value);
end;

function TVerInfoData.AddStringTable(TransStr: string): Integer;
begin
  // New string table will be added to end of list of tables
  Result := GetStringTableCount;
  // Add a new string table entry under the 'StringFileInfo' record named with
  // given translation string
  CreateNode(GetStringFileInfoRoot, TransStr);
end;

function TVerInfoData.AddStringTableByTrans(LanguageID, CharSet: Word): Integer;
begin
  Result := AddStringTable(TransToString(LanguageID, CharSet));
end;

function TVerInfoData.AddTranslation(LanguageID, CharSet: Word): Integer;
var
  TransRec: TVerInfoRec;  // reference to 'Translation' record
  TempBuf: PByte;         // temp buffer for new translation list
  TempBufSize: Integer;   // size of temp buffer
begin
  // New translation is added to end of list => index is current last item
  Result := GetTranslationCount;
  // Get reference to 'Translation' record, which must exist
  TransRec := GetTranslationRec;
  Assert(TransRec <> nil);
  // Create a buffer to hold all current translation list + new entry
  TempBufSize := TransRec.GetValueSize + SizeOf(DWORD);
  GetMem(TempBuf, TempBufSize);
  try
    // Store old translation list at start of new storage
    Move(TransRec.Value^, TempBuf^, TransRec.GetValueSize);
    // Store new extended list as translation's value: the new entry is at the
    // the end of the list and has undefined value
    TransRec.SetBinaryValue(TempBuf^, TempBufSize);
    // Store the new translation's value, created from given language and char
    // set, at the end of the translation list
    InternalSetTranslation(Result, EncodeTrans(0, LanguageID, CharSet));
  finally
    // Free the temporary buffer
    FreeMem(TempBuf, TempBufSize);
  end;
end;

procedure TVerInfoData.Assign(const Source: TVerInfoData);
var
  SrcStrTableIdx: Integer;  // index of a string table in source object
  NewTableIdx: Integer;     // index of a new string table in this object
  SrcStrIdx: Integer;       // index of a string in source object
  SrcTransIdx: Integer;     // index of a translation in source object
begin
  // Clear all existing data from this object
  Self.Reset;
  // Set fixed file info to be same as source object
  Self.SetFixedFileInfo(Source.GetFixedFileInfo);
  // Add translations to match those in source object
  for SrcTransIdx := 0 to Pred(Source.GetTranslationCount) do
    Self.AddTranslation(
      Source.GetTranslationLanguageID(SrcTransIdx),
      Source.GetTranslationCharSet(SrcTransIdx)
    );
  // Add string tables and string entries to match those in source object
  for SrcStrTableIdx := 0 to Pred(Source.GetStringTableCount) do
  begin
    // add new string table and record its index
    NewTableIdx := Self.AddStringTable(
      Source.GetStringTableTransStr(SrcStrTableIdx)
    );
    // add strings from source string table to new string table
    for SrcStrIdx := 0 to Pred(Source.GetStringCount(SrcStrTableIdx)) do
      Self.AddString(
        NewTableIdx,
        Source.GetStringName(SrcStrTableIdx, SrcStrIdx),
        Source.GetStringValue(SrcStrTableIdx, SrcStrIdx)
      );
  end;
end;

constructor TVerInfoData.Create(VerResType: TVerResType);
begin
  inherited Create;
  // Record type of version infor records we're dealing with
  // (required before root record created)
  fVerResType := VerResType;
  // Create the root object
  fVIRoot := VerInfoRecClass.Create;
  // Ensure FFI record is zero with required signature and required child nodes
  // are created of fVIRoot
  Reset;
end;

function TVerInfoData.CreateNode(Owner: TVerInfoRec;
  const Name: string): TVerInfoRec;
begin
  Result := VerInfoRecClass.Create(Owner);
  Result.Name := Name;
end;

class procedure TVerInfoData.DecodeTrans(const Trans: DWORD; out Language,
  CharSet: WORD);
begin
  Language := LoWord(Trans);
  CharSet := HiWord(Trans);
end;

class procedure TVerInfoData.DecodeTransStr(const TransStr: string;
  out Language, CharSet: WORD);

  {$IF not Defined(StrToUInt)}
  function StrToUInt(const AValue: string): Cardinal;
  begin
    Result := Cardinal(StrToInt(AValue));
  end;
  {$IFEND}

begin
  Language := LongRec(StrToUInt('$' + Copy(TransStr, 1, 4))).Lo;
  CharSet := LongRec(StrToUInt('$' + Copy(TransStr, 5, 4))).Lo;
end;

procedure TVerInfoData.DeleteString(TableIdx, StringIdx: Integer);
var
  StrRec: TVerInfoRec;  // reference to required string info item
begin
  // Get reference to required string info item
  StrRec := GetStringFileInfoItem(TableIdx, StringIdx);
  Assert(Assigned(StrRec));
  // Freeing string item unlinks from string table's list
  StrRec.Free;
end;

procedure TVerInfoData.DeleteStringByName(TableIdx: Integer; Name: string);
var
  StrIdx: Integer;
begin
  StrIdx := IndexOfString(TableIdx, Name);
  if StrIdx = -1 then
    Error(sBadStrName, [Name, TableIdx]);
  DeleteString(TableIdx, StrIdx);
end;

procedure TVerInfoData.DeleteStringTable(TableIdx: Integer);
var
  StrTableRec: TVerInfoRec; // reference to required string table record
begin
  // Get reference to string table
  StrTableRec := GetStringFileInfoTable(TableIdx);
  Assert(Assigned(StrTableRec));
  // Freeing record unlink from list
  StrTableRec.Free;
end;

procedure TVerInfoData.DeleteTranslation(TransIdx: Integer);
var
  TransRec: TVerInfoRec;    // ref to 'Translation' record
  TempBuf: Pointer;         // temp buffer to hold updated translation list
  TempBufSize: Integer;     // size of temp buffer
  I: Integer;               // loops through current translations
  NumTrans: Integer;        // current number of translations
  TransName: string;        // name of translation at given index
begin
  // Get translation as string and number of translations
  TransName := GetTranslationString(TransIdx);
  NumTrans := GetTranslationCount;
  // Record reference to translation record
  TransRec := GetTranslationRec;
  Assert(TransRec <> nil);
  // Create a temp buffer to hold current translation table
  TempBufSize := TransRec.GetValueSize;
  GetMem(TempBuf, TempBufSize);
  try
    Move(TransRec.Value^, TempBuf^, TransRec.GetValueSize);
    // Shuffle down translation elements in table above deleted item
    for I := Pred(NumTrans) downto TransIdx + 1 do
      // move element down list
      TDWORDArray(TempBuf^)[I - 1] := TDWORDArray(TempBuf^)[I];
    // Rewrite translation table, leaving out last item
    TransRec.SetBinaryValue(TempBuf^, TempBufSize - SizeOf(DWORD));
  finally
    // Free temporary buffer
    FreeMem(TempBuf, TempBufSize);
  end;
end;

destructor TVerInfoData.Destroy;
begin
  fVIRoot.Free;
  inherited;
end;

class function TVerInfoData.EncodeTrans(const OldTrans: DWORD; const Language,
  CharSet: WORD): DWORD;
begin
  Result := OldTrans;
  if Language <> $FFFF then
    LongRec(Result).Lo := Language;
  if CharSet <> $FFFF then
    LongRec(Result).Hi := CharSet;
end;

procedure TVerInfoData.EnsureRequiredNodes;

  // Checks if a version info record with the given name exists as a child of
  // the given owner record. If the node dosen't exist it is created. A
  // reference to the required node is returned.
  function EnsureNode(Owner: TVerInfoRec;
    const Name: string): TVerInfoRec;
  begin
    // Check if record (node) exists
    Result := FindChildByName(Owner, Name);
    if not Assigned(Result) then
      // Node doesn't exist so create it
      Result := CreateNode(Owner, Name);
  end;

var
  VarFileInfoRoot: TVerInfoRec;     // root record for variable info
begin
  // Ensure root node has required name
  fVIRoot.Name := 'VS_VERSION_INFO';
  // Make sure 'VarFileInfo' node exists under root
  VarFileInfoRoot := EnsureNode(fVIRoot, cVarFileInfo);
  // Make sure 'Translation' node exists under 'VarFileInfo'
  EnsureNode(VarFileInfoRoot, cTranslation);
  // Make sure 'StringFileInfo' exists under root
  EnsureNode(fVIRoot, cStringFileInfo);
end;

procedure TVerInfoData.Error(const FmtStr: string;
  const Args: array of const);
begin
  raise EVerInfoData.CreateFmt(FmtStr, Args);
end;

function TVerInfoData.FindChildByName(const Root: TVerInfoRec;
  const Name: string): TVerInfoRec;
var
  ChildIdx: Integer;  // Index of child in parent's Children property
begin
  // Get index of child in parent's Children property (-1 on error)
  ChildIdx := IndexOfChildByName(Root, Name);
  // Now return reference to child object or nil if doesn't exist
  if ChildIdx > -1 then
    Result := Root.Children[ChildIdx]
  else
    Result := nil;
end;

function TVerInfoData.GetFixedFileInfo: TVSFixedFileInfo;
var
  Ptr: ^TVSFixedFileInfo; // pointer to fixed file info record
begin
  Assert(Assigned(fVIRoot));
  // Fixed file info is stored as root record's value
  Ptr := fVIRoot.Value;
  if Ptr = nil then
  begin
    // we have no value, so return a zeroed FFI record, with correct signature
    FillChar(Result, SizeOf(Result), 0);
    StampFFI(Result);
  end
  else
    // copy date from record into result
    Result := Ptr^;
end;

function TVerInfoData.GetStringCount(TableIdx: Integer): Integer;
var
  StrTable: TVerInfoRec;  // reference to require string table record
begin
  // Get reference to required string table record
  StrTable := GetStringFileInfoTable(TableIdx);
  Assert(Assigned(StrTable));
  // Return its number of children
  Result := StrTable.NumChildren;
end;

function TVerInfoData.GetStringFileInfoItem(TableIdx,
  StrIdx: Integer): TVerInfoRec;
var
  StrTable: TVerInfoRec;  // required string file info table
begin
  // Get string table: will raise exception if doesn't exist
  StrTable := GetStringFileInfoTable(TableIdx);
  Assert(Assigned(StrTable));
  // Check string item index in bounds
  if (StrIdx < 0) or (StrIdx >= StrTable.NumChildren) then
    Error(sStrIndexOutOfBounds, [StrIdx, TableIdx]);
  // We have required item: return reference to it
  Result := StrTable.Children[StrIdx]
end;

function TVerInfoData.GetStringFileInfoRoot: TVerInfoRec;
begin
  // The 'StringFileInfo' record is a child of the root record: must exist
  Result := FindChildByName(fVIRoot, cStringFileInfo);
  Assert(Assigned(Result));
end;

function TVerInfoData.GetStringFileInfoTable(
  TableIdx: Integer): TVerInfoRec;
var
  StrRoot: TVerInfoRec; // root ver info record for all string file info
begin
  // Get root record for all string file info ('StringFileInfo'): must exist
  StrRoot := GetStringFileInfoRoot;
  // Check index in bounds
  if (TableIdx < 0) or (TableIdx >= StrRoot.NumChildren) then
    Error(sStrTableIndexOutOfBounds, [TableIdx]);
  // Return reference to required table record
  Result := StrRoot.Children[TableIdx]
end;

function TVerInfoData.GetStringName(TableIdx,
  StringIdx: Integer): string;
var
  StrRec: TVerInfoRec;  // the ver info string record for the string
begin
  // Get the required ver info string record
  StrRec := GetStringFileInfoItem(TableIdx, StringIdx);
  Assert(Assigned(StrRec));
  // Return its name
  Result := StrRec.Name
end;

function TVerInfoData.GetStringTableCharSet(TableIdx: Integer): Word;
var
  Dummy: Word;
begin
  DecodeTransStr(GetStringTableTransStr(TableIdx), Dummy, Result);
end;

function TVerInfoData.GetStringTableCount: Integer;
var
  StrRoot: TVerInfoRec; // root ver info record for all string file info
begin
  // Number of string info tables is number of children of string info root rec
  StrRoot := GetStringFileInfoRoot;
  Assert(Assigned(StrRoot));
  Result := StrRoot.NumChildren;
end;

function TVerInfoData.GetStringTableLanguageID(TableIdx: Integer): Word;
var
  Dummy: Word;
begin
  DecodeTransStr(GetStringTableTransStr(TableIdx), Result, Dummy);
end;

function TVerInfoData.GetStringTableTransStr(TableIdx: Integer): string;
var
  StrTable: TVerInfoRec;  // refers to string table's ver info record
begin
  // Translation string is key associated with string info table at given index
  StrTable := GetStringFileInfoTable(TableIdx);
  Assert(Assigned(StrTable));
  Result := StrTable.Name;
end;

function TVerInfoData.GetStringValue(TableIdx,
  StringIdx: Integer): string;
var
  StrRec: TVerInfoRec;  // string item record referece
begin
  // Get reference to require string item
  StrRec := GetStringFileInfoItem(TableIdx, StringIdx);
  Assert(Assigned(StrRec));
  // Return its value
  Result := StrRec.GetStringValue;
end;

function TVerInfoData.GetStringValueByName(TableIdx: Integer;
  Name: string): string;
var
  StringIdx: Integer;
begin
  StringIdx := IndexOfString(TableIdx, Name);
  if StringIdx = -1 then
    Error(sBadStrName, [Name, TableIdx]);
  Result := GetStringValue(TableIdx, StringIdx);
end;

function TVerInfoData.GetTranslationCharSet(TransIdx: Integer): Word;
var
  Dummy: Word;
begin
  // Decode the translation value at given index to get just the char set
  DecodeTrans(InternalGetTranslation(TransIdx), Dummy, Result);
end;

function TVerInfoData.GetTranslationCount: Integer;
begin
  // Get count of translation from translation record (which must exist)
  Result := InternalGetTranslationCount(GetTranslationRec);
end;

function TVerInfoData.GetTranslationLanguageID(TransIdx: Integer): Word;
var
  Dummy: Word;
begin
  // Decode the translation value at index  to get just the language id
  DecodeTrans(InternalGetTranslation(TransIdx), Result, Dummy);
end;

function TVerInfoData.GetTranslationRec: TVerInfoRec;
begin
  // Get translation root from within VarFileInfo: both these must exist
  Result := FindChildByName(GetVarFileInfoRoot, cTranslation);
  Assert(Assigned(Result));
end;

function TVerInfoData.GetTranslationString(TransIdx: Integer): string;
var
  Language, CharSet: WORD;  // the language id and charset for the translation
begin
  // Get translation at given index and decode into language and char set
  DecodeTrans(InternalGetTranslation(TransIdx), Language, CharSet);
  // Get translation string for language and char set
  Result := TransToString(Language, CharSet);
end;

function TVerInfoData.GetVarFileInfoRoot: TVerInfoRec;
begin
  // The 'VarFileInfo' record is a child of the root record: must exist
  Result := FindChildByName(fVIRoot, cVarFileInfo);
  Assert(Assigned(Result));
end;

function TVerInfoData.IndexOfChildByName(const Root: TVerInfoRec;
  const Name: string): Integer;
var
  Child: TVerInfoRec; // reference to each child record of root
  Idx: Integer;           // loops thru list of root's children
begin
  // Assume we don't find record
  Result := -1;
  // Scan all children, looking for required one
  for Idx := 0 to Pred(Root.NumChildren) do
  begin
    // Get reference to current child record
    Child := Root.Children[Idx];
    // Check if we have required name
    if AnsiCompareText(Name, Child.Name) = 0 then
    begin
      // Found it: record its index and stop
      Result := Idx;
      Break;
    end;
  end;
end;

function TVerInfoData.IndexOfString(TableIdx: Integer;
  const Name: string): Integer;
var
  StrTable: TVerInfoRec;  // reference to required string table
begin
  // Get reference to string table
  StrTable := Self.GetStringFileInfoTable(TableIdx);
  Assert(Assigned(StrTable));
  // Return index (if any) of child record with required name
  Result := IndexOfChildByName(StrTable, Name)
end;

function TVerInfoData.IndexOfStringTable(const TransStr: string): Integer;
var
  StrRoot: TVerInfoRec; // root ver info record for all string file info
begin
  // Get reference to string table identified by translation string
  StrRoot := GetStringFileInfoRoot;
  Assert(Assigned(StrRoot));
  // Find index (if any) of child record with given name
  Result := IndexOfChildByName(StrRoot, TransStr)
end;

function TVerInfoData.IndexOfStringTableByTrans(LanguageID,
  CharSet: Word): Integer;
begin
  Result := IndexOfStringTable(TransToString(LanguageID, CharSet));
end;

function TVerInfoData.IndexOfTranslation(LanguageID,
  CharSet: Word): Integer;
var
  TransRec: TVerInfoRec;  // record that provides info about translations
  TransCode: DWORD;       // translation code for language and char set
  TransIdx: Integer;      // loops thru all translations
begin
  // Get reference to record that provides info about translations
  TransRec := GetTranslationRec;
  // Encode language id and char set into translation code we're looking for
  TransCode := EncodeTrans(0, LanguageID, CharSet);
  // Search for require value
  // assume failure
  Result := -1;
  // loop through all entries in translations array in record's value 'field'
  for TransIdx := 0 to Pred(TransRec.GetValueSize div SizeOf(DWORD)) do
  begin
    // test current array entry against required code
    if TDWORDArray(TransRec.Value^)[TransIdx] = TransCode then
    begin
      // found it: set true result and finish
      Result := TransIdx;
      Break;
    end;
  end;
end;

function TVerInfoData.InternalGetTranslation(TransIdx: Integer): DWORD;
var
  TransRec: TVerInfoRec;  // Ver info record that stores translation info
begin
  // Get ver info record where translation info stored: this must exist
  TransRec := GetTranslationRec;
  Assert(Assigned(TransRec));
  // Check translation index is in bounds
  if (TransIdx < 0) or (TransIdx >= InternalGetTranslationCount(TransRec)) then
    Error(sTransIndexOutOfBounds, [TransIdx]);
  // Translation info is stored as a DWORD array in record's value field
  // return entry at given index in array
  Result := TDWORDArray(TransRec.Value^)[TransIdx];
end;

function TVerInfoData.InternalGetTranslationCount(
  TransRec: TVerInfoRec): Integer;
begin
  Assert(Assigned(TransRec));
  // Number of translations = number of elements in translation list stored in
  // value (each translation is stored as a DWORD)
  Result := TransRec.GetValueSize div SizeOf(DWORD);
end;

procedure TVerInfoData.InternalSetTranslation(TransIdx: Integer;
  Value: DWORD);
var
  TransRec: TVerInfoRec;  // 'Translation' record reference
begin
  // Get reference to 'Translation' record: stores info about all translations
  // in the value 'field' - there must be such a record
  TransRec := GetTranslationRec;
  Assert(TransRec <> nil);
  // Check translation index is in bounds
  if (TransIdx < 0) or (TransIdx >= InternalGetTranslationCount(TransRec)) then
    Error(sTransIndexOutOfBounds, [TransIdx]);
  // Set the required array element to the given value
  TDWORDArray(TransRec.Value^)[TransIdx] := Value;
end;

procedure TVerInfoData.ReadFromStream(const Stream: IStream);
begin
  // Get root record to read itself from stream: this automatically reads the
  // whole tree of version info data
  fVIRoot.ReadFromStream(Stream);
  EnsureRequiredNodes;
end;

procedure TVerInfoData.Reset;
var
  FFI: TVSFixedFileInfo;  // fixed file info value record of root
begin
  // Clear object: deleting all children
  fVIRoot.Clear;
  // Add empty fixed file info to root node
  FillChar(FFI, SizeOf(FFI), 0);
  SetFixedFileInfo(FFI);
  // Make sure we have all required nodes
  EnsureRequiredNodes;
end;

procedure TVerInfoData.SetFixedFileInfo(const Value: TVSFixedFileInfo);
var
  FFI: TVSFixedFileInfo;  // copy of data to be written: we update this
begin
  Assert(Assigned(fVIRoot));
  // Record value: we update some field before writing
  FFI := Value;
  // Ensure we have correct version and signature
  StampFFI(FFI);
  // Fixed file info stored as root record's value: update it
  fVIRoot.SetBinaryValue(FFI, SizeOf(FFI));
end;

procedure TVerInfoData.SetStringValue(TableIdx, StringIdx: Integer;
  const Value: string);
var
  StrRec: TVerInfoRec;     // string info record with given name
begin
  // Get reference to required string inof item
  StrRec := GetStringFileInfoItem(TableIdx, StringIdx);
  Assert(Assigned(StrRec));
  // Set its value
  StrRec.SetStringValue(Value);
end;

procedure TVerInfoData.SetStringValueByName(TableIdx: Integer; const Name,
  Value: string);
var
  StrIdx: Integer;
begin
  StrIdx := IndexOfString(TableIdx, Name);
  if StrIdx = -1 then
    Error(sBadStrName, [Name, TableIdx]);
  // Set the string value
  SetStringValue(TableIdx, StrIdx, Value);
end;

procedure TVerInfoData.SetTranslation(TransIdx: Integer; LanguageID,
  CharSet: Word);
begin
  InternalSetTranslation(TransIdx, EncodeTrans(0, LanguageID, CharSet));
end;

class procedure TVerInfoData.StampFFI(var FFI: TVSFixedFileInfo);
begin
  FFI.dwSignature := $FEEF04BD;
  FFI.dwStrucVersion := $00010000;
end;

class function TVerInfoData.TransToString(const Language,
  CharSet: WORD): string;
begin
  Result := IntToHex(Language, 4) + IntToHex(CharSet, 4);
end;

function TVerInfoData.VerInfoRecClass: TVerInfoRecClass;
begin
  case fVerResType of
    vrtAnsi: Result := TVerInfoRecA;
    vrtUnicode: Result := TVerInfoRecW;
    else  Result := nil;
  end;
  Assert(Result <> nil);
end;

procedure TVerInfoData.WriteToStream(const Stream: IStream);
begin
  // Get the root record to write itself to stream: this automatically writes
  // all the tree of records
  fVIRoot.WriteToStream(Stream);
end;

end.


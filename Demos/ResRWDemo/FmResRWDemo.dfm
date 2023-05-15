object ResRWDemoForm: TResRWDemoForm
  Left = 0
  Top = 0
  Caption = 'ddablib/vibin | ResRWDemo'
  ClientHeight = 464
  ClientWidth = 809
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    809
    464)
  PixelsPerInch = 96
  TextHeight = 15
  object lblDescription: TLabel
    AlignWithMargins = True
    Left = 7
    Top = 4
    Width = 795
    Height = 15
    Margins.Left = 7
    Margins.Top = 4
    Margins.Right = 7
    Margins.Bottom = 4
    Align = alTop
    Caption = 
      'This project demonstrates how to read / write version informatio' +
      'n in 32 resource files.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
    ExplicitWidth = 480
  end
  object bvlDescription: TBevel
    AlignWithMargins = True
    Left = 7
    Top = 23
    Width = 795
    Height = 1
    Margins.Left = 7
    Margins.Top = 0
    Margins.Right = 7
    Margins.Bottom = 4
    Align = alTop
    Shape = bsBottomLine
  end
  object btnView: TButton
    Left = 7
    Top = 110
    Width = 113
    Height = 22
    Caption = 'View Version Info'
    TabOrder = 0
    OnClick = btnViewClick
  end
  object memoView: TMemo
    Left = 7
    Top = 138
    Width = 784
    Height = 319
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
    ExplicitHeight = 313
  end
  object btnOpen: TButton
    Left = 7
    Top = 30
    Width = 113
    Height = 22
    Caption = 'Open Resource File'
    TabOrder = 2
    OnClick = btnOpenClick
  end
  object btnSave: TButton
    Left = 7
    Top = 55
    Width = 113
    Height = 21
    Caption = 'Save Resource File'
    TabOrder = 3
    OnClick = btnSaveClick
  end
  object btnViewRaw: TButton
    Left = 125
    Top = 110
    Width = 113
    Height = 22
    Caption = 'View Raw Data'
    TabOrder = 4
    OnClick = btnViewRawClick
  end
  object btnViewResFile: TButton
    Left = 244
    Top = 110
    Width = 112
    Height = 22
    Caption = 'View Resource File'
    TabOrder = 5
    OnClick = btnViewResFileClick
  end
  object btnAddTranslation: TButton
    Left = 125
    Top = 30
    Width = 113
    Height = 22
    Hint = 
      'Enter character set and language ID for translation in Character' +
      ' set & Language ID edit boxes'
    Caption = 'Add Translation'
    TabOrder = 6
    OnClick = btnAddTranslationClick
  end
  object leCharSet: TLabeledEdit
    Left = 731
    Top = 30
    Width = 60
    Height = 23
    Anchors = [akTop, akRight]
    EditLabel.Width = 99
    EditLabel.Height = 15
    EditLabel.Caption = 'Character set (hex)'
    EditLabel.Layout = tlBottom
    LabelPosition = lpLeft
    TabOrder = 7
    OnKeyPress = HexEditKeyPress
  end
  object leLanguageID: TLabeledEdit
    Left = 731
    Top = 55
    Width = 60
    Height = 23
    Anchors = [akTop, akRight]
    EditLabel.Width = 96
    EditLabel.Height = 15
    EditLabel.Caption = 'Language ID (hex)'
    EditLabel.Layout = tlBottom
    LabelPosition = lpLeft
    TabOrder = 8
    OnKeyPress = HexEditKeyPress
  end
  object leStringName: TLabeledEdit
    Left = 592
    Top = 81
    Width = 199
    Height = 23
    Anchors = [akTop, akRight]
    EditLabel.Width = 64
    EditLabel.Height = 15
    EditLabel.Caption = 'String name'
    EditLabel.Layout = tlBottom
    LabelPosition = lpLeft
    TabOrder = 9
  end
  object leStringValue: TLabeledEdit
    Left = 592
    Top = 106
    Width = 199
    Height = 23
    Anchors = [akTop, akRight]
    EditLabel.Width = 62
    EditLabel.Height = 15
    EditLabel.Caption = 'String value'
    EditLabel.Layout = tlBottom
    LabelPosition = lpLeft
    TabOrder = 10
  end
  object btnDeleteTrans: TButton
    Left = 125
    Top = 80
    Width = 113
    Height = 22
    Hint = 'Enter index in Translation index # edit box'
    Caption = 'Delete Translation'
    TabOrder = 11
    OnClick = btnDeleteTransClick
  end
  object btnIndexOfTrans: TButton
    Left = 125
    Top = 55
    Width = 113
    Height = 21
    Hint = 
      'Enter translation'#39's character set and language ID in Character s' +
      'et & Language ID edit boxes'
    Caption = 'Index Of Translation'
    TabOrder = 12
    OnClick = btnIndexOfTransClick
  end
  object leTransIdx: TLabeledEdit
    Left = 592
    Top = 30
    Width = 38
    Height = 23
    Hint = 'Enter index of translation'
    Anchors = [akTop, akRight]
    EditLabel.Width = 99
    EditLabel.Height = 15
    EditLabel.Caption = 'Translation index #'
    EditLabel.Layout = tlBottom
    LabelPosition = lpLeft
    NumbersOnly = True
    TabOrder = 13
  end
  object leStrTableIdx: TLabeledEdit
    Left = 592
    Top = 55
    Width = 38
    Height = 23
    Hint = 'Enter index of translation'
    Anchors = [akTop, akRight]
    EditLabel.Width = 103
    EditLabel.Height = 15
    EditLabel.Caption = 'String Table index #'
    EditLabel.Layout = tlBottom
    LabelPosition = lpLeft
    NumbersOnly = True
    TabOrder = 14
  end
  object btnAddStrTable: TButton
    Left = 244
    Top = 30
    Width = 112
    Height = 22
    Hint = 
      'Enter character set and language ID for string table in Characte' +
      'r set & Language ID edit boxes'
    Caption = 'Add String Table'
    TabOrder = 15
    OnClick = btnAddStrTableClick
  end
  object btnIndexOfStrTable: TButton
    Left = 244
    Top = 55
    Width = 112
    Height = 21
    Hint = 
      'Enter string table'#39's character set and language ID in Character ' +
      'set & Language ID edit boxes'
    Caption = 'Index Of String Table'
    TabOrder = 16
    OnClick = btnIndexOfStrTableClick
  end
  object btnDeleteStrTable: TButton
    Left = 244
    Top = 80
    Width = 112
    Height = 22
    Hint = 'Enter index of string table in String Table index # edit box'
    Caption = 'Delete String Table'
    TabOrder = 17
    OnClick = btnDeleteStrTableClick
  end
  object btnAddOrUpdateString: TButton
    Left = 362
    Top = 30
    Width = 113
    Height = 22
    Hint = 
      'Enter string name && value in String name && String value edit b' +
      'oxes and string table index per String Table index # edit box'
    Caption = 'Add or Update String'
    TabOrder = 18
    OnClick = btnAddOrUpdateStringClick
  end
  object btnDeleteString: TButton
    Left = 362
    Top = 80
    Width = 113
    Height = 22
    Hint = 
      'Enter name of string in String name edit box and string table in' +
      'dex in String Table index # edit box'
    Caption = 'Delete String'
    TabOrder = 19
    OnClick = btnDeleteStringClick
  end
  object btnSetFFI: TButton
    Left = 7
    Top = 80
    Width = 113
    Height = 22
    Caption = 'Set FFI'
    TabOrder = 20
    OnClick = btnSetFFIClick
  end
  object btnIndexOfString: TButton
    Left = 362
    Top = 55
    Width = 113
    Height = 21
    Hint = 
      'Enter string name String name #edit box and string table index p' +
      'er String Table index # edit box'
    Caption = 'Index Of String'
    TabOrder = 21
    OnClick = btnIndexOfStringClick
  end
end

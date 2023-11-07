object CleanView: TCleanView
  Left = 0
  Top = 0
  Caption = 'Files Cleaner'
  ClientHeight = 701
  ClientWidth = 519
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 13
  object ListBoxesSplitter: TSplitter
    Left = 0
    Top = 398
    Width = 519
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 100
    ExplicitWidth = 172
  end
  object CleanPathPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 513
    Height = 75
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object PathLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 507
      Height = 13
      Align = alTop
      Caption = 'Path:'
      ExplicitWidth = 26
    end
    object AppImagesPathPanel: TPanel
      Left = 0
      Top = 19
      Width = 513
      Height = 26
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object SelectCleanPathSpeedButton: TSpeedButton
        AlignWithMargins = True
        Left = 487
        Top = 2
        Width = 23
        Height = 22
        Margins.Left = 0
        Margins.Top = 2
        Margins.Bottom = 2
        Align = alRight
        Caption = '...'
        OnClick = SelectCleanPathSpeedButtonClick
        ExplicitLeft = 484
        ExplicitTop = 12
      end
      object CleanPathEdit: TEdit
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 484
        Height = 20
        Hint = 
          'The folder to search in for images. Check the checkbox to includ' +
          'e subfolders'
        Margins.Right = 0
        Align = alClient
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        ExplicitHeight = 21
      end
    end
    object CleanPathIncludeSubdirsCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 48
      Width = 507
      Height = 17
      Hint = 'Includes subfolders when searching for images'
      Align = alTop
      Caption = 'Include subfolders when cleaning'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 1
    end
  end
  object FileTypesCheckListBox: TCheckListBox
    AlignWithMargins = True
    Left = 3
    Top = 101
    Width = 513
    Height = 294
    Align = alClient
    ItemHeight = 13
    Items.Strings = (
      'apk'
      'dex'
      'dcu'
      'deployproj'
      'dsym'
      'exe'
      'identcache'
      'jar'
      'local'
      'o'
      'res'
      'rsm'
      'so')
    TabOrder = 1
  end
  object AppImagesButtonsPanel: TPanel
    Left = 0
    Top = 666
    Width = 519
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 4
    Padding.Top = 4
    Padding.Right = 4
    Padding.Bottom = 4
    TabOrder = 2
    object CleanButton: TButton
      AlignWithMargins = True
      Left = 349
      Top = 4
      Width = 80
      Height = 27
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Action = CleanAction
      Align = alRight
      Cancel = True
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
    end
    object CancelButton: TButton
      AlignWithMargins = True
      Left = 435
      Top = 4
      Width = 80
      Height = 27
      Margins.Left = 6
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      Cancel = True
      Caption = 'Cancel'
      DoubleBuffered = True
      ModalResult = 2
      ParentDoubleBuffered = False
      TabOrder = 1
    end
  end
  object FoldersPanel: TPanel
    Left = 0
    Top = 401
    Width = 519
    Height = 265
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object FoldersCheckListBox: TCheckListBox
      AlignWithMargins = True
      Left = 3
      Top = 20
      Width = 513
      Height = 242
      Align = alClient
      ItemHeight = 13
      Items.Strings = (
        '__history'
        '__recovery'
        'Android'
        'Android64'
        'iOSDevice32'
        'iOSDevice64'
        'iOSSimulator'
        'OSX32'
        'OSX64'
        'Win32'
        'Win64')
      TabOrder = 0
    end
    object FoldersCheckBox: TCheckBox
      Left = 0
      Top = 0
      Width = 519
      Height = 17
      Align = alTop
      Caption = 'Folders:'
      TabOrder = 1
      OnClick = FoldersCheckBoxClick
    end
  end
  object FileTypesCheckBox: TCheckBox
    Left = 0
    Top = 81
    Width = 519
    Height = 17
    Align = alTop
    Caption = 'File types:'
    TabOrder = 4
    OnClick = FileTypesCheckBoxClick
  end
  object FileOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders]
    Left = 166
    Top = 131
  end
  object ActionList: TActionList
    Left = 248
    Top = 132
    object CleanAction: TAction
      Caption = 'Clean'
      OnExecute = CleanActionExecute
      OnUpdate = CleanActionUpdate
    end
  end
end

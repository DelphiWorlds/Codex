object KeyStoreInfoView: TKeyStoreInfoView
  Left = 0
  Top = 0
  Caption = 'Rebuild Bundle With Asset Packs'
  ClientHeight = 326
  ClientWidth = 627
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object KeystoreFilePanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 61
    Width = 619
    Height = 53
    Margins.Left = 4
    Margins.Top = 0
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 1
    object SelectKeystoreFileButton: TSpeedButton
      AlignWithMargins = True
      Left = 592
      Top = 24
      Width = 23
      Height = 25
      Margins.Left = 0
      Margins.Right = 4
      Action = SelectKeyStoreFileAction
      Align = alRight
      ExplicitTop = 27
      ExplicitHeight = 21
    end
    object KeystoreFileLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 613
      Height = 15
      Align = alTop
      Caption = 'KeyStore file:'
      ExplicitWidth = 68
    end
    object KeystoreFileNameEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 25
      Width = 588
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
  object KeystoreAliasPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 175
    Width = 619
    Height = 53
    Margins.Left = 4
    Margins.Top = 0
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 3
    object KeystoreAliasLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 613
      Height = 15
      Align = alTop
      Caption = 'Alias:'
      ExplicitWidth = 28
    end
    object KeyStoreAliasEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 25
      Width = 611
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
  object KeystorePassPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 118
    Width = 619
    Height = 53
    Margins.Left = 4
    Margins.Top = 0
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 2
    object KeystorePassLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 613
      Height = 15
      Align = alTop
      Caption = 'KeyStore Password:'
      ExplicitWidth = 102
    end
    object KeyStorePassEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 25
      Width = 611
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      ParentShowHint = False
      PasswordChar = '*'
      ShowHint = True
      TabOrder = 0
    end
  end
  object KeystoreAliasPassPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 232
    Width = 619
    Height = 53
    Margins.Left = 4
    Margins.Top = 0
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 4
    object KeystoreAliasPassLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 613
      Height = 15
      Align = alTop
      Caption = 'Alias Password:'
      ExplicitWidth = 81
    end
    object KeyStoreAliasPassEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 25
      Width = 611
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      ParentShowHint = False
      PasswordChar = '*'
      ShowHint = True
      TabOrder = 0
    end
  end
  object CommandButtonsPanel: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 292
    Width = 627
    Height = 34
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 5
    object CancelButton: TButton
      AlignWithMargins = True
      Left = 549
      Top = 3
      Width = 75
      Height = 28
      Align = alRight
      Cancel = True
      Caption = 'Cancel'
      Default = True
      DoubleBuffered = True
      ModalResult = 2
      ParentDoubleBuffered = False
      TabOrder = 1
    end
    object OKButton: TButton
      AlignWithMargins = True
      Left = 467
      Top = 3
      Width = 76
      Height = 28
      Action = OKAction
      Align = alRight
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
    end
  end
  object AABPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 4
    Width = 619
    Height = 53
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 0
    object SelectAABFileButton: TSpeedButton
      AlignWithMargins = True
      Left = 592
      Top = 24
      Width = 23
      Height = 25
      Margins.Left = 0
      Margins.Right = 4
      Action = SelectAABFileAction
      Align = alRight
      ExplicitTop = 27
      ExplicitHeight = 22
    end
    object AABLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 613
      Height = 15
      Align = alTop
      Caption = 'AAB file:'
      ExplicitWidth = 45
    end
    object AABFileNameEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 25
      Width = 588
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
  object ActionList: TActionList
    Left = 280
    Top = 195
    object OKAction: TAction
      Caption = 'OK'
      OnExecute = OKActionExecute
      OnUpdate = OKActionUpdate
    end
    object SelectAABFileAction: TAction
      Caption = '...'
      OnExecute = SelectAABFileActionExecute
    end
    object SelectKeyStoreFileAction: TAction
      Caption = '...'
      OnExecute = SelectKeyStoreFileActionExecute
    end
  end
  object AABFileOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'AAB files (*.aab)'
        FileMask = '*.aab'
      end>
    Options = [fdoFileMustExist]
    Left = 280
    Top = 127
  end
  object KeyStoreFileOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Keystore files (*.keystore)'
        FileMask = '*.keystore'
      end>
    Options = [fdoFileMustExist]
    Left = 280
    Top = 59
  end
end

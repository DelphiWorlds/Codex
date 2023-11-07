object AssetPackDetailsView: TAssetPackDetailsView
  Left = 0
  Top = 0
  Caption = 'Asset Pack Details'
  ClientHeight = 252
  ClientWidth = 400
  Color = clBtnFace
  Constraints.MinHeight = 290
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 218
    Width = 400
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object CancelButton: TButton
      AlignWithMargins = True
      Left = 322
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
      TabOrder = 0
    end
    object OKButton: TButton
      AlignWithMargins = True
      Left = 241
      Top = 3
      Width = 75
      Height = 28
      Action = OKAction
      Align = alRight
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
    end
  end
  object AssetPackDetailsPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 394
    Height = 212
    Align = alClient
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    TabStop = True
    ExplicitWidth = 386
    ExplicitHeight = 208
    object PackFolderLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 103
      Width = 388
      Height = 15
      Align = alTop
      Caption = 'Folder:'
      ExplicitWidth = 36
    end
    object AssetPackTypeLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 153
      Width = 388
      Height = 15
      Align = alTop
      Caption = 'Pack Type:'
      ExplicitWidth = 55
    end
    object PackNameLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 53
      Width = 388
      Height = 15
      Align = alTop
      Caption = 'Pack Name:'
      ExplicitWidth = 63
    end
    object PackPackageNameLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 388
      Height = 15
      Align = alTop
      Caption = 'Package:'
      ExplicitWidth = 47
    end
    object PackKindComboBox: TComboBox
      AlignWithMargins = True
      Left = 3
      Top = 174
      Width = 388
      Height = 23
      Align = alTop
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 1
      Text = 'Install Time'
      Items.Strings = (
        'Install Time'
        'Fast Follow'
        'On Demand')
      ExplicitWidth = 380
    end
    object PackNameEdit: TEdit
      AlignWithMargins = True
      Left = 3
      Top = 74
      Width = 388
      Height = 23
      Align = alTop
      TabOrder = 2
      ExplicitWidth = 380
    end
    object PackageEdit: TEdit
      AlignWithMargins = True
      Left = 3
      Top = 24
      Width = 388
      Height = 23
      Align = alTop
      TabOrder = 3
      ExplicitWidth = 380
    end
    object FolderComboBox: TComboBox
      AlignWithMargins = True
      Left = 3
      Top = 124
      Width = 388
      Height = 23
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 380
    end
  end
  object ActionList: TActionList
    Left = 332
    Top = 59
    object OKAction: TAction
      Caption = 'OK'
      OnExecute = OKActionExecute
      OnUpdate = OKActionUpdate
    end
  end
end

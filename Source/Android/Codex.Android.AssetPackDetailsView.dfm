object AssetPackDetailsView: TAssetPackDetailsView
  Left = 0
  Top = 0
  Margins.Left = 5
  Margins.Top = 5
  Margins.Right = 5
  Margins.Bottom = 5
  Caption = 'Asset Pack Details'
  ClientHeight = 378
  ClientWidth = 609
  Color = clBtnFace
  Constraints.MinHeight = 291
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  PixelsPerInch = 144
  TextHeight = 25
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 327
    Width = 609
    Height = 51
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object CancelButton: TButton
      AlignWithMargins = True
      Left = 491
      Top = 5
      Width = 113
      Height = 41
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
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
      Left = 369
      Top = 5
      Width = 112
      Height = 41
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Action = OKAction
      Align = alRight
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
    end
  end
  object AssetPackDetailsPanel: TPanel
    AlignWithMargins = True
    Left = 5
    Top = 5
    Width = 599
    Height = 317
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alClient
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    TabStop = True
    object PackFolderLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 161
      Width = 589
      Height = 25
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Folder:'
      ExplicitTop = 135
      ExplicitWidth = 54
    end
    object AssetPackTypeLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 239
      Width = 589
      Height = 25
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Pack Type:'
      ExplicitTop = 203
      ExplicitWidth = 81
    end
    object PackNameLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 83
      Width = 589
      Height = 25
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Pack Name:'
      ExplicitTop = 70
      ExplicitWidth = 91
    end
    object PackPackageNameLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 589
      Height = 25
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Package:'
      ExplicitWidth = 68
    end
    object PackKindComboBox: TComboBox
      AlignWithMargins = True
      Left = 5
      Top = 274
      Width = 589
      Height = 33
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 1
      Text = 'Install Time'
      Items.Strings = (
        'Install Time'
        'Fast Follow'
        'On Demand')
    end
    object PackNameEdit: TEdit
      AlignWithMargins = True
      Left = 5
      Top = 118
      Width = 589
      Height = 33
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      TabOrder = 2
    end
    object PackageEdit: TEdit
      AlignWithMargins = True
      Left = 5
      Top = 40
      Width = 589
      Height = 33
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      TabOrder = 3
    end
    object FolderComboBox: TComboBox
      AlignWithMargins = True
      Left = 5
      Top = 196
      Width = 589
      Height = 33
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      TabOrder = 0
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

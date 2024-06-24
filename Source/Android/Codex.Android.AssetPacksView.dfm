object AssetPacksView: TAssetPacksView
  Left = 0
  Top = 0
  Margins.Left = 5
  Margins.Top = 5
  Margins.Right = 5
  Margins.Bottom = 5
  Caption = 'Asset Packs'
  ClientHeight = 638
  ClientWidth = 1055
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  ShowHint = True
  PixelsPerInch = 144
  TextHeight = 21
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 584
    Width = 1055
    Height = 54
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 912
      Top = 5
      Width = 138
      Height = 44
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alRight
      Caption = '&Close'
      DoubleBuffered = True
      ModalResult = 8
      ParentDoubleBuffered = False
      TabOrder = 0
      OnClick = CloseButtonClick
    end
    object BuildAllButton: TButton
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 144
      Height = 44
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Action = BuildAllAction
      Align = alLeft
      TabOrder = 1
    end
    object InstallButton: TButton
      AlignWithMargins = True
      Left = 159
      Top = 5
      Width = 144
      Height = 44
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Action = InstallAction
      Align = alLeft
      TabOrder = 2
    end
  end
  object AssetPackPathPanel: TPanel
    AlignWithMargins = True
    Left = 6
    Top = 6
    Width = 1043
    Height = 81
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    Padding.Bottom = 2
    TabOrder = 1
    object SelectAssetPacksPathButton: TSpeedButton
      AlignWithMargins = True
      Left = 1002
      Top = 36
      Width = 35
      Height = 37
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alRight
      Caption = '...'
      OnClick = SelectAssetPacksPathButtonClick
      ExplicitTop = 33
      ExplicitHeight = 41
    end
    object AssetPackPathLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 1033
      Height = 21
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Asset packs path:'
      ExplicitWidth = 133
    end
    object AssetPacksPathEdit: TEdit
      AlignWithMargins = True
      Left = 6
      Top = 37
      Width = 996
      Height = 36
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 0
      Margins.Bottom = 6
      Align = alClient
      ParentShowHint = False
      ReadOnly = True
      ShowHint = True
      TabOrder = 0
      ExplicitHeight = 29
    end
  end
  object AssetPacksListPanel: TPanel
    AlignWithMargins = True
    Left = 6
    Top = 93
    Width = 1043
    Height = 479
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 12
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object AssetPacksLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 1033
      Height = 21
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Asset Packs:'
      ExplicitWidth = 95
    end
    object PackButtonsPanel: TPanel
      Left = 0
      Top = 425
      Width = 1043
      Height = 54
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object DeletePackButton: TButton
        AlignWithMargins = True
        Left = 900
        Top = 5
        Width = 138
        Height = 44
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Action = DeletePackAction
        Align = alRight
        TabOrder = 1
      end
      object AddPackButton: TButton
        AlignWithMargins = True
        Left = 604
        Top = 5
        Width = 138
        Height = 44
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Action = AddPackAction
        Align = alRight
        TabOrder = 0
      end
      object EditPackButton: TButton
        AlignWithMargins = True
        Left = 752
        Top = 5
        Width = 138
        Height = 44
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Action = EditPackAction
        Align = alRight
        TabOrder = 2
      end
    end
    object AssetPacksListView: TListView
      AlignWithMargins = True
      Left = 5
      Top = 36
      Width = 1033
      Height = 384
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alClient
      Columns = <
        item
          Caption = 'Package'
          Width = 375
        end
        item
          Caption = 'Asset Pack Name'
          Width = 270
        end
        item
          Caption = 'Folder'
          Width = 180
        end
        item
          Caption = 'Type'
          Width = 150
        end>
      Items.ItemData = {050000000000000000}
      MultiSelect = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object ActionList: TActionList
    Left = 515
    Top = 151
    object AddPackAction: TAction
      Caption = 'Add..'
      Hint = 'Add an Asset Pack'
      OnExecute = AddPackActionExecute
      OnUpdate = AddPackActionUpdate
    end
    object DeletePackAction: TAction
      Caption = 'Delete'
      Hint = 'Delete an Asset Pack'
      OnExecute = DeletePackActionExecute
      OnUpdate = DeletePackActionUpdate
    end
    object EditPackAction: TAction
      Caption = 'Edit..'
      Hint = 'Edit the selected Asset Pack'
      OnExecute = EditPackActionExecute
      OnUpdate = EditPackActionUpdate
    end
    object BuildAllAction: TAction
      Caption = 'Build..'
      Hint = 
        'Build asset packs, and app bundle to include the packs. Note: Ap' +
        'p first needs to be deployed with Delphi'
      OnExecute = BuildAllActionExecute
      OnUpdate = BuildAllActionUpdate
    end
    object InstallAction: TAction
      Caption = 'Install'
      Hint = 'Install bundle on the selected device for local testing'
      OnExecute = InstallActionExecute
      OnUpdate = InstallActionUpdate
    end
  end
  object PackFolderOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Title = 'Select Asset Pack root folder'
    Left = 516
    Top = 216
  end
end

object AssetPacksView: TAssetPacksView
  Left = 0
  Top = 0
  Caption = 'Asset Packs'
  ClientHeight = 425
  ClientWidth = 703
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  ShowHint = True
  TextHeight = 13
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 389
    Width = 703
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 608
      Top = 3
      Width = 92
      Height = 30
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
      Left = 3
      Top = 3
      Width = 96
      Height = 30
      Action = BuildAllAction
      Align = alLeft
      TabOrder = 1
    end
    object InstallButton: TButton
      AlignWithMargins = True
      Left = 105
      Top = 3
      Width = 96
      Height = 30
      Action = InstallAction
      Align = alLeft
      TabOrder = 2
    end
  end
  object AssetPackPathPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 4
    Width = 695
    Height = 54
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 1
    object SelectAssetPacksPathButton: TSpeedButton
      AlignWithMargins = True
      Left = 668
      Top = 22
      Width = 23
      Height = 27
      Margins.Left = 0
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      Caption = '...'
      OnClick = SelectAssetPacksPathButtonClick
      ExplicitLeft = 658
      ExplicitTop = 19
      ExplicitHeight = 25
    end
    object AssetPackPathLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 689
      Height = 13
      Align = alTop
      Caption = 'Asset packs path:'
      ExplicitWidth = 86
    end
    object AssetPacksPathEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 23
      Width = 664
      Height = 26
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alClient
      ParentShowHint = False
      ReadOnly = True
      ShowHint = True
      TabOrder = 0
      ExplicitHeight = 21
    end
  end
  object AssetPacksListPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 62
    Width = 695
    Height = 319
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 8
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object AssetPacksLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 689
      Height = 13
      Align = alTop
      Caption = 'Asset Packs:'
      ExplicitWidth = 61
    end
    object PackButtonsPanel: TPanel
      Left = 0
      Top = 283
      Width = 695
      Height = 36
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object DeletePackButton: TButton
        AlignWithMargins = True
        Left = 600
        Top = 3
        Width = 92
        Height = 30
        Action = DeletePackAction
        Align = alRight
        TabOrder = 1
      end
      object AddPackButton: TButton
        AlignWithMargins = True
        Left = 404
        Top = 3
        Width = 92
        Height = 30
        Action = AddPackAction
        Align = alRight
        TabOrder = 0
      end
      object EditPackButton: TButton
        AlignWithMargins = True
        Left = 502
        Top = 3
        Width = 92
        Height = 30
        Action = EditPackAction
        Align = alRight
        TabOrder = 2
      end
    end
    object AssetPacksListView: TListView
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 689
      Height = 258
      Align = alClient
      Columns = <
        item
          Caption = 'Package'
          Width = 250
        end
        item
          Caption = 'Asset Pack Name'
          Width = 180
        end
        item
          Caption = 'Folder'
          Width = 120
        end
        item
          Caption = 'Type'
          Width = 100
        end>
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

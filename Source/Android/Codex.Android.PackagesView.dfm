object PackagesView: TPackagesView
  Left = 0
  Top = 0
  Caption = 'Android Packages'
  ClientHeight = 405
  ClientWidth = 594
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 13
  object PackageFolderLabel: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 588
    Height = 13
    Align = alTop
    Caption = 'Packages:'
    ExplicitWidth = 49
  end
  object ExtractButtonsPanel: TPanel
    Left = 0
    Top = 367
    Width = 594
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object BuildButton: TButton
      AlignWithMargins = True
      Left = 398
      Top = 3
      Width = 92
      Height = 32
      Action = BuildAction
      Align = alRight
      TabOrder = 0
    end
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 496
      Top = 3
      Width = 95
      Height = 32
      Align = alRight
      Caption = '&Close'
      DoubleBuffered = True
      ModalResult = 8
      ParentDoubleBuffered = False
      TabOrder = 1
    end
    object RetainWorkingFilesCheckBox: TCheckBox
      Left = 0
      Top = 0
      Width = 205
      Height = 38
      Hint = 
        'Leaves working files in place, which can be useful when errors o' +
        'ccur'
      Align = alLeft
      Caption = 'Retain working files'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = RetainWorkingFilesCheckBoxClick
    end
  end
  object RJarPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 261
    Width = 588
    Height = 50
    Margins.Top = 0
    Align = alBottom
    BevelOuter = bvNone
    Caption = '...'
    TabOrder = 1
    Visible = False
    object SelectRJarPathButton: TSpeedButton
      AlignWithMargins = True
      Left = 560
      Top = 22
      Width = 24
      Height = 25
      Margins.Left = 0
      Margins.Right = 4
      Align = alRight
      Caption = '...'
      ExplicitLeft = 557
      ExplicitTop = 24
      ExplicitHeight = 23
    end
    object RJarFileNameLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 582
      Height = 13
      Align = alTop
      Caption = 'Output folder:'
      ExplicitWidth = 69
    end
    object RJarPathEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 23
      Width = 556
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alClient
      TabOrder = 0
      ExplicitHeight = 21
    end
  end
  object PackagesPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 22
    Width = 588
    Height = 236
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object PackagesListBox: TListBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 582
      Height = 192
      Align = alClient
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 0
    end
    object PackagesButtonsPanel: TPanel
      Left = 0
      Top = 198
      Width = 588
      Height = 38
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object RemovePackageButton: TButton
        AlignWithMargins = True
        Left = 101
        Top = 3
        Width = 92
        Height = 32
        Action = RemovePackageAction
        Align = alLeft
        TabOrder = 1
      end
      object AddPackageButton: TButton
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 92
        Height = 32
        Action = AddPackageAction
        Align = alLeft
        TabOrder = 0
      end
    end
  end
  object ProjectFolderPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 314
    Width = 588
    Height = 50
    Margins.Top = 0
    Align = alBottom
    BevelOuter = bvNone
    Caption = '...'
    TabOrder = 3
    object SelectProjectFolderButton: TSpeedButton
      AlignWithMargins = True
      Left = 560
      Top = 22
      Width = 24
      Height = 25
      Margins.Left = 0
      Margins.Right = 4
      Align = alRight
      Caption = '...'
      ExplicitLeft = 557
      ExplicitTop = 24
      ExplicitHeight = 23
    end
    object ProjectFolderLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 582
      Height = 13
      Align = alTop
      Caption = 'Project folder:'
      ExplicitWidth = 69
    end
    object ProjectFolderEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 23
      Width = 556
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alClient
      TabOrder = 0
      ExplicitHeight = 21
    end
  end
  object ActionList: TActionList
    Left = 328
    Top = 40
    object AddPackageAction: TAction
      Caption = 'Add..'
      OnExecute = AddPackageActionExecute
    end
    object RemovePackageAction: TAction
      Caption = 'Remove'
      OnExecute = RemovePackageActionExecute
      OnUpdate = RemovePackageActionUpdate
    end
    object BuildAction: TAction
      Caption = 'Execute'
      OnExecute = BuildActionExecute
      OnUpdate = BuildActionUpdate
    end
  end
  object RJarPathOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders]
    Title = 'Select  folder to output R jar'
    Left = 72
    Top = 40
  end
  object SelectFolderOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders]
    Title = 'Select folder...'
    Left = 212
    Top = 40
  end
end

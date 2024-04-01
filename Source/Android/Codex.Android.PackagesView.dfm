object PackagesView: TPackagesView
  Left = 0
  Top = 0
  Margins.Left = 5
  Margins.Top = 5
  Margins.Right = 5
  Margins.Bottom = 5
  Caption = 'Android Packages'
  ClientHeight = 608
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  PixelsPerInch = 144
  TextHeight = 21
  object PackageFolderLabel: TLabel
    AlignWithMargins = True
    Left = 5
    Top = 5
    Width = 890
    Height = 21
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alTop
    Caption = 'Packages:'
    ExplicitWidth = 75
  end
  object ExtractButtonsPanel: TPanel
    Left = 0
    Top = 555
    Width = 900
    Height = 53
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object BuildButton: TButton
      AlignWithMargins = True
      Left = 606
      Top = 5
      Width = 138
      Height = 43
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Action = BuildAction
      Align = alRight
      TabOrder = 0
    end
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 754
      Top = 5
      Width = 141
      Height = 43
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
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
      Width = 308
      Height = 53
      Hint = 
        'Leaves working files in place, which can be useful when errors o' +
        'ccur'
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
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
    Left = 5
    Top = 397
    Width = 890
    Height = 73
    Margins.Left = 5
    Margins.Top = 0
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alBottom
    BevelOuter = bvNone
    Caption = '...'
    TabOrder = 1
    Visible = False
    object SelectRJarPathButton: TSpeedButton
      AlignWithMargins = True
      Left = 848
      Top = 36
      Width = 36
      Height = 32
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 6
      Margins.Bottom = 5
      Align = alRight
      Caption = '...'
      ExplicitLeft = 840
      ExplicitTop = 33
      ExplicitHeight = 36
    end
    object RJarFileNameLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 880
      Height = 21
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Output folder:'
      ExplicitWidth = 104
    end
    object RJarPathEdit: TEdit
      AlignWithMargins = True
      Left = 6
      Top = 37
      Width = 842
      Height = 30
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 0
      Margins.Bottom = 6
      Align = alClient
      TabOrder = 0
      ExplicitHeight = 29
    end
  end
  object PackagesPanel: TPanel
    AlignWithMargins = True
    Left = 5
    Top = 36
    Width = 890
    Height = 356
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object PackagesListBox: TListBox
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 880
      Height = 289
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alClient
      ItemHeight = 21
      MultiSelect = True
      TabOrder = 0
    end
    object PackagesButtonsPanel: TPanel
      Left = 0
      Top = 299
      Width = 890
      Height = 57
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object RemovePackageButton: TButton
        AlignWithMargins = True
        Left = 153
        Top = 5
        Width = 138
        Height = 47
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Action = RemovePackageAction
        Align = alLeft
        TabOrder = 1
      end
      object AddPackageButton: TButton
        AlignWithMargins = True
        Left = 5
        Top = 5
        Width = 138
        Height = 47
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Action = AddPackageAction
        Align = alLeft
        TabOrder = 0
      end
    end
  end
  object ProjectFolderPanel: TPanel
    AlignWithMargins = True
    Left = 5
    Top = 475
    Width = 890
    Height = 75
    Margins.Left = 5
    Margins.Top = 0
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alBottom
    BevelOuter = bvNone
    Caption = '...'
    TabOrder = 3
    object SelectProjectFolderButton: TSpeedButton
      AlignWithMargins = True
      Left = 848
      Top = 36
      Width = 36
      Height = 34
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 6
      Margins.Bottom = 5
      Align = alRight
      Caption = '...'
      ExplicitLeft = 840
      ExplicitTop = 33
      ExplicitHeight = 38
    end
    object ProjectFolderLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 880
      Height = 21
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Project folder:'
      ExplicitWidth = 105
    end
    object ProjectFolderEdit: TEdit
      AlignWithMargins = True
      Left = 6
      Top = 37
      Width = 842
      Height = 32
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 0
      Margins.Bottom = 6
      Align = alClient
      TabOrder = 0
      ExplicitHeight = 29
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

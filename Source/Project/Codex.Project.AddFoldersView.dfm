object AddFoldersView: TAddFoldersView
  Left = 0
  Top = 0
  Caption = 'Add Folders To Search Path'
  ClientHeight = 795
  ClientWidth = 908
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 13
  object ConfigLabel: TLabel
    AlignWithMargins = True
    Left = 6
    Top = 707
    Width = 896
    Height = 13
    Margins.Left = 6
    Margins.Top = 5
    Margins.Right = 6
    Align = alBottom
    Caption = 'Config:'
    ExplicitWidth = 35
  end
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 761
    Width = 908
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object OKButton: TButton
      AlignWithMargins = True
      Left = 715
      Top = 3
      Width = 92
      Height = 28
      Action = OKAction
      Align = alRight
      TabOrder = 0
    end
    object CancelButton: TButton
      AlignWithMargins = True
      Left = 813
      Top = 3
      Width = 92
      Height = 28
      Align = alRight
      Caption = 'Close'
      DoubleBuffered = True
      ModalResult = 8
      ParentDoubleBuffered = False
      TabOrder = 1
    end
  end
  object PathsPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 902
    Height = 407
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object PathsLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 896
      Height = 13
      Margins.Bottom = 6
      Align = alTop
      Caption = 'Folders:'
      ExplicitWidth = 39
    end
    object FoldersMemo: TMemo
      AlignWithMargins = True
      Left = 3
      Top = 25
      Width = 896
      Height = 343
      Margins.Bottom = 5
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object PathsButtonsPanel: TPanel
      Left = 0
      Top = 373
      Width = 902
      Height = 34
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object SelectFromFolderButton: TButton
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 124
        Height = 28
        Align = alLeft
        Caption = 'Select Folder..'
        TabOrder = 0
        OnClick = SelectFromFolderButtonClick
      end
      object ClearFoldersButton: TButton
        AlignWithMargins = True
        Left = 807
        Top = 3
        Width = 92
        Height = 28
        ParentCustomHint = False
        Action = ClearFoldersAction
        Align = alRight
        TabOrder = 1
      end
    end
  end
  object ConfigPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 726
    Width = 902
    Height = 27
    Margins.Bottom = 8
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
  end
  object MacrosPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 416
    Width = 902
    Height = 283
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object MacrosLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 896
      Height = 13
      Margins.Bottom = 6
      Align = alTop
      Caption = 'User Overrides:'
      ExplicitWidth = 76
    end
    object MacrosButtonsPanel: TPanel
      Left = 0
      Top = 249
      Width = 902
      Height = 34
      Margins.Top = 8
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object ApplyMacroButton: TButton
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 124
        Height = 28
        Action = UseMacroAction
        Align = alLeft
        Caption = 'Use Override Folders'
        TabOrder = 0
      end
    end
    object MacrosCheckListBox: TCheckListBox
      AlignWithMargins = True
      Left = 3
      Top = 25
      Width = 896
      Height = 219
      Margins.Bottom = 5
      Align = alClient
      ItemHeight = 13
      TabOrder = 1
    end
  end
  object ActionList: TActionList
    Left = 160
    Top = 121
    object OKAction: TAction
      Caption = 'OK'
      OnExecute = OKActionExecute
      OnUpdate = OKActionUpdate
    end
    object UseMacroAction: TAction
      Caption = 'Use Override'
      OnExecute = UseMacroActionExecute
      OnUpdate = UseMacroActionUpdate
    end
    object ClearFoldersAction: TAction
      Caption = 'Clear Folders'
      OnExecute = ClearFoldersActionExecute
      OnUpdate = ClearFoldersActionUpdate
    end
  end
  object FolderOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Title = 'Select folder to add, including subfolders'
    Left = 280
    Top = 120
  end
end

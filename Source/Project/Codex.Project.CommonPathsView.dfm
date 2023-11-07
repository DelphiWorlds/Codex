object CommonPathsView: TCommonPathsView
  Left = 0
  Top = 0
  Caption = 'Common Paths'
  ClientHeight = 451
  ClientWidth = 572
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 417
    Width = 572
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object MessageLabel: TLabel
      AlignWithMargins = True
      Left = 6
      Top = 3
      Width = 367
      Height = 28
      Margins.Left = 6
      Align = alClient
      Caption = 'Copied to clipboard'
      Layout = tlCenter
      ExplicitWidth = 92
      ExplicitHeight = 13
    end
    object CopyButton: TButton
      AlignWithMargins = True
      Left = 379
      Top = 3
      Width = 92
      Height = 28
      Align = alRight
      Caption = 'Copy'
      TabOrder = 0
      OnClick = CopyActionExecute
    end
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 477
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
  object RecentProjectsPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 4
    Width = 564
    Height = 153
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object ProjectsLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 558
      Height = 13
      Align = alTop
      Caption = 'Projects:'
      ExplicitWidth = 43
    end
    object FileButtonsPanel: TPanel
      Left = 0
      Top = 121
      Width = 564
      Height = 32
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object RemoveFileButton: TButton
        AlignWithMargins = True
        Left = 469
        Top = 3
        Width = 92
        Height = 26
        Action = RemoveProjectAction
        Align = alRight
        TabOrder = 1
      end
      object AddFileButton: TButton
        AlignWithMargins = True
        Left = 371
        Top = 3
        Width = 92
        Height = 26
        Action = AddProjectAction
        Align = alRight
        TabOrder = 0
      end
    end
    object ProjectsListBox: TListBox
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 558
      Height = 96
      Align = alClient
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 0
      OnClick = ProjectsListBoxClick
    end
  end
  object ProjectPathsPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 193
    Width = 566
    Height = 221
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object ProjectPathsLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 560
      Height = 13
      Align = alTop
      Caption = 'Project Paths:'
      ExplicitWidth = 68
    end
    object ProjectPathsListBox: TListBox
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 560
      Height = 196
      Align = alClient
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object ConfigPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 160
    Width = 566
    Height = 27
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
  end
  object ActionList: TActionList
    Left = 160
    Top = 245
    object AddProjectAction: TAction
      Caption = 'Add..'
      OnExecute = AddProjectActionExecute
    end
    object RemoveProjectAction: TAction
      Caption = 'Remove'
      OnExecute = RemoveProjectActionExecute
      OnUpdate = RemoveProjectActionUpdate
    end
    object CopyAction: TAction
      Caption = 'Copy'
      OnExecute = CopyActionExecute
      OnUpdate = CopyActionUpdate
    end
  end
  object ProjectOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Delphi Project Files (*.dproj)'
        FileMask = '*.dproj'
      end>
    Options = []
    Title = 'Select Delphi Project'
    Left = 286
    Top = 245
  end
  object MessageTimer: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = MessageTimerTimer
    Left = 428
    Top = 247
  end
end

object CommonPathsView: TCommonPathsView
  Left = 0
  Top = 0
  Margins.Left = 4
  Margins.Top = 4
  Margins.Right = 4
  Margins.Bottom = 4
  Caption = 'Common Paths'
  ClientHeight = 564
  ClientWidth = 718
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  PixelsPerInch = 120
  TextHeight = 17
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 521
    Width = 718
    Height = 43
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object MessageLabel: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 4
      Width = 460
      Height = 35
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      Caption = 'Copied to clipboard'
      Layout = tlCenter
      ExplicitWidth = 118
      ExplicitHeight = 17
    end
    object CopyButton: TButton
      AlignWithMargins = True
      Left = 476
      Top = 4
      Width = 115
      Height = 35
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      Caption = 'Copy'
      TabOrder = 0
      OnClick = CopyActionExecute
    end
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 599
      Top = 4
      Width = 115
      Height = 35
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
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
    Left = 5
    Top = 5
    Width = 708
    Height = 191
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object ProjectsLabel: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 700
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      Caption = 'Projects:'
      ExplicitWidth = 55
    end
    object FileButtonsPanel: TPanel
      Left = 0
      Top = 151
      Width = 708
      Height = 40
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object RemoveFileButton: TButton
        AlignWithMargins = True
        Left = 589
        Top = 4
        Width = 115
        Height = 32
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Action = RemoveProjectAction
        Align = alRight
        TabOrder = 1
      end
      object AddFileButton: TButton
        AlignWithMargins = True
        Left = 466
        Top = 4
        Width = 115
        Height = 32
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Action = AddProjectAction
        Align = alRight
        TabOrder = 0
      end
    end
    object ProjectsListBox: TListBox
      AlignWithMargins = True
      Left = 4
      Top = 29
      Width = 700
      Height = 118
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      ItemHeight = 17
      MultiSelect = True
      TabOrder = 0
      OnClick = ProjectsListBoxClick
    end
  end
  object ProjectPathsPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 242
    Width = 710
    Height = 275
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object ProjectPathsLabel: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 702
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      Caption = 'Project Paths:'
      ExplicitWidth = 87
    end
    object ProjectPathsListBox: TListBox
      AlignWithMargins = True
      Left = 4
      Top = 29
      Width = 702
      Height = 242
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      ItemHeight = 17
      TabOrder = 0
    end
  end
  object ConfigPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 200
    Width = 710
    Height = 34
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
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

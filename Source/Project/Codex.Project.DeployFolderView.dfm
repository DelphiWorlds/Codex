object DeployFolderView: TDeployFolderView
  Left = 0
  Top = 0
  Caption = 'Deploy Folder'
  ClientHeight = 400
  ClientWidth = 542
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object SourcePathPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 0
    Width = 534
    Height = 50
    Margins.Left = 4
    Margins.Top = 0
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 0
    object SelectSourcePathSpeedButton: TSpeedButton
      AlignWithMargins = True
      Left = 507
      Top = 24
      Width = 23
      Height = 22
      Margins.Left = 0
      Margins.Right = 4
      Align = alRight
      Caption = '...'
      OnClick = SelectSourcePathSpeedButtonClick
      ExplicitLeft = 658
      ExplicitTop = 19
      ExplicitHeight = 25
    end
    object SourcePathLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 528
      Height = 15
      Align = alTop
      Caption = 'Source Folder:'
      ExplicitWidth = 75
    end
    object SourcePathEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 25
      Width = 503
      Height = 20
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnChange = SourcePathEditChange
      ExplicitHeight = 23
    end
  end
  object RemotePathPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 54
    Width = 534
    Height = 50
    Margins.Left = 4
    Margins.Top = 0
    Margins.Right = 4
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 1
    object RemotePathLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 528
      Height = 15
      Align = alTop
      Caption = 'Remote Path:'
      ExplicitWidth = 71
    end
    object RemotePathEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 25
      Width = 530
      Height = 20
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      ExplicitHeight = 23
    end
  end
  object ButtonsPanel: TPanel
    Left = 0
    Top = 369
    Width = 542
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object CancelButton: TButton
      AlignWithMargins = True
      Left = 463
      Top = 3
      Width = 75
      Height = 25
      Margins.Right = 4
      Align = alRight
      Cancel = True
      Caption = 'Cancel'
      DoubleBuffered = True
      ModalResult = 2
      ParentDoubleBuffered = False
      TabOrder = 0
    end
    object OKButton: TButton
      AlignWithMargins = True
      Left = 381
      Top = 3
      Width = 75
      Height = 25
      Margins.Right = 4
      Action = OKAction
      Align = alRight
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
    end
  end
  object PlatformsPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 107
    Width = 536
    Height = 259
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object PlatformsLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 530
      Height = 15
      Align = alTop
      Caption = 'Platforms:'
      ExplicitWidth = 54
    end
    object PlatformsTreeView: TTreeView
      AlignWithMargins = True
      Left = 3
      Top = 21
      Width = 530
      Height = 235
      Margins.Top = 0
      Align = alClient
      Indent = 19
      TabOrder = 0
    end
  end
  object ActionList: TActionList
    Left = 131
    Top = 159
    object OKAction: TAction
      Caption = 'OK'
      OnExecute = OKActionExecute
      OnUpdate = OKActionUpdate
    end
  end
  object SourceFolderOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Title = 'Select Asset Pack root folder'
    Left = 130
    Top = 228
  end
end

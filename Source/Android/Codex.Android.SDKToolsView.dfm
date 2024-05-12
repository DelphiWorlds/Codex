object SDKToolsView: TSDKToolsView
  Left = 0
  Top = 0
  Caption = 'SDK Tools'
  ClientHeight = 498
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnResize = FormResize
  TextHeight = 15
  object APILevelsLabel: TLabel
    AlignWithMargins = True
    Left = 4
    Top = 4
    Width = 472
    Height = 15
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 0
    Align = alTop
    Caption = 'Available API Levels: (greyed items are already installed)'
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 293
  end
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 464
    Width = 480
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 4
    Padding.Top = 4
    Padding.Right = 4
    Padding.Bottom = 4
    TabOrder = 0
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 382
      Top = 4
      Width = 94
      Height = 26
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      Cancel = True
      Caption = 'Close'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
      OnClick = CloseButtonClick
    end
    object InstallButton: TButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 94
      Height = 26
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Action = InstallAction
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
      ExplicitLeft = 8
      ExplicitTop = 8
    end
  end
  object APILevelsCheckListBox: TCheckListBox
    AlignWithMargins = True
    Left = 4
    Top = 23
    Width = 472
    Height = 409
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 0
    Align = alClient
    ItemHeight = 17
    Sorted = True
    TabOrder = 1
    ExplicitWidth = 464
    ExplicitHeight = 363
  end
  object ProgressBar: TProgressBar
    AlignWithMargins = True
    Left = 3
    Top = 435
    Width = 474
    Height = 26
    Align = alBottom
    TabOrder = 2
    ExplicitTop = 389
    ExplicitWidth = 466
  end
  object ActionList: TActionList
    Left = 228
    Top = 256
    object InstallAction: TAction
      Caption = 'Install'
      OnExecute = InstallActionExecute
      OnUpdate = InstallActionUpdate
    end
    object AddAVDAction: TAction
      Caption = 'Add..'
    end
    object DeleteAVDAction: TAction
      Caption = 'Delete'
    end
    object StartAVDAction: TAction
      Caption = 'Start..'
    end
  end
end

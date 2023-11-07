object ADBConnectView: TADBConnectView
  Left = 0
  Top = 0
  Caption = 'ADB Connect'
  ClientHeight = 304
  ClientWidth = 606
  Color = clBtnFace
  Constraints.MinWidth = 608
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  TextHeight = 13
  object IPAddressLabel: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 45
    Width = 600
    Height = 13
    Align = alTop
    Caption = 'Target Device IP Address && Port:'
    ExplicitWidth = 159
  end
  object ReminderLabel: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 600
    Height = 36
    Align = alTop
    AutoSize = False
    Caption = 
      'Remember that the target device needs to first be connected to a' +
      ' PC or Mac and this command run on it: adb tcpip 5555'#13#10'This only' +
      ' has to be done once since the device was last restarted'
    WordWrap = True
  end
  object ButtonsPanel: TPanel
    Left = 0
    Top = 272
    Width = 606
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 527
      Top = 3
      Width = 75
      Height = 26
      Margins.Right = 4
      Align = alRight
      Caption = 'Close'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 2
      OnClick = CloseButtonClick
    end
    object ConnectButton: TButton
      AlignWithMargins = True
      Left = 445
      Top = 3
      Width = 75
      Height = 26
      Margins.Right = 4
      Align = alRight
      Caption = 'Connect'
      Default = True
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
      OnClick = ConnectButtonClick
    end
    object DismissCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 8
      Top = 0
      Width = 434
      Height = 32
      Margins.Left = 8
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      Caption = 'Dismiss on successful connect'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
  end
  object IPPanel: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 61
    Width = 606
    Height = 24
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object RecentIPLabel: TLabel
      AlignWithMargins = True
      Left = 344
      Top = 0
      Width = 38
      Height = 22
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 8
      Margins.Bottom = 2
      Align = alRight
      Alignment = taRightJustify
      Caption = 'Recent:'
      Layout = tlCenter
      ExplicitHeight = 13
    end
    object IPComboBox: TComboBox
      AlignWithMargins = True
      Left = 390
      Top = 0
      Width = 216
      Height = 21
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      Style = csDropDownList
      TabOrder = 0
      OnChange = IPComboBoxChange
    end
    object IPAddressPanel: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 0
      Width = 344
      Height = 24
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Padding.Left = 2
      Padding.Top = 2
      Padding.Right = 2
      Padding.Bottom = 2
      TabOrder = 1
    end
  end
  object OutputMemo: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 88
    Width = 600
    Height = 181
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
end

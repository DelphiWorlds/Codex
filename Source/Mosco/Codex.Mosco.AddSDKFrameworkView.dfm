object AddSDKFrameworkView: TAddSDKFrameworkView
  Left = 0
  Top = 0
  Caption = 'Add SDK Frameworks'
  ClientHeight = 712
  ClientWidth = 354
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 13
  object SDKsLabel: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 348
    Height = 13
    Align = alTop
    Caption = 'SDKs on the Mac:'
    ExplicitWidth = 84
  end
  object FrameworksLabel: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 153
    Width = 348
    Height = 13
    Margins.Top = 0
    Align = alTop
    Caption = 'Frameworks:'
    ExplicitWidth = 62
  end
  object BottomPanel: TPanel
    Left = 0
    Top = 678
    Width = 354
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
      Left = 266
      Top = 4
      Width = 84
      Height = 26
      Margins.Left = 8
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      Caption = 'Close'
      ModalResult = 8
      TabOrder = 0
    end
    object AddFrameworksButton: TButton
      Left = 174
      Top = 4
      Width = 84
      Height = 26
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Action = AddFrameworksAction
      Align = alRight
      TabOrder = 1
    end
  end
  object SDKsListBox: TListBox
    Tag = -1
    AlignWithMargins = True
    Left = 3
    Top = 19
    Width = 348
    Height = 78
    Margins.Top = 0
    Margins.Bottom = 5
    Align = alTop
    ItemHeight = 13
    TabOrder = 1
    OnClick = SDKsListBoxClick
  end
  object FrameworksListBox: TCheckListBox
    AlignWithMargins = True
    Left = 3
    Top = 169
    Width = 348
    Height = 504
    Margins.Top = 0
    Margins.Bottom = 5
    Align = alClient
    ItemHeight = 13
    TabOrder = 2
  end
  object MatchingSDKPanel: TPanel
    Left = 0
    Top = 102
    Width = 354
    Height = 51
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    object MatchingSDKLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 0
      Width = 348
      Height = 13
      Margins.Top = 0
      Align = alTop
      Caption = 'Matching imported SDK:'
      ExplicitWidth = 114
    end
    object MatchingSDKEdit: TEdit
      AlignWithMargins = True
      Left = 3
      Top = 19
      Width = 348
      Height = 21
      Align = alTop
      ReadOnly = True
      TabOrder = 0
    end
  end
  object ActionList: TActionList
    Left = 280
    Top = 168
    object AddFrameworksAction: TAction
      Caption = 'Add..'
      OnExecute = AddFrameworksActionExecute
      OnUpdate = AddFrameworksActionUpdate
    end
  end
end

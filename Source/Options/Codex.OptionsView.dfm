object OptionsView: TOptionsView
  Left = 0
  Top = 0
  Caption = 'Codex Options'
  ClientHeight = 604
  ClientWidth = 802
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 13
  object SectionSplitter: TSplitter
    Left = 212
    Top = 0
    Width = 4
    Height = 570
    ExplicitHeight = 553
  end
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 570
    Width = 802
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object CancelButton: TButton
      AlignWithMargins = True
      Left = 724
      Top = 3
      Width = 75
      Height = 28
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
      Left = 643
      Top = 3
      Width = 75
      Height = 28
      Align = alRight
      Caption = 'OK'
      Default = True
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
      OnClick = OKButtonClick
    end
  end
  object SectionsTreeView: TTreeView
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 206
    Height = 564
    Align = alLeft
    HideSelection = False
    Indent = 19
    MultiSelectStyle = []
    ReadOnly = True
    RowSelect = True
    ShowButtons = False
    ShowLines = False
    TabOrder = 1
    OnChange = SectionsTreeViewChange
  end
  object SectionPanel: TPanel
    AlignWithMargins = True
    Left = 219
    Top = 3
    Width = 580
    Height = 564
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
  end
end

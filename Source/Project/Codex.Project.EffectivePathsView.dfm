object EffectivePathsView: TEffectivePathsView
  Left = 0
  Top = 0
  Caption = 'Effective Paths'
  ClientHeight = 408
  ClientWidth = 612
  Color = clBtnFace
  Constraints.MinHeight = 132
  Constraints.MinWidth = 624
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 13
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 376
    Width = 612
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object CopyListLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 426
      Height = 26
      Align = alLeft
      Caption = 
        'List is multi-selectable. Use Ctrl-C to copy all to clipboard, o' +
        'r Shift-Ctrl-C to copy selected'
      Layout = tlCenter
      ExplicitHeight = 13
    end
    object FindUnitButton: TBitBtn
      AlignWithMargins = True
      Left = 453
      Top = 3
      Width = 75
      Height = 26
      Action = FindUnitAction
      Align = alRight
      Caption = 'Find'
      NumGlyphs = 2
      TabOrder = 1
    end
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 534
      Top = 3
      Width = 75
      Height = 26
      Align = alRight
      Caption = '&Close'
      DoubleBuffered = True
      ModalResult = 8
      ParentDoubleBuffered = False
      TabOrder = 0
    end
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 612
    Height = 376
    ActivePage = EffectivePathsTab
    Align = alClient
    TabOrder = 0
    object EffectivePathsTab: TTabSheet
      Caption = 'Effective Paths'
      TabVisible = False
      object InvalidPathsLabel: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 350
        Width = 598
        Height = 13
        Margins.Top = 0
        Align = alBottom
        Caption = 'Invalid paths are colored orange'
        ExplicitWidth = 156
      end
      object EffectivePathsListBox: TListBox
        AlignWithMargins = True
        Left = 4
        Top = 4
        Width = 596
        Height = 342
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Style = lbOwnerDrawFixed
        Align = alClient
        ItemHeight = 13
        MultiSelect = True
        TabOrder = 0
        OnDrawItem = EffectivePathsListBoxDrawItem
      end
    end
    object FindUnitTab: TTabSheet
      Caption = 'Find Unit'
      ImageIndex = 1
      TabVisible = False
      object UnitNameLabel: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 53
        Height = 13
        Align = alTop
        Caption = 'Unit Name:'
      end
      object FindResultsLabel: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 46
        Width = 39
        Height = 13
        Align = alTop
        Caption = 'Results:'
      end
      object UnitNameEdit: TEdit
        AlignWithMargins = True
        Left = 3
        Top = 19
        Width = 596
        Height = 21
        Margins.Top = 0
        Align = alTop
        TabOrder = 0
      end
      object FindResultsListBox: TListBox
        AlignWithMargins = True
        Left = 3
        Top = 65
        Width = 596
        Height = 301
        Margins.Bottom = 0
        Style = lbOwnerDrawFixed
        Align = alClient
        ItemHeight = 13
        MultiSelect = True
        TabOrder = 1
        OnDrawItem = FindResultsListBoxDrawItem
      end
    end
  end
  object ActionList: TActionList
    Left = 196
    Top = 170
    object FindUnitAction: TAction
      Caption = 'Find'
      OnExecute = FindUnitActionExecute
      OnUpdate = FindUnitActionUpdate
    end
  end
end

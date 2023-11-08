object DuplicateModuleView: TDuplicateModuleView
  Left = 0
  Top = 0
  Caption = 'Duplicate Module'
  ClientHeight = 206
  ClientWidth = 572
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object ContentsPanel: TPanel
    Left = 0
    Top = 0
    Width = 572
    Height = 172
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 4
    Padding.Top = 4
    Padding.Right = 4
    Padding.Bottom = 4
    TabOrder = 0
    ExplicitWidth = 568
    ExplicitHeight = 171
    object DetailsPanel: TPanel
      Left = 4
      Top = 4
      Width = 564
      Height = 164
      Align = alClient
      BevelOuter = bvNone
      Padding.Left = 8
      Padding.Top = 2
      Padding.Right = 2
      Padding.Bottom = 2
      ParentColor = True
      TabOrder = 0
      ExplicitWidth = 560
      ExplicitHeight = 163
      object ExistingNameLabel: TLabel
        AlignWithMargins = True
        Left = 8
        Top = 49
        Width = 554
        Height = 15
        Margins.Left = 0
        Margins.Top = 6
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        Caption = 'Existing Object Name:'
        ExplicitWidth = 117
      end
      object ModuleIDLabel: TLabel
        AlignWithMargins = True
        Left = 8
        Top = 2
        Width = 554
        Height = 15
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        Caption = 'Module:'
        ExplicitWidth = 44
      end
      object NewNameLabel: TLabel
        AlignWithMargins = True
        Left = 8
        Top = 97
        Width = 554
        Height = 15
        Margins.Left = 0
        Margins.Top = 6
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        Caption = 'New Object Name:'
        ExplicitWidth = 100
      end
      object ExistingNameEdit: TEdit
        AlignWithMargins = True
        Left = 8
        Top = 68
        Width = 530
        Height = 23
        Margins.Left = 0
        Margins.Top = 4
        Margins.Right = 24
        Margins.Bottom = 0
        Align = alTop
        ReadOnly = True
        TabOrder = 1
        OnChange = ModuleIDEditChange
        ExplicitWidth = 526
      end
      object ModuleIDPanel: TPanel
        AlignWithMargins = True
        Left = 8
        Top = 19
        Width = 554
        Height = 24
        Margins.Left = 0
        Margins.Top = 2
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        BevelOuter = bvNone
        Padding.Bottom = 1
        TabOrder = 0
        ExplicitWidth = 550
        object SelectModuleButton: TSpeedButton
          AlignWithMargins = True
          Left = 531
          Top = 0
          Width = 23
          Height = 23
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alRight
          Caption = '...'
          OnClick = SelectModuleButtonClick
          ExplicitLeft = 658
          ExplicitTop = 19
          ExplicitHeight = 25
        end
        object ModuleIDEdit: TEdit
          AlignWithMargins = True
          Left = 0
          Top = 0
          Width = 531
          Height = 23
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alClient
          ParentShowHint = False
          ReadOnly = True
          ShowHint = True
          TabOrder = 0
          OnChange = ModuleIDEditChange
          ExplicitWidth = 527
        end
      end
      object NewNameEdit: TEdit
        AlignWithMargins = True
        Left = 8
        Top = 116
        Width = 530
        Height = 23
        Margins.Left = 0
        Margins.Top = 4
        Margins.Right = 24
        Margins.Bottom = 0
        Align = alTop
        Enabled = False
        TabOrder = 2
        OnChange = NewNameEditChange
        ExplicitWidth = 526
      end
    end
  end
  object DialogButtonsPanel: TPanel
    Left = 0
    Top = 172
    Width = 572
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 171
    ExplicitWidth = 568
    object CancelButton: TButton
      AlignWithMargins = True
      Left = 494
      Top = 3
      Width = 75
      Height = 28
      Align = alRight
      Cancel = True
      Caption = 'Cancel'
      Default = True
      DoubleBuffered = True
      ModalResult = 2
      ParentDoubleBuffered = False
      TabOrder = 0
      ExplicitLeft = 490
    end
    object OKButton: TButton
      AlignWithMargins = True
      Left = 413
      Top = 3
      Width = 75
      Height = 28
      Action = OKAction
      Align = alRight
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
      ExplicitLeft = 409
    end
    object AddToProjectCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 12
      Top = 0
      Width = 161
      Height = 34
      Margins.Left = 12
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      Caption = 'Add To Active Project'
      TabOrder = 2
    end
  end
  object ActionList: TActionList
    Left = 193
    Top = 84
    object OKAction: TAction
      Caption = 'OK'
      OnExecute = OKActionExecute
      OnUpdate = OKActionUpdate
    end
  end
  object ModuleOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Delphi source (*.pas)'
        FileMask = '*.pas'
      end>
    Options = [fdoFileMustExist]
    Left = 292
    Top = 84
  end
  object ModuleSaveDialog: TFileSaveDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Module files (*.pas)'
        FileMask = '*.pas'
      end>
    Options = [fdoOverWritePrompt]
    Left = 416
    Top = 84
  end
end

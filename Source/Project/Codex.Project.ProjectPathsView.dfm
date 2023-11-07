object ProjectPathsView: TProjectPathsView
  Left = 0
  Top = 0
  Caption = 'Insert Project Paths'
  ClientHeight = 350
  ClientWidth = 821
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 13
  object MainSplitter: TSplitter
    Left = 420
    Top = 0
    Width = 4
    Height = 319
    ExplicitLeft = 473
    ExplicitTop = -20
  end
  object ButtonsPanel: TPanel
    Left = 0
    Top = 319
    Width = 821
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object CancelButton: TButton
      AlignWithMargins = True
      Left = 742
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
      Left = 660
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
  object EffectivePathsPanel: TPanel
    AlignWithMargins = True
    Left = 427
    Top = 3
    Width = 391
    Height = 313
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object EffectivePathsLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 385
      Height = 13
      Align = alTop
      Caption = 'Current Effective Paths:'
      ExplicitWidth = 117
    end
    object EffectivePathsListBox: TListBox
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 385
      Height = 288
      Align = alClient
      ItemHeight = 13
      TabOrder = 0
    end
  end
  inline CustomPaths: TCustomPathsView
    Left = 0
    Top = 0
    Width = 420
    Height = 319
    Align = alLeft
    TabOrder = 2
    ExplicitWidth = 420
    ExplicitHeight = 319
    inherited PathsPanel: TPanel
      Width = 414
      Height = 313
      ExplicitWidth = 414
      ExplicitHeight = 313
      inherited PathsLabel: TLabel
        Width = 408
        Height = 13
        ExplicitWidth = 78
        ExplicitHeight = 13
      end
      inherited PathPanel: TPanel
        Top = 251
        Width = 414
        ExplicitTop = 251
        ExplicitWidth = 414
        inherited SelectPathButton: TSpeedButton
          Left = 392
          ExplicitLeft = 434
        end
        inherited PathEdit: TEdit
          Width = 385
          Height = 22
          ExplicitWidth = 385
          ExplicitHeight = 21
        end
      end
      inherited PathsCheckListBox: TCheckListBox
        Top = 22
        Width = 384
        Height = 226
        ItemHeight = 13
        ExplicitTop = 22
        ExplicitWidth = 384
        ExplicitHeight = 226
      end
      inherited PathsButtonsPanel: TPanel
        Top = 281
        Width = 414
        ExplicitTop = 281
        ExplicitWidth = 414
      end
      inherited UpDownButtonsPanel: TPanel
        Left = 390
        Top = 19
        Height = 232
        ExplicitLeft = 390
        ExplicitTop = 19
        ExplicitHeight = 232
        inherited MovePathDownSpeedButton: TSpeedButton
          Top = 204
          ExplicitTop = 203
        end
      end
    end
  end
  object ActionList: TActionList
    OnUpdate = ActionListUpdate
    Left = 59
    Top = 39
    object AddPathAction: TAction
      Caption = 'Add'
      Hint = 'Add a path to the list'
    end
    object RemovePathAction: TAction
      Caption = 'Remove'
      Hint = 'Remove the selected jar files from the configuration'
    end
    object SelectPathAction: TAction
      Caption = '...'
    end
    object ReplacePathAction: TAction
      Caption = 'Replace'
    end
    object MovePathUpAction: TAction
    end
    object MovePathDownAction: TAction
    end
    object OKAction: TAction
      Caption = 'OK'
      OnExecute = OKActionExecute
    end
    object ToggleCheckedPathsAction: TAction
      Caption = 'Toggle'
    end
  end
  object PathOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Title = 'Select a folder to use as a path'
    Left = 152
    Top = 40
  end
end

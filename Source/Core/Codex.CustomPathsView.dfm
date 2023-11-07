object CustomPathsView: TCustomPathsView
  Left = 0
  Top = 0
  Width = 466
  Height = 311
  TabOrder = 0
  object PathsPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 460
    Height = 305
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object PathsLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 454
      Height = 15
      Align = alTop
      Caption = 'Paths To Insert:'
      ExplicitWidth = 79
    end
    object PathPanel: TPanel
      Left = 0
      Top = 243
      Width = 460
      Height = 30
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object SelectPathButton: TSpeedButton
        AlignWithMargins = True
        Left = 438
        Top = 3
        Width = 22
        Height = 24
        Margins.Right = 0
        Action = SelectPathAction
        Align = alRight
        ExplicitLeft = 437
      end
      object PathEdit: TEdit
        AlignWithMargins = True
        Left = 4
        Top = 4
        Width = 431
        Height = 23
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 0
        Margins.Bottom = 4
        Align = alClient
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
    end
    object PathsCheckListBox: TCheckListBox
      AlignWithMargins = True
      Left = 3
      Top = 24
      Width = 430
      Height = 216
      Align = alClient
      ItemHeight = 15
      TabOrder = 1
      OnClick = PathsCheckListBoxClick
    end
    object PathsButtonsPanel: TPanel
      Left = 0
      Top = 273
      Width = 460
      Height = 32
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object AddPathButton: TButton
        AlignWithMargins = True
        Left = 88
        Top = 3
        Width = 70
        Height = 26
        Action = AddPathAction
        Align = alLeft
        TabOrder = 0
      end
      object RemovePathButton: TButton
        AlignWithMargins = True
        Left = 164
        Top = 3
        Width = 70
        Height = 26
        Action = RemovePathAction
        Align = alLeft
        TabOrder = 1
      end
      object ReplacePathButton: TButton
        AlignWithMargins = True
        Left = 240
        Top = 3
        Width = 70
        Height = 26
        Action = ReplacePathAction
        Align = alLeft
        TabOrder = 2
      end
      object ToggleCheckedPathsButton: TButton
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 70
        Height = 26
        Margins.Right = 12
        Action = ToggleCheckedPathsAction
        Align = alLeft
        TabOrder = 3
      end
    end
    object UpDownButtonsPanel: TPanel
      Left = 436
      Top = 21
      Width = 24
      Height = 222
      Align = alRight
      BevelOuter = bvNone
      Padding.Top = 4
      Padding.Bottom = 4
      TabOrder = 3
      object MovePathUpSpeedButton: TSpeedButton
        Left = 0
        Top = 4
        Width = 24
        Height = 25
        Action = MovePathUpAction
        Align = alTop
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          0400000000000001000000000000000000001000000000000000000000000000
          BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          3333333333333333333333333333333333333333333333333333333333888883
          3333333333FFFFF3333333333444448333333333388888F3333333333CCCC483
          33333333388888F3333333333CCCC48333333333388888F3333333333CCCC483
          33333333388888F3333333333CCCC48333333333388888F3333333333CCCC488
          83333333388888FFF333333CCCCCCCCC333333388888888833333333CCCCCCC3
          3333333388888883333333333CCCCC3333333333388888333333333333CCC333
          333333333388833333333333333C333333333333333833333333333333333333
          3333333333333333333333333333333333333333333333333333}
        NumGlyphs = 2
      end
      object MovePathDownSpeedButton: TSpeedButton
        Left = 0
        Top = 194
        Width = 24
        Height = 24
        Action = MovePathDownAction
        Align = alBottom
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          0400000000000001000000000000000000001000000000000000000000000000
          BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          33333333333333333333333333338333333333333333F3333333333333348833
          333333333338FF333333333333CC48833333333333888FF3333333333CCCC488
          33333333388888FF33333333CCCCCC48833333338888888FF333333CCCCCC444
          3333333888888888333333333CCCC48333333333388888F3333333333CCCC483
          33333333388888F3333333333CCCC48333333333388888F3333333333CCCC483
          33333333388888F3333333333CCCC48333333333388888F3333333333CCCC433
          3333333338888833333333333333333333333333333333333333333333333333
          3333333333333333333333333333333333333333333333333333}
        NumGlyphs = 2
        ExplicitTop = 191
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
      OnExecute = AddPathActionExecute
    end
    object RemovePathAction: TAction
      Caption = 'Remove'
      Hint = 'Remove the selected jar files from the configuration'
      OnExecute = RemovePathActionExecute
    end
    object SelectPathAction: TAction
      Caption = '...'
    end
    object ReplacePathAction: TAction
      Caption = 'Replace'
      OnExecute = ReplacePathActionExecute
    end
    object MovePathUpAction: TAction
      OnExecute = MovePathUpActionExecute
    end
    object MovePathDownAction: TAction
      OnExecute = MovePathDownActionExecute
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

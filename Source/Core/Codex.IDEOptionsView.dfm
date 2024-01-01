object IDEOptionsView: TIDEOptionsView
  Left = 0
  Top = 0
  ClientHeight = 300
  ClientWidth = 649
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 13
  object RootPanel: TPanel
    Left = 0
    Top = 0
    Width = 649
    Height = 300
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object ChangesNeedRestartLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 643
      Height = 13
      Margins.Bottom = 6
      Align = alTop
      Caption = 'Changes to items with a * require an IDE restart'
      Visible = False
      ExplicitWidth = 232
    end
    object ShowProjectManagerCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 210
      Width = 643
      Height = 17
      Hint = 'Shows Project Manager when opening a project or group'
      Margins.Top = 6
      Align = alTop
      Caption = 'Show Project Manager when opening a project or group'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object RunRunInterceptCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 28
      Width = 643
      Height = 17
      Hint = 
        'It'#39's not actually possible to Run With Debugging when in the App' +
        ' Store build type, so if you'#39've perhaps forgotten what build typ' +
        'e was selected and you invoke Run With Debugging, this option wi' +
        'll display a warning'
      Margins.Top = 6
      Align = alTop
      Caption = 
        'Display warning for App Store build type when using Run With Deb' +
        'ugging'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object ShowPlatformConfigPathCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 184
      Width = 643
      Height = 17
      Hint = 
        'Shows the currently selected platform, config and build type in ' +
        'the IDE title bar'
      Margins.Top = 6
      Align = alTop
      Caption = 'Show Platform > Config > Build type caption in title bar'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
    object StartupLoadLastProjectCheckbox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 132
      Width = 643
      Height = 17
      Hint = 
        'At startup, loads the project that was last opened before the ID' +
        'E was shut down'
      Margins.Top = 6
      Align = alTop
      Caption = 'Load last opened project (if present)'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
    end
    object HideViewSelectorCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 80
      Width = 643
      Height = 17
      Hint = 'Hide the view selector when form designer is active'
      Margins.Top = 6
      Align = alTop
      Caption = 'Hide View Selector'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
    end
    object EnableReadOnlyEditorMenuItemCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 54
      Width = 643
      Height = 17
      Hint = 'Ensure the Read Only editor popup menu item stays enabled'
      Margins.Top = 6
      Align = alTop
      Caption = 'Enable Read Only editor popup menu item'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
    end
    object SuppressBuildEventsWarningCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 236
      Width = 643
      Height = 17
      Hint = 'Suppress the warning when a project has build events'
      Margins.Top = 6
      Align = alTop
      Caption = 'Suppress project build events warning'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
    end
    object ShowErrorInsightMessagesCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 158
      Width = 643
      Height = 17
      Hint = 'Show error insight messages in the editor'
      Margins.Top = 6
      Align = alTop
      Caption = 
        'Show Error Insight messages in the editor (requires Structure Vi' +
        'ew to be visible)'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
    end
    object KillProjectProcessCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 106
      Width = 643
      Height = 17
      Hint = 'Kills the project process (exact path) if it is running'
      Margins.Top = 6
      Align = alTop
      Caption = 'Kill the project process if it is running (Windows only)'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
    end
    object SysJarsWarningCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 262
      Width = 643
      Height = 17
      Hint = 
        'Shows a warning when the system jars for an Android project do n' +
        'ot exist'
      Margins.Top = 6
      Align = alTop
      Caption = 'Warn if project system jars do not exist'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
    end
  end
end

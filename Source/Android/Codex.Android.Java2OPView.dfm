object Java2OPView: TJava2OPView
  Left = 0
  Top = 0
  Caption = 'Java2OP'
  ClientHeight = 672
  ClientWidth = 1011
  Color = clBtnFace
  Constraints.MinHeight = 711
  Constraints.MinWidth = 500
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 13
  object JarsPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 4
    Width = 1003
    Height = 145
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object ClassesLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 997
      Height = 13
      Align = alTop
      Caption = 'Classes to extract:'
      ExplicitWidth = 91
    end
    object JarsButtonsPanel: TPanel
      Left = 0
      Top = 113
      Width = 1003
      Height = 32
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object RemoveClassButton: TButton
        AlignWithMargins = True
        Left = 918
        Top = 3
        Width = 82
        Height = 26
        Action = RemoveClassAction
        Align = alRight
        TabOrder = 0
      end
      object AddClassButton: TButton
        AlignWithMargins = True
        Left = 830
        Top = 3
        Width = 82
        Height = 26
        Action = AddClassAction
        Align = alRight
        TabOrder = 1
      end
      object ClassEdit: TEdit
        AlignWithMargins = True
        Left = 3
        Top = 5
        Width = 821
        Height = 22
        Margins.Top = 5
        Margins.Bottom = 5
        Align = alClient
        TabOrder = 2
        ExplicitHeight = 21
      end
    end
    object ClassesListBox: TListBox
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 997
      Height = 88
      Align = alClient
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 1
    end
  end
  object SourceFoldersPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 314
    Width = 1003
    Height = 134
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 0
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object SourceFoldersLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 997
      Height = 13
      Align = alTop
      Caption = 'Source folders:'
      ExplicitWidth = 73
    end
    object SourceFoldersButtonsPanel: TPanel
      Left = 0
      Top = 102
      Width = 1003
      Height = 32
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object RemoveSourceFolderButton: TButton
        AlignWithMargins = True
        Left = 918
        Top = 3
        Width = 82
        Height = 26
        Action = RemoveSourceFolderAction
        Align = alRight
        TabOrder = 0
      end
      object AddSourceFolderButton: TButton
        AlignWithMargins = True
        Left = 830
        Top = 3
        Width = 82
        Height = 26
        Action = AddSourceFolderAction
        Align = alRight
        TabOrder = 1
      end
    end
    object SourceFoldersListBox: TListBox
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 997
      Height = 77
      Align = alClient
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 1
    end
  end
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 640
    Width = 1011
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object BuildJarButton: TButton
      AlignWithMargins = True
      Left = 845
      Top = 3
      Width = 82
      Height = 26
      Action = RunAction
      Align = alRight
      TabOrder = 0
    end
    object PostProcessingCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 142
      Height = 26
      Hint = 'Removes declarations suspected of being internal'
      Align = alLeft
      Caption = 'Perform Post Processing'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 2
    end
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 933
      Top = 3
      Width = 75
      Height = 26
      Align = alRight
      Caption = '&Close'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
      OnClick = CloseButtonClick
    end
  end
  object OutputFilePanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 583
    Width = 1003
    Height = 53
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 3
    object SelectOutputFileButton: TSpeedButton
      AlignWithMargins = True
      Left = 953
      Top = 22
      Width = 23
      Height = 27
      Margins.Left = 0
      Margins.Right = 0
      Action = SelectOutputFileAction
      Align = alRight
      ExplicitLeft = 658
      ExplicitTop = 19
      ExplicitHeight = 25
    end
    object ClearOutputFileButton: TSpeedButton
      AlignWithMargins = True
      Left = 976
      Top = 22
      Width = 23
      Height = 27
      Margins.Left = 0
      Margins.Right = 4
      Align = alRight
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
        55555FFFFFFF5F55FFF5777777757559995777777775755777F7555555555550
        305555555555FF57F7F555555550055BB0555555555775F777F55555550FB000
        005555555575577777F5555550FB0BF0F05555555755755757F555550FBFBF0F
        B05555557F55557557F555550BFBF0FB005555557F55575577F555500FBFBFB0
        B05555577F555557F7F5550E0BFBFB00B055557575F55577F7F550EEE0BFB0B0
        B05557FF575F5757F7F5000EEE0BFBF0B055777FF575FFF7F7F50000EEE00000
        B0557777FF577777F7F500000E055550805577777F7555575755500000555555
        05555777775555557F5555000555555505555577755555557555}
      NumGlyphs = 2
      OnClick = ClearOutputFileButtonClick
      ExplicitLeft = 539
      ExplicitTop = 19
      ExplicitHeight = 24
    end
    object OutputFileLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 997
      Height = 13
      Align = alTop
      Caption = 'Output file:'
      ExplicitWidth = 55
    end
    object OutputFileEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 23
      Width = 949
      Height = 25
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      ExplicitHeight = 21
    end
  end
  object JarFilesPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 153
    Width = 1003
    Height = 157
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 4
    object JarFilesLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 997
      Height = 13
      Align = alTop
      Caption = 'Jars:'
      ExplicitWidth = 24
    end
    object JarFilesListBox: TListBox
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 997
      Height = 99
      Align = alClient
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 0
    end
    object JarFilesButtonsPanel: TPanel
      Left = 0
      Top = 124
      Width = 1003
      Height = 32
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object RemoveJarFileButton: TButton
        AlignWithMargins = True
        Left = 918
        Top = 3
        Width = 82
        Height = 26
        Action = RemoveJarAction
        Align = alRight
        TabOrder = 0
      end
      object AddJarFileButton: TButton
        AlignWithMargins = True
        Left = 830
        Top = 3
        Width = 82
        Height = 26
        Action = AddJarAction
        Align = alRight
        TabOrder = 1
      end
    end
  end
  object ClassPathPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 452
    Width = 1003
    Height = 127
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 0
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 5
    object ClassPathsLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 997
      Height = 13
      Align = alTop
      Caption = 'Class Paths:'
      ExplicitWidth = 59
    end
    object ClassPathButtonsPanel: TPanel
      Left = 0
      Top = 95
      Width = 1003
      Height = 32
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object RemoveClassPathFolderButton: TButton
        AlignWithMargins = True
        Left = 918
        Top = 3
        Width = 82
        Height = 26
        Action = RemoveClassPathFolderAction
        Align = alRight
        TabOrder = 0
      end
      object AddClassPathFolderButton: TButton
        AlignWithMargins = True
        Left = 830
        Top = 3
        Width = 82
        Height = 26
        Action = AddClassPathFolderAction
        Align = alRight
        TabOrder = 1
      end
    end
    object ClassPathListBox: TListBox
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 997
      Height = 70
      Align = alClient
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 1
    end
  end
  object ActionList: TActionList
    OnUpdate = ActionListUpdate
    Left = 51
    Top = 55
    object AddSourceFolderAction: TAction
      Caption = 'Add..'
      OnExecute = AddSourceFolderActionExecute
    end
    object RemoveSourceFolderAction: TAction
      Caption = 'Remove'
      OnExecute = RemoveSourceFolderActionExecute
    end
    object AddClassAction: TAction
      Caption = 'Add'
      OnExecute = AddClassActionExecute
    end
    object RemoveClassAction: TAction
      Caption = 'Remove'
      OnExecute = RemoveClassActionExecute
    end
    object RunAction: TAction
      Caption = 'Run'
      OnExecute = RunActionExecute
    end
    object SelectOutputFileAction: TAction
      Caption = '...'
      OnExecute = SelectOutputFileActionExecute
    end
    object AddJarAction: TAction
      Caption = 'Add..'
      OnExecute = AddJarActionExecute
    end
    object RemoveJarAction: TAction
      Caption = 'Remove'
      OnExecute = RemoveJarActionExecute
    end
    object AddClassPathFolderAction: TAction
      Caption = 'Add..'
      OnExecute = AddClassPathFolderActionExecute
    end
    object RemoveClassPathFolderAction: TAction
      Caption = 'Remove'
      OnExecute = RemoveClassPathFolderActionExecute
    end
  end
  object JarOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Jar files (*.jar)'
        FileMask = '*.jar'
      end>
    Options = [fdoStrictFileTypes, fdoNoChangeDir, fdoAllowMultiSelect]
    Title = 'Select Jar files'
    Left = 140
    Top = 56
  end
  object SourceFolderOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Title = 'Select Java folder'
    Left = 260
    Top = 56
  end
  object OutputFileSaveDialog: TFileSaveDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Delphi unit files (*.pas)'
        FileMask = '*.pas'
      end>
    Options = [fdoStrictFileTypes]
    Title = 'Jar file to build'
    Left = 392
    Top = 56
  end
end

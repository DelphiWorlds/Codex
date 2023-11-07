object BuildJarView: TBuildJarView
  Left = 0
  Top = 0
  Caption = 'Build a Jar'
  ClientHeight = 702
  ClientWidth = 928
  Color = clBtnFace
  Constraints.MinWidth = 940
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  ShowHint = True
  OnClose = FormClose
  TextHeight = 13
  object JarsSourceSplitter: TSplitter
    Left = 0
    Top = 272
    Width = 928
    Height = 4
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 209
    ExplicitWidth = 782
  end
  object DependentJarsPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 280
    Width = 920
    Height = 205
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 0
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object JarsLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 914
      Height = 13
      Align = alTop
      Caption = 'Dependent Jars:'
      ExplicitWidth = 80
    end
    object JarsButtonsPanel: TPanel
      Left = 0
      Top = 173
      Width = 920
      Height = 32
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object RemoveJarButton: TButton
        AlignWithMargins = True
        Left = 825
        Top = 3
        Width = 92
        Height = 26
        Action = RemoveJarAction
        Align = alRight
        TabOrder = 1
      end
      object AddJarButton: TButton
        AlignWithMargins = True
        Left = 727
        Top = 3
        Width = 92
        Height = 26
        Action = AddJarAction
        Align = alRight
        TabOrder = 0
      end
    end
    object JarsListBox: TListBox
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 914
      Height = 148
      Align = alClient
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 0
    end
  end
  object JavaSourcePanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 4
    Width = 920
    Height = 268
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object JavaSourceLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 914
      Height = 13
      Align = alTop
      Caption = 
        'Java Source Files (Folders added will include all java files in ' +
        'them)'
      ExplicitWidth = 312
    end
    object JavaButtonsPanel: TPanel
      Left = 0
      Top = 236
      Width = 920
      Height = 32
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object RemoveJavaFileButton: TButton
        AlignWithMargins = True
        Left = 825
        Top = 3
        Width = 92
        Height = 26
        Action = RemoveJavaFileAction
        Align = alRight
        TabOrder = 2
      end
      object AddJavaFileButton: TButton
        AlignWithMargins = True
        Left = 727
        Top = 3
        Width = 92
        Height = 26
        Action = AddJavaFileAction
        Align = alRight
        TabOrder = 1
      end
      object AddJavaFolderButton: TButton
        AlignWithMargins = True
        Left = 629
        Top = 3
        Width = 92
        Height = 26
        Action = AddJavaFolderAction
        Align = alRight
        TabOrder = 0
      end
    end
    object JavaListBox: TListBox
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 914
      Height = 211
      Align = alClient
      ItemHeight = 13
      TabOrder = 1
    end
  end
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 663
    Width = 928
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object BuildJarButton: TButton
      AlignWithMargins = True
      Left = 735
      Top = 3
      Width = 92
      Height = 33
      Action = BuildJarAction
      Align = alRight
      TabOrder = 0
    end
    object LoadJarConfigButton: TButton
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 98
      Height = 33
      Action = LoadJarConfigAction
      Align = alLeft
      TabOrder = 2
    end
    object SaveJarConfigButton: TButton
      AlignWithMargins = True
      Left = 107
      Top = 3
      Width = 98
      Height = 33
      Action = SaveJarConfigAction
      Align = alLeft
      TabOrder = 3
    end
    object ToolsOptionsButton: TButton
      AlignWithMargins = True
      Left = 328
      Top = 3
      Width = 98
      Height = 33
      Margins.Left = 16
      Action = ToolsOptionsAction
      Align = alLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
    end
    object DexCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 606
      Top = 3
      Width = 123
      Height = 33
      Hint = 'Include "dex-ing" the .jar file in the process'
      Align = alRight
      Caption = 'Include "dex-ing"'
      TabOrder = 5
    end
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 833
      Top = 3
      Width = 92
      Height = 33
      Align = alRight
      Caption = '&Close'
      DoubleBuffered = True
      ModalResult = 8
      ParentDoubleBuffered = False
      TabOrder = 1
      OnClick = CloseButtonClick
    end
    object RetainWorkingFilesCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 456
      Top = 3
      Width = 144
      Height = 33
      Hint = 'Useful for debugging'
      Align = alRight
      Caption = 'Retain working files'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
    end
    object NewConfigButton: TButton
      AlignWithMargins = True
      Left = 211
      Top = 3
      Width = 98
      Height = 33
      Action = NewConfigAction
      Align = alLeft
      TabOrder = 7
    end
  end
  object OutputPathPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 609
    Width = 920
    Height = 50
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
      Left = 893
      Top = 22
      Width = 23
      Height = 24
      Margins.Left = 0
      Margins.Right = 4
      Action = SelectOutputFileAction
      Align = alRight
      ExplicitLeft = 658
      ExplicitTop = 19
      ExplicitHeight = 25
    end
    object OutputFileLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 914
      Height = 13
      Align = alTop
      Caption = 'Output file:'
      ExplicitWidth = 55
    end
    object OutputFileEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 23
      Width = 889
      Height = 22
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnChange = OutputFileEditChange
      ExplicitHeight = 21
    end
  end
  object VersionsPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 489
    Width = 920
    Height = 112
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 2
    object SourceVersionLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 914
      Height = 13
      Align = alTop
      Caption = 'Source (Version that the sources are compatible with)'
      ExplicitWidth = 257
    end
    object TargetVersionLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 68
      Width = 914
      Height = 13
      Align = alTop
      Caption = 'Target (Oldest version of the JRE to be supported)'
      ExplicitWidth = 245
    end
    object VersionsLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 914
      Height = 13
      Align = alTop
      Caption = 'Versions:'
      ExplicitWidth = 44
    end
    object SourceVersionComboBox: TComboBox
      AlignWithMargins = True
      Left = 3
      Top = 41
      Width = 914
      Height = 21
      Align = alTop
      Style = csDropDownList
      TabOrder = 0
      OnChange = SourceVersionComboBoxChange
      OnDropDown = SourceVersionComboBoxDropDown
      Items.Strings = (
        '1.7'
        '1.8'
        '1.9'
        '1.10')
    end
    object TargetVersionComboBox: TComboBox
      AlignWithMargins = True
      Left = 3
      Top = 87
      Width = 914
      Height = 21
      Align = alTop
      Style = csDropDownList
      TabOrder = 1
      OnChange = SourceVersionComboBoxChange
      OnDropDown = SourceVersionComboBoxDropDown
      Items.Strings = (
        '1.7'
        '1.8'
        '1.9'
        '1.10')
    end
  end
  object ActionList: TActionList
    OnUpdate = ActionListUpdate
    Left = 59
    Top = 39
    object AddJarAction: TAction
      Caption = 'Add..'
      Hint = 'Add a jar file to the configuration'
      OnExecute = AddJarActionExecute
    end
    object RemoveJarAction: TAction
      Caption = 'Remove'
      Hint = 'Remove the selected jar files from the configuration'
      OnExecute = RemoveJarActionExecute
    end
    object AddJavaFileAction: TAction
      Caption = 'Add..'
      Hint = 'Add a java file to the current configuration'
      OnExecute = AddJavaFileActionExecute
    end
    object RemoveJavaFileAction: TAction
      Caption = 'Remove'
      Hint = 'Remove the selected java files from the current configuration'
      OnExecute = RemoveJavaFileActionExecute
    end
    object BuildJarAction: TAction
      Caption = 'Build Jar'
      Hint = 'Build the jar file using the current configuration'
      OnExecute = BuildJarActionExecute
    end
    object SelectOutputFileAction: TAction
      Caption = '...'
      OnExecute = SelectOutputFileActionExecute
    end
    object LoadJarConfigAction: TAction
      Caption = 'Open..'
      Hint = 'Open a configuration'
      OnExecute = LoadJarConfigActionExecute
    end
    object SaveJarConfigAction: TAction
      Caption = 'Save'
      Hint = 'Save the current configuration'
      OnExecute = SaveJarConfigActionExecute
    end
    object AddJavaFolderAction: TAction
      Caption = 'Add Folder..'
      Hint = 'Add a folder containing .java files (will include subfolders)'
      OnExecute = AddJavaFolderActionExecute
    end
    object ToolsOptionsAction: TAction
      Caption = 'Options..'
      Hint = 'Prefill Jars/Files/Folders with values for FMX.jar'
      Visible = False
    end
    object NewConfigAction: TAction
      Caption = 'New..'
      Hint = 'Create a new configuration'
      OnExecute = NewConfigActionExecute
    end
  end
  object JarOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Jar files (*.jar)'
        FileMask = '*.jar'
      end>
    Options = [fdoStrictFileTypes, fdoAllowMultiSelect]
    Title = 'Select Jar files'
    Left = 152
    Top = 40
  end
  object JavaOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Java files (*.java)'
        FileMask = '*.java'
      end>
    Options = [fdoStrictFileTypes, fdoForceFileSystem, fdoAllowMultiSelect, fdoPathMustExist]
    Title = 'Select Java files'
    Left = 248
    Top = 40
  end
  object JarSaveDialog: TFileSaveDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Jar files (*.jar)'
        FileMask = '*.jar'
      end>
    Options = [fdoStrictFileTypes]
    Title = 'Jar file to build'
    Left = 348
    Top = 40
  end
  object JarConfigFileOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Jar project files (*.json)'
        FileMask = '*.json'
      end>
    Options = [fdoStrictFileTypes, fdoForceFileSystem, fdoAllowMultiSelect, fdoPathMustExist]
    Title = 'Open jar project file'
    Left = 148
    Top = 104
  end
  object JarConfigFileSaveDialog: TFileSaveDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Jar project files (*.json)'
        FileMask = '*.json'
      end>
    Options = [fdoOverWritePrompt, fdoStrictFileTypes]
    Title = 'Save jar project file'
    Left = 296
    Top = 104
  end
  object JavaFolderOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Title = 'Select folder containing Java files (will include subfolders)'
    Left = 452
    Top = 40
  end
end

object SourcePatchOptionsView: TSourcePatchOptionsView
  Left = 0
  Top = 0
  ClientHeight = 516
  ClientWidth = 710
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 13
  object RootPanel: TPanel
    Left = 0
    Top = 0
    Width = 710
    Height = 516
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 706
    ExplicitHeight = 515
    object SourceCopyPathPanel: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 86
      Width = 710
      Height = 50
      Margins.Left = 0
      Margins.Top = 8
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      BevelOuter = bvNone
      Padding.Bottom = 1
      TabOrder = 0
      ExplicitWidth = 706
      object SelectSourceCopyPathButton: TSpeedButton
        AlignWithMargins = True
        Left = 683
        Top = 22
        Width = 23
        Height = 24
        Margins.Left = 0
        Margins.Right = 4
        Align = alRight
        Caption = '...'
        OnClick = SelectSourceCopyPathButtonClick
        ExplicitLeft = 658
        ExplicitTop = 19
        ExplicitHeight = 25
      end
      object SourceCopyPathLabel: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 704
        Height = 13
        Align = alTop
        Caption = 'Default folder to copy source to:'
        ExplicitWidth = 157
      end
      object SourceCopyPathEdit: TEdit
        AlignWithMargins = True
        Left = 4
        Top = 23
        Width = 679
        Height = 22
        Hint = 
          'Default folder to copy source files to. When the checkbox above ' +
          'is checked, this folder will be relative to the active project'
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 0
        Margins.Bottom = 4
        Align = alClient
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        ExplicitWidth = 675
        ExplicitHeight = 21
      end
    end
    object SourceCopyProjectRelativeCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 58
      Width = 704
      Height = 17
      Hint = 
        'When this option is checked, the "Default folder to copy source ' +
        'to" will be relative to the active project'
      Margins.Top = 6
      Align = alTop
      Caption = 'Folder to copy source to is relative to active project'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = SourceCopyProjectRelativeCheckBoxClick
      ExplicitWidth = 700
    end
    object PatchFilesLocationPanel: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 140
      Width = 710
      Height = 50
      Margins.Left = 0
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      BevelOuter = bvNone
      Padding.Bottom = 1
      TabOrder = 2
      ExplicitWidth = 706
      object SelectPatchFilesLocationButton: TSpeedButton
        AlignWithMargins = True
        Left = 683
        Top = 22
        Width = 23
        Height = 24
        Margins.Left = 0
        Margins.Right = 4
        Align = alRight
        Caption = '...'
        OnClick = SelectPatchFilesLocationButtonClick
        ExplicitLeft = 658
        ExplicitTop = 19
        ExplicitHeight = 25
      end
      object PatchFilesLocationLabel: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 704
        Height = 13
        Align = alTop
        Caption = 'Default location for patch files:'
        ExplicitWidth = 148
      end
      object PatchFilesFolderEdit: TEdit
        AlignWithMargins = True
        Left = 4
        Top = 23
        Width = 679
        Height = 22
        Hint = 
          'Default location for patch files that can be applied to source f' +
          'iles'
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 0
        Margins.Bottom = 4
        Align = alClient
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        ExplicitWidth = 675
        ExplicitHeight = 21
      end
    end
    object SourceCopyAlwaysPromptCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 6
      Width = 704
      Height = 17
      Hint = 
        'When source files are to be copied, a dialog will show for selec' +
        'ting which folder to copy to'
      Margins.Top = 6
      Align = alTop
      Caption = 'Always prompt for folder to copy source to'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      ExplicitWidth = 700
    end
    object ShouldOpenSourceFilesCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 32
      Width = 704
      Height = 17
      Hint = 
        'When this option is checked, source files will be opened in the ' +
        'IDE once they have been copied'
      Margins.Top = 6
      Align = alTop
      Caption = 'Open source files once copied'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      ExplicitWidth = 700
    end
  end
  object SourceCopyFolderOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Title = 'Select folder where source files will be copied to'
    Left = 96
    Top = 232
  end
  object PatchFilesFolderOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Title = 'Select folder where patch files are located'
    Left = 268
    Top = 232
  end
end

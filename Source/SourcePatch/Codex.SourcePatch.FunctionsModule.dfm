object SourcePatchFunctionsModule: TSourcePatchFunctionsModule
  Height = 420
  Width = 394
  object SourceOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Delphi source files (*.pas)'
        FileMask = '*.pas'
      end>
    Options = [fdoStrictFileTypes, fdoAllowMultiSelect]
    Title = 'Select Delphi source files'
    Left = 152
    Top = 40
  end
  object SourceCopyFolderOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Title = 'Select folder where source files will be copied to'
    Left = 154
    Top = 104
  end
  object PatchOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoFileMustExist]
    Left = 156
    Top = 176
  end
  object PatchSaveDialog: TFileSaveDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Patch files (*.patch)'
        FileMask = '*.patch'
      end>
    Options = []
    Title = 'Save patch file as'
    Left = 156
    Top = 248
  end
end

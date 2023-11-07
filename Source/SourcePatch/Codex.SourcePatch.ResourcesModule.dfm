object SourcePatchResourcesModule: TSourcePatchResourcesModule
  Height = 248
  Width = 595
  object ActionList: TActionList
    Left = 136
    Top = 76
    object SourcePatchSep1Action: TAction
      Category = 'Codex.SourcePatch'
      Caption = '-'
      OnExecute = SourcePatchSep1ActionExecute
    end
    object CopySourceFromEditorAction: TAction
      Category = 'Codex.SourcePatch'
    end
    object CopySourceFromEditorToProjectAction: TAction
      Category = 'Codex.SourcePatch'
    end
    object CreatePatchFromEditorAction: TAction
      Category = 'Codex.SourcePatch'
    end
    object PatchSourceFromEditorAction: TAction
      Category = 'Codex.SourcePatch'
    end
  end
end

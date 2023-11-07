object ProjectToolsView: TProjectToolsView
  Left = 0
  Top = 0
  Caption = 'Codex Project Tools'
  ClientHeight = 40
  ClientWidth = 572
  Color = clBtnFace
  Constraints.MinHeight = 52
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 572
    Height = 24
    ButtonWidth = 28
    TabOrder = 0
    ExplicitWidth = 568
    object CompileToolButton: TToolButton
      Left = 0
      Top = 0
      Action = CompileAction
    end
    object BuildToolButton: TToolButton
      Left = 28
      Top = 0
      Action = BuildAction
    end
    object CleanToolButton: TToolButton
      Left = 56
      Top = 0
      Action = CleanAction
    end
    object TotalCleanToolButton: TToolButton
      Left = 84
      Top = 0
      Action = TotalCleanAction
    end
    object OptionsSepToolButton: TToolButton
      Left = 112
      Top = 0
      Width = 9
      Style = tbsSeparator
    end
    object ProjectOptionsToolButton: TToolButton
      Left = 121
      Top = 0
      Action = ShowOptionsAction
    end
    object InsertPathsToolButton: TToolButton
      Left = 149
      Top = 0
      Action = InsertPathsAction
    end
    object PlatformSepToolButton: TToolButton
      Tag = -1
      Left = 177
      Top = 0
      Width = 9
      Style = tbsSeparator
    end
    object Win32ToolButton: TToolButton
      Tag = -1
      Left = 186
      Top = 0
      Action = Win32Action
    end
    object Android32ToolButton: TToolButton
      Tag = -1
      Left = 214
      Top = 0
      Action = Android32Action
    end
    object MacOSToolButton: TToolButton
      Tag = -1
      Left = 242
      Top = 0
      Action = MacOSAction
    end
    object iOSToolButton: TToolButton
      Tag = -1
      Left = 270
      Top = 0
      Action = iOSAction
    end
    object SourceSepToolButton: TToolButton
      Left = 298
      Top = 0
      Width = 9
      Style = tbsSeparator
    end
    object ViewSourceToolButton: TToolButton
      Left = 307
      Top = 0
      Action = ViewSourceAction
    end
    object ShowDeployToolButton: TToolButton
      Left = 335
      Top = 0
      Action = ShowDeployAction
    end
    object DeployToolButton: TToolButton
      Left = 363
      Top = 0
      Action = DeployAction
    end
  end
  object ProjectActionList: TActionList
    Left = 414
    Top = 65530
    object CompileAction: TAction
      Hint = 'Compile active project'
      ImageIndex = 2
      ImageName = 'Compile'
      OnExecute = CommonProjectActionExecute
      OnUpdate = CommonProjectActionUpdate
    end
    object BuildAction: TAction
      Hint = 'Build active project'
      ImageIndex = 0
      ImageName = 'Build'
      OnExecute = CommonProjectActionExecute
      OnUpdate = CommonProjectActionUpdate
    end
    object CleanAction: TAction
      Hint = 'Clean active project'
      ImageIndex = 1
      ImageName = 'Clean'
      OnExecute = CommonProjectActionExecute
      OnUpdate = CommonProjectActionUpdate
    end
    object TotalCleanAction: TAction
      Hint = 'Total clean active project'
      ImageIndex = 3
      ImageName = 'TotalClean'
      OnExecute = CommonProjectActionExecute
      OnUpdate = CommonProjectActionUpdate
    end
    object ShowOptionsAction: TAction
      Hint = 'Show project options'
      ImageIndex = 4
      ImageName = 'Options'
      OnExecute = CommonProjectActionExecute
      OnUpdate = CommonProjectActionUpdate
    end
    object Win32Action: TAction
      Hint = 'Activate Win32 platform'
      ImageIndex = 5
      ImageName = 'Windows'
      OnExecute = CommonProjectActionExecute
      OnUpdate = CommonProjectActionUpdate
    end
    object Android32Action: TAction
      Hint = 'Activate Android32 platform'
      ImageIndex = 6
      ImageName = 'Android'
      OnExecute = CommonProjectActionExecute
      OnUpdate = CommonProjectActionUpdate
    end
    object MacOSAction: TAction
      Hint = 'Activate macOS64 platform'
      ImageIndex = 7
      ImageName = 'MacOS'
      OnExecute = CommonProjectActionExecute
      OnUpdate = CommonProjectActionUpdate
    end
    object iOSAction: TAction
      Hint = 'Activate iOS platform'
      ImageIndex = 8
      ImageName = 'iPhone'
      OnExecute = CommonProjectActionExecute
      OnUpdate = CommonProjectActionUpdate
    end
    object ViewSourceAction: TAction
      Hint = 'View project source'
      ImageIndex = 9
      ImageName = 'ViewSource'
      OnExecute = CommonProjectActionExecute
      OnUpdate = CommonProjectActionUpdate
    end
    object ShowDeployAction: TAction
      Hint = 'Show project deployment'
      ImageIndex = 10
      ImageName = 'DeployManager'
      OnExecute = CommonProjectActionExecute
      OnUpdate = CommonProjectActionUpdate
    end
    object InsertPathsAction: TAction
      Hint = 'Insert paths into project options'
      ImageIndex = 11
      ImageName = 'AddFolder16'
      OnExecute = CommonProjectActionExecute
      OnUpdate = CommonProjectActionUpdate
    end
    object DeployAction: TAction
      ImageIndex = 12
      ImageName = 'target--arrow'
      OnExecute = CommonProjectActionExecute
      OnUpdate = DeployActionUpdate
    end
  end
end

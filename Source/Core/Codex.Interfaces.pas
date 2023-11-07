unit Codex.Interfaces;

{*******************************************************}
{                                                       }
{                      Codex                            }
{                                                       }
{         Add-in for Delphi from Delphi Worlds          }
{                                                       }
{  Copyright 2020-2023 Dave Nottage under MIT license   }
{  which is located in the root folder of this library  }
{                                                       }
{*******************************************************}

interface

uses
  System.Classes, System.SysUtils,
  Vcl.ActnList, Vcl.ImgList, Vcl.Menus,
  Codex.Types;

type
  IResourcesModule = interface(IInterface)
    ['{837A0A0C-3509-45C2-8860-F61D9BD036F1}']
    procedure AddToolbarActions;
    function GetActionList(const AName: string): TActionList;
    function GetImageList: TCustomImageList;
    procedure LinkAction(const ALinkedAction: TAction); overload;
    procedure LinkAction(const AName: string; const AOnExecute: TNotifyEvent; const AOnUpdate: TNotifyEvent = nil); overload;
    procedure PerformAction(const AAction: TAction);
  end;

  IMoscoProvider = interface(IInterface)
    ['{B039D52A-8B08-4EB4-ACB9-75DC4A63E5F1}']
    procedure AddSDKFramework;
    procedure ProfileChanged;
    procedure ShowDeployedApp;
    procedure ShowOptions;
  end;

  ICodexProvider = interface(IInterface)
    ['{C6C7CBEB-8166-44B6-B8ED-1307200DA4BB}']
    function GetEditorActionList: TActionList;
    procedure NotifyContextMenu(const AMenuItem: TMenuItem);
  end;

  IProjectToolsProvider = interface(IInterface)
    ['{3A39F49A-5614-45B2-8959-204593C7B5D4}']
    procedure AddFolders;
    procedure BuildProject;
    function CanDeployProject: Boolean;
    procedure CleanProject;
    procedure CompileProject;
    procedure DeployProject;
    procedure DeployProjectFolder;
    function HasActiveProject: Boolean;
    procedure InsertProjectPaths;
    procedure ShowProjectDeployment;
    procedure ShowProjectOptions;
    procedure TotalCleanProject;
    procedure ViewProjectSource;
  end;

  IModuleListener = interface(IInterface)
    ['{A2605533-E0C4-4ACF-B771-C56F7981AC70}']
    procedure ProjectSaved(const AFileName: string);
    procedure SourceSaved(const AFileName: string);
  end;

  IModuleNotifier = interface(IInterface)
    ['{73294A4F-CE7A-4401-92E2-171D8162207E}']
    procedure AddListener(const AListener: IModuleListener);
  end;

implementation

end.

unit Codex.Project.ProjectManagerMenu;

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
  System.Classes,
  ToolsAPI,
  DW.OTA.ProjectManagerMenu, DW.OTA.Consts;

type
  TProjectProjectManagerMenuNotifier = class(TProjectManagerMenuNotifier)
  private
    procedure AddFolders;
    procedure DeployAppExtensions;
    procedure DeployFolder;
    procedure TotalClean;
  public
    procedure DoAddMenu(const AProject: IOTAProject; const AIdentList: TStrings; const AProjectManagerMenuList: IInterfaceList;
      AIsMultiSelect: Boolean); override;
    procedure DoAddGroupMenu(const AProject: IOTAProject; const AIdentList: TStrings; const AProjectManagerMenuList: IInterfaceList;
      AIsMultiSelect: Boolean); override;
  end;

implementation

uses
  System.SysUtils,
  DW.OTA.Helpers,
  Codex.Consts, Codex.Core;

type
  TAddFoldersProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

  TDeployExtensionProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

  TDeployFolderProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

resourcestring
  sAddFoldersCaption = 'Add Folders To Search Path';
  sDeployExtensionsCaption = 'Deploy Extensions';
  sDeployFolderCaption = 'Deploy Folder';
  sTotalCleanCaption = 'Total Clean';

{ TAddFoldersProjectManagerMenu }

constructor TAddFoldersProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sAddFoldersCaption), 'CodexAddFolders', APosition, AExecuteProc);
end;

function TAddFoldersProjectManagerMenu.GetEnabled: Boolean;
begin
  Result := TOTAHelper.GetCurrentSelectedProject <> nil;
end;

{ TDeployExtensionProjectManagerMenu }

constructor TDeployExtensionProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sDeployExtensionsCaption), 'CodexDeployExtension', APosition, AExecuteProc);
end;

function TDeployExtensionProjectManagerMenu.GetEnabled: Boolean;
var
  LProject: IOTAProject;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  Result :=  (LProject <> nil) and (TOTAHelper.GetProjectCurrentPlatform(LProject) in cAppleProjectPlatforms);
end;

{ TDeployFolderProjectManagerMenu }

constructor TDeployFolderProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sDeployFolderCaption), 'CodexDeployFolder', APosition, AExecuteProc);
end;

function TDeployFolderProjectManagerMenu.GetEnabled: Boolean;
begin
  Result := TOTAHelper.GetCurrentSelectedProject <> nil;
end;

{ TProjectProjectManagerMenuNotifier }

procedure TProjectProjectManagerMenuNotifier.DoAddGroupMenu(const AProject: IOTAProject; const AIdentList: TStrings;
  const AProjectManagerMenuList: IInterfaceList; AIsMultiSelect: Boolean);
begin
  //
end;

procedure TProjectProjectManagerMenuNotifier.DoAddMenu(const AProject: IOTAProject; const AIdentList: TStrings;
  const AProjectManagerMenuList: IInterfaceList; AIsMultiSelect: Boolean);
begin
  AProjectManagerMenuList.Add(TProjectManagerMenu.Create(Babel.Tx(sTotalCleanCaption), 'TotalClean', pmmpClean + 1, TotalClean));
  AProjectManagerMenuList.Add(TProjectManagerMenuSeparator.Create(cPMMPCodexMainSection));
  AProjectManagerMenuList.Add(TAddFoldersProjectManagerMenu.Create(cPMMPCodexMainSection + 40, AddFolders));
  AProjectManagerMenuList.Add(TDeployExtensionProjectManagerMenu.Create(cPMMPCodexMainSection + 50, DeployAppExtensions));
  AProjectManagerMenuList.Add(TDeployFolderProjectManagerMenu.Create(cPMMPCodexMainSection + 60, DeployFolder));
end;

procedure TProjectProjectManagerMenuNotifier.AddFolders;
begin
  ProjectToolsProvider.AddFolders;
end;

procedure TProjectProjectManagerMenuNotifier.DeployAppExtensions;
begin
  ProjectToolsProvider.ShowDeployAppExtensions;
end;

procedure TProjectProjectManagerMenuNotifier.DeployFolder;
begin
  ProjectToolsProvider.DeployProjectFolder;
end;

procedure TProjectProjectManagerMenuNotifier.TotalClean;
begin
  ProjectToolsProvider.TotalCleanProject;
end;

end.
